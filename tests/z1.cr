require "tablo"
require "colorize"

table = Tablo::Table.new([1, 2, 3],
  header_frequency: 2, masked_headers: true,
  title: Tablo::FramedHeading.new("Numbers and text",
    line_breaks_after: 2),
  subtitle: Tablo::UnFramedHeading.new("No booleans"),
  footer: Tablo::UnFramedHeading.new("End of page")) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "Double",
    body_styler: ->(c : Tablo::CellType, f : String) { f.colorize(:red).to_s }) { |n| n * 2 }
  t.add_group("Numbers")
  t.add_column(:column_3, header: "String") { |n| n.even?.to_s }
  t.add_group("Text", alignment: Tablo::Justify::Left)
end
puts table
