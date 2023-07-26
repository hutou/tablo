
## Overview

Tablo is a port of [Matt Harvey's
Tabulo](https://github.com/matt-harvey/tabulo) Ruby gem to the Crystal
Language.

The first version of Tablo (v0.10.1) was released on November 30, 2021,
in the context of learning the Crystal language, which explains its
relative limitations compared to Tabulo v2.7, the current version
at that time, subject of the software port.

So this version of Tablo (v1.0) is a complete rewrite of the library.

Compared to the first version, it offers extended capabilities,
sometimes at the cost of a modified syntax. It also offers new features,
such as the ability to add a Summary table, powered by user-defined
functions (such as sum, mean, etc.), the ability to process any
Enumerable data, as well as elaborate layout possibilities: grouped
columns, different types of headers (title, subtitle, footer), linked or
detached border lines, etc.

While overall, Tablo remains, in terms of its functionalities, broadly
comparable, with a few exceptions, to the Tabulo v3.0 version of Matt
Harvey, the source code, meanwhile, has been deeply redesigned.

To give you a taste of both the richness of the layout and the code that implements it, here's an example that's somewhat contrived, but interesting to study. 

<img src="docs/assets/images/overview.svg" width="400">

```crystal
require "colorize"
require "tablo"

Tablo::Config.styler_tty_only = false

table = Tablo::Table.new([1, 2, 3, 4, 5],
  border_type: Tablo::BorderName::Fancy,
  title: Tablo::HeadingFramed.new("\na\nstretched\nand\ncolored\nmultiline\ntitle\n\n",
    spacing_after: 1,
    formatter: ->(c : Tablo::CellType, column_width : Int32) {
      Tablo::Util.stretch(c.to_s.titleize, width: column_width, insert_char: ' ', gap: 2, margin: 4)
    },
    styler: ->(s : String, line : Int32) {
      if line == 4
        str = String.build do |str|
          s.each_char do |c|
            if c.ascii_whitespace?
              str << c
            else
              str << c.colorize([:blue, :red, :green, :yellow, :magenta, :cyan][rand(0..5)]).to_s
            end
          end
        end
        str.to_s
      else
        s
      end
    }),
  subtitle: Tablo::HeadingFramed.new("\nSubtitle\n",
    spacing_before: 2,
  ),
  footer: Tablo::HeadingFramed.new("Footer"),
  header_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
    s.colorize(:magenta).to_s
  },
  body_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
    if r.column_index == 3 && c.is_a?(Float) && c >= 0.8
      s.colorize.fore(:red).mode(:bold).to_s
    elsif r.row_index % 2 == 0
      s.colorize(:light_gray).to_s
    else
      s
    end
  },
  row_divider_frequency: 2,
  omit_last_rule: true) do |t|
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
        header_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
          s.colorize(:cyan).to_s
        },
        body_styler: ->(c : Tablo::CellType, s : String, r : Tablo::CellData) {
          s.colorize(:blue).to_s
        },
  },
},
  title: Tablo::HeadingFramed.new("Summary")
)
puts "--- Table Overview ---".center(table.total_table_width)
```

