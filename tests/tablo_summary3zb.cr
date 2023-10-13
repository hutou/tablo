require "uniwidth"
require "tablo"
require "colorize"
require "debug"

# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Rune
# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Word

# # body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
# header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_magenta).to_s },

table = Tablo::Table.new([1, "abc", 2, 3, 4, "つのだ☆HIRO", 5, 37],
  header_frequency: 0,
  row_divider_frequency: 1,
  title: Tablo::Title.new("Detail", frame: Tablo::Frame.new, repeated: true),
  subtitle: Tablo::SubTitle.new("Detail subtitle"),
  # footer: Tablo::Footer.new("My beautiful footer", frame: Tablo::Frame.new(0, 1), page_break: true),
  footer: Tablo::Footer.new("My beautiful footer", frame: Tablo::Frame.new(0, 1), page_break: true),
  #   bordered: true, detached: false, page_break: true),
  # border_type: "╭┬╮├┼┤╰┴╯│:│TGHBM",
  # border: Tablo::Border.new(Tablo::BorderName::Fancy),
  border: Tablo::Border.new(:fancy, styler: ->(s : String) { s.colorize(:yellow).to_s }),
  group_formatter: ->(c : Tablo::CellType) { c.as(String).downcase },
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
  omit_last_rule: true,
  body_wrap: 3
) do |t|
  t.add_column("A", header: "itself", width: 13, &.itself)
  t.add_column("B", header: "double",
    body_alignment: Tablo::Justify::Center,
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    &.*(2))
  t.add_column("C", header: "triple", &.*(3))
  t.add_group("My group", formatter: ->(c : Tablo::CellType) { c.as(String).upcase })
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  t.add_group("ZORRO", formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String).downcase, 9, '-') })
end

ts = table.summary({
  "A" => {
    header:           "Somme\nMoyenne\nCount",
    header_formatter: ->(c : Tablo::CellType) { c.to_s.capitalize },
    body_formatter:   ->(c : Tablo::CellType, r : Tablo::CellData) { c.nil? ? "N/A" : r.row_index == 2 ? "%d" % c : "%.2f" % c },
    body_styler:      ->(c : Tablo::CellType, r : Tablo::CellData, s : String) {
      color = [:blue, :red, :yellow][r.row_index]?
      color.nil? ? s : s.colorize(color).to_s
    },
    body_alignment: Tablo::Justify::Right,
    proc:           [
      {1, ->(ary : Array(Tablo::CellType)) { (ary.select(&.is_a?(Number))
        .map &.as(Number)).sum.as(Tablo::CellType) }},
      {2, ->(ary : Array(Tablo::CellType)) {
        ar = ary.select(&.is_a?(Number)).map &.as(Number)
        (ar.size > 0 ? ar.sum / ar.size : "ND").as(Tablo::CellType)
      }},
      {3, ->(ary : Array(Tablo::CellType)) { (ary.select(&.is_a?(Number))
        .map &.as(Number)).size.as(Tablo::CellType) }},
    ],
  },
  "B" => {header: "Somme",
          body_styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:blue).to_s },
          proc: [
            {1, ->(ary : Array(Tablo::CellType)) { (ary.select(&.is_a?(Number))
              .map &.as(Number)).sum.to_i.as(Tablo::CellType) }},
          ],
  },
  # "C" => [
  #   {proc: ->(ary : Tablo::NumCol) { ary.sum.to_i }},
  #   {header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_red).to_s }},
  #   {body_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData, l : Int32) {
  #     r.row_index == 1 ? s.colorize(:blue).to_s : s.colorize(:light_red).to_s
  #   }},
  #   {proc: ->(ary : Tablo::NumCol) { ary.size > 0 ? (ary.sum/ary.size).to_s : "NA" }},
  #   {body_alignment: Tablo::Justify::Left},
  # ],
  "C" => {
    header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_red).to_s },
    body_styler:   ->(c : Tablo::CellType, r : Tablo::CellData, s : String, l : Int32) {
      r.row_index == 1 ? s.colorize(:blue).to_s : s.colorize(:light_red).to_s
    },
    body_formatter: ->(c : Tablo::CellType, r : Tablo::CellData) {
      case r.row_index
      when 0 then "%d" % c
      when 1 then c.nil? ? "N/A" : "%.2f" % c
      else        ""
      end
    },
    body_alignment: Tablo::Justify::Left,
    proc:           [
      {1, ->(ary : Array(Tablo::CellType)) { (ary.select(&.is_a?(Number))
        .map &.as(Number)).sum.to_i.as(Tablo::CellType) }},
      {2, ->(ary : Array(Tablo::CellType)) { ar = ary.select(&.is_a?(Number))
        .map &.as(Number)
      (ar.size > 0 ? ar.sum / ar.size : "ND").as(Tablo::CellType) }},
    ],
  },
  "D" => {
    body_alignment: Tablo::Justify::Left,
    proc:           [
      {1, ->(ary : Array(Tablo::CellType)) { "<-- Somme".as(Tablo::CellType) }},
      {2, ->(ary : Array(Tablo::CellType)) { "<-- Moyenne".as(Tablo::CellType) }},
    ],
  },
},
  subtitle: Tablo::SubTitle.new("Sub Summary", frame: Tablo::Frame.new),
  title: Tablo::Title.new("Summary", frame: Tablo::Frame.new),
  header_frequency: 0,
  omit_last_rule: false,
  body_alignment: Tablo::Justify::Center,
  row_divider_frequency: 1,
  # masked_headers: true,
  # border_type: Tablo::BorderName::Ascii,
  header_formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
  header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
  body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s }
)

puts table
puts table.summary
puts table.transpose
puts table.summary.as(Tablo::Table(Array(Tablo::CellType))).transpose
exit

# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   position = index == 0 ? Tablo::Position::BodyTop : Tablo::Position::BodyBody
#   puts table.horizontal_rule(position)
#   puts table.rendered_body_row(row.source, index)
# end
# puts table.horizontal_rule(Tablo::Position::BodyBottom)

# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_group_row
# end
# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_header_row(row.source, index)
# end
