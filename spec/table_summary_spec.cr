require "./spec_helper"

# def context_data
#   sources = [
#     [2, 3.14, false, "abcd"],
#     [12, 2.78, false, "xyz"],
#     [42, 4.21, true, "ijkl"],
#     [33, 1.41, false, "rst"],
#     [17, 1.33, true, "uvw"],
#   ]
# end

# def context_table
#   sources = context_data
#   table = Tablo::Table.new(sources,
#     omit_last_rule: true,
#     row_divider_frequency: 1) do |t|
#     t.add_column("Integer") { |n| n[0] }
#     t.add_column("Float") { |n| n[1] }
#     t.add_group("Number")
#     t.add_column("Bool") { |n| n[2] }
#     t.add_column("String") { |n| n[3] }
#     t.add_group("Other")
#   end
# end

# def get_summary_definition
#   summary_definition = {
#     :header_column => {
#       "Integer" => {:alignment => Tablo::Justify::Right},
#       "Float"   => {:alignment => Tablo::Justify::Left,
#                   :formatter => ->(value : Tablo::CellType) { value.to_s.upcase },
#                   :styler => ->(s : String) { s.colorize(:yellow).to_s }},
#       "Bool" => {:formatter => ->(value : Tablo::CellType) { value.to_s.upcase }},
#     },
#     :header_row => {
#       "Integer" => "Entier".as(Tablo::CellType),
#       "Float"   => "Réel".as(Tablo::CellType),
#       "Bool"    => "Booléen".as(Tablo::CellType),
#     },
#     :body_column => {
#       "Integer" => {:alignment => Tablo::Justify::Right},
#       "Float"   => {:alignment => Tablo::Justify::Left,
#                   :formatter => ->(value : Tablo::CellType) { value.to_s.upcase },
#                   :styler => ->(s : String) { s.colorize(:red).to_s }},
#       "Bool" => {:formatter => ->(value : Tablo::CellType) { value.to_s.upcase }},
#     },
#     :body_row => {
#       "Integer" => {
#         1 => "Literal value 1".as(Tablo::CellType),
#         2 => "Literal value 2".as(Tablo::CellType),
#         3 => ->{ Tablo::Summary.use("Float",
#           Tablo::Aggregate::Sum).as(Tablo::CellType) },
#       },
#       "Float" => {
#         1 => ->{ Tablo::Summary.use("Float",
#           Tablo::Aggregate::Sum).as(Tablo::CellType) },
#       },
#       "Bool" => {
#         1 => "Bool literal value".as(Tablo::CellType),
#       },
#     },
#     :aggregation => {
#       "Integer" => [Tablo::Aggregate::Count],
#       "Float"   => [Tablo::Aggregate::Sum],
#     }, #
#     :user_aggregation => {
#       :user_source => ->(sources : Enumerable(Array(Int32 | Float64 | Bool | String))) {
#         42.as(Tablo::CellType)
#       },
#       :user_table => ->(tbl : Tablo::Table(Array(Int32 | Float64 | Bool | String))) {
#         (tbl.source_column("Integer").select(&.is_a?(Int32))
#           .map &.as(Int32)).sum.as(Tablo::CellType)
#       },
#     },
#   }
# end

record Entry, product : String, quantity : Int32?, price : Int32?

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
    # add a masked column
  end
end

#     :aggregation => {
#       "Integer" => [Tablo::Aggregate::Count],
#       "Float"   => [Tablo::Aggregate::Sum],
#     }, #
def get_summary_definition
  summary_definition = {
    :aggregation => {
      "Product" => [Tablo::Aggregate::Count],
      :total    => [Tablo::Aggregate::Sum, Tablo::Aggregate::Count,
                 Tablo::Aggregate::Min, Tablo::Aggregate::Max],
      "Price" => [Tablo::Aggregate::Sum, Tablo::Aggregate::Count,
                  Tablo::Aggregate::Min, Tablo::Aggregate::Max],
    },
    :user_aggregation => {
      :user_sum_price_source => ->(invoice : Enumerable(Entry)) { 42.as(Tablo::CellType) },
      :user_sum_price_column => ->(tbl : Tablo::Table(Entry)) {
        (tbl.source_column("Price").select(&.is_a?(Int32)).map &.as(Int32)).sum.as(Tablo::CellType)
      },
    },
    # :header_column => {
    #   "Product" => {
    #     :alignment => Tablo::Justify::Left,
    #     :formatter => ->(value : Tablo::CellType) { value.to_s },
    #   },
    # :tax => {
    #   :alignment => Tablo::Justify::Right,
    #   :styler    => ->(s : String) { s },
    # },
    # "Price" => {
    #   :alignment => Tablo::Justify::Right,
    # },
    # },
    # :header_row => {
    #   "Product" => "Product\nName",
    #   # :tax      => "VAT 20%",
    #   "Price" => "Unit\nPrice",
    # },
    :body_column => {
      "Product" => {
        :alignment => Tablo::Justify::Left,
        :formatter => ->(value : Tablo::CellType) { value.to_s },
        :styler    => ->(s : String) { s.colorize(:yellow).to_s },
      },
      "Price" => {
        :alignment => Tablo::Justify::Right,
        :styler    => ->(s : String) { s.colorize(:magenta).to_s },
      },
      :total => {
        :alignment => Tablo::Justify::Right,
        :styler    => ->(s : String) { s.colorize(:blue).to_s },
        :formatter => ->(value : Tablo::CellType) {
          value.is_a?(String) ? value : "%.2f" % (value.as(Int32) / 100)
        },
      },
    },
    :body_row => {
      "Price" => {
        1 => "SubTotal".as(Tablo::CellType),
        2 => "Discount 5%".as(Tablo::CellType),
        3 => "SubTotal after discount".as(Tablo::CellType),
        4 => "Tax (rate 20%)".as(Tablo::CellType),
        5 => "========".as(Tablo::CellType),
        6 => "Balance due".as(Tablo::CellType),
      },
      :total => {
        1 => ->{ Tablo::Summary.use(:total, Tablo::Aggregate::Sum).as(Tablo::CellType) },
        2 => ->{ (Tablo::Summary.keep(:discount,
          (Tablo::Summary.use(:total, Tablo::Aggregate::Sum).as(Int32) * 0.05)
            .to_i)).as(Tablo::CellType) },
        3 => ->{ (Tablo::Summary.keep(:total_after_discount,
          Tablo::Summary.use(:total, Tablo::Aggregate::Sum).as(Int32) -
          Tablo::Summary.use(:discount).as(Int32))).as(Tablo::CellType) },
        4 => ->{ (Tablo::Summary.keep(:tax,
          (Tablo::Summary.use(:total_after_discount).as(Int32) * 0.2)
            .to_i)).as(Tablo::CellType) },
        5 => "========".as(Tablo::CellType),
        6 => ->{ (Tablo::Summary.use(:tax).as(Int32) +
                  Tablo::Summary.use(:total_after_discount).as(Int32)).as(Tablo::CellType) },
      },
    },
  }
end

describe "#{Tablo::Table} -> summary definition", tags: "summary" do
  tbl = context_table
  tbl.summary(get_summary_definition,
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
# Border, define a "space" BordefName  (<> Blank)
# TODO
