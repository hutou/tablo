require "uniwidth"
require "tablo"
require "colorize"
require "debug"

Tablo::Config.styler_tty_only = true

detached = false
bordered = true
page_break = true
header_frequency = 0

[false, true].each do |framed|
  [false, true].each do |page_break|
    [0, 3].each do |header_frequency|
      table = Tablo::Table.new((1..7).to_a,
        header_frequency: header_frequency,
        row_divider_frequency: nil,
        title: Tablo::Title.new("\nDetail\n"),
        # masked_headers: true,
        subtitle: Tablo::SubTitle.new("Detail subtitle"),
        footer: Tablo::Footer.new(
          "My footer <%d>\n" +
          "framed: #{framed}, " +
          " page_break: #{page_break}, header_frequency: #{header_frequency}", page_break: page_break),
        border_type: Tablo::BorderName::Fancy,
        wrap_mode: Tablo::WrapMode::Word,
        body_wrap: 3,
      ) do |t|
        t.add_column("A", header: "itself", width: 13, &.itself)
        t.add_column("B", header: "double",
          # align_body: Tablo::Justify::Center,
          header_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:light_blue).to_s },
          header_alignment: Tablo::Justify::Center,
          &.*(2))
        t.add_column("C", header: "triple", &.*(3))
        # t.add_group("My group 1")
        t.add_column("D", header: "Alpha", width: 16) { |n| (n.to_s + " ") * 7 }
        # t.add_group("My group 2")
        t.summary({
          "B" => {header: "Somme",
                  body_formatter: ->(c : Tablo::CellType) { "Total: %d" % c },
                  proc: ->(ary : Tablo::NumCol) { ary.compact.sum.to_i }},
        },
          title: Tablo::Title.new("Summary"),
          body_formatter: ->(c : Tablo::CellType) { "#{c.to_s}" },
          body_styler: ->(c : Tablo::CellType, s : String) { s.colorize(:green).to_s }
        )
      end

      puts table.pack
      puts "\n-=-=-=-=-=-=-\n"
    end
  end
end

# puts table.autosize_columns(nil)
# puts table.pack(56)
# puts table.pack(-76)
# puts table.autosize_columns(nil)
# puts table.pack
# puts table.pack(56)

# puts table.pack(-45)
# puts table.autosize_columns(nil)
# puts table.shrink_to(27)
# puts table.expand_to(56, nil)
# puts table.pack(Tablo::GetWidthFrom::Screen)
# exit

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
