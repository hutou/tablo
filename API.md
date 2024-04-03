# Tablo API

## Tablo internals

[:top:](#tablo-api)
[:arrow_up:](#table-of-contents)
[:arrow_down:](#struct-border)

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

## struct Border

[:top:](#tablo-api)
[:arrow_up:](#tablo-internals)
[:arrow_down:](#class-table)
[:arrow_lower_right:](#border-method-initialize)

A border type is defined by a 16-character string, consisting of vertical or
horizontal separator characters and junction or intersection characters.

It can be styled by a user defined proc, of type `BorderStyler` allowing
for colorized output, either by using ANSI sequences or "colorize"
module (default: no style)

(See the [Tutorial](tutorial.md#borders) for details on definition
string and predefined border names)

### Border method `initialize`

[:top:](#tablo-api)
[:arrow_upper_left:](#struct-border)
[:arrow_lower_left:](#class-table)

Returns an instance of `Border`

_Optional parameters, with default values_

- `border_type`: type is `String` or `BorderName` <br />
  Default set by `Config.border_type` <br />

- `styler`: type is BorderStyler <br />
  Default set by `Config.border_styler`

## class Table

### Method `summary`

[:top:](#tablo-api)
[:arrow_up:](#method-pack)
[:arrow_down:](#method-transpose)

The Summary method allows you to perform aggregation calculations on
detailed data, and define their presentation and formatting. To do this,
it creates a new Table instance (of type SummaryTable), which inherits
some of the parameters of the main table. This approach allows you to
display the 2 tables as if they were a single table, or to display them
separately.

The summary method is an overloaded method that serves two different purposes:

- The first is to define the various elements making up the summary
  presentation. It accepts 2 parameters, the first
  (`summary_definition`) is an array of datatype instances and the
  second `options` is a `NamedTuple`, containing table creation
  parameters overriding inherited values. There are 6 (`struct`) types,
  each of which can define several instances, grouped together in an
  array, which constitutes the method's first argument. The second
  argument (`options`), allows you to customize the Summary table, which
  otherwise inherits from the main table.

- The second is to return an instance of the table thus created, ready for
  display.

Let's take a look at the contents of the first parameter of the summary
method, in its defined version. It's an array of data type instances, as
detailed below:

#### `Aggregation` type

The `Aggregation` type is used to calculate an aggregated value for all
the data in a column. An aggregated value is of type `Aggregate`, an
`enum` that can take the values `Sum`, `Count`, `Min` and `Max`. `Nil`
values are ignored, and for `Sum`, `Min` and `Max` aggregates, only
numerical data are taken into account. The definition of `struct
Aggregation` is as follows:

```crystal
record Aggregation, column : LabelType | Array(LabelType),
                    aggregate : Aggregate | Array(Aggregate)
```

and therefore includes 2 parameters :

- The relevant data column(s)
- The aggregate(s) to be calculated on them

**Whatever the number of defined `Aggregation` instances, the number
of columns and aggregates in each of them, the dataset is read only
once (but indirectly through user defined column extractors).**

Here are some sample declarations:

- `Tablo::Aggregation.new("Column one", Tablo:Aggregate::Sum)` to
  calculate the sum of the numerical data in column "Column one".
- `Tablo::Aggregation.new(["Column one", "Column two].map
&.as(Tablo::LabelType), [Tablo:Aggregate::Count,
Tablo::Aggregate:Max])` to calculate the count of non nil
  elements and the maximum numerical value of columns "Column one"
  and "column two".

  In the event of a duplicate `column/aggregate` pair, the `summary`
  method raises a `DuplicateInSummaryDefinition` exception.

#### `SummaryProc` type

The `SummaryProc` type is used to define custom aggregation
functions. The user has full control over the data, and is therefore
responsible for filtering `nil` values, non-numeric values, etc.

The SummaryProc type definition is:

```crystal
record SummaryProc(S), ident : Symbol,
                           proc : Proc(Table(S), CellType)
```

where :

- `ident` is used to name the function to be created
- `proc` is the source code of the aggregation function itself. This
  function must receive as parameter a variable of type `Table(S)`
  where `S` is the data type of the main table, and must return an
  aggregated value of type `CellType`.

The function can process data in two different ways, either directly
(using `table.sources`) or indirectly (using
`table.column_data(colum)`). In the latter case, the use of iterators
may be necessary if several columns are involved in the calculation.

The following examples illustrate the 2 possible cases, with the aim of
calculating the same result as that obtained previously using
Tablo::Aggregate::Sum

First case, using `table.sources`

```crystal
Tablo::SummaryProc(InvoiceItem).new(
  ident: :total_sum, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
  total_sum = 0
  tbl.sources.each do |row|
    unless row.quantity.nil? || row.price.nil?
      if row.quantity.is_a?(Number) && row.price.is_a?(Number)
        total_sum += row.quantity.as(Int32) * row.price.as(Int32)
      end
    end
  end
  total_sum.as(Tablo::CellType) })
```

or

```crystal
Tablo::SummaryProc(InvoiceItem).new(
  ident: :total_sum, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
  tbl.sources.select { |n| n.quantity.is_a?(Number) && n.price.is_a?(Number) }
    .map { |n| n.quantity.as(Number) * n.price.as(Number) }
    .sum.to_i.as(Tablo::CellType) })
```

Second case, using `table.column_data(column)` with 2 columns, and iterators

```crystal
Tablo::SummaryProc(InvoiceItem).new(
  ident: :total_sum, proc: ->(tbl : Tablo::Table(InvoiceItem)) {
  total_sum = 0
  iter_quantity = tbl.column_data("Quantity").each
  iter_price = tbl.column_data("Price").each
  loop do
    quantity = iter_quantity.next
    price = iter_price.next
    break if quantity == Iterator::Stop::INSTANCE ||
             price == Iterator::Stop::INSTANCE
    next if quantity.nil? || price.nil?
    if quantity.is_a?(Number) && price.is_a?(Number)
      total_sum += quantity.as(Int32) * price.as(Int32)
    end
  end
  total_sum.as(Tablo::CellType) })
```

It's worth noting that the performance of these different approaches is
not the same.

**TODO TODO
TODO TODO
TODO TODO
Benchmark needed !
TODO TODO
TODO TODO
TODO TODO**

#### `SummaryBodyRow` type

```crystal
record SummaryBodyRow, column : LabelType,
                row : Int32,
                content : CellType | Proc(CellType)
```

#### `HeaderRow` type

```crystal
record HeaderRow, column : LabelType,
                  content : CellType
```

#### `SummaryBodyColumn` type

```crystal
record SummaryBodyColumn, column : LabelType,
                   alignment : Justify? = nil,
                   formatter : DataCellFormatter? = nil,
                   styler : DataCellStyler? = nil
```

#### `SummaryHeaderColumn` type

```crystal
record SummaryHeaderColumn, column : LabelType,
                     alignment : Justify? = nil,
                     formatter : DataCellFormatter? = nil,
                     styler : DataCellStyler? = nil
```

### Method `transpose`

[:top:](#tablo-api)
[:arrow_up:](#methodp;summary)
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

```

```
