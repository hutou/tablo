require "uniwidth"
require "tablo"
require "colorize"
require "debug"

# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Rune
# Tablo::Config.default_wrap_mode = Tablo::WrapMode::Word

# # body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s },
# header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_magenta).to_s },

# table = Tablo::Table.new([1, "abc", 2, 3, 4, "つのだ☆HIRO", 5, 37],
table = Tablo::Table.new([1, "abc", 2, 3, 4, "Crystal language is the best!", 5, 37],
  header_frequency: 0,
  row_divider_frequency: nil,
  title: Tablo::Title.new("\n\n", frame: Tablo::Frame.new, repeated: true),
  subtitle: Tablo::SubTitle.new("Detail subtitle"),
  footer: Tablo::Footer.new("My beautiful footer - Page <%d>", frame: Tablo::Frame.new, page_break: true),
  # border_type: "╭┬╮├┼┤╰┴╯│:│TGHBM",
  border_type: Tablo::BorderName::Fancy,
  # border_type: Tablo::BorderName::ReducedAscii,
  # border_type: "+++++++++|:|=---",
  # border_type: "/x\\!x!\\x/!:!=~-.",
  # border_type: Tablo::BorderName::Ascii,
  # border_type: Tablo::BorderName::Modern,
  # border_type: Tablo::BorderName::ReducedModern,
  # border_type: Tablo::BorderName::Classic, # Error
  # border_type: Tablo::BorderName::Markdown,
  # border_type: Tablo::BorderName::Blank,
  wrap_mode: Tablo::WrapMode::Word,
  body_wrap: 2_u8
) do |t|
  t.add_column("A", header: "itself", width: 13, &.itself)
  t.add_column("B", header: "double",
    body_alignment: Tablo::Justify::Center,
    header_styler: ->(_value : Tablo::CellType, content : String) { content.colorize(:light_blue).to_s },
    header_alignment: Tablo::Justify::Center,
    &.*(2))
  t.add_column("C", header: "triple", &.*(3))
  t.add_group("My group")
  t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
  t.summary({
    "A" => {
      header:           "Somme\nMoyenne\nCount",
      header_formatter: ->(value : Tablo::CellType) { value.as(String).capitalize },
      # body_formatter:   ->(c : Tablo::CellType, r : Tablo::CellData) { c.nil? ? "N/A" : (r.row_index == 2 ? "%d" % c : "%.2f" % c) },
      body_formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
        if value.nil?
          "N/A"
        else
          if cell_data.row_index == 2
            "%d" % value.as(Int)
          else
            "%.2f" % value.as(Float)
          end
        end
      },
      body_styler: ->(_value : Tablo::CellType, cell_data : Tablo::CellData, content : String) {
        color = [:blue, :red, :yellow][cell_data.row_index]?
        color.nil? ? content : content.colorize(color).to_s
      },
      body_alignment: Tablo::Justify::Right,
      body_1:         ->(ary : Tablo::NumCol) { ary.compact.sum },
      body_2:         ->(ary : Tablo::NumCol) { ary.compact.sum / ary.size },
      body_3:         ->(ary : Tablo::NumCol) { ary.size },
    },
    "B" => {header: "Somme",
            body_styler: ->(_value : Tablo::CellType, content : String) { content.colorize(:blue).to_s },
            proc: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
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
      header_styler: ->(_value : Tablo::CellType, content : String) { content.colorize(:light_red).to_s },
      body_styler:   ->(_value : Tablo::CellType, cell_data : Tablo::CellData, content : String) {
        cell_data.row_index == 1 ? content.colorize(:blue).to_s : content.colorize(:light_red).to_s
      },
      body_formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
        case cell_data.row_index
        # when 0 then "%d" % value.as(Int)
        when 0 then value.nil? ? "N/A" : "%d" % value.as(Int)
        when 1 then value.nil? ? "N/A" : "%.2f" % value.as(Float)
        else        ""
        end
      },
      body_alignment: Tablo::Justify::Left,
      proc1:          ->(ary : Tablo::NumCol) { ary.compact.sum.to_i },
      proc2:          ->(ary : Tablo::NumCol) { ary.compact.size > 0 ? (ary.compact.sum/ary.compact.size).to_s : "NA" },
    },
    "D" => {
      body_alignment: Tablo::Justify::Left,
      proc1:          ->(_ary : Tablo::NumCol) { "<-- Somme" },
      proc2:          ->(_ary : Tablo::NumCol) { "<-- Moyenne" },

    },
  },
    title: Tablo::Title.new("\n\n\n", frame: Tablo::Frame.new),
    header_frequency: nil,
    body_alignment: Tablo::Justify::Center,
    row_divider_frequency: 1,
    # masked_headers: true,
    # border_type: Tablo::BorderName::Ascii,
    header_formatter: ->(value : Tablo::CellType) { value.as(String).upcase },
    header_styler: ->(_value : Tablo::CellType, content : String) { content.colorize(:yellow).to_s },
    body_styler: ->(_value : Tablo::CellType, content : String) { content.colorize(:green).to_s }
  )
end

puts table
puts table.pack(30)
exit

ar = [] of Int32 | String
ar << 1 << 2 << 3 << 4 << 5 << 6 << 7 << 8 << 9
table.reset_sources(to: ar)

puts table
exit

print "\n---------\n\n"

table.each do |row|
  puts row
end

# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   position = index == 0 ? Tablo::Position::BodyTop : Tablo::Position::BodyBody
#   puts table.horizontal_rule(position)
#   puts table.rendered_body_row(row.source, index)
# end
# puts table.horizontal_rule(Tablo::Position::BodyBottom)

# print "\n---------\n\n"

# table.each_with_index do |_row, _index|
#   puts table.rendered_group_row
# end
# print "\n---------\n\n"

# table.each_with_index do |row, index|
#   puts table.rendered_header_row(row.source, index)
# end
