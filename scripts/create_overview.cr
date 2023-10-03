require "colorize"
require "tablo"
require "debug"

Tablo::Config.styler_tty_only = false

table = Tablo::Table.new([1, 2, 3, 4, 5],
  border_type: Tablo::BorderName::Fancy,
  border_styler: ->(s : String) { s.colorize(:dark_gray).to_s },
  title: Tablo::HeadingFramed.new("\na\nstretched\nand\ncolored\nmultiline\ntitle\n\n",
    spacing_after: 1,
    formatter: ->(c : Tablo::CellType, column_width : Int32) {
      Tablo::Util.stretch(c.to_s.titleize, width: column_width,
        insert_char: ' ', gap: 2, margin: 4)
    },
    styler: ->(s : String, line : Int32) {
      if line == 4
        colors = [:blue, :red, :green, :yellow, :magenta, :cyan]
        str = String.build do |str|
          s.each_char do |c|
            str << c.colorize(colors[rand(0..5)]).to_s
          end
        end
        str.to_s
      else
        s
      end
    }
  ),
  subtitle: Tablo::HeadingFree.new("\nSubtitle\n",
    styler: ->(s : String) { s.colorize.fore(:cyan).mode(:bold).underline.to_s },
    # spacing_before: 2,
  ),
  footer: Tablo::HeadingFramed.new("Footer"),
  header_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
    s.colorize(:magenta).to_s
  },
  body_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
    if r.column_index == 3 && c.is_a?(Float) && c == 0.8
      s.colorize.fore(:red).mode(:bold).to_s
    elsif r.row_index % 2 == 0
      s.colorize(:light_gray).to_s
    else
      s
    end
  },
  row_divider_frequency: 2,
  omit_last_rule: true
) do |t|
  t.add_column("row#") { |n, i| i }
  t.add_group("")
  t.add_column("col1", &.itself)
  t.add_column(2, header: "col2\nDouble", &.*(2))
  t.add_column("col3\n1/5", &./(5))
  t.add_group("group1")
  t.add_column("col4\nto_s", &.to_s)
  t.add_column("col5\neven?", &.even?)
  t.add_group("group2")
end

puts table.pack
puts table.summary({
  2 => {header: "Sum\nAvg",

        proc1: ->(ary : Tablo::Numbers) { ary.sum.to_i },
        proc2: ->(ary : Tablo::Numbers) { (ary.sum / ary.size).to_i },
        header_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData, line : Int32) {
          if line == 0
            s.colorize(:cyan).to_s
          else
            s.colorize(:red).to_s
          end
        },
        body_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
          if r.row_index == 0
            s.colorize(:cyan).to_s
          else
            s.colorize(:yellow).to_s
          end
        },
  },
},
  title: Tablo::HeadingFramed.new("Summary")
)

# legend = "--- Table Overview ---".center(table.total_table_width)
# puts "\e[3m#{legend}\e[0m"
