# Tablo

[![Build Status](https://travis-ci.org/hutou/tablo.svg?branch=master)](https://travis-ci.org/hutou/tablo)

Tablo generates formatted text tables from 2D arrays\*.

Tablo is a port of [Matt Harvey's
Tabulo](https://github.com/matt-harvey/tabulo) Ruby gem to the Crystal
Language. Most Tabulo features are available, as a significant part of the Ruby
source code has been merely copied, with almost no modification.

However, some substantial modifications and additions were required to meet
Crystal's strict typing rules, especially for conversion of input data to the
internal data structure. Indeed, where Tabulo accepts any type of Enumerable
data, **Tablo only accepts a 2D array as argument**, further converted to Tablo::DataType,
a 2D array of CellType, the elementary data type union Tablo works on, before
processing.

Finally, new features have been added with respect to formatting: UTF characters, preset or
at the user's choice, for drawing borders, and optional row or column
separators

\* _Here, 2D is used as a writing simplification for "array of scalar data arrays" defining a rectangular matrix_

## Main features

Most features of Tabulo are found in Tablo

- Automatic layout from colums definitions
- Set fixed column widths, then either wrap or truncate the overflow.
- Alternatively, shrinkwrap the table so that each column is just wide enough for its contents.
- Put an upper limit on total table width when shrinkwrapping, to stop it overflowing your terminal horizontally.
- Put a lower limit on total table width when shrinkwrapping, to keep table
  width from being too small.
- Alignment of cell content is configurable, but has helpful content-based defaults (numbers right, strings left).
- Headers are repeatable.
- Newlines within cell content are correctly handled.
- A Table is an Enumerable, so you can step through it a row at a time, printing as you go, without waiting for the entire underlying collection to load.
- Each Row is also an Enumerable, providing access to the underlying cell values, before formatting.
- Release 0.10 : styler added feature (colors)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tablo:
    github: hutou/tablo
```

## Usage

```crystal
require "tablo"
```

### Example data set

Most of the examples below are built upon the following 2D array, excerpt
from my imagination !

```text
    data = [
    # Name         kind     Sex      Age     Weight       Initial     Annual
    #                            (years)       (Kg)          cost   expenses
    ["Charlie",   "Dog",   'M',        7,      37.4,       420.50,       695],
    ["Max",       "Cat",   'M',       12,       4.2,       575.32,       790],
    ["Simba",     "Cat",   'M',        5,       3.8,       498.70,       720],
    ["Coco",      "Dog",   'F',        8,      13.9,       276.36,       632],
    ["Ruby",      "Dog",   'F',        6,      15.7,       320.95,       543],
    ]
```

### Tutorial

As a first step towards using Tablo, let's define a basic set of statements for displaying
each element of the data array.

```crystal
12: table = Tablo::Table.new(data) do |t|
13:   t.add_column("Name") { |n| n[0] }
14:   t.add_column("Kind") { |n| n[1] }
15:   t.add_column("Sex") { |n| n[2] }
16:   t.add_column("Age") { |n| n[3] }
17:   t.add_column("Weight") { |n| n[4] }
18:   t.add_column("Initial\ncost") { |n| n[5] }
19:   t.add_column("Average\nannual\nexpenses") { |n| n[6] }
20: end
21: puts table
```

_Numbered lines extracted from examples/readme1.cr_

```text
+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
| Name         | Kind         | Sex          |          Age |       Weight |      Initial |      Average |
|              |              |              |              |              |         cost |       annual |
|              |              |              |              |              |              |     expenses |
+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
| Charlie      | Dog          | M            |            7 |         37.0 |        420.5 |          695 |
| Max          | Cat          | M            |           12 |          4.2 |       575.32 |          790 |
| Simba        | Cat          | M            |            5 |          3.8 |        498.7 |          720 |
| Coco         | Dog          | F            |            8 |         13.9 |       276.36 |          632 |
| Ruby         | Dog          | F            |            6 |         15.7 |       320.95 |          543 |
+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
```

So, using the Table class is simply feeding it with data and adding some columns with header and extracting proc.

In this first example, several defaults are used for table initialization and columns definition

- Unless explicitly specified (at column level by align_header or globally by
  default_header_alignment), cell alignment (header and body) is inferred from
  the body contents : left alignment for strings and chars, and right alignment
  for numbers (Boolean data would be centered)
- Default cell width is 12 characters, not counting padding (default is one space on each side)
- Adding a column is done by defining a header and a proc to extract data. As we are dealing with a 2D array, each row is a one-dimensional array, so we need to use the [] notation to access an element
- Borders are fairly basic, using the default ASCII connectors string

Now, let's do something more elaborate and more fancy !

Here are the modified lines :

```crystal
12: table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_SINGLE_ROUNDED) do |t|
13:   t.add_column("Name", width: 8) { |n| n[0].as(String).upcase }
14:   t.add_column("Kind", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[1] }
15:   t.add_column("Sex", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[2] }
18:   t.add_column("Initial\ncost", formatter: ->(x : Tablo::CellType) { "%.2f" % x }) { |n| n[5] }
```

_file : examples/readme2.cr_

```text
╭──────────┬──────┬──────┬──────────────┬──────────────┬──────────────┬──────────────╮
│ Name     │ Kind │  Sex │          Age │       Weight │      Initial │      Average │
│          │      │      │              │              │         cost │       annual │
│          │      │      │              │              │              │     expenses │
├──────────┼──────┼──────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ CHARLIE  │  Dog │   M  │            7 │         37.0 │       420.50 │          695 │
│ MAX      │  Cat │   M  │           12 │          4.2 │       575.32 │          790 │
│ SIMBA    │  Cat │   M  │            5 │          3.8 │       498.70 │          720 │
│ COCO     │  Dog │   F  │            8 │         13.9 │       276.36 │          632 │
│ RUBY     │  Dog │   F  │            6 │         15.7 │       320.95 │          543 │
╰──────────┴──────┴──────┴──────────────┴──────────────┴──────────────┴──────────────╯
```

- In line 12, the default connectors string is replaced by a predefined string for a better appearance
- In line 13, we need to convert the cell value (which is of type CellType, an union of commonly used scalar types) to a String type with the _as_ method, as the _upcase_ method is not defined for the other types of the union
- Lines 14 and 15 justify (center) both header and body
- Lines 13, 14 and 15 set a specific column width
- Line 18 use the Proc formatter, to properly display the cell value (note that alignment is left unchanged as it depends on the underlying data, which is a number)

Several columns may use the same data element, and more than one data element may be used in a column !

Let's compute the total cost of each pet, by replacing line 19 with :

```crystal
19:   t.add_column("Total\nCost", formatter: ->(x : Tablo::CellType) { "%.2f" % x }) { |n| n[3].as(Number) * n[6].as(Number) + n[5].as(Number) }
```

_file : examples/readme3.cr_

```text
╭──────────┬──────┬──────┬──────────────┬──────────────┬──────────────┬──────────────╮
│ Name     │ Kind │  Sex │          Age │       Weight │      Initial │        Total │
│          │      │      │              │              │         cost │         cost │
├──────────┼──────┼──────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ CHARLIE  │  Dog │   M  │            7 │         37.0 │       420.50 │      5285.50 │
│ MAX      │  Cat │   M  │           12 │          4.2 │       575.32 │     10055.32 │
│ SIMBA    │  Cat │   M  │            5 │          3.8 │       498.70 │      4098.70 │
│ COCO     │  Dog │   F  │            8 │         13.9 │       276.36 │      5332.36 │
│ RUBY     │  Dog │   F  │            6 │         15.7 │       320.95 │      3578.95 │
╰──────────┴──────┴──────┴──────────────┴──────────────┴──────────────┴──────────────╯
```

Suppose we want to associate age and weight in the same column, with special
formatting. We could replace lines 16 and 17 with the following :

```crystal
16:   t.add_column("Age : weight") { |n| "%3d : %6.1f" % [n[3], n[4]] }
```

Note that we cannot use the formatter proc here, as it expects a CellType
value, not an Array.

_file : examples/readme4.cr_

```text
╭──────────┬──────┬──────┬──────────────┬──────────────┬──────────────╮
│ Name     │ Kind │  Sex │ Age : weight │      Initial │        Total │
│          │      │      │              │         cost │         cost │
├──────────┼──────┼──────┼──────────────┼──────────────┼──────────────┤
│ CHARLIE  │  Dog │   M  │   7 :   37.0 │       420.50 │      5285.50 │
│ MAX      │  Cat │   M  │  12 :    4.2 │       575.32 │     10055.32 │
│ SIMBA    │  Cat │   M  │   5 :    3.8 │       498.70 │      4098.70 │
│ COCO     │  Dog │   F  │   8 :   13.9 │       276.36 │      5332.36 │
│ RUBY     │  Dog │   F  │   6 :   15.7 │       320.95 │      3578.95 │
╰──────────┴──────┴──────┴──────────────┴──────────────┴──────────────╯
```

And if we want double line borders horizontally and single line borders
vertically, excluding top and bottom borders, we could replace line 12 with

```crystal
12: table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_SINGLE_DOUBLE, style: "lc,mc,rc,ml") do |t|
```

_file : examples/readme5.cr_

```text
│ Name     │ Kind │  Sex │ Age : weight │      Initial │        Total │
│          │      │      │              │         cost │         cost │
╞══════════╪══════╪══════╪══════════════╪══════════════╪══════════════╡
│ CHARLIE  │  Dog │   M  │   7 :   37.0 │       420.50 │      5285.50 │
│ MAX      │  Cat │   M  │  12 :    4.2 │       575.32 │     10055.32 │
│ SIMBA    │  Cat │   M  │   5 :    3.8 │       498.70 │      4098.70 │
│ COCO     │  Dog │   F  │   8 :   13.9 │       276.36 │      5332.36 │
│ RUBY     │  Dog │   F  │   6 :   15.7 │       320.95 │      3578.95 │
```

### Main classes and methods reference

#### The Tablo::Table class

##### data input

As shown in the examples, if we except the block used to add columns, a Table
can be created with only one mandatory argument : the data structure to work
on. This data structure needs to be a 2D array of some types included in Celltype, which are defined
as

```crystal
alias CellType = Bool | Char | Int::Signed | Int::Unsigned | Float32 | Float64 | String | Symbol
alias DataType = Array(Array(CellType))
```

A DataException is raised if given data is not a 2D array or cannot be converted
for some reason.

##### Default formatting parameters

- _default_column_width:_ 12

- _column_padding:_ 1 space

- _header_frequency:_ possible values are an integer n or nil

  - n == 0 (default) : the header is automatically displayed before the first row
  - n < 0 : the header is repeated every n rows, with a closing horizontal rule between each group
  - n > 0 : the header is repeated every n rows, with a cross horizontal rule between each group
  - nil : no header

- _wrap_header_cells_to:_ is the number of "lines" of wrapped cell content to allow before truncating. Defaults to nil, which means no truncation. If set to a positive integer, truncating may occur and in this case, the default truncation indicator is displayed in the padding area

- _wrap_body_cells_to:_ id as _wrap_header_cells_to:_, but for body cells

- _default_header_alignment_ : possible values are : _Tablo::Justify::Left_, _Tablo::Justify::Center_, _Tablo::Justify::Right_ and _Tablo::Justify::None_. If set to the latter (default), alignment is inferred from the column _align_header_ parameter if set, or from the body contents type otherwise.

- _truncation_indicator:_ defaults to a tilde (~)

- _style:_ is a string of border initials : _lc_ for left column, _mc_ for middle colums, _rc_ for right column, _tl_ for top line, _ml_ for middle lines and _bl_ for bottom line. With style = "TLMLBL,LCMCRC" (default), all borders are displayed. With style = "ml", only a header/body separator horizontal rule is displayed. Initials may be separated by any space or punctuation character for better readability and are case insensitive.

- Line 18 use the Proc formatter, to properly display the cell value (note that alignment is left unchanged as it depends on the underlying data, which is a number)
- _styler proc:_ From version 0.10, it is now possible to style the content of a column with the styler proc, using either the ANSI color codes or the Crystal `colorize` methods.
  The style is applied on the formatted value (a String), for example:

```
t.add_column("Initial\ncost",
    formatter: ->(x : Tablo::CellType) { "%.2f" % x },
    styler : ->(s : Tablo::CellType) { "#{s.colorize(:red)}" })
    { |n| n[5] }
```

- _connectors:_ is a string of 15 characters long, containing the cross, corner and line character for drawing borders. Several connectors sets are defined in the module but user may provide its own character set.
  - The first 9 characters define the corner and cross characters (first 3 for the top line, next 3 for the middle line and last 3 for the bottom line.
  - The next 3 are vertical line connectors, one for each column type : lc, mc, rc
  - The last 3 are horizontal line connectors, one for each line type : tl, ml, bl

In the previous example, some headers are 2 lines high. Here is the effect of limiting their height to 1.

```crystal
12: table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_SINGLE_DOUBLE, style: "lc,mc,rc,ml", wrap_header_cells_to: 1) do |t|
```

_file : examples/readme6.cr_

```text
│ Name     │ Kind │  Sex │ Age : weight │      Initial~│        Total~│
╞══════════╪══════╪══════╪══════════════╪══════════════╪══════════════╡
│ CHARLIE  │  Dog │   M  │   7 :   37.0 │       420.50 │      5285.50 │
│ MAX      │  Cat │   M  │  12 :    4.2 │       575.32 │     10055.32 │
│ SIMBA    │  Cat │   M  │   5 :    3.8 │       498.70 │      4098.70 │
│ COCO     │  Dog │   F  │   8 :   13.9 │       276.36 │      5332.36 │
│ RUBY     │  Dog │   F  │   6 :   15.7 │       320.95 │      3578.95 │
```

The truncation character is displayed in the header right padding area of the last
2 columns.

When dealing with data containing many rows, it could be interesting to repeat the headers every n rows. Here is a first example, with a factor repetition of 3

```crystal
12: table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_LIGHT_HEAVY, header_frequency: 3) do |t|
```

_file : examples/readme7.cr_

```text
┍━━━━━━━━━━┯━━━━━━┯━━━━━━┯━━━━━━━━━━━━━━┯━━━━━━━━━━━━━━┯━━━━━━━━━━━━━━┑
│ Name     │ Kind │  Sex │ Age : weight │      Initial │        Total │
│          │      │      │              │         cost │         Cost │
┝━━━━━━━━━━┿━━━━━━┿━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┥
│ CHARLIE  │  Dog │   M  │   7 :   37.0 │       420.50 │      5285.50 │
│ MAX      │  Cat │   M  │  12 :    4.2 │       575.32 │     10055.32 │
│ SIMBA    │  Cat │   M  │   5 :    3.8 │       498.70 │      4098.70 │
┝━━━━━━━━━━┿━━━━━━┿━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┥
│ Name     │ Kind │  Sex │ Age : weight │      Initial │        Total │
│          │      │      │              │         cost │         Cost │
┝━━━━━━━━━━┿━━━━━━┿━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━┥
│ COCO     │  Dog │   F  │   8 :   13.9 │       276.36 │      5332.36 │
│ RUBY     │  Dog │   F  │   6 :   15.7 │       320.95 │      3578.95 │
┕━━━━━━━━━━┷━━━━━━┷━━━━━━┷━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━┙
```

and again, with the same factor, but negative

```crystal
12: table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_HEAVY_LIGHT, header_frequency: -3) do |t|
```

_file : examples/readme8.cr_

```text
┎──────────┰──────┰──────┰──────────────┰──────────────┰──────────────┒
┃ Name     ┃ Kind ┃  Sex ┃ Age : weight ┃      Initial ┃        Total ┃
┃          ┃      ┃      ┃              ┃         cost ┃         Cost ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ CHARLIE  ┃  Dog ┃   M  ┃   7 :   37.0 ┃       420.50 ┃      5285.50 ┃
┃ MAX      ┃  Cat ┃   M  ┃  12 :    4.2 ┃       575.32 ┃     10055.32 ┃
┃ SIMBA    ┃  Cat ┃   M  ┃   5 :    3.8 ┃       498.70 ┃      4098.70 ┃
┖──────────┸──────┸──────┸──────────────┸──────────────┸──────────────┚
┎──────────┰──────┰──────┰──────────────┰──────────────┰──────────────┒
┃ Name     ┃ Kind ┃  Sex ┃ Age : weight ┃      Initial ┃        Total ┃
┃          ┃      ┃      ┃              ┃         cost ┃         Cost ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ COCO     ┃  Dog ┃   F  ┃   8 :   13.9 ┃       276.36 ┃      5332.36 ┃
┃ RUBY     ┃  Dog ┃   F  ┃   6 :   15.7 ┃       320.95 ┃      3578.95 ┃
┖──────────┸──────┸──────┸──────────────┸──────────────┸──────────────┚
```

As of release 0.9.4, formatting has been enhanced by a new method
: `Tablo.fpjust`, which allows alignment on decimal point for floating point
values, after removing non significant digits.

To illustrate, running the program below :

```crystal
require "tablo"

data = [
  # Name        Initial   Initial   Initial   Initial   Initial
  #                cost      cost      cost      cost      cost
  ["Charlie",    420.50,   420.50,   420.50,   420.50,   420.50],
  ["Max",        575.32,   575.32,   575.32,   575.32,   575.32],
  ["Simba",      498.00,   498.00,   498.00,   498.00,   498.00],
  ["Coco",       276.36,   276.36,   276.36,   276.36,   276.36],
  ["Ruby",       320.95,   320.95,   320.95,   320.95,   320.95],
  ["Freecat",      0.0,      0.0,      0.0,      0.0,      0.0 ],
]

Tablo.fpjust(data, 1, 5, nil) # Params: data array, column, decimals, mode
Tablo.fpjust(data, 2, 4, 0)
Tablo.fpjust(data, 3, 3, 1)
Tablo.fpjust(data, 4, 2, 2)
Tablo.fpjust(data, 5, 1, 3)
table = Tablo::Table.new(data) do |t|
  t.add_column("Name") { |n| n[0] }
  t.add_column("Initial\ncost\nmode=nil\ndec=5") { |n| n[1] }
  t.add_column("Initial\ncost\nmode=0\ndec=4") { |n| n[2] }
  t.add_column("Initial\ncost\nmode=1\ndec=3") { |n| n[3] }
  t.add_column("Initial\ncost\nmode=2\ndec=2") { |n| n[4] }
  t.add_column("Initial\ncost\nmode=3\ndec=1") { |n| n[5] }
end
table.shrinkwrap!
puts table
```

_file : examples/readme11.cr_

produces the following output :

```text

+---------+-----------+---------+---------+---------+---------+
| Name    | Initial   | Initial | Initial | Initial | Initial |
|         | cost      | cost    | cost    | cost    | cost    |
|         | mode=nil  | mode=0  | mode=1  | mode=2  | mode=3  |
|         | dec=5     | dec=4   | dec=3   | dec=2   | dec=1   |
+---------+-----------+---------+---------+---------+---------+
| Charlie | 420.50000 | 420.5   | 420.5   | 420.5   | 420.5   |
| Max     | 575.32000 | 575.32  | 575.32  | 575.32  | 575.3   |
| Simba   | 498.00000 | 498.    | 498     | 498     | 498.0   |
| Coco    | 276.36000 | 276.36  | 276.36  | 276.36  | 276.4   |
| Ruby    | 320.95000 | 320.95  | 320.95  | 320.95  | 320.9   |
| Freecat |   0.00000 |   0.    |   0     |         |   0.0   |
+---------+-----------+---------+---------+---------+---------+
```

**Caution:** _Notice that this method alters the input data array, turning a floating point
column into a string column._

##### Table methods

There are essentially 4 methods useful for the user : _add_column_, _each_, _horizontal_rule_ and _shrinkwrap!_

###### add_column

This is the method used for table definition. Its parameters are :

- _label:_ string used to identify the column (mandatory), and most often, also assigned to the header
- _header:_ default to _label:_
- _width:_ column width, defaults to _default_column_width:_
- _align_header:_ possible values are : _Tablo::Justify::Left_, _Tablo::Justify::Center_, _Tablo::Justify::Right_ and _Tablo::Justify::None_. If set to the latter (default), alignment is inferred from the body contents type unless _default_header_alignment_ is set to any value excepted _Tablo::Justify::None_ (default).
- _align_body:_ same as _align_header:_, for body cells
- _formatter:_ a Proc to format the cells, while conserving the inferred alignment from the body contents. Default to "_->(n : CellType) { n.to_s }_"

In addition, _add_column_ requires a block defining how array element is extracted, and possibly converted.

###### horizontal_rule

When specific formatting is desirable, the _horizontal_rule_ method come handy. It accepts one argument, the type of line to be displayed : Top, Middle or Bottom. See an example of use for the next method _each_

###### each

The _each_ method is useful when one wants to fine tune output. Instead of a mere

```crystal
puts table
```

one can write the table one row at a time, so that it becomes possible to
define very specific output, for example by inserting an horizontal rule
between each row. Lets try it with the previous example, replacing the `puts table` in line 21 with

```crystal
21: table.each_with_index do |row, i|
22:   puts table.horizontal_rule(Tablo::TLine::Mid) if i > 0 && (i % 3) != 0 && table.style =~ /ML/i
23:   puts row
24: end
25  puts table.horizontal_rule(Tablo::TLine::Bot) if table.style =~ /BL/i
```

_file : examples/readme9.cr_

```text
┎──────────┰──────┰──────┰──────────────┰──────────────┰──────────────┒
┃ Name     ┃ Kind ┃  Sex ┃ Age : weight ┃      Initial ┃        Total ┃
┃          ┃      ┃      ┃              ┃         cost ┃         Cost ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ CHARLIE  ┃  Dog ┃   M  ┃   7 :   37.0 ┃       420.50 ┃      5285.50 ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ MAX      ┃  Cat ┃   M  ┃  12 :    4.2 ┃       575.32 ┃     10055.32 ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ SIMBA    ┃  Cat ┃   M  ┃   5 :    3.8 ┃       498.70 ┃      4098.70 ┃
┖──────────┸──────┸──────┸──────────────┸──────────────┸──────────────┚
┎──────────┰──────┰──────┰──────────────┰──────────────┰──────────────┒
┃ Name     ┃ Kind ┃  Sex ┃ Age : weight ┃      Initial ┃        Total ┃
┃          ┃      ┃      ┃              ┃         cost ┃         Cost ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ COCO     ┃  Dog ┃   F  ┃   8 :   13.9 ┃       276.36 ┃      5332.36 ┃
┠──────────╂──────╂──────╂──────────────╂──────────────╂──────────────┨
┃ RUBY     ┃  Dog ┃   F  ┃   6 :   15.7 ┃       320.95 ┃      3578.95 ┃
┖──────────┸──────┸──────┸──────────────┸──────────────┸──────────────┚
```

Note that, when using the _each_ (or _each_with_index_) method on the table, it is now up to the user to manage the display of horizontal rules.

###### shrinkwrap!

And now, the magic ! If we insert the line `table.shrinkwrap!` before line
21, all columns have their width reduced to the minimum !

_Take care, however, because the width of columns is then adjusted to their
content, regardless of their width (fixed or default): so columns may be
narrowed or widened!_

If table width gets too wide, there is fortunately a workaround : just pass an
argument to _shrinkwrap!_ to limit the total width of the table (or, if table
width is too small, pass this argument as a negative value to force a minimum
table width).

```crystal
21: table.shrinkwrap!
22: table.each_with_index do |row, i|
23:   puts table.horizontal_rule(Tablo::TLine::Mid) if i > 0 && (i % 3) != 0 && table.style =~ /ML/i
24:   puts row
25: end
26  puts table.horizontal_rule(Tablo::TLine::Bot) if table.style =~ /BL/i
```

_file : examples/readme10.cr_

```text
┎─────────┰──────┰─────┰──────────────┰─────────┰──────────┒
┃ Name    ┃ Kind ┃ Sex ┃ Age : weight ┃ Initial ┃    Total ┃
┃         ┃      ┃     ┃              ┃    cost ┃     Cost ┃
┠─────────╂──────╂─────╂──────────────╂─────────╂──────────┨
┃ CHARLIE ┃  Dog ┃  M  ┃   7 :   37.0 ┃  420.50 ┃  5285.50 ┃
┠─────────╂──────╂─────╂──────────────╂─────────╂──────────┨
┃ MAX     ┃  Cat ┃  M  ┃  12 :    4.2 ┃  575.32 ┃ 10055.32 ┃
┠─────────╂──────╂─────╂──────────────╂─────────╂──────────┨
┃ SIMBA   ┃  Cat ┃  M  ┃   5 :    3.8 ┃  498.70 ┃  4098.70 ┃
┖─────────┸──────┸─────┸──────────────┸─────────┸──────────┚
┎─────────┰──────┰─────┰──────────────┰─────────┰──────────┒
┃ Name    ┃ Kind ┃ Sex ┃ Age : weight ┃ Initial ┃    Total ┃
┃         ┃      ┃     ┃              ┃    cost ┃     Cost ┃
┠─────────╂──────╂─────╂──────────────╂─────────╂──────────┨
┃ COCO    ┃  Dog ┃  F  ┃   8 :   13.9 ┃  276.36 ┃  5332.36 ┃
┠─────────╂──────╂─────╂──────────────╂─────────╂──────────┨
┃ RUBY    ┃  Dog ┃  F  ┃   6 :   15.7 ┃  320.95 ┃  3578.95 ┃
┖─────────┸──────┸─────┸──────────────┸─────────┸──────────┚
```

#### The Tablo::Row class

Generally, class Row is not meant to be used directly, but its methods can be used for specific needs.

##### Row methods

###### each

Iterates over the row cells, as extracted from source (unformatted unless
formatting occurs in the extractor proc)

###### to_s

Returns a string being an "ASCII" graphical representation of the `Row`,
including any column headers that appear just above it in the `Table`
(depending on where this `Row` is in the `Table` and how the `Table` was
configured with respect to header frequency).

###### to_h

Returns a Hash representation of the `Row`, with column labels acting as keys
and the calculated cell values (before formatting) providing the values.

## Contributing

1. Fork it (<https://github.com/your-github-user/tablo/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
