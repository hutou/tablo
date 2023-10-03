require "uniwidth"
require "tablo"
require "colorize"
require "debug"

# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Rune
# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Word

# # body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
# header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_magenta).to_s },

# table = Tablo::Table.new([1, "abc", 2, 3, 4, "つのだ☆HIRO", 5, 37],
# table = Tablo::Table.new([1, "abc", 2, 3, 4, 5, 37],
table = Tablo::Table.new((1..9).to_a,
  # table = Tablo::Table.new([1, "abc", 2, 3, 4, "plusieurs mots", 5, 37],
  header_frequency: 5,
  row_divider_frequency: nil,
  title: Tablo::Title.new("\nDetail\n", repeated: true),
  subtitle: Tablo::SubTitle.new("Detail subtitle", frame: Tablo::Frame.new),
  # footer: Tablo::Footer.new("This is my footer\nPage <%d>", framed: true,
  #   spacing_after: nil,
  #   page_break: false),
  # masked_headers: true,
  # border_type: "╭┬╮├┼┤╰┴╯│:│TGHBM",
  border_type: Tablo::BorderName::Fancy,
  # border_type: Tablo::BorderName::Ascii,
  # border_type: "+++++++++|:|=---",
  # border_type: "/x\\!x!\\x/!:!=~-.",
  # border_type: Tablo::BorderName::ReducedAscii,
  # border_type: Tablo::BorderName::Modern,
  # border_type: Tablo::BorderName::ReducedModern,
  # border_type: Tablo::BorderName::Classic, # Error
  # border_type: Tablo::BorderName::Markdown,
  # border_type: Tablo::BorderName::Blank,
  wrap_mode: Tablo::WrapMode::Word,
  omit_last_rule: false,
  body_wrap: 3
) do |t|
  t.add_column("A", header: "itself", width: 13, &.itself)
  t.add_column("B", header: "double",
    body_alignment: Tablo::Justify::Center,
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    width: 5,
    &.*(2))
  t.add_column("C", header: "triple", &.*(3))
  # t.add_group("My group")
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  # t.summary(summary_def, **summary_table)
end

# p! typeof(summary_def)
# p! typeof(summary_table)

# puts table.autosize_columns(nil)
# puts table.pack(56)
# puts table.pack(-76)
# puts table.autosize_columns(nil)
# puts table.pack
# puts table.pack(56)

# puts table.pack(-45)
# puts table.autosize_columns(nil)
puts "-----------------------------------------------------------"
puts "puts table"
puts table
puts table.total_table_width
puts ""
puts "-----------------------------------------------------------"
puts "puts table.pack"
puts table.pack
puts table.total_table_width
puts ""
puts "-----------------------------------------------------------"
puts "puts table.pack(50)"
puts table.pack(50)
puts table.total_table_width
puts ""
puts "-----------------------------------------------------------"

# puts table.pack(init: Tablo::PackInit::Reset)
# puts table
# Summary_Def and Summary_Table are constants
table.summary({
  "A" => {
    header:           "Sum",
    header_formatter: ->(c : Tablo::CellType) { c.to_s.downcase },
    body_styler:      ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
    proc:             ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
  },
  "B" => {
    header:      "Somme",
    body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:blue).to_s },
    proc:        ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
  },
  "C" => {
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_red).to_s },
    body_styler:   ->(c : Tablo::CellType, r : Tablo::CellData, s : String, l : Int32) {
      r.row_index == 1 ? s.colorize(:blue).to_s : s.colorize(:light_red).to_s
    },
    proc1:          ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
    proc2:          ->(ary : Tablo::NumCol) { ar = ary.compact; ar.size > 0 ? (ar.sum/ar.size).to_s : "NA" },
    body_alignment: Tablo::Justify::Left,
  },
  "D" => {
    body_alignment: Tablo::Justify::Left,
    proc1:          ->(ary : Tablo::NumCol) { "<-- Somme" },
    proc2:          ->(ary : Tablo::NumCol) { "<-- Moyenne" },
  },

},
  title: Tablo::Title.new(" ", frame: Tablo::Frame.new(0, 1)),
  # title: Tablo::Heading.new("Récap !", bordered: true, detached: false),
  # subtitle: Tablo::Heading.new("sub Récap !", detached: true),
  masked_headers: false,
  header_frequency: 0,
  body_alignment: Tablo::Justify::Center,
  row_divider_frequency: 1,
  # border_type: Tablo::BorderName::Ascii,
  header_formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
  header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
  body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
)
puts table.summary
exit 0
# puts table
# puts "\n-=-=-=-=\n\n"
# puts table.summary(Summary_Def, Summary_Table)

# puts "\n\nyes !!!!!!"

# puts table.summary

# puts tb
# puts table.shrink_to(27)
# puts table.expand_to(56, nil)
# puts table.pack(Tablo::GetWidthFrom::Screen)
p! typeof({
  1 => {
    header: "Somme",
    # header: "",
    header_formatter: ->(c : Tablo::CellType) { c.to_s.downcase },
    body_styler:      ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
    proc:             ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
  },
  "B" => {
    header:      "Somme",
    body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:blue).to_s },
    proc:        ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
  },
  "C" => {
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_red).to_s },
    body_styler:   ->(c : Tablo::CellType, r : Tablo::CellData, s : String, l : Int32) {
      r.row_index == 1 ? s.colorize(:blue).to_s : s.colorize(:light_red).to_s
    },
    proc1:          ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
    proc2:          ->(ary : Tablo::NumCol) { ar = ary.compact; ar.size > 0 ? (ar.sum/ar.size).to_s : "NA" },
    body_alignment: Tablo::Justify::Left,
  },
  "D" => {
    body_alignment: Tablo::Justify::Left,
    proc1:          ->(ary : Tablo::NumCol) { "<-- Somme" },
    proc2:          ->(ary : Tablo::NumCol) { "<-- Moyenne" },
  },
})
exit

print "\n---------\n\n"

# table.each_with_index do |row, index|
#   position = index == 0 ? Tablo::Position::BodyTop : Tablo::Position::BodyBody
#   puts table.horizontal_rule(position)
#   puts table.rendered_body_row(row.source, index)
# puts row.body
# end
# puts table.horizontal_rule(Tablo::Position::BodyBottom)

print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_group_row
# end
# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_header_row(row.source, index)
#   # puts row.header
# end
