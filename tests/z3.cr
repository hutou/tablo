require "tablo"
require "colorize"
require "debug"

Debug.enabled = true

table = Tablo::Table.new([1, 2, 3],
  header_frequency: 0,
  title: Tablo::FramedHeading.new("Numbers and text",
    line_breaks_after: 2),
  subtitle: Tablo::UnFramedHeading.new("No booleans"),
  footer: Tablo::UnFramedHeading.new("End of page")) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "Double",
    body_styler: ->(c : Tablo::CellType, f : String) { f.colorize(:green).to_s }) { |n| n * 2 }
  t.add_group("Numbers")
  t.add_column(:column_3, width: 20, header: "\nX\nMy\nString\n ",
    # t.add_column(:column_3, header: "X My String",
    # header_alignment: nil, # Tablo::Justify::Left,
    header_alignment: Tablo::Justify::Center,
    # header_formatter: ->(ct : Tablo::CellType, width : Int32) {
    #   Tablo::Util.stretch(ct.to_s, width, ' ', 0)
    # },
    # header_formatter: ->(ct : Tablo::CellType, width : Int32) { ct.to_s.split("\n").map_with_index do |line, index|
    #   line = index == 0 ? line.upcase : line
    #   Tablo::Util.stretch(line, width, ' ', 0)
    # end.join("\n") },
    header_formatter: ->(ct : Tablo::CellType, width : Int32) { Tablo::Util.stretch(ct.to_s.split("\n").map_with_index do |line, index|
      line = index == 1 ? line.upcase : line
    end.join("\n"), width, ' ', 0, 1) },
    header_styler: ->(_ct : Tablo::CellType, _cc : Tablo::CellData, s : String, line : Int32) { line == 1 ? s.colorize(:red).to_s : s }
  ) { |n| n.even?.to_s }
  t.add_group("Text", alignment: Tablo::Justify::Left)
end

puts table
