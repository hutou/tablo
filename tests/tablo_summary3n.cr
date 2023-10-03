require "uniwidth"
require "tablo"
require "colorize"
require "debug"
# require "big"

# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Rune
# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Word

# # body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
# header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_magenta).to_s },

# table = Tablo::Table.new([1, "abc", 2, 3, 4, "つのだ☆HIRO", 5, 37],

data = [1, 2, 3, 4, 5, nil, 7]
table = Tablo::Table.new(data,
  # table = Tablo::Table.new(1..7,
  # table = Tablo::Table.new([1, "abc", 2, 3, 4, "plusieurs mots", 5, 37],
  header_frequency: 30,
  row_divider_frequency: nil,
  title: Tablo::Title.new("\nDetail\n", frame: Tablo::Frame.new, repeated: true),
  # masked_headers: true,
  subtitle: Tablo::SubTitle.new("Detail subtitle"),
  border_type: "E  E  E     ----",
  wrap_mode: Tablo::WrapMode::Word,
  body_wrap: 3
) do |t|
  t.add_column("A", header: "itself",
    body_formatter: ->(c : Tablo::CellType) { c.nil? ? "N/A" : c.to_s },
    # body_formatter: ->(c : Tablo::CellType) { c.nil? ? "N/A" : c.to_s },
    width: 6,
    &.itself)
  t.add_column("B", header: "double",
    # align_body: Tablo::Justify::Center,
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    width: 18,
    &.itself.try &.*(2))
  t.add_column("C", header: "triple", width: 9, &.itself.try &.*(3))
  t.add_group("My group 1")
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  t.add_group("My group 2")
  t.summary({
    "A" => {header: "Somme",
            body_alignment: Tablo::Justify::Right,
            proc1: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
            # proc: ->(ary : Tablo::NumCol) { "Summary:" }
    },
    "B" => {header: "Somme",
            body_formatter: ->(c : Tablo::CellType, cd : Tablo::CellData) {
              if c.nil?
                ""
              elsif cd.row_index == 0
                "Total: %d" % c
              else
                "Moyenne: %d" % c
              end
            },
            proc1: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
            proc2: ->(ary : Tablo::NumCol) { ary.size }},
    "C" => {header: "Somme",
    # body_formatter: ->(c : Tablo::CellType) { c == "" ? "" : "Total: %d" % c },
            body_formatter: ->(c : Tablo::CellType) { c.nil? ? "" : "Total: %d" % c },
            proc: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i }},
  },
    **{
      # title:          Tablo::Heading.new(nil),
      masked_headers: true,
      border_type:    "E  E  E     E---",
      # body_formatter: ->(c : Tablo::CellType) { "#{c.to_s}" },
      # body_styler:    ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
    })
end
puts table
# puts table.autosize_columns(nil)
# puts table.pack(56)
# puts table.pack(-76)
# puts table.autosize_columns(nil)
# puts table.pack
# puts table.pack(56)

# puts table.pack(-45)
# puts table.autosize_columns(nil)
puts table.pack
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
