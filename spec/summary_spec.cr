require "./spec_helper"
require "big"

# create or Redefine protected and private methods for tests
class Tablo::Table(T)
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
    InvoiceItem.new("Router", 1, 9900),
    InvoiceItem.new("Switch", nil, 4500),
    InvoiceItem.new("Accessories", 5, 6450),
  ]
  table = Tablo::Table.new(invoice,
    omit_last_rule: false,
    border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
    title: Tablo::Heading.new("Invoice")) do |t|
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

struct BigDecimal
  include Tablo::CellType
end

struct InvoiceItemBig
  getter product, quantity, price

  def initialize(@product : String, @quantity : Int32?, @price : BigDecimal?)
  end
end

def create_table_big
  invoice = [
    InvoiceItemBig.new("Laptop", 3, BigDecimal.new(980)),
    InvoiceItemBig.new("Printer", 2, BigDecimal.new(154.99)),
    InvoiceItemBig.new("Router", 1, BigDecimal.new(99)),
    InvoiceItemBig.new("Switch", nil, BigDecimal.new(45)),
    InvoiceItemBig.new("Accessories", 5, BigDecimal.new(64.50)),
  ]

  table = Tablo::Table.new(invoice,
    omit_last_rule: true,
    border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
    title: Tablo::Heading.new("\nInvoice\n=======\n"),
    subtitle: Tablo::Heading.new("Details", framed: true)) do |t|
    t.add_column("Product",
      &.product)
    t.add_column("Quantity",
      body_formatter: ->(value : Tablo::CellType) {
        (value.nil? ? "N/A" : value.to_s)
      }, &.quantity)
    t.add_column("Price",
      body_formatter: ->(value : Tablo::CellType) {
        "%.2f" % value.as(BigDecimal)
      }, &.price.as(Tablo::CellType))
    t.add_column(:total, header: "Total",
      body_formatter: ->(value : Tablo::CellType) {
        value.nil? ? "" : "%.2f" % value.as(BigDecimal)
      }) { |n| n.price.nil? || n.quantity.nil? ? nil : (
      n.price.as(BigDecimal) *
        n.quantity.as(Int32)
    ).as(Tablo::CellType) }
  end
end

invoice_summary_definition_base =
  [
    Tablo::Summary::BodyColumn.new("Price", alignment: Tablo::Justify::Right),
    Tablo::Summary::BodyColumn.new(:total, alignment: Tablo::Justify::Right,
      formatter: ->(value : Tablo::CellType) {
        value.is_a?(String) ? value : (
          value.nil? ? "" : "%.2f" % (value.as(Int32) / 100)
        )
      },
      styler: ->(_value : Tablo::CellType, cd : Tablo::Cell::Data::Coords, fc : String) {
        case cd.row_index
        when 0, 2, 5
          fc.colorize.mode(:bold).to_s
        when 1
          fc.colorize.mode(:italic).to_s
        else
          fc
        end
      }
    ),
    Tablo::Summary::BodyRow.new("Price", 1, "SubTotal"),
    Tablo::Summary::BodyRow.new("Price", 2, "Discount 5%"),
    Tablo::Summary::BodyRow.new("Price", 3, "S/T after discount"),
    Tablo::Summary::BodyRow.new("Price", 4, "Tax (20%)"),
    Tablo::Summary::BodyRow.new("Price", 6, "Balance due"),
    Tablo::Summary::BodyRow.new(:total, 1, -> { Tablo::Summary.use(:total_sum) }),
    Tablo::Summary::BodyRow.new(:total, 2, -> { Tablo::Summary.use(:discount) }),
    Tablo::Summary::BodyRow.new(:total, 3, -> { Tablo::Summary.use(:total_after_discount) }),
    Tablo::Summary::BodyRow.new(:total, 4, -> { Tablo::Summary.use(:tax) }),
    Tablo::Summary::BodyRow.new(:total, 5, "========"),
    Tablo::Summary::BodyRow.new(:total, 6, -> { Tablo::Summary.use(:total_due) }),
  ]

invoice_summary_definition_1 =
  [
    Tablo::Summary::UserProc.new(
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
    Tablo::Summary::UserProc.new(
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
    Tablo::Summary::UserProc.new(
      proc: ->(tbl : Tablo::Table(InvoiceItem)) {
        total_sum = 0
        iter_quantity = tbl.column_data("Quantity").each
        iter_price = tbl.column_data("Price").each

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

invoice_summary_definition_big = [
  Tablo::Summary::UserProc.new(
    proc: ->(tbl : Tablo::Table(InvoiceItemBig)) {
      total_sum = BigDecimal.new(0)
      tbl.column_data(:total).each do |tot|
        total_sum += tot.as(BigDecimal) unless tot.nil?
      end
      discount = total_sum * 0.05
      total_after_discount = total_sum - discount
      tax = total_after_discount * 0.2
      total_due = total_after_discount + tax
      {
        :total_sum            => total_sum.as(Tablo::CellType),
        :discount             => discount.as(Tablo::CellType),
        :total_after_discount => total_after_discount.as(Tablo::CellType),
        :tax                  => tax.as(Tablo::CellType),
        :total_due            => total_due.as(Tablo::CellType),
      }
    }),
  Tablo::Summary::BodyColumn.new("Price", alignment: Tablo::Justify::Right),
  Tablo::Summary::BodyColumn.new(:total, alignment: Tablo::Justify::Right,
    formatter: ->(value : Tablo::CellType) {
      value.is_a?(String) ? value : (
        value.nil? ? "" : "%.2f" % value.as(BigDecimal)
      )
    },
    styler: ->(_value : Tablo::CellType, cd : Tablo::Cell::Data::Coords, fc : String) {
      case cd.row_index
      when 0, 2, 5 then fc.colorize.mode(:bold).to_s
      when 1       then fc.colorize.mode(:italic).to_s
      else              fc
      end
    }
  ),
  Tablo::Summary::HeaderColumn.new("Product", content: ""),
  Tablo::Summary::HeaderColumn.new("Quantity", content: ""),
  Tablo::Summary::HeaderColumn.new("Price", content: "Total Invoice",
    alignment: Tablo::Justify::Right),
  Tablo::Summary::HeaderColumn.new(:total, content: "Amounts"),

  Tablo::Summary::BodyRow.new("Price", 10, "SubTotal"),
  Tablo::Summary::BodyRow.new("Price", 20, "Discount 5%"),
  Tablo::Summary::BodyRow.new("Price", 30, "S/T after discount"),
  Tablo::Summary::BodyRow.new("Price", 40, "Tax (20%)"),
  Tablo::Summary::BodyRow.new("Price", 60, "Balance due"),

  Tablo::Summary::BodyRow.new(:total, 10, -> { Tablo::Summary.use(:total_sum) }),
  Tablo::Summary::BodyRow.new(:total, 20, -> { Tablo::Summary.use(:discount) }),
  Tablo::Summary::BodyRow.new(:total, 30, -> { Tablo::Summary.use(:total_after_discount) }),
  Tablo::Summary::BodyRow.new(:total, 40, -> { Tablo::Summary.use(:tax) }),
  Tablo::Summary::BodyRow.new(:total, 50, "========"),
  Tablo::Summary::BodyRow.new(:total, 60, -> { Tablo::Summary.use(:total_due) }),
]

invoice_layout_0 = <<-OUTPUT
                            Invoice                         
  ╭─────────────┬──────────┬────────────────────┬──────────╮
  │ Product     : Quantity :              Price :    Total │
  ├-------------┼----------┼--------------------┼----------┤
  │ Laptop      :        3 :             980.00 :  2940.00 │
  │ Printer     :        2 :             154.99 :   309.98 │
  │ Router      :        1 :              99.00 :    99.00 │
  │ Switch      : N/A      :              45.00 :          │
  │ Accessories :        5 :              64.50 :   322.50 │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
invoice_layout_0 += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
                                       SubTotal    \e[1m3671.48\e[0m  
                                    Discount 5%     \e[3m183.57\e[0m  
                             S/T after discount    \e[1m3487.91\e[0m  
                                      Tax (20%)     697.58  
                                                  ========  
                                    Balance due    \e[1m4185.49\e[0m  
  OUTPUT
else
  <<-OUTPUT
                                       SubTotal    3671.48  
                                    Discount 5%     183.57  
                             S/T after discount    3487.91  
                                      Tax (20%)     697.58  
                                                  ========  
                                    Balance due    4185.49  
  OUTPUT
end

invoice_layout1 =
  <<-OUTPUT
                             Invoice                           
  ╭──────────────┬──────────────┬──────────────┬──────────────╮
  │ Product      :     Quantity :        Price :        Total │
  ├--------------┼--------------┼--------------┼--------------┤
  │ Laptop       :            3 :       980.00 :      2940.00 │
  │ Printer      :            2 :       154.99 :       309.98 │
  │ Router       :            1 :        99.00 :        99.00 │
  │ Switch       : N/A          :        45.00 :              │
  │ Accessories  :            5 :        64.50 :       322.50 │
  ╰──────────────┴──────────────┴──────────────┴──────────────╯
  OUTPUT
invoice_layout1 += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
  ╭──────────────┬──────────────┬──────────────┬──────────────╮
  │              :              :     SubTotal :      \e[1m3671.48\e[0m │
  │              :              :  Discount 5% :       \e[3m183.57\e[0m │
  │              :              :    S/T after :      \e[1m3487.91\e[0m │
  │              :              :     discount :              │
  │              :              :    Tax (20%) :       697.58 │
  │              :              :              :     ======== │
  │              :              :  Balance due :      \e[1m4185.49\e[0m │
  ╰──────────────┴──────────────┴──────────────┴──────────────╯
  OUTPUT
else
  <<-OUTPUT
  ╭──────────────┬──────────────┬──────────────┬──────────────╮
  │              :              :     SubTotal :      3671.48 │
  │              :              :  Discount 5% :       183.57 │
  │              :              :    S/T after :      3487.91 │
  │              :              :     discount :              │
  │              :              :    Tax (20%) :       697.58 │
  │              :              :              :     ======== │
  │              :              :  Balance due :      4185.49 │
  ╰──────────────┴──────────────┴──────────────┴──────────────╯
  OUTPUT
end

invoice_layout2 = <<-OUTPUT
                                Invoice                              
  ╭──────────────┬──────────────┬────────────────────┬──────────────╮
  │ Product      :     Quantity :              Price :        Total │
  ├--------------┼--------------┼--------------------┼--------------┤
  │ Laptop       :            3 :             980.00 :      2940.00 │
  │ Printer      :            2 :             154.99 :       309.98 │
  │ Router       :            1 :              99.00 :        99.00 │
  │ Switch       : N/A          :              45.00 :              │
  │ Accessories  :            5 :              64.50 :       322.50 │
  ╰──────────────┴──────────────┴────────────────────┴──────────────╯
  OUTPUT
invoice_layout2 += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
  ╭──────────────┬──────────────┬────────────────────┬──────────────╮
  │              :              :           SubTotal :      \e[1m3671.48\e[0m │
  │              :              :        Discount 5% :       \e[3m183.57\e[0m │
  │              :              : S/T after discount :      \e[1m3487.91\e[0m │
  │              :              :          Tax (20%) :       697.58 │
  │              :              :                    :     ======== │
  │              :              :        Balance due :      \e[1m4185.49\e[0m │
  ╰──────────────┴──────────────┴────────────────────┴──────────────╯
  OUTPUT
else
  <<-OUTPUT
  ╭──────────────┬──────────────┬────────────────────┬──────────────╮
  │              :              :           SubTotal :      3671.48 │
  │              :              :        Discount 5% :       183.57 │
  │              :              : S/T after discount :      3487.91 │
  │              :              :          Tax (20%) :       697.58 │
  │              :              :                    :     ======== │
  │              :              :        Balance due :      4185.49 │
  ╰──────────────┴──────────────┴────────────────────┴──────────────╯
  OUTPUT
end

invoice_layout3 = <<-OUTPUT
                            Invoice                         
  ╭─────────────┬──────────┬────────────────────┬──────────╮
  │ Product     : Quantity :              Price :    Total │
  ├-------------┼----------┼--------------------┼----------┤
  │ Laptop      :        3 :             980.00 :  2940.00 │
  │ Printer     :        2 :             154.99 :   309.98 │
  │ Router      :        1 :              99.00 :    99.00 │
  │ Switch      : N/A      :              45.00 :          │
  │ Accessories :        5 :              64.50 :   322.50 │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
invoice_layout3 += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
  ╭─────────────┬──────────┬────────────────────┬──────────╮
  │             :          :           SubTotal :  \e[1m3671.48\e[0m │
  │             :          :        Discount 5% :   \e[3m183.57\e[0m │
  │             :          : S/T after discount :  \e[1m3487.91\e[0m │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  \e[1m4185.49\e[0m │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
else
  <<-OUTPUT
  ╭─────────────┬──────────┬────────────────────┬──────────╮
  │             :          :           SubTotal :  3671.48 │
  │             :          :        Discount 5% :   183.57 │
  │             :          : S/T after discount :  3487.91 │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  4185.49 │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
end

invoice_layout4 = <<-OUTPUT
                            Invoice                         
  ╭─────────────┬──────────┬────────────────────┬──────────╮
  │ Product     : Quantity :              Price :    Total │
  ├-------------┼----------┼--------------------┼----------┤
  │ Laptop      :        3 :             980.00 :  2940.00 │
  │ Printer     :        2 :             154.99 :   309.98 │
  │ Router      :        1 :              99.00 :    99.00 │
  │ Switch      : N/A      :              45.00 :          │
  │ Accessories :        5 :              64.50 :   322.50 │
  ├─────────────┼──────────┼────────────────────┼──────────┤
  OUTPUT
invoice_layout4 += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
  │             :          :           SubTotal :  \e[1m3671.48\e[0m │
  │             :          :        Discount 5% :   \e[3m183.57\e[0m │
  │             :          : S/T after discount :  \e[1m3487.91\e[0m │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  \e[1m4185.49\e[0m │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
else
  <<-OUTPUT
  │             :          :           SubTotal :  3671.48 │
  │             :          :        Discount 5% :   183.57 │
  │             :          : S/T after discount :  3487.91 │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  4185.49 │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
end

invoice_layout_big = <<-OUTPUT
                                                            
                            Invoice                         
                            =======                         
                                                            
  ╭────────────────────────────────────────────────────────╮
  │                         Details                        │
  ├─────────────┬──────────┬────────────────────┬──────────┤
  │ Product     : Quantity :              Price :    Total │
  ├-------------┼----------┼--------------------┼----------┤
  │ Laptop      :        3 :             980.00 :  2940.00 │
  │ Printer     :        2 :             154.99 :   309.98 │
  │ Router      :        1 :              99.00 :    99.00 │
  │ Switch      : N/A      :              45.00 :          │
  │ Accessories :        5 :              64.50 :   322.50 │
  ├─────────────┴──────────┴────────────────────┴──────────┤
  │                         Summary                        │
  ├─────────────┬──────────┬────────────────────┬──────────┤
  │             :          :      Total Invoice :  Amounts │
  ├-------------┼----------┼--------------------┼----------┤
  OUTPUT
invoice_layout_big += "\n" + if Tablo::Util.styler_allowed
  <<-OUTPUT
  │             :          :           SubTotal :  \e[1m3671.48\e[0m │
  │             :          :        Discount 5% :   \e[3m183.57\e[0m │
  │             :          : S/T after discount :  \e[1m3487.91\e[0m │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  \e[1m4185.49\e[0m │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
else
  <<-OUTPUT
  │             :          :           SubTotal :  3671.48 │
  │             :          :        Discount 5% :   183.57 │
  │             :          : S/T after discount :  3487.91 │
  │             :          :          Tax (20%) :   697.58 │
  │             :          :                    : ======== │
  │             :          :        Balance due :  4185.49 │
  ╰─────────────┴──────────┴────────────────────┴──────────╯
  OUTPUT
end

describe "#{Tablo::Summary}", tags: "summary" do
  describe "#{Tablo::Summary} Calculations and summary rows arrangement, with no border" do
    describe "#{Tablo::Summary} summary definition using Summary::UserProc (with sources " +
             "- 1)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_1,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_0
      end
    end
    describe "#{Tablo::Summary} summary definition using Summary::UserProc " +
             "(with sources - 2)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_2,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_0
      end
    end
    describe "#{Tablo::Summary} summary definition using Summary::UserProc " +
             "(with columns)", tags: "summary" do
      it "Returns the correct, cleanly formatted values, with the expected layout" do
        tbl = create_table
        tbl.pack
        tbl.add_summary(invoice_summary_definition_3,
          {
            masked_headers: true,
            border:         Tablo::Border.new("EEESSSEEESSSESSS"),
          })
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
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
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
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
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
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
        tbl.summary.as(Tablo::Table).pack(only: ["Price", :total])
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout4
      end
    end

    context "#{Tablo::Summary} Fully optimized packing and joined tables, with
                            Summary title and headers, and using BigDecimal for prices" do
      it "Returns the expected layout" do
        tbl = create_table_big
        tbl.omit_last_rule = true
        tbl.pack
        tbl.add_summary(invoice_summary_definition_big,
          title: Tablo::Heading.new("Summary", framed: true)
        )
        tbl.summary.as(Tablo::Table).pack
        output = tbl.to_s + "\n" + tbl.summary.to_s
        {% if flag?(:DEBUG) %}
          puts "\n#{output}"
        {% end %}
        output.should eq invoice_layout_big
      end
    end
  end
end
