require "./spec_helper"

# create or Redefine protected and private methods for tests
class Tablo::Table(T)
  getter sources
  setter omit_last_rule
end

struct InvoiceItem
  include Tablo::CellType
  getter product, quantity, price

  def initialize(@product : String, @quantity : Int32?, @price : Int32?)
  end
end

def create_table
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

invoice_summary_definition_base =
  [
    Tablo::BodyColumn.new("Price", alignment: Tablo::Justify::Right),
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
    Tablo::BodyRow.new("Price", 1, "SubTotal"),
    Tablo::BodyRow.new("Price", 2, "Discount 5%"),
    Tablo::BodyRow.new("Price", 3, "S/T after discount"),
    Tablo::BodyRow.new("Price", 4, "Tax (20%)"),
    Tablo::BodyRow.new("Price", 6, "Balance due"),
    Tablo::BodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum) }),
    Tablo::BodyRow.new(:total, 2, ->{ Tablo::Summary.use(:discount) }),
    Tablo::BodyRow.new(:total, 3, ->{ Tablo::Summary.use(:total_after_discount) }),
    Tablo::BodyRow.new(:total, 4, ->{ Tablo::Summary.use(:tax) }),
    Tablo::BodyRow.new(:total, 5, "========"),
    Tablo::BodyRow.new(:total, 6, ->{ Tablo::Summary.use(:total_due) }),
  ]
invoice_summary_definition_1 =
  [
    Tablo::UserAggregation(InvoiceItem).new(
      proc: ->(tbl : Tablo::Table(InvoiceItem)) {
        total_sum = 0
        tbl.sources.each do |row|
          next unless row.quantity.is_a?(Int32) && row.price.is_a?(Int32)
          total_sum += row.quantity.as(Int32) * row.price.as(Int32)
        end
        discount = total_sum * 5 // 100
        total_after_discount = total_sum - discount
        tax = total_after_discount * 20 // 100
        total_due = total_after_discount + tax
        {
          :total_sum            => total_sum.as(Tablo::CellType),
          :discount             => discount.as(Tablo::CellType),
          :total_after_discount => total_after_discount.as(Tablo::CellType),
          :tax                  => tax.as(Tablo::CellType),
          :total_due            => total_due.as(Tablo::CellType),
        }
      }),
  ] + invoice_summary_definition_base

invoice_summary_definition_2 =
  [
    Tablo::UserAggregation(InvoiceItem).new(
      proc: ->(tbl : Tablo::Table(InvoiceItem)) {
        total_sum = tbl.sources.select { |n| n.quantity.is_a?(Int32) && n.price.is_a?(Int32) }
          .map { |n| n.quantity.as(Int32) * n.price.as(Int32) }
          .sum.to_i
        discount = total_sum * 5 // 100
        total_after_discount = total_sum - discount
        tax = total_after_discount * 20 // 100
        total_due = total_after_discount + tax
        {
          :total_sum            => total_sum.as(Tablo::CellType),
          :discount             => discount.as(Tablo::CellType),
          :total_after_discount => total_after_discount.as(Tablo::CellType),
          :tax                  => tax.as(Tablo::CellType),
          :total_due            => total_due.as(Tablo::CellType),
        }
      }),
  ] + invoice_summary_definition_base

invoice_summary_definition_3 =
  [
    Tablo::UserAggregation(InvoiceItem).new(
      proc: ->(tbl : Tablo::Table(InvoiceItem)) {
        total_sum = 0
        iter_quantity = tbl.source_column("Quantity").each
        iter_price = tbl.source_column("Price").each

        iter = iter_quantity.zip(iter_price)
        iter.each do |q, p|
          next unless q.is_a?(Int32) && p.is_a?(Int32)
          total_sum += q * p
        end
        discount = total_sum * 5 // 100
        total_after_discount = total_sum - discount
        tax = total_after_discount * 20 // 100
        total_due = total_after_discount + tax
        {
          :total_sum            => total_sum.as(Tablo::CellType),
          :discount             => discount.as(Tablo::CellType),
          :total_after_discount => total_after_discount.as(Tablo::CellType),
          :tax                  => tax.as(Tablo::CellType),
          :total_due            => total_due.as(Tablo::CellType),
        }
      }),
  ] + invoice_summary_definition_base

invoice_layout_0 =
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

invoice_layout1 =
  "                           Invoice                           \n" +
    "╭──────────────┬──────────────┬──────────────┬──────────────╮\n" +
    "│ Product      :     Quantity :        Price :        Total │\n" +
    "├--------------┼--------------┼--------------┼--------------┤\n" +
    "│ Laptop       :            3 :       980.00 :      2940.00 │\n" +
    "│ Printer      :            2 :       154.99 :       309.98 │\n" +
    "│ Router       :            1 :        99.00 :        99.00 │\n" +
    "│ Switch       : N/A          :        45.00 :              │\n" +
    "│ Accessories  :            5 :        64.50 :       322.50 │\n" +
    "╰──────────────┴──────────────┴──────────────┴──────────────╯\n" +
    "╭──────────────┬──────────────┬──────────────┬──────────────╮\n" +
    "│              :              :     SubTotal :      \e[1m3671.48\e[0m │\n" +
    "│              :              :  Discount 5% :       \e[3m183.57\e[0m │\n" +
    "│              :              :    S/T after :      \e[1m3487.91\e[0m │\n" +
    "│              :              :     discount :              │\n" +
    "│              :              :    Tax (20%) :       697.58 │\n" +
    "│              :              :              :     ======== │\n" +
    "│              :              :  Balance due :      \e[1m4185.49\e[0m │\n" +
    "╰──────────────┴──────────────┴──────────────┴──────────────╯"

invoice_layout2 =
  "                              Invoice                              \n" +
    "╭──────────────┬──────────────┬────────────────────┬──────────────╮\n" +
    "│ Product      :     Quantity :              Price :        Total │\n" +
    "├--------------┼--------------┼--------------------┼--------------┤\n" +
    "│ Laptop       :            3 :             980.00 :      2940.00 │\n" +
    "│ Printer      :            2 :             154.99 :       309.98 │\n" +
    "│ Router       :            1 :              99.00 :        99.00 │\n" +
    "│ Switch       : N/A          :              45.00 :              │\n" +
    "│ Accessories  :            5 :              64.50 :       322.50 │\n" +
    "╰──────────────┴──────────────┴────────────────────┴──────────────╯\n" +
    "╭──────────────┬──────────────┬────────────────────┬──────────────╮\n" +
    "│              :              :           SubTotal :      \e[1m3671.48\e[0m │\n" +
    "│              :              :        Discount 5% :       \e[3m183.57\e[0m │\n" +
    "│              :              : S/T after discount :      \e[1m3487.91\e[0m │\n" +
    "│              :              :          Tax (20%) :       697.58 │\n" +
    "│              :              :                    :     ======== │\n" +
    "│              :              :        Balance due :      \e[1m4185.49\e[0m │\n" +
    "╰──────────────┴──────────────┴────────────────────┴──────────────╯"

invoice_layout3 =
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
    "╭─────────────┬──────────┬────────────────────┬──────────╮\n" +
    "│             :          :           SubTotal :  \e[1m3671.48\e[0m │\n" +
    "│             :          :        Discount 5% :   \e[3m183.57\e[0m │\n" +
    "│             :          : S/T after discount :  \e[1m3487.91\e[0m │\n" +
    "│             :          :          Tax (20%) :   697.58 │\n" +
    "│             :          :                    : ======== │\n" +
    "│             :          :        Balance due :  \e[1m4185.49\e[0m │\n" +
    "╰─────────────┴──────────┴────────────────────┴──────────╯"

invoice_layout4 =
  "                          Invoice                         \n" +
    "╭─────────────┬──────────┬────────────────────┬──────────╮\n" +
    "│ Product     : Quantity :              Price :    Total │\n" +
    "├-------------┼----------┼--------------------┼----------┤\n" +
    "│ Laptop      :        3 :             980.00 :  2940.00 │\n" +
    "│ Printer     :        2 :             154.99 :   309.98 │\n" +
    "│ Router      :        1 :              99.00 :    99.00 │\n" +
    "│ Switch      : N/A      :              45.00 :          │\n" +
    "│ Accessories :        5 :              64.50 :   322.50 │\n" +
    "├─────────────┼──────────┼────────────────────┼──────────┤\n" +
    "│             :          :           SubTotal :  \e[1m3671.48\e[0m │\n" +
    "│             :          :        Discount 5% :   \e[3m183.57\e[0m │\n" +
    "│             :          : S/T after discount :  \e[1m3487.91\e[0m │\n" +
    "│             :          :          Tax (20%) :   697.58 │\n" +
    "│             :          :                    : ======== │\n" +
    "│             :          :        Balance due :  \e[1m4185.49\e[0m │\n" +
    "╰─────────────┴──────────┴────────────────────┴──────────╯"

describe "#{Tablo::Summary}", tags: "summary" do
  describe "#{Tablo::Summary} Calculations and summary rows arrangement, with no border" do
    describe "#{Tablo::Summary} summary definition using UserAggregation (with sources " +
             "- 1)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_0
      end
    end

    describe "#{Tablo::Summary} summary definition using UserAggregation " +
             "(with sources - 2)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_2,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_0
      end
    end
    describe "#{Tablo::Summary} summary definition using UserAggregation " +
             "(with columns)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_3,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_0
      end
    end
  end

  context "#{Tablo::Summary} Summary layouts" do
    context "#{Tablo::Summary} Defining main and summary, no packing" do
      it "Returns the expected layout (summary table is detached, with borders)" do
        tbl = create_table
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
          })
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout1
      end
    end

    context "#{Tablo::Summary} Defining main and summary, packing main, packing summary" do
      it "Returns the expected layout (packing is partially optimized)" do
        tbl = create_table
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
          })
        tbl.pack
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout2
      end
    end

    context "#{Tablo::Summary} Defining and packing main, defining summary, packing summary" do
      it "Returns the expected layout (packing is fully optimized)" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
          })
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout3
      end
    end

    context "#{Tablo::Summary} Fully optimized packing and joined tables" do
      it "Returns the expected layout" do
        tbl = create_table
        tbl.omit_last_rule = true
        tbl.pack
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
          })
        tbl.summary.as(Tablo::Table(Array(Tablo::CellType))).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout4
      end
    end
  end
end
