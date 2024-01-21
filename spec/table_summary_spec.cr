require "./spec_helper"

summary_definition = [
  # Tablo::Aggregation.new("Product", [Tablo::Aggregate::Count, Tablo::Aggregate::Max]),
  # Tablo::Aggregation.new("Product", [Tablo::Aggregate::Count, Tablo::Aggregate::Max]),
  Tablo::Aggregation.new(["Quantity", "Price"].map &.as(Tablo::LabelType),
    [Tablo::Aggregate::Count, Tablo::Aggregate::Max, Tablo::Aggregate::Sum]),
  # Tablo::Aggregation.new("Price", [Tablo::Aggregate::Count]),
  Tablo::Aggregation.new("Product", [Tablo::Aggregate::Count]),
  Tablo::UserAggregation(Entry).new(
    ident: :user_table, proc: ->(tbl : Tablo::Table(Entry)) {
    (tbl.sources.select(&.quantity.is_a?(Int32))
      .map &.quantity.as(Int32)).sum.as(Tablo::CellType)
  }),
  Tablo::UserAggregation(Entry).new(
    ident: :user_table2, proc: ->(tbl : Tablo::Table(Entry)) {
    (tbl.source_column("Price").select(&.is_a?(Int32))
      .map &.as(Int32)).sum.as(Tablo::CellType)
  }),
  Tablo::BodyColumn.new("Product", alignment: nil,
    formatter: ->(value : Tablo::CellType) {
      value.is_a?(String) ? value : (
        value.nil? ? "" : "%.2f" % (value.as(Int32) / 100)
      )
    },
    styler: ->(s : String) { s.colorize(:blue).to_s }),
  Tablo::BodyRow.new("Product", 1, "SubTotal"),
  Tablo::BodyRow.new("Product", 2, ->{ Tablo::Summary.use(
    "Product", Tablo::Aggregate::Count) }),
  Tablo::BodyRow.new("Quantity", 3, ->{ Tablo::Summary.use(:user_table) }),
  Tablo::HeaderRow.new(column: "Product", content: "Mon produit"),
  Tablo::HeaderRow.new(column: "Price", content: "Prix serré"),
]

record Entry2, recno : String, integer1 : Int32, integer2 : Int32?,
  float1 : Float64, float2 : Float64?, boolean : Bool?, string : String? do
  include Tablo::CellType
end

datasource = [
  Entry2.new("Rec1", 3, 18, 3.14159, 2.789, false, "abc"),
  Entry2.new("Rec2", 7, 117, 4.21, nil, false, "ijk"),
  Entry2.new("Rec3", 4, nil, 8.7436, 11.174, true, "ijk"),
  Entry2.new("Rec4", 12, 93, 1.121, 4.778, false, "ABC"),
  Entry2.new("Rec5", 8, 42, 7.998, 19.713, true, "xyz"),
  Entry2.new("Rec6", 1, 33, 1.7398, 12.433, nil, "Def"),
  Entry2.new("Rec7", 9, 107, 9.221, 22.142, false, "abc"),
  Entry2.new("Rec8", 6, nil, 3.784, 15.45, true, "Def"),
  Entry2.new("Rec9", 13, 82, 6.4455, 19.777, true, "ijk"),
]
table = Tablo::Table.new(datasource,
  # omit_last_rule: false,
  body_formatter: ->(value : Tablo::CellType) { value.nil? ? "<N/D>" : value.to_s },
  body_styler: ->(s : String) { s == "<N/D>" ? s.colorize(:red).mode(:bold).to_s : s },
  omit_last_rule: false,
  # border: Tablo::Border.new(Tablo::BorderName::Fancy),
  title: Tablo::Title.new("Summary method data")) do |t|
  t.add_column(:recno, header: "Record\nNumber", &.recno)
  t.add_column(:integer1, header: "Integer\nSerie 1", &.integer1)
  t.add_column(:integer2, header: "Integer\nSerie 2", &.integer2)
  t.add_column(:float1, header: "Float\nSerie 1", &.float1)
  t.add_column(:float2, header: "Float\nSerie 2", &.float2)
  t.add_column(:boolean, header: "Boolean\nSerie", &.boolean)
  t.add_column(:string, header: "String\nSerie", &.string)
end
puts table

arcol = [:integer1, :integer2, :float1, :float2, :boolean, :string].map &.as(Tablo::LabelType)
debug! arcol

summary_definition3 = [
  Tablo::Aggregation.new([:integer1, :integer2, :float1, :float2, :boolean,
                          :string].map &.as(Tablo::LabelType),
    [Tablo::Aggregate::Count, Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:integer1, Tablo::Aggregate::Max),
]

summary_definition2 = [
  Tablo::Aggregation.new(:integer1, [Tablo::Aggregate::Count,
                                     Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:integer2, [Tablo::Aggregate::Count,
                                     Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:float1, [Tablo::Aggregate::Count,
                                   Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:float2, [Tablo::Aggregate::Count,
                                   Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:boolean, [Tablo::Aggregate::Count,
                                    Tablo::Aggregate::Sum]),
  Tablo::Aggregation.new(:string, [Tablo::Aggregate::Count,
                                   Tablo::Aggregate::Sum]),
]

struct Entry
  include Tablo::CellType
  getter product, quantity, price

  def initialize(@product : String, @quantity : Int32?, @price : Int32?)
  end
end

def context_data
  invoice = [
    Entry.new("Laptop", 3, 98000),
    Entry.new("Printer", 2, 15499),
    # Entry.new("fAKE", nil, nil),
    Entry.new("Router", 1, 9900),
    Entry.new("Accessories", 5, 6450),
  ]
end

def context_table
  sources = context_data
  table = Tablo::Table.new(sources,
    omit_last_rule: false,
    border: Tablo::Border.new(Tablo::BorderName::Fancy),
    title: Tablo::Title.new("Invoice")) do |t|
    t.add_column("Product",
      &.product)
    t.add_column("Quantity", &.quantity)
    t.add_column("Price",
      body_formatter: ->(value : Tablo::CellType) {
        "%.2f" % (value.as(Int32) / 100)
      }, &.price)
    t.add_column(:total, header: "Total",
      body_formatter: ->(value : Tablo::CellType) {
        "%.2f" % (value.as(Int32) / 100)
      }) { |n| n.price.nil? || n.quantity.nil? ? nil : (n.price.as(Int32) * n.quantity.as(Int32)) }
    t.add_column(:entry) { |n| n }
    # add a masked column
  end
end

describe "#{Tablo::Table} -> summary definition", tags: "summary" do
  tbl = context_table
  # tbl.summary(get_summary_definition,
  tbl.summary(summary_definition,
    {
      masked_headers: true,
      # body_styler:    ->(s : String) { s.colorize(:green).to_s },
      # header_styler:  ->(s : String) { s.colorize(:blue).mode(:italic).to_s },
      # title:  Tablo::Title.new("Summary", frame: Tablo::Frame.new),
      # border: Tablo::Border.new(Tablo::BorderName::Blank,
      border: Tablo::Border.new("EEESSSSSSSSSESSS",
        styler: ->(s : String) { s.colorize(:yellow).to_s }),
    })
  it "returns valid data", focus: true do
    sources_array = tbl.summary.as(Tablo::SummaryTable).sources.to_a
    # debug! sources_array
    # sources_array[0][0].should eq("Literal value 1")
    # sources_array[1][0].should eq("Literal value 2")
    # sources_array[2][0].should eq(12.87)
    # sources_array[0][1].should eq(12.87)
    # sources_array[0][2].should eq("Bool literal value")
    puts "\n#{tbl}"
    puts tbl.summary.as(Tablo::SummaryTable) # .pack
    # puts "\n#{tbl.summary}"
  end
end

#
# TODO
# Border, define a "space" BordefName  (<> Blank) : done!
# and update tutorial and API accordingly !       : TODO
#
# # in case of summary.pack, update main table column widths : TODO
# TODO
