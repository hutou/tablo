require "tablo"
require "colorize"

table = Tablo::Table.new([1, 2, 3],
  border_type: Tablo::BorderName::Fancy,
  border_styler: ->(border : String) { border.colorize(:yellow).to_s },
  header_styler: ->(content : String) { content.colorize(:blue).to_s }) do |t|
  t.add_column("itself", &.itself)
  t.add_column("even?", &.even?)
end
puts table
