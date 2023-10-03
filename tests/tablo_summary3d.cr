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
table = Tablo::Table.new((1..7).to_a,
  # table = Tablo::Table.new([1, "abc", 2, 3, 4, "plusieurs mots", 5, 37],
  header_frequency: 30,
  omit_last_rule: true,
  row_divider_frequency: nil,
  title: Tablo::Title.new("\nDetail\n", frame: Tablo::Frame.new, repeated: true),
  # masked_headers: true,
  subtitle: Tablo::SubTitle.new("Detail subtitle"),
  # subtitle: nil,
  #  footer: "This is my footer\nPage <%d>",
  #  footer_has_border: true,
  #  footer_has_page_break: true,

  # border_type: "╭┬╮├┼┤╰┴╯│:│TGHBM",
  # border_type: Tablo::BorderName::Fancy,
  # border_type: Tablo::BorderName::Blank,

  # border_type: "E EEEEEEE   ----",
  # border_type: " -  -  -    ----",
  border_type: "E  E  E     ----",
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
  body_wrap: 3
) do |t|
  t.add_column("A", header: "itself", width: 13, &.itself)
  t.add_column("B", header: "double",
    # align_body: Tablo::Justify::Center,
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    &.*(2))
  t.add_column("C", header: "triple", &.*(3))
  t.add_group("My group 1")
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  t.add_group("My group 2")
end

# puts table.autosize_columns(nil)
# puts table.pack(56)
# puts table.pack(-76)
# puts table.autosize_columns(nil)
# puts table.pack
# puts table.pack(56)

# puts table.pack(-45)
# puts table.autosize_columns(nil)
puts table.pack(nil)

puts table.summary({

  # "A" => [{header: "Somme",
  #          align_body: Tablo::Justify::Right,
  #          proc: ->(ary : Tablo::NumCol) { "Total:" }}],
  "B" => {header: "Somme",
          body_formatter: ->(c : Tablo::CellType) { "Total: %d" % c },
          proc: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
  },
},
  # title: "Récap !",
  title: Tablo::Title.new(nil),
  # title_detached: true,
  masked_headers: true,
  omit_last_rule: true,
  # header_frequency: 0,
  # border_type: "                ",
  # border_type: Tablo::BorderName::Blank,
  # border_type: "EEEEEEEEE   EEEE",
  # align_body: Tablo::Justify::Center,
  # row_divider_frequency: 1,
  # border_type: Tablo::BorderName::Ascii,
  border_type: "E  E  E     ----",
  # border_type: Tablo::BorderName::Fancy,
  body_formatter: ->(c : Tablo::CellType) { "#{c.to_s}" },
  # header_formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
  # header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
  body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s }
)
# puts table.shrink_to(27)
# puts table.expand_to(56, nil)
# puts table.pack(Tablo::GetWidthFrom::Screen)
exit

# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   position = index == 0 ? Tablo::Position::BodyTop : Tablo::Position::BodyBody
#   puts table.horizontal_rule(position)
#   puts table.rendered_body_row(row.source, index)
#   # puts row.body
# end
# puts table.horizontal_rule(Tablo::Position::BodyBottom)

# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_group_row
# end
# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_header_row(row.source, index)
#   # puts row.header
# end
