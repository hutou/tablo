require "./types"
require "./table"

module Tablo
  class Summary(T, U, V)
    private getter data_series = {} of LabelType => Array(SummaryInputTypes)
    private getter body_alignments = {} of LabelType => Justify
    private getter header_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler
    private getter headers_styler = {} of LabelType => DataCellStyler
    private getter headers = {} of LabelType => String
    private getter proc_results = {} of LabelType => Array(SummaryOutputTypes)
    private getter summary_sources = [] of Array(SummaryOutputTypes?)
    private getter summary_def, summary_options
    private getter table

    def initialize(@table : Table(T), @summary_def : U, @summary_options : V)
    end

    def check_keys
      missing = summary_def.keys - table.column_registry.keys
      unless missing.empty?
        raise LabelNotFound.new "Label #{missing.first} does not exist"
      end
    end

    def initialize_arrays
      summary_def.each do |label, _|
        data_series[label] = [] of SummaryInputTypes
        proc_results[label] = [] of SummaryOutputTypes
      end
    end

    def calculate_data_series
      # for each row of data
      table.sources.each_with_index do |source, row_index|
        # for each column used in summary
        summary_def.each do |label, _|
          value = table.column_registry[label].body_cell_value(source, row_index: row_index)
          next if value.nil? || !value.is_a?(Number)
          case value
          when Int
            data_series[label] << value.as(Int).to_i
          when Float
            data_series[label] << value.as(Float).to_f
          end
        end
      end
    end

    def populate_parameters
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
          when {_, SummaryFunction}
            proc_results[column_label] << value.call(data_series[column_label])
          else
            raise InvalidValue.new("Invalid summary definition key <#{key}>")
          end
        end
      end
    end

    def calculate_sources
      # puts all summary results them in colum/row matrix for output
      loop do
        ok = false
        summary_source = Array.new(table.column_registry.size, nil.as(SummaryOutputTypes?))
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

    def run
      check_keys
      initialize_arrays
      calculate_data_series
      populate_parameters
      calculate_sources

      # default_parameters NamedTuple contains parameters copied from the current
      # (main) table instance, which may be default values or given arguments to the
      # Table#initialize method
      default_parameters = {
        # parameters copied from the main table
        border_type:   table.border_type,
        border_styler: table.border_styler,

        # groups are *not* used in summary table

        # These parameters may also be set in summary_def
        header_alignment: table.header_alignment,
        header_formatter: table.header_formatter,
        header_styler:    table.header_styler,

        body_alignment: table.body_alignment,
        body_formatter: table.body_formatter,
        body_styler:    table.body_styler,
      }
      # default parameters may be overriden by summary options
      initializers = default_parameters.merge(summary_options)

      # 'Summary_table' is initialized by :
      # 1) The Table parameters with their default value or given
      # arguments, (as stated in the Table initialize method), altered
      # by the merging of the 'summary_options' parameters
      # 2) The column parameters taken from the Table default parameters,
      # possibly overriden by the allowed parameters of summary_def, and
      # from the main table columns

      # TODO
      # TODO Here we use the standard NamedTuple.merge method
      # TODO See the transpose method which uses the Util.update method : why ???
      # TODO To be investigated !!!
      # TODO
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
          # following parameters are read from the main table column
          left_padding: column.left_padding,
          right_padding: column.right_padding,
          padding_character: column.padding_character,
          truncation_indicator: column.truncation_indicator,
          width: column.width,
        ) { |n| n[column_index] }
      end
      summary_table
    end
  end
end
