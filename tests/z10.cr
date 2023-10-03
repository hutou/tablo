require "tablo"
require "colorize"

table = Tablo::Table.new([1, 2, 3, 4, 5],
  title: Tablo::Title.new("My black and white fancy table", frame: Tablo::Frame.new),
  footer: Tablo::Footer.new("End of data", frame: Tablo::Frame.new),
  border_type: Tablo::BorderName::Fancy,
  border_styler: ->(border_char : String) { border_char.colorize(:light_gray).to_s },
  body_styler: ->(value : Tablo::CellType, cell_data : Tablo::CellData, content : String) {
    if cell_data.row_index.even?
      "\e[3m" + content.colorize(:light_gray).to_s + "\e[0m"
    else
      content.colorize.fore(:dark_gray).mode(:bold).to_s
    end
  },
  header_styler: ->(content : String) { content.colorize.mode(:bold).to_s }) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "Double") { |n| n * 2 }
  t.add_column(:column_3, header: "String") { |n| n.even?.to_s }
end
puts table
