require "tablo"
require "colorize"
require "debug"

Tablo::Config.styler_tty_only = false
table = Tablo::Table.new([1, 2, 3],
  border_type: Tablo::BorderName::Fancy,
  border_styler: ->(border_char : String) { border_char.colorize(:yellow).to_s },
  body_styler: ->(value : Tablo::CellType, content : String) {
    case value
    when Int32
      value > 2 ? content.colorize.fore(:green).mode(:bold).to_s : content
    else
      value == "true" ? content.colorize.mode(:underline).to_s : content
    end
  },
  header_styler: ->(content : String) { content.colorize(:blue).to_s }) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "Double") { |n| n * 2 }
  t.add_column(:column_3, header: "String") { |n| n.even?.to_s }
end
puts table
