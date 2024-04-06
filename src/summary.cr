require "./types"
require "./table"

module Tablo
  # The purpose of the Summary class is to calculate and format aggregated
  # source data in a dedicated table, closely linked to the main table.
  class Summary(T, U, V)
    private getter summary_definition, summary_options, table
    private getter summary_sources = [] of Array(CellType)

    private getter header_values = {} of LabelType => CellType
    private getter header_alignments = {} of LabelType => Justify
    private getter header_formatters = {} of LabelType => Cell::Data::Formatter
    private getter header_stylers = {} of LabelType => Cell::Data::Styler

    private getter body_values = {} of LabelType => Hash(Int32, CellType | Proc(CellType))
    private getter body_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => Cell::Data::Formatter
    private getter body_stylers = {} of LabelType => Cell::Data::Styler

    private class_property proc_results = {} of Symbol => CellType

    # Summary class constructor
    #
    # _Mandatory parameters:_
    #
    # - `table`: type is Table(T) <br />
    #   This parameter references the main table
    #
    # - `summary_definition`: its type is U, as its content is a user defined
    # array containing `n` instances of `SummaryProc`, `SummaryHeaderColumn`,
    # `SummaryBodyColumn`, `SummaryBodyRow` structs)
    #
    # - `summary_options`: its type is V, a NamedTuple of Table initializers (may be
    # empty)
    #
    # Here is a complete and functional example of Detail and Summary tables
    # "working" together (See relevant infos on usage in structs listed above)
    # ```
    # require "tablo"
    # require "colorize"
    # require "big"
    #
    # struct BigDecimal
    #   include Tablo::CellType
    # end
    #
    # struct InvoiceItem
    #   getter product, quantity, price
    #
    #   def initialize(@product : String, @quantity : Int32?, @price : BigDecimal?)
    #   end
    # end
    #
    # invoice = [
    #   InvoiceItem.new("Laptop", 3, BigDecimal.new(980)),
    #   InvoiceItem.new("Printer", 2, BigDecimal.new(154.99)),
    #   InvoiceItem.new("Router", 1, BigDecimal.new(99)),
    #   InvoiceItem.new("Switch", nil, BigDecimal.new(45)),
    #   InvoiceItem.new("Accessories", 5, BigDecimal.new(64.50)),
    # ]
    #
    # invoice_summary_definition = [
    #   Tablo::SummaryProc.new(
    #     proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    #       total_sum = BigDecimal.new(0)
    #       tbl.column_data(:total).each do |tot|
    #         total_sum += tot.as(BigDecimal) unless tot.nil?
    #       end
    #       discount = total_sum * 0.05
    #       total_after_discount = total_sum - discount
    #       tax = total_after_discount * 0.2
    #       total_due = total_after_discount + tax
    #       {
    #         :total_sum            => total_sum.as(Tablo::CellType),
    #         :discount             => discount.as(Tablo::CellType),
    #         :total_after_discount => total_after_discount.as(Tablo::CellType),
    #         :tax                  => tax.as(Tablo::CellType),
    #         :total_due            => total_due.as(Tablo::CellType),
    #       }
    #     }),
    #   Tablo::SummaryBodyColumn.new("Price", alignment: Tablo::Justify::Right),
    #   Tablo::SummaryBodyColumn.new(:total, alignment: Tablo::Justify::Right,
    #     formatter: ->(value : Tablo::CellType) {
    #       value.is_a?(String) ? value : (
    #         value.nil? ? "" : "%.2f" % value.as(BigDecimal)
    #       )
    #     },
    #     styler: ->(_value : Tablo::CellType, cd : Tablo::Cell::Data::Coords, fc : String) {
    #       case cd.row_index
    #       when 0, 2, 5 then fc.colorize.mode(:bold).to_s
    #       when 1       then fc.colorize.mode(:italic).to_s
    #       else              fc
    #       end
    #     }),
    #   Tablo::SummaryHeaderColumn.new("Product", content: ""),
    #   Tablo::SummaryHeaderColumn.new("Quantity", content: ""),
    #   Tablo::SummaryHeaderColumn.new("Price", content: "Total Invoice",
    #     alignment: Tablo::Justify::Right),
    #   Tablo::SummaryHeaderColumn.new(:total, content: "Amounts"),
    #
    #   Tablo::SummaryBodyRow.new("Price", 10, "SubTotal"),
    #   Tablo::SummaryBodyRow.new("Price", 20, "Discount 5%"),
    #   Tablo::SummaryBodyRow.new("Price", 30, "S/T after discount"),
    #   Tablo::SummaryBodyRow.new("Price", 40, "Tax (20%)"),
    #   Tablo::SummaryBodyRow.new("Price", 60, "Balance due"),
    #
    #   Tablo::SummaryBodyRow.new(:total, 10, ->{ Tablo::Summary.use(:total_sum) }),
    #   Tablo::SummaryBodyRow.new(:total, 20, ->{ Tablo::Summary.use(:discount) }),
    #   Tablo::SummaryBodyRow.new(:total, 30, ->{ Tablo::Summary.use(:total_after_discount) }),
    #   Tablo::SummaryBodyRow.new(:total, 40, ->{ Tablo::Summary.use(:tax) }),
    #   Tablo::SummaryBodyRow.new(:total, 50, "========"),
    #   Tablo::SummaryBodyRow.new(:total, 60, ->{ Tablo::Summary.use(:total_due) }),
    # ]
    #
    # table = Tablo::Table.new(invoice,
    #   omit_last_rule: true,
    #   border: Tablo::Border.new(Tablo::BorderName::Fancy),
    #   title: Tablo::Title.new("\nInvoice\n=======\n"),
    #   subtitle: Tablo::SubTitle.new("Details", frame: Tablo::Heading::Frame.new)) do |t|
    #   t.add_column("Product",
    #     &.product)
    #   t.add_column("Quantity",
    #     body_formatter: ->(value : Tablo::CellType) {
    #       (value.nil? ? "N/A" : value.to_s)
    #     }, &.quantity)
    #   t.add_column("Price",
    #     body_formatter: ->(value : Tablo::CellType) {
    #       "%.2f" % value.as(BigDecimal)
    #     }, &.price.as(Tablo::CellType))
    #   t.add_column(:total, header: "Total",
    #     body_formatter: ->(value : Tablo::CellType) {
    #       value.nil? ? "" : "%.2f" % value.as(BigDecimal)
    #     }) { |n| n.price.nil? || n.quantity.nil? ? nil : (
    #     n.price.as(BigDecimal) *
    #       n.quantity.as(Int32)
    #   ).as(Tablo::CellType) }
    # end
    #
    # table.pack
    # table.add_summary(invoice_summary_definition,
    #   title: Tablo::Title.new("Summary", frame: Tablo::Heading::Frame.new))
    # table.summary.as(Tablo::Table).pack
    # puts table
    # puts table.summary
    # ```
    # output (styling disabled):
    # ```
    #
    #                           Invoice
    #                           =======
    #
    # ╭────────────────────────────────────────────────────────╮
    # │                         Details                        │
    # ├─────────────┬──────────┬────────────────────┬──────────┤
    # │ Product     : Quantity :              Price :    Total │
    # ├-------------┼----------┼--------------------┼----------┤
    # │ Laptop      :        3 :             980.00 :  2940.00 │
    # │ Printer     :        2 :             154.99 :   309.98 │
    # │ Router      :        1 :              99.00 :    99.00 │
    # │ Switch      : N/A      :              45.00 :          │
    # │ Accessories :        5 :              64.50 :   322.50 │
    # ├─────────────┴──────────┴────────────────────┴──────────┤
    # │                         Summary                        │
    # ├─────────────┬──────────┬────────────────────┬──────────┤
    # │             :          :      Total Invoice :  Amounts │
    # ├-------------┼----------┼--------------------┼----------┤
    # │             :          :           SubTotal :  3671.48 │
    # │             :          :        Discount 5% :   183.57 │
    # │             :          : S/T after discount :  3487.91 │
    # │             :          :          Tax (20%) :   697.58 │
    # │             :          :                    : ======== │
    # │             :          :        Balance due :  4185.49 │
    # ╰─────────────┴──────────┴────────────────────┴──────────╯
    # ```
    # A few points of note <br />
    # - Use of the `BigDecimal` type (not included in Tablo by default, but made
    #   possible by reopening the `BigDecimal` struct and adding the `include CellType`
    #   statement).
    # - Joining of the summary table to the main table, with the main table's
    # `omit_last_rule` parameter set to `true`.
    # - Row numbers need not be consecutive. What's important is that their
    # order is well defined, as they will ultimately be replaced by their index
    # in a sorted array of row values.
    # - To obtain optimal result in packing, the main table must be packed
    #   before summary table definition.
    def initialize(@table : Table(T),
                   @summary_definition : U,
                   @summary_options : V)
    end

    # Class method to save results of calculations
    protected def self.keep(user_func, value)
      proc_results[user_func] = value.as(CellType)
    end

    # Class method to retrieve and use results of saved calculations
    # by key (which is of type Symbol).
    #
    # For example, to populate row 1 of column `:total` with the result of
    # a previous calculation identified by `:total_sum`:
    # ```
    # Tablo::SummaryBodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum) })
    # ```
    def self.use(key)
      proc_results[key]
    end

    # Scans the summary definition to group entries of the same type and then
    # processes them in the appropriate order.
    private def build_summary
      summary_procs = [] of SummaryProc(T)
      body_rows = [] of SummaryBodyRow
      body_columns = [] of SummaryBodyColumn
      header_columns = [] of SummaryHeaderColumn
      summary_definition.each do |sd|
        case sd
        when SummaryProc(T)
          summary_procs << sd
        when SummaryBodyRow
          body_rows << sd
        when SummaryBodyColumn
          body_columns << sd
        when SummaryHeaderColumn
          header_columns << sd
        end
      end
      unless summary_procs.empty?
        build_summary_procs(summary_procs)
      end
      unless body_rows.empty?
        build_body_rows(body_rows)
      end
      unless body_columns.empty?
        build_body_columns(body_columns)
      end
      unless header_columns.empty?
        build_header_columns(header_columns)
      end
    end

    # Execute summary procs and save their results
    private def build_summary_procs(summary_procs)
      summary_procs.each do |entry|
        entry.proc.call(table).each do |k, v|
          Summary.keep(k, v)
        end
      end
    end

    # define Headers : content and format
    private def build_header_columns(header_columns)
      duplicates = {} of LabelType => Int32
      header_columns.each do |entry|
        if entry.column.is_a?(Array(LabelType))
          columns = entry.column # .as(Array(LabelType))
        else
          columns = [entry.column.as(LabelType)]
        end
        columns.as(Array(LabelType)).each do |column|
          if duplicates.has_key?(column)
            raise Exception::DuplicateKey.new(
              "Summary: duplicate header column definition for column<#{column}>")
          else
            duplicates[column] = 1
            header_values[column] = entry.content
            unless entry.alignment.nil?
              header_alignments[column] = entry.alignment.as(Justify)
            end
            unless entry.formatter.nil?
              header_formatters[column] = entry.formatter.as(Cell::Data::Formatter)
            end
            unless entry.styler.nil?
              header_stylers[column] = entry.styler.as(Cell::Data::Styler)
            end
          end
        end
      end
    end

    # Defines body rows and populate Summary table source
    private def build_body_rows(body_rows)
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end
      defined_rows = [] of Int32
      duplicates = {} of {LabelType, Int32} => Int32
      body_rows.each do |entry|
        if duplicates.has_key?({entry.column, entry.row})
          raise Exception::DuplicateKey.new(
            "Summary: duplicate body definition, row<#{entry.row}> for column<#{entry.column}> already used.")
        else
          defined_rows << entry.row
          duplicates[{entry.column, entry.row}] = 1
        end
        unless body_values.has_key?(entry.column)
          body_values[entry.column] = {} of Int32 => CellType | Proc(CellType)
        end
        case entry.content
        when CellType
          body_values[entry.column][entry.row] = entry.content
        when Proc(CellType)
          body_values[entry.column][entry.row] = entry.content.as(Proc(CellType)).call
        end
      end
      row_number = {} of Int32 => Int32
      defined_rows.sort!.uniq!.each_with_index do |row, index|
        row_number[row] = index
      end
      row_number.size.times do |i|
        summary_sources << Array.new(table.column_registry.size, nil.as(CellType))
      end
      body_values.each do |column_label, body_rows|
        body_rows.each do |body_row|
          row = body_row[0]
          value = body_row[1]
          summary_sources[row_number[row]][column_number[column_label]] = value.as(CellType)
        end
      end
    end

    # Body columns format
    private def build_body_columns(body_columns)
      duplicates = {} of LabelType => Int32
      body_columns.each do |entry|
        if entry.column.is_a?(Array(LabelType))
          columns = entry.column
        else
          columns = [entry.column.as(LabelType)] # .as(Array(LabelType)) # .as(Array(LabelType))
        end
        columns.as(Array(LabelType)).each do |column|
          if duplicates.has_key?(column)
            raise Exception::DuplicateKey.new(
              "Summary: duplicate body column definition for column<#{column}>")
          else
            duplicates[column] = 1
            unless entry.alignment.nil?
              body_alignments[column] = entry.alignment.as(Justify)
            end
            unless entry.formatter.nil?
              body_formatters[column] = entry.formatter.as(Cell::Data::Formatter)
            end
            unless entry.styler.nil?
              body_stylers[column] = entry.styler.as(Cell::Data::Styler)
            end
          end
        end
      end
    end

    # Returns the summary table
    protected def run
      build_summary
      # Parameters taken from the main table
      default_parameters = {
        border: table.border,
        # groups are *not* used in summary table
        header_alignment: table.header_alignment,
        header_formatter: table.header_formatter,
        header_styler:    table.header_styler,
        body_alignment:   table.body_alignment,
        body_formatter:   table.body_formatter,
        body_styler:      table.body_styler,
      }

      # Here we use the stdlib NamedTuple.merge method, which ensures
      # all summary_options elements will be added to initializers, possibly
      # updating those of default_parameters
      initializers = default_parameters.merge(summary_options)

      # So, in short, :summary_table is initialized by :
      # 1) For the table itself, the initializers variable contents
      # 2) For the columns, either by the parameters existing in summary_def,
      # or by default, those of :summary table, with the exception of some
      # (the last 5 in add_column) which are read from the :main table columns.

      # save self (which is main)
      summary_table = Table.new(summary_sources, **initializers)
      # summary_table = table.summary_table.as(Table)
      # summary_table has no column defined yet,
      # so we use main table for looping over columns
      table.column_registry.each_with_index do |(label, column), column_index|
        header = header_values.has_key?(label) ? header_values[label].as(String) : column.header
        header_alignment = header_alignments[label]? || summary_table.header_alignment
        header_formatter = header_formatters[label]? || summary_table.header_formatter
        header_styler = header_stylers[label]? || summary_table.header_styler
        body_alignment = body_alignments[label]? || summary_table.body_alignment
        body_formatter = body_formatters[label]? || summary_table.body_formatter
        body_styler = body_stylers[label]? || summary_table.body_styler
        summary_table.add_column(label: label,
          header: header,
          header_alignment: header_alignment,
          header_formatter: header_formatter,
          header_styler: header_styler,
          body_alignment: body_alignment,
          body_formatter: body_formatter,
          body_styler: body_styler,
          # following parameters are read from the main table columns
          left_padding: column.left_padding,
          right_padding: column.right_padding,
          padding_character: column.padding_character,
          truncation_indicator: column.truncation_indicator,
          width: column.width,
        ) { |n| n[column_index] }
      end
      summary_table.name = :summary
      summary_table
    end
  end

  # The `SummaryProc` struct lets you define specific functions to be applied
  # to source data, accessible either by column or directly from the source,
  # in order to provide aggregated results.
  struct SummaryProc(T)
    protected getter proc

    # The constructor's only parameter is a Proc, which in turn expects
    # a Table(T) as its only parameter.
    #
    # The Proc must return a hash of results (of type CellType), which are
    # automatically saved for future use (See `Summary.use` method
    # in `SummaryBodyRow`).
    #
    # Example of accessing data directly from source:
    # ```
    # struct InvoiceItem
    #   getter product, quantity, price
    #
    #   def initialize(@product : String, @quantity : Int32?, @price : Int32?)
    #   end
    # end
    #
    # Tablo::SummaryProc.new(
    #   proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    #     total_sum = 0
    #     tbl.sources.each do |row|
    #       next unless row.quantity.is_a?(Int32) && row.price.is_a?(Int32)
    #       total_sum += row.quantity.as(Int32) * row.price.as(Int32)
    #     end
    #     {:total_sum => total_sum.as(Tablo::CellType)}
    #   })
    # ```
    # Another example, this time using column access, with iterators, and
    # returning several results.
    # ```
    # Tablo::SummaryProc.new(
    #   proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    #     total_sum = total_count = max_price = 0
    #     iter_quantity = tbl.column_data("Quantity").each
    #     iter_price = tbl.column_data("Price").each
    #     iter = iter_quantity.zip(iter_price)
    #     iter.each do |q, p|
    #       next unless q.is_a?(Int32) && p.is_a?(Int32)
    #       total_sum += q * p
    #       total_count += 1
    #       max_price = [max_price, p].max
    #     end
    #     {
    #       :total_count => total_count.as(Tablo::CellType),
    #       :total_sum   => total_sum.as(Tablo::CellType),
    #       :max_price   => max_price.as(Tablo::CellType),
    #     }
    #   })
    # ```
    def initialize(@proc : Proc(Table(T), Hash(Symbol, CellType)))
    end
  end

  # The `SummaryHeaderColumn` struct lets you define header content and specific
  # alignment, formatting and styling
  struct SummaryHeaderColumn
    protected getter column, content, alignment, formatter, styler

    # The constructor expects up to 5 parameters, the first 2 being mandatory
    #
    # - `column` : type if `LabelType` <br />
    #    It is the column identifier.
    #
    # - `content` : type is String <br />
    #    (may be empty)
    #
    # - The last three are optional (`alignment`, `formatter` and `styler`)
    #
    # Examples:
    # ```
    # Tablo::SummaryHeaderColumn.new("Price",
    #   content: "Total Invoice",
    #   alignment: Tablo::Justify::Right),
    # Tablo::SummaryHeaderColumn.new(:total,
    #   content: "Amounts",
    #   styler: ->(s : String) {s.colorize(:red).to_s}),
    # ```
    def initialize(@column : LabelType | Array(LabelType),
                   @content : String,
                   @alignment : Justify? = nil,
                   @formatter : Cell::Data::Formatter? = nil,
                   @styler : Cell::Data::Styler? = nil)
    end
  end

  # The `SummaryBodyColumn` struct lets you define specific
  # alignment, formatting and styling on body columns.
  struct SummaryBodyColumn
    protected getter column, alignment, formatter, styler

    # The constructor expects up to 4 parameters, of which the first, the
    # column identifier, is the only mandatory one (but it goes without saying
    # that at least one of the 3 optional parameters must be defined!)
    #
    # - `column` : type is `LabelType`
    #
    # - The last three optional parameters are (`alignment`,
    #   `formatter` and `styler`)
    #
    # Example:
    # ```
    # Tablo::SummaryBodyColumn.new(:total, alignment: Tablo::Justify::Right,
    #   formatter: ->(value : Tablo::CellType) {
    #     value.is_a?(String) ? value : (
    #       value.nil? ? "" : "%.2f" % value.as(BigDecimal)
    #     )
    #   },
    #   styler: ->(_value : Tablo::CellType, cd : Tablo::Cell::Data::Coords, fc : String) {
    #     case cd.row_index
    #     when 0, 2, 5 then fc.colorize.mode(:bold).to_s
    #     when 1       then fc.colorize.mode(:italic).to_s
    #     else              fc
    #     end
    #   }),
    # ```
    def initialize(@column : LabelType | Array(LabelType),
                   @alignment : Justify? = nil,
                   @formatter : Cell::Data::Formatter? = nil,
                   @styler : Cell::Data::Styler? = nil)
    end
  end

  # The `SummaryBodyRow` struct lets you define body rows content
  struct SummaryBodyRow
    protected getter column, row, content

    # The constructor expects 3 mandatory parameters.
    #
    # - `column` : type is `LabelType`, the column identifier
    #
    # - `row` : type is `Int32`, the row number
    #
    # - `content` : type is `CellType` or a Proc returning a `CellType`
    #
    # `column` and `row` define the precise location of the aggregated value in the
    # Summary table. Row numbers need not be contiguous; what's important is that
    # they allow results to be displayed in the desired row order.
    #
    # Example of `content` directly fed by a literal string:
    # ```
    # Tablo::SummaryBodyRow.new("Price", 40, "Tax (20%)")
    # Tablo::SummaryBodyRow.new("Price", 60, "Balance due"),
    # ```
    #  Example of `content` fed by a proc returning a `CellType` value:
    # ```
    # Tablo::SummaryBodyRow.new(:total, 40, ->{ Tablo::Summary.use(:tax) }),
    # Tablo::SummaryBodyRow.new(:total, 60, ->{ Tablo::Summary.use(:total_due) }),
    # ```
    #
    # **Important**:
    # Note here the use of the `Summary.use` class method, which retrieves, via
    # a Symbol key, an aggregated value previously calculated in
    # a `SummaryProc`  instance.
    def initialize(@column : LabelType,
                   @row : Int32,
                   @content : CellType | Proc(CellType))
    end
  end
end
