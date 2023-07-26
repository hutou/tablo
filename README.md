## History
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

## Features

- Presents a DRY API that is column-based, not row-based, meaning header and body rows are automatically in sync
- Lets you set fixed column widths, then either wrap or truncate the overflow
- Alternatively, “pack” the table so that columns are auto-sized to their contents
- Cell alignment is configurable, but has helpful content-based defaults (numbers right, strings left)
- Tabulate any Enumerable: the underlying collection need not be an array
- Step through your table a row at a time, printing as you go, without waiting for the underlying collection to load. In other words, have a streaming interface for free.
- Add optional title, subtitle and footer to your table
- The header row can be repeated at arbitrary intervals
- Newlines within cell content are correctly handled
- Multibyte Unicode characters are correctly handled (needs the "uniwidth" library)
- Option to preserve whole words when wrapping content
- Apply colors and other styling to table content and borders, without breaking the table
- Easily transpose the table, so that rows are swapped with columns
- Choose from several border configurations, including predefined ones such as Markdown, Ascii (default), and user-defined ones.
- Adjacent columns can be capped by a group header
- A summary table can be added to apply user-defined functions to numeric values of a column

## Overview

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
## API

### Table

To create a table, the only parameter required is the Enumerable data source, all other *named* parameters have default values.

for example :
```crystal
require "tablo"
data = [
{name: "Enrique", age: 33}
{name: "Edward", age: 44}
]
table = Tablo:Table.new(data) do |t|
t.add_column("Name") {|n| n.name}
t.add_column("Age") {|n| n.age}



