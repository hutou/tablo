require "uniwidth"
require "tablo"
require "colorize"
require "debug"

# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Rune
# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Word

# # body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
# header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_magenta).to_s },

# table = Tablo::Table.new([1, "abc", 2, 3, 4, "つのだ☆HIRO", 5, 37],
table = Tablo::Table.new([1, 2, 3],
  header_frequency: 5,
  row_divider_frequency: 1,
  title: Tablo::Title.new("Detail", repeated: true),
  subtitle: Tablo::SubTitle.new("Detail subtitle"),
  footer: Tablo::Footer.new("This is my footer\nPage <%d>"),

  # border_type: "╭┬╮├┼┤╰┴╯│:│TGHBM",
  border_type: Tablo::BorderName::Fancy,
  # border_type: Tablo::BorderName::Ascii,
  # border_type: "+++++++++|:|=---",
  # border_type: "/x\\!x!\\x/!:!=~-.",
  # border_type: Tablo::BorderName::Ascii,
  # border_type: Tablo::BorderName::Modern,
  # border_type: Tablo::BorderName::ReducedModern,
  # border_type: Tablo::BorderName::Classic, # Error
  # border_type: Tablo::BorderName::Markdown,
  # border_type: Tablo::BorderName::Blank,
  wrap_mode: Tablo::WrapMode::Word,
  body_wrap: 3
) do |t|
  t.add_column("A", header: "itself", width: 13, &.itself)
  t.add_column("B", header: "double",
    body_alignment: Tablo::Justify::Center,
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    &.*(2))
  t.add_column("C", header: "triple", &.*(3))
  t.add_group("My group")
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  t.summary({
    "A" => {
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
      body_alignment: Tablo::Justify::Left,
      header_styler:  ->(c : Tablo::CellType, s : String) { s.colorize(:light_red).to_s },
      body_styler:    ->(c : Tablo::CellType, r : Tablo::CellData, s : String, l : Int32) {
        r.row_index == 1 ? s.colorize(:blue).to_s : s.colorize(:light_red).to_s
      },
      proc1: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
      proc2: ->(ary : Tablo::NumCol) { ar = ary.compact; ar.size > 0 ? (ar.sum/ar.size).to_s : "NA" },
    },
    "D" => {
      body_alignment: Tablo::Justify::Left,
      proc1:          ->(ary : Tablo::NumCol) { "<-- Somme" },
      proc2:          ->(ary : Tablo::NumCol) { "<-- Moyenne" },
    },
  },
    title: Tablo::Title.new("Summary"),
    # title: nil,
    header_frequency: 0,
    body_alignment: Tablo::Justify::Center,
    row_divider_frequency: 1,
    # border_typeTablo::BorderName::Ascii,
    header_formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
    body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s }
  )
end

# puts table
# puts table.pack(33)

# print "\n---------\n\n"
# puts table.pack(77)

print "\n--- Detail ---\n\n"
puts table
print "\n--- Summary ---\n\n"
puts table.summary

exit

print "\n---------\n\n"

# table.each_with_index do |row, index|
#   position = index == 0 ? Tablo::Position::BodyTop : Tablo::Position::BodyBody
#   puts table.horizontal_rule(position)
#   puts table.rendered_body_row(row.source, index)
#   # puts row.body
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
