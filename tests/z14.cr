require "tablo"
require "debug"

Tablo::Config.border_type = "EDEEDEEDEEDE----"
Tablo::Config.left_padding = 0
Tablo::Config.right_padding = 0
table = Tablo::Table.new((1..2).to_a,
  # table = Tablo::Table.new([1, 2, 3],
  header_frequency: 0,
  # border_type: Tablo::BorderName::Fancy,
  # border_type: Tablo::BorderName::Ascii,
  # title: Tablo::Title.new("Numbers and text", frame: Tablo::Frame.new(0, 2)),
  # title: Tablo::Title.new("Numbers and text", frame: Tablo::Frame.new),
  # footer: Tablo::Footer.new("End of page", frame: Tablo::Frame.new),
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "") { |n| n * 2 }
  t.add_group("")
  t.add_column(:column_3, header: "") { |n| n.even?.to_s }
  t.add_group("Text", alignment: Tablo::Justify::Left)
end

puts table
