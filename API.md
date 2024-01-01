# Tablo API

###### [switch to Tutorial](tutorial.md)

[<img src="images/logo.png" alt="Logo" width=700/>](README.md)

## Table of contents

- [Tablo internals](#tablo-internals)
- [class Table](#class-table)
  - [Method initialize](#method-initialize)
  - [Method add_column](#method-add_column)
  - [Method add_group](#method-add_group)
  - [Method reset_sources](#method-reset_sources)
  - [Method to_s](#method-to_s)
  - [Method each](#method-each)
  - [Method pack](#method-pack)
  - [Method summary](#method-summary)
  - [Method transpose](#method-transpose)
  - [Method horizontal_rule](#horizontal_rule)
  - [Method total_table_width](#total_table_width)
- [Abstract struct Heading](#abstract-struct-heading)
  - [Method framed?](#method-framed)
- [struct Title](#struct-title)
  - [Title method initialize](#title-method-initialize)
- [struct SubTitle](#struct-subtitle)
  - [SubTitle method initialize](#subtitle-method-initialize)
- [struct Footer](#struct-footer)
  - [Footer method initialize](#footer-method-initialize)
- [struct Frame](#struct-frame)
  - [Frame method initialize](#frame-method-initialize)

## Tablo internals

[:top:](#tablo-api)
[:arrow_up:](#table-of-contents)
[:arrow_down:](#class-table)

Table definition is largely based on default values, which can be modified via
named parameters if required.

Most of the parameters defined when initializing a table are taken over by
default, if appropriate, when creating columns.

Tablo features a column-based rather than row-based API, which means that
header and body lines are automatically synchronized.

At the heart of Tablo's operation lies the cell, a data structure containing
all the elements required for display. There are 2 different types of cell:

- Those containing source or source-dependent data, the DataCell type (for Header and Body rows)

- Text cells, the TextCell type (for Group and Headings)

They differ mainly in 2 exclusive attribute types:

- RowType for TextCell cells

- CellData for DataCell cells

Both have the `value` attribute, which contains the raw data extracted from
source. Its type is `Tablo::CellType`

## class Table

[:top:](#tablo-api)
[:arrow_up:](#tablo-internals)
[:arrow_down:](#abstract-struct-Heading)
[:arrow_lower_right:](#method-initialize)

The Table class is Tablo's main class. Its initialization defines the main
parameters governing the overall operation of the Tablo library, in particular
the data source and column definitions.

| Used constants                  | Default value                         |
| :------------------------------ | :------------------------------------ |
| `DEFAULT_HEADING_ALIGNMENT`     | `Justify::Center`                     |
| `DEFAULT_FORMATTER`             | `->(c : CellType) { c.to_s }`         |
| `DEFAULT_STYLER`                | `->(s : String) { s }`                |
| `DEFAULT_DATA_DEPENDENT_STYLER` | `->(_c : CellType, s : String) { s }` |

### Method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#class-table)
[:arrow_down:](#method-add_column)

Returns an instance of `Table(T)`

_Mandatory parameters:_

- `sources`: type is Enumerable(T)<br />
  Can be any Enumerable data type _(`Range` is currently (Crystal 1.9.2) not correctly supported in this context: use `Range.to_a` instead)_

_Optional named parameters, with default values_

- `title`: type is `Title`<br />
  Default set by `Config.title`<br />
  Initializing this class without any argument set its value to `nil`,
  so there is nothing to display
- `subtitle`: type is `SubTitle`<br />
  Default set by `Config.subtitle`<br />
  (Initialization: see `title`)
- `footer`: type is `Footer`<br />
  Default set by `Config.footer`<br />
  (Initialization: see `title`)
- `border`: type is `Border`<br />
  Initalized by `Config.border`, which defaults to `BorderName::Ascii` <br />
  Other `BorderName` are `ReducedAscii`, `Modern`,
  `ReducedModern`, `Markdown`, `Fancy` and `Blank`. <br />
  `border` may also be initialized directly by a string of 16 characters.
- `group_alignment`: type is `Justify`<br />
  Default value is `DEFAULT_HEADING_ALIGNMENT`
- `group_formatter`: type is `TextCellFormatter`<br />
  Default value is `DEFAULT_FORMATTER`
- `group_styler`: type is `TextCellStyler` <br />
  Default value is `DEFAULT_STYLER`
- `header_alignment`: type is `Justify?` <br />
  Default value is `nil` <br />
  (with `nil` as default, alignment
  depends on the type of the related body cell value)
- `header_formatter`: type is `DataCellFormatter` <br />
  Default value is `DEFAULT_FORMATTER`
- `header_styler`: type is `DataCellStyler` <br />
  Defaut value is `DEFAULT_DATA_DEPENDENT_STYLER`
- `body_alignment`: type is `Justify?` <br />
  Default value is `nil` <br />
  (With `nil` as default, alignment depends on the type of its cell value)
- `body_formatter`: type id `DataCellFormatter` <br />
  Default value is `DEFAULT_FORMATTER`
- `body_styler`: type is `DataCellStyler` <br />
  Default value is `DEFAULT_DATA_DEPENDENT_STYLER`
- `left_padding`: type is `Int32`<br />
  Default value is `1` <br />
  Permitted range of values is governed by `Config.padding_width_range` in the `check_padding` method<br />
  (raises `InvalidValue` runtime exception if value not in range)
- `right_padding`: type is `Int32` <br />
  Default value is `1` <br />
  Permitted range of values is governed by `Config.padding_width_range` in the `check_padding` method<br />
  (raises `InvalidValue` runtime exception if value not in range)
- `padding_character`: type is `String`<br />
  Default value is `" "` <br />
  The `check_padding_character` auxiliairy method ensures the `padding_character` string size is only one <br />
  (raises an `InvalidValue` runtime exception otherwise)
- `truncation_indicator`: type is `String` <br />
  Defaut value is `"~"` <br />
  The `check_truncation_indicator` auxiliairy method ensures the `truncation_indicator` string size
  is only one (raises an `InvalidValue` runtime exception otherwise)
- `width`: type is `Int32` <br />
  Default value is `12`<br />
  Permitted range of values is governed by `Config.column_width_range` in the
  `check_width` auxiliary method (raises `InvalidValue` runtime exception
  unless value in range)

- `header_frequency`: type is `Int32?` <br />
  Default value is `0` <br />
  Permitted range of values is governed by `Config.header_frequency_range` in the
  `check_header_frequency` auxiliary method (raises `InvalidValue` runtime exception
  unless value in range or `nil`)

  - If set to `0`, rows of data other than body are displayed
    only once, at the beginning for titles and headers, at the end for the footer.
  - If set to `n` (positive), group or column headers are repeated every `n`
    rows, as are footers, but titles and subtitles are not repeated (unless
    title `repeated` attribute is set to `true`)
  - If set to `nil`, only body rows are displayed.

- `row_divider_frequency`: type is `Int32?` <br />
  Default value is `nil` <br />
  Permitted range of values is governed by `Config.row_divider_frequency_range` in the
  `check_row_divider_frequency` auxiliary method (raises `InvalidValue` runtime
  exception unless value in range or `nil`)

- `wrap_mode`: type is `WrapMode` <br />
  Default value is `WrapMode::Word`<br />
  The `WrapMode` enum defines 2 modes :

  - `Rune` : long lines can be cut between characters (graphemes)
  - `Word` : long lines can be cut between words only

- `header_wrap`: type is `Int32?` <br />
  Default value is `nil` <br />
  Permitted range of values is governed by
  `Config.header_wrap_range` in the `check_header_wrap` auxiliary method
  (raises `InvalidValue` runtime exception unless value in range or `nil`)

- `body_wrap` | `Int32?`<br />
  Default value is `nil` <br />
  Permitted range of values is governed by
  `Config.body_wrap_range` in the `check_body_wrap` auxiliary method (raises
  `InvalidValue` runtime exception unless value in range or `nil`)

- `masked_headers`: type is `Bool` <br />
  Default value is `false` <br />
  If `true`, groups and column headers are not displayed <br />
  (this does not prevent display of title, subtitle and footer)

- `omit_group_header_rule`: type is `Bool` <br />
  Default value is `false` <br />
  If `true`, the rule between Group and Header rows is not displayed.
  This is useful for headers custom rendering.

- `omit_last_rule`: type is `Bool` <br />
  Default value is `false` <br />
  If `true`, the closing rule of table is not displayed.
  This is useful for custom rendering (and notably for Detail and Summary tables joining)

### Method `add_column`

[:top:](#tablo-api)
[:arrow_up:](#method-initialize)
[:arrow_down:](#method-add_group)

Returns an instance of `Column(T)`

_Mandatory positional parameter:_

- `label`: type is `LabelType`<br />
  The label identifies the column (`LabelType` is an alias of `Int32 | Symbol | String`)

_Optional named parameters, with default values_

- `header`: type is `String` <br />
  Default value is `label.to_s`<br />
  Can be an empty string

- `header_alignment`: type is `Justify?`<br />
  By default, inherits from table `header_alignment` initializer

- `header_formatter`: type is `DataCellFormatter` <br />
  By default, inherits from table `header_formatter` initializer

- `header_styler`: type is `DataCellStyler` <br />
  By default, inherits from table `header_styler` initializer

- `body_alignment`: type is `Justify?` <br />
  By default, inherits from table `body_alignment` initializer

- `body_formatter`: type is `DataCellFormatter` <br />
  By default, inherits from table `body_formatter` initializer

- `body_styler`: type is `DataCellStyler` <br />
  By default, inherits from table `body_styler` initializer

- `left_padding`: type is `Int32` <br />
  By default, inherits from table `left_padding` initializer

- `right_padding`: type is `Int32` <br />
  By default, inherits from table `right_padding` initializer

- `padding_character`: type is `String` <br />
  By default, inherits from table `padding_character` initializer

- `width`: type is `Int32` <br />
  By default, inherits from table `width` initializer

- `truncation_indicator`: type is `String` <br />
  By default, inherits from table `truncation_indicator` initializer

- `wrap_mode`: type is `WrapMode` <br />
  By default, inherits from table `wrap_mode` initializer

_Captured block_

- `&extractor`: type is `(T | Int32) -> CellType` <br />
  Captured block for extracting data from source

### Method `add_group`

[:top:](#tablo-api)
[:arrow_up:](#method-add_column)
[:arrow_down:](#method-reset_sources)

Returns an instance of `TextCell`

_Mandatory positional parameter_

- `label`: type is `LabelType` <br />
  The label identifies the group.

_Optional named parameters, with default values_

- `header`: type is `String` <br />
  Default value id `label.to_s` <br />
  Can be an empty string

- `alignment`: type is `Justify` <br />
  By default, inherits from table `group_alignment` initializer

- `formatter`: type is `TextCellFormatter` <br />
  By default, inherits from table `group_formatter` initializer

- `styler`: type is `TextCellFormatter` <br />
  By default, inherits from table `group_styler` initializer

- `padding_character`: type is `String` <br />
  By default, inherits from table `padding_character` initializer

- `truncation_indicator`: type is `String` <br />
  By default, inherits from table `truncation_indicator` initializer

- `wrap_mode`: type is `WrapMode` <br />
  By default, inherits from table `wrap_mode` initializer

### Method `reset_sources`

[:top:](#tablo-api)
[:arrow_up:](#method-add_group)
[:arrow_down:](#method-to_s)

Replaces existing data source with a new one and returns it. <br />
_(This could be seen as a hack to do some special form of pagination !)_

_Mandatory positional parameter_

- `src`: type is `Enumerable(T)`

### Method `to_s`

[:top:](#tablo-api)
[:arrow_up:](#method-reset_sources)
[:arrow_down:](#method-each)

Returns the table as a formatted string

### Method `each`

[:top:](#tablo-api)
[:arrow_up:](#method-to_s)
[:arrow_down:](#method-pack)

Returns successive formatted rows, with all corresponding headers and footers,
according to the parameters defined.

In fact,

```crystal
table.each do |r|
  puts r
end
```

is the same as

```crystal
puts table
```

### Method `pack`

[:top:](#tablo-api)
[:arrow_up:](#method-each)
[:arrow_down:](#method-summary)

Returns `self` (the current Table instance) after modifying its column widths

_All named parameters are optional, with default values_

- `width`: type is `Int32?` <br />
  Default value is `nil` <br />
  `width` is the requested total table width. If `nil` and `Config.terminal_capped_width`
  is `true` (and output not redirected), `width` finally takes the value of the terminal size.

- `starting_widths`: type is `StartingWidths` <br />
  Default set by `Config.starting_widths` <br />
  `Starting_widths` allows you to specify the starting point for resizing :

  - either from the current column width value (`StartingWidths::Current`)
  - or from its initial value (`StartingWidths::Initial`)
  - or ignore it and directly perform optimized resizing (`StartingWidths::AutoSized`)

- `except`: type is `Except?` <br />
  Default value is `nil` <br />
  `except` is a column identifier or array of column identifiers to be excluded
  from packing (`Except` is an alias of `LabelType | Array(LabelType)`)

##### Description of the packing algorithm

The resizing algorithm is actually quite simple.

if the final value of the `width` parameter is not `nil`, it first compares
the table's current width with the requested width, to determine whether this
is a reduction or an increase in size. Then, depending on the case, either the
widest column is reduced, or the narrowest increased, in steps of 1, until the
requested table width is reached.

This explains why the final result of resizing depends on the starting column
widths.

### Method `summary`

[:top:](#tablo-api)
[:arrow_up:](#method-pack)
[:arrow_down:](#method-transpose)

### Method `transpose`

[:top:](#tablo-api)
[:arrow_up:](#method-summary)
[:arrow_down:](#method-horizontal_rule)

### Method `horizontal_rule`

[:top:](#tablo-api)
[:arrow_up:](#method-transpose)
[:arrow_down:](#method-total_table_width)

### Method `total_table_width`

[:top:](#tablo-api)
[:arrow_up:](#method-horizontal_rule)
[:arrow_lower_left:](#abstract-struct-Heading)

## abstract struct Heading

[:top:](#tablo-api)
[:arrow_up:](#class-table)
[:arrow_down:](#struct-title)
[:arrow_lower_right:](#method-framed)

Concrete structs are `Title`, `SubTitle` and `Footer`

### Method `framed?`

[:top:](#tablo-api)
[:arrow_upper_left:](#abstract-struct-heading)
[:arrow_lower_left:](#struct-title)

Returns `true` if `Title`, `SubTitle` or `Footer` contents are framed, `false` otherwise.

Attributes `value`, `frame`, `alignment` and `repeated` are declared as
properties, and can be modified after initialization

## struct Title

[:top:](#tablo-api)
[:arrow_up:](#abstract-struct-heading)
[:arrow_down:](#struct-subtitle)
[:arrow_lower_right:](#title-method-initialize)

### Title method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#struct-title)
[:arrow_lower_left:](#struct-subtitle)

Returns an instance of `Title`

_Parameters_

- `value`: type is `CellType?` <br />
  Default value is `nil` (no display)<br />
  `value` is the title contents (may not be an empty string).
- `frame`: type is `Frame?` <br />
  Default value is `nil` <br />
  Defines a frame around title contents. If `nil`, no frame.

- `repeated`: type is `Bool` <br />
  Default value is `false` <br />
  If `true`, force title (and subtitle) to be repeated at header frequency
- `alignment`: type if `Justify` <br />
  Default value is `DEFAULT_HEADING_ALIGNMENT`

- `formatter`: type is `TextCellFormatter` <br />
  Default value is `DEFAULT_FORMATTER`

- `styler`: type is `TextCellStyler` <br />
  Default value is `DEFAULT_STYLER`

## struct SubTitle

[:top:](#tablo-api)
[:arrow_up:](#struct-title)
[:arrow_down:](#struct-footer)
[:arrow_lower_right:](#subtitle-method-initialize)

Attributes `value`, `frame` and `alignment` are declared as properties, and
can be modified after initialization

### SubTitle method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#struct-subtitle)
[:arrow_lower_left:](#struct-footer)

Returns an instance of `SubTitle`

_Parameters (see `Title` for details)_

- `value`
- `frame`
- `alignment`
- `formatter`
- `styler`

## struct Footer

[:top:](#tablo-api)
[:arrow_up:](#struct-subtitle)
[:arrow_down:](#struct-frame)
[:arrow_lower_right:](#footer-method-initialize)

Attributes `value`, `frame`, `alignment` and `page_break` are declared as
properties, and can be modifiedafter initialization

### Footer method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#struct-footer)
[:arrow_lower_left:](#struct-frame)

Returns an instance of `Footer`

_Parameters (see `Title` for details)_

- `value`
- `frame`
- `alignment`
- `formatter`
- `styler`
- `page_break`: type is `Bool`<br />
  Default value is `false` <br />
  If `true`, emit a page break

## struct Frame

[:top:](#tablo-api)
[:arrow_up:](#struct-footer)
[:arrow_lower_right:](#frame-method-initialize)

The `Frame` struct is used to add a frame to `Title`, `SubTitle` or `Footer`.

### Frame method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#struct-frame)

Returns an instance of `Frame`

_Parameters_

- `line_breaks_before`: type is `Int32` <br />
  Default value is `0` <br />
  `line_breaks_before` id the count of line breaks to emit before displaying framed contents
- `line_breaks_after`: type is `Int32` <br />
  Default value is `0` <br />
  `line_breaks_after` id the count of line breaks to emit after displaying framed contents

The effective count of line breaks is the maximum value of
`line_breaks_before` and `line_breaks_after` for adjacent rows.

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;
