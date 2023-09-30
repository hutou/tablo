require "./types"
require "./table"

module Tablo
  class Summary(T, U, V)
    private getter data_series = {} of LabelType => NumCol
    private getter summary_sources = [] of Array(StrNum?)
    private getter proc_results = {} of LabelType => Array(StrNum?)
    private getter body_alignments = {} of LabelType => Justify
    private getter header_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler
    private getter headers_styler = {} of LabelType => DataCellStyler
    private getter headers = {} of LabelType => String
    private getter summary_def, summary_options
    private getter table

    def initialize(@table : Table(T), @summary_def : U, @summary_options : V)
    end

    # Returns nil
    private def check_keys
      missing = summary_def.keys - table.column_registry.keys
      unless missing.empty?
        raise LabelNotFound.new "Label #{missing.first} does not exist"
      end
    end

    # Initialize arrays of input and output data, by column
    # Returns nil
    private def initialize_arrays
      summary_def.each do |label, _|
        data_series[label] = [] of Num
        proc_results[label] = [] of StrNum?
      end
    end

    # Browse source data and summary def columns to compute an array of numeric
    # values only (Float64 or Int32)
    # Returns nil
    private def calculate_data_series
      # for each row of data
      table.sources.each_with_index do |source, row_index|
        # for each column used in summary
        summary_def.each do |label, _|
          value = table.column_registry[label].body_cell_value(source, row_index: row_index)
          next if value.nil? || !value.is_a?(Number)
          case value
          when Int
            # data_series[label] << value.as(Int).to_i
            data_series[label] << value.as(Int).to_f64
          when Float
            data_series[label] << value.as(Float).to_f64
          end
        end
      end
    end

    # Browse each column defined in summary def and:
    # - store key parameters for use in summary_table build (add_column)
    # - calculate results of applying summary function procs to input data
    # Returns nil
    private def populate_parameters
      summary_def.each do |column_label, column_def|
        # column_defs is a hash of named tuples for a given columns,
        # it may have several summary data lines  (=several procs)
        column_def.each do |key, value|
          case {key, value}
          when {:header, String}
            headers[column_label] = value
          when {:header_alignment, Justify}
            header_alignments[column_label] = value
          when {:header_formatter, DataCellFormatter}
            header_formatters[column_label] = value
          when {:header_styler, DataCellStyler}
            headers_styler[column_label] = value
          when {:body_alignment, Justify}
            body_alignments[column_label] = value
          when {:body_formatter, DataCellFormatter}
            body_formatters[column_label] = value
          when {:body_styler, DataCellStyler}
            body_stylers[column_label] = value
          when {_, SummaryNumCols}
            proc_results[column_label] << value.call(data_series)
          when {_, SummaryNumCol}
            proc_results[column_label] << value.call(data_series[column_label])
          else
            raise InvalidValue.new("Invalid summary definition key <#{key}>")
          end
        end
      end
    end

    # Reformat results computed by summary functions to summary_table expected
    # sources format
    # Returns nil
    private def calculate_sources
      # puts all summary results them in colum/row matrix for output
      loop do
        ok = false
        summary_source = Array.new(table.column_registry.size, nil.as(StrNum?))
        table.column_registry.each_with_index do |(label, column), column_index|
          if proc_results.has_key?(label) && !proc_results[label].empty?
            summary_source[column_index] = proc_results[label].shift
            ok = true
          end
        end
        if ok
          summary_sources << summary_source
        else
          break
        end
      end
    end

    # Returns the summary table
    protected def run
      check_keys
      initialize_arrays
      calculate_data_series
      populate_parameters
      calculate_sources

      # default_parameters NamedTuple contains parameters copied from the current
      # (main) table instance, which may be default values or given arguments to the
      # Table#initialize method. To ensure optimal styling between :main and :sumary
      # tables, they should be used for summary. However, they can be overriden
      # by summary_options when merging both named tuples.
      default_parameters = {
        border_type:   table.border_type,
        border_styler: table.border_styler,

        # groups are *not* used in summary table

        header_alignment: table.header_alignment,
        header_formatter: table.header_formatter,
        header_styler:    table.header_styler,

        body_alignment: table.body_alignment,
        body_formatter: table.body_formatter,
        body_styler:    table.body_styler,
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

      summary_table = Table.new(summary_sources, **initializers)
      # summary_table has no column defined yet,
      # so we use main table for looping over columns
      table.column_registry.each_with_index do |(label, column), column_index|
        header = headers[label]? || "" # label.to_s
        header_alignment = header_alignments[label]? || summary_table.header_alignment
        header_formatter = header_formatters[label]? || summary_table.header_formatter
        header_styler = headers_styler[label]? || summary_table.header_styler
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
end
