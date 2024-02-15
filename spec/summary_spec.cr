require "./spec_helper"

# Redefine protected and private methods for tests
class Tablo::Table(T)
  getter sources
end

# clear aggregations and user_aggregations between tests
class Tablo::Summary(T, U, V)
  def self.clear_results
    aggr_results.clear
    proc_results.clear
  end
end

struct InvoiceItem
  include Tablo::CellType
  getter product, quantity, price

  def initialize(@product : String, @quantity : Int32?, @price : Int32?)
  end
end

def invoice
  invoice = [
    InvoiceItem.new("Laptop", 3, 98000),
    InvoiceItem.new("Printer", 2, 15499),
    # InvoiceItem.new("FAKE", nil, nil),
    InvoiceItem.new("Router", 1, 9900),
    InvoiceItem.new("Switch", nil, 4500),
    InvoiceItem.new("Accessories", 5, 6450),
  ]

  table = Tablo::Table.new(invoice,
    omit_last_rule: false,
    border: Tablo::Border.new(Tablo::BorderName::Fancy),
    title: Tablo::Title.new("Invoice")) do |t|
    t.add_column("Product",
      &.product)
    t.add_column("Quantity",
      body_formatter: ->(value : Tablo::CellType) {
        (value.nil? ? "N/A" : value.to_s)
      }, &.quantity)
    t.add_column("Price",
      body_formatter: ->(value : Tablo::CellType) {
        value.nil? ? "N/A" : "%.2f" % (value.as(Int32) / 100)
      }, &.price)
    t.add_column(:total, header: "Total",
      body_formatter: ->(value : Tablo::CellType) {
        value.nil? ? "" : "%.2f" % (value.as(Int32) / 100)
      }) { |n| n.price.nil? || n.quantity.nil? ? nil : (n.price.as(Int32) *
      n.quantity.as(Int32)) }
  end
end

invoice_summary_definition = [
  Tablo::BodyColumn.new(:total, alignment: Tablo::Justify::Right,
    formatter: ->(value : Tablo::CellType) {
      value.is_a?(String) ? value : (
        value.nil? ? "" : "%.2f" % (value.as(Int32) / 100)
      )
    },
    styler: ->(_value : Tablo::CellType, cd : Tablo::CellData, fc : String) {
      case cd.row_index
      when 0, 2, 5
        fc.colorize.mode(:bold).to_s
      when 1
        fc.colorize.mode(:italic).to_s
      else
        fc
      end
    }),
  # for tests on unused types
  # Tablo::HeaderRow.new("Price", "Here is my header"),
  # Tablo::HeaderColumn.new("Price", alignment: nil, formatter: nil, styler: nil),

  Tablo::BodyRow.new("Price", 1, "SubTotal"),
  Tablo::BodyRow.new("Price", 2, "Discount 5%"),
  Tablo::BodyRow.new("Price", 3, "S/T after discount"),
  Tablo::BodyRow.new("Price", 4, "Tax (20%)"),
  Tablo::BodyRow.new("Price", 6, "Balance due"),

  Tablo::BodyColumn.new("Price", alignment: Tablo::Justify::Right),
  Tablo::BodyRow.new(:total, 4, ->{ (Tablo::Summary.keep(:tax,
    (Tablo::Summary.use(:total_after_discount).as(Int32) * 0.2)
      .to_i)).as(Tablo::CellType) }),
  Tablo::BodyRow.new(:total, 5, "========".as(Tablo::CellType)),
  Tablo::BodyRow.new(:total, 6, ->{ (Tablo::Summary.use(:tax).as(Int32) +
                                     Tablo::Summary.use(:total_after_discount)
                                       .as(Int32)).as(Tablo::CellType) }),
]
invoice_summary_definition_1 =
  [
    Tablo::Aggregation.new(:total, Tablo::Aggregate::Sum),
    Tablo::BodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total,
      Tablo::Aggregate::Sum) }),
    Tablo::BodyRow.new(:total, 2, ->{ Tablo::Summary.keep(:discount,
      (Tablo::Summary.use(:total, Tablo::Aggregate::Sum).as(Int32) * 0.05)
        .to_i).as(Tablo::CellType) }),
    Tablo::BodyRow.new(:total, 3, ->{ (Tablo::Summary.keep(:total_after_discount,
      Tablo::Summary.use(:total, Tablo::Aggregate::Sum).as(Int32) -
      Tablo::Summary.use(:discount).as(Int32))).as(Tablo::CellType) }),
  ] + invoice_summary_definition

invoice_summary_definition_2a =
  [Tablo::UserAggregation(InvoiceItem).new(
    ident: :total_sum_2a, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    tbl.sources.select { |n| n.quantity.is_a?(Number) && n.price.is_a?(Number) }
      .map { |n| n.quantity.as(Number) * n.price.as(Number) }
      .sum.to_i.as(Tablo::CellType)
  }
  ),
   Tablo::BodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum_2a) }),
   Tablo::BodyRow.new(:total, 2, ->{ Tablo::Summary.keep(:discount,
     (Tablo::Summary.use(:total_sum_2a).as(Int32) * 0.05)
       .to_i).as(Tablo::CellType) }),
   Tablo::BodyRow.new(:total, 3, ->{ (Tablo::Summary.keep(:total_after_discount,
     Tablo::Summary.use(:total_sum_2a).as(Int32) -
     Tablo::Summary.use(:discount).as(Int32))).as(Tablo::CellType) }),
  ] + invoice_summary_definition

invoice_summary_definition_2b =
  [Tablo::UserAggregation(InvoiceItem).new(
    ident: :total_sum_2b, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    total_sum = 0
    tbl.sources.each do |row|
      if row.quantity.is_a?(Number) && row.price.is_a?(Number)
        total_sum += row.quantity.as(Int32) * row.price.as(Int32)
      end
    end
    total_sum.as(Tablo::CellType)
  }),
   Tablo::BodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum_2b) }),
   Tablo::BodyRow.new(:total, 2, ->{ Tablo::Summary.keep(:discount,
     (Tablo::Summary.use(:total_sum_2b).as(Int32) * 0.05)
       .to_i).as(Tablo::CellType) }),
   Tablo::BodyRow.new(:total, 3, ->{ (Tablo::Summary.keep(:total_after_discount,
     Tablo::Summary.use(:total_sum_2b).as(Int32) -
     Tablo::Summary.use(:discount).as(Int32))).as(Tablo::CellType) }),
  ] + invoice_summary_definition

invoice_summary_definition_3 =
  [Tablo::UserAggregation(InvoiceItem).new(
    ident: :total_sum_3, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    total_sum = 0
    iter_quantity = tbl.source_column("Quantity").each
    iter_price = tbl.source_column("Price").each

    iter = iter_quantity.zip(iter_price)
    iter.each do |q, p|
      next if q.nil? || p.nil?
      total_sum += q.as(Int32) * p.as(Int32)
    end
    total_sum.as(Tablo::CellType)
  }),
   Tablo::BodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum_3) }),
   Tablo::BodyRow.new(:total, 2, ->{ Tablo::Summary.keep(:discount,
     (Tablo::Summary.use(:total_sum_3).as(Int32) * 0.05)
       .to_i).as(Tablo::CellType) }),
   Tablo::BodyRow.new(:total, 3, ->{ (Tablo::Summary.keep(:total_after_discount,
     Tablo::Summary.use(:total_sum_3).as(Int32) -
     Tablo::Summary.use(:discount).as(Int32))).as(Tablo::CellType) }),
  ] + invoice_summary_definition

invoice_output =
  "                          Invoice                         \n" +
    "╭─────────────┬──────────┬────────────────────┬──────────╮\n" +
    "│ Product     : Quantity :              Price :    Total │\n" +
    "├-------------┼----------┼--------------------┼----------┤\n" +
    "│ Laptop      :        3 :             980.00 :  2940.00 │\n" +
    "│ Printer     :        2 :             154.99 :   309.98 │\n" +
    "│ Router      :        1 :              99.00 :    99.00 │\n" +
    "│ Switch      : N/A      :              45.00 :          │\n" +
    "│ Accessories :        5 :              64.50 :   322.50 │\n" +
    "╰─────────────┴──────────┴────────────────────┴──────────╯\n" +
    "                                     SubTotal    \e[1m3671.48\e[0m  \n" +
    "                                  Discount 5%     \e[3m183.57\e[0m  \n" +
    "                           S/T after discount    \e[1m3487.91\e[0m  \n" +
    "                                    Tax (20%)     697.58  \n" +
    "                                                ========  \n" +
    "                                  Balance due    \e[1m4185.49\e[0m  "

describe "#{Tablo::Summary} -> summary definition using Aggregation", tags: "summary" do
  Tablo::Summary.clear_results
  tbl = invoice
  tbl.pack
  tbl.add_summary(invoice_summary_definition_1,
    {
      masked_headers: true,
      border:         Tablo::Border.new("EEESSSEEESSSESSS"),
    })
  it "Returns the correct, cleanly formatted values, with the expected layout" do
    tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
    output = tbl.to_s + "\n" + tbl.summary.to_s
    {% if flag?(:DEBUG) %}
      puts "\n#{output}"
    {% end %}
    output.should eq invoice_output
  end
end

describe "#{Tablo::Summary} -> summary definition using UserAggregation (with sources " +
         "- a)", tags: "summary" do
  Tablo::Summary.clear_results
  tbl = invoice
  tbl.pack
  tbl.add_summary(invoice_summary_definition_2a,
    {
      masked_headers: true,
      border:         Tablo::Border.new("EEESSSEEESSSESSS"),
    })
  it "Returns the correct, cleanly formatted values, with the expected layout" do
    tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
    output = tbl.to_s + "\n" + tbl.summary.to_s
    {% if flag?(:DEBUG) %}
      puts "\n#{output}"
    {% end %}
    output.should eq invoice_output
  end
end

describe "#{Tablo::Summary} -> summary definition using UserAggregation " +
         "(with sources - b)", tags: "summary" do
  Tablo::Summary.clear_results
  tbl = invoice
  tbl.pack
  tbl.add_summary(invoice_summary_definition_2b,
    {
      masked_headers: true,
      border:         Tablo::Border.new("EEESSSEEESSSESSS"),
    })
  it "Returns the correct, cleanly formatted values, with the expected layout" do
    tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
    output = tbl.to_s + "\n" + tbl.summary.to_s
    {% if flag?(:DEBUG) %}
      puts "\n#{output}"
    {% end %}
    output.should eq invoice_output
  end
end
describe "#{Tablo::Summary} -> summary definition using UserAggregation " +
         "(with columns)", tags: "summary" do
  Tablo::Summary.clear_results
  tbl = invoice
  tbl.pack
  tbl.add_summary(invoice_summary_definition_3,
    {
      masked_headers: true,
      border:         Tablo::Border.new("EEESSSEEESSSESSS"),
    })
  it "Returns the correct, cleanly formatted values, with the expected layout" do
    tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
    output = tbl.to_s + "\n" + tbl.summary.to_s
    {% if flag?(:DEBUG) %}
      puts "\n#{output}"
    {% end %}
    output.should eq invoice_output
  end
end
