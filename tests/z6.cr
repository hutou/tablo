require "tablo"
require "debug"

table = Tablo::Table.new([0.0, 1.0, 2.0],
  body_formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
    case cell_data.column_index
    when 1 then Tablo::Util.dot_align(value.as(Float), 4, Tablo::Util::DotAlign::Empty)
    when 2 then Tablo::Util.dot_align(value.as(Float), 4, Tablo::Util::DotAlign::Blank)
    when 3 then Tablo::Util.dot_align(value.as(Float), 4, Tablo::Util::DotAlign::Dot)
    when 4 then Tablo::Util.dot_align(value.as(Float), 4, Tablo::Util::DotAlign::DotZero)
    else        value.as(Float).to_s
    end
  }) do |t|
  t.add_column("itself",
    header_styler: ->(content : String) { content.colorize(:red).to_s }, &.itself)
  t.add_group("")
  t.add_column("dot\nalign\nEmpty") { |n| n ** 0.5 }
  t.add_column("dot\nalign\nBlank") { |n| n ** 0.5 }
  t.add_column("dot\nalign\nDot") { |n| n ** 0.5 }
  t.add_column("dot\nalign\nDotZero") { |n| n ** 0.5 }
  t.add_group("dots")
end
puts table
puts table.pack
puts table.pack(25)
