require "tablo"
require "debug"

table = Tablo::Table.new([1, 2, 3, 4, 5]) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "Double") { |n| n * 2 }
  t.add_column(3, header: "Float",
    header_formatter: ->(value : Tablo::CellType, width : Int32) { Tablo::Util.stretch(value.to_s.upcase, width, ' ') }) { |n| n ** 0.5 }
  # header_formatter: ->(value : Tablo::CellType, width : Int32) { value.to_s.split("\n").map_with_index do |line, index|
  #  line = index == 0 ? line.upcase : line
  #  Tablo::Util.stretch(line, width, ' ', 0)
  # end.join("\n") })
  # body_formatter: ->(value : Tablo::CellType) { Tablo::Util.dot_align(value.as(Float64), 4, Tablo::Util::DotAlign::Blank) })
  t.add_column(:column_4, header: "String") { |n| n.even?.to_s }
end
puts table
