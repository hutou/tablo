require "spec"
require "../src/tablo"

# def newtable(sources,
#             default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
#             column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
#             header_frequency : Int32? = 0,
#             wrap_header_cells_to : Int32? = nil,
#             wrap_body_cells_to : Int32 | Nil = nil,
#             truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
#             connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
#             style : String = Tablo::STYLE_ALL_BORDERS)
#  table = Tablo::Table.new(sources,
#    default_column_width,
#    column_padding,
#    header_frequency,
#    wrap_header_cells_to,
#    wrap_body_cells_to,
#    truncation_indicator,
#    connectors,
#    style) do |t|
#    t.add_column("N") { |n| n[0].as(Int32) }
#    t.add_column("Double") { |n| n[0].as(Int32) * 2 }
#  end
# end
