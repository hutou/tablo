require "./types"
require "./table"

module Tablo
  class Summary(T, U, V)
    private getter data_series = {} of LabelType => Array(CellType)
    # private getter proc_results = {} of LabelType => Array(CellType)
    # private getter proc_results = {} of LabelType => Hash(Int32, Array(CellType))
    private getter proc_results = {} of LabelType => Hash(Int32, CellType)
    private getter summary_sources = [] of Array(CellType)
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
      pp! typeof(@summary_def)
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
        data_series[label] = [] of CellType
        proc_results[label] = Hash(Int32, CellType).new
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
          # p! typeof(table.column_registry[label].body_cell_value(source, row_index: row_index).as(CellType))
          # p! typeof(data_series[label])
          # data_series[label] << 1
          data_series[label] << table.column_registry[label].body_cell_value(source, row_index: row_index).as(CellType)
          # case value
          # when Int
          #   data_series[label] << value.as(Int).to_i32
          # when Float
          #   data_series[label] << value.as(Float).to_f64
          # else
          #   # All other values must be set to nil, not ignored, in order to
          #   # keep source data rows in sync.
          #   data_series[label] << nil
          # end
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
            # when {:proc1, SummaryColRow}
            #   p! "coucou 1 !"
            #   row = value[0].as(Int32)
            #   proc = (value[1]).as(SummaryCols)
            #   p! typeof(row)
            #   p! typeof(proc)
            #   proc_results[column_label][row] = proc.call(data_series)
            #   p! proc_results
            #   # proc_results[column_label][row] << 33.as(CellType)
          when {:proc, SummaryProcs}
            p "Ça match !"
            pp! SummaryProcs
            p ""
            value.as(Array).each do |rowproc|
              p! "toto!"
              p! typeof(rowproc)
              p! rowproc.class
              row = rowproc[0]
              proc = rowproc[1]
              p! proc
              p! proc.class
              case proc
              when SummaryCols
                p! "coucou cols !"
                # row = rowproc[0]
                # proc = rowproc[1].class

                if proc_results[column_label].has_key?(row)
                  raise "Duplicate key"
                else
                  proc_results[column_label][row] = proc.as(SummaryCols).call(data_series)
                  p proc_results
                end
              when SummaryCol
                p! "coucou col !"
                # row = rowproc[0]
                # proc = rowproc[1]

                if proc_results[column_label].has_key?(row)
                  raise "Duplicate key"
                else
                  proc_results[column_label][row] = proc.as(SummaryCol).call((data_series)[column_label])
                  p proc_results
                end
              else
                p! "NO MATCH !!!"
              end
            end
          else
            p "Ça ne match pas !"
            p! SummaryProcs
            # if key == :proc
            # value.as(Array(SummaryColsRow)).each do |rowproc|
            # value.as(Array).each do |rowproc|
            #   p! "toto!"
            #   p! typeof(rowproc)
            #   p! rowproc.class
            #   if rowproc.class == SummaryColsRow
            #     p! "coucou 1 !"
            #     row = rowproc[0]
            #     proc = rowproc[1]

            #     if proc_results[column_label].has_key?(row)
            #       raise "Duplicate key"
            #     else
            #       proc_results[column_label][row] = proc.call(data_series)
            #     end
            #     p! proc_results
            #     # elsif rowproc.is_a?(SummaryColRow)
            #     #   p! "coucou 2 !"
            #     #   row = rowproc[0]
            #     #   proc = rowproc[1]

            #     #   if proc_results[column_label].has_key?(row)
            #     #     raise "Duplicate key"
            #     #   else
            #     #     proc_results[column_label][row] = proc.call(data_series[column_label])
            #     #   end
            #   end
            # end
            # else
            raise InvalidValue.new("Invalid summary definition key <#{key}>")
          end
          # when {:proc, SummaryColsRow}
          #   p! "coucou 2 !"
          #   row = value[0].as(Int32)
          #   proc = (value[1]).as(SummaryCols)
          #   p! typeof(row)
          #   p! typeof(proc)
          #   proc_results[column_label][row] = proc.call(data_series)
          #   p! proc_results
          #   # proc_results[column_label][row] << 33.as(CellType)
          # else
          #   # p! typeof(key)
          #   # p! value[0]
          #   # p! typeof(value[0])
          #   # p! typeof(value[1])
          #   raise InvalidValue.new("Invalid summary definition key <#{key}>")
          # end
        end
      end
    end

    private def new_populate_parameters
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
            # when {:proc1, SummaryColRow}
            #   p! "coucou 1 !"
            #   row = value[0].as(Int32)
            #   proc = (value[1]).as(SummaryCols)
            #   p! typeof(row)
            #   p! typeof(proc)
            #   proc_results[column_label][row] = proc.call(data_series)
            #   p! proc_results
            #   # proc_results[column_label][row] << 33.as(CellType)
          else
            if key == :proc
              # value.as(Array(SummaryColsRow)).each do |rowproc|
              value.as(Array).each do |rowproc|
                p! "toto!"
                p! typeof(rowproc)
                p! rowproc.class
                if rowproc.class == SummaryColsRow
                  p! "coucou 1 !"
                  row = rowproc[0]
                  proc = rowproc[1]

                  if proc_results[column_label].has_key?(row)
                    raise "Duplicate key"
                  else
                    proc_results[column_label][row] = proc.call(data_series)
                  end
                  p! proc_results
                  # elsif rowproc.is_a?(SummaryColRow)
                  #   p! "coucou 2 !"
                  #   row = rowproc[0]
                  #   proc = rowproc[1]

                  #   if proc_results[column_label].has_key?(row)
                  #     raise "Duplicate key"
                  #   else
                  #     proc_results[column_label][row] = proc.call(data_series[column_label])
                  #   end
                end
              end
            else
              raise InvalidValue.new("Invalid summary definition key <#{key}>")
            end
          end
          # when {:proc, SummaryColsRow}
          #   p! "coucou 2 !"
          #   row = value[0].as(Int32)
          #   proc = (value[1]).as(SummaryCols)
          #   p! typeof(row)
          #   p! typeof(proc)
          #   proc_results[column_label][row] = proc.call(data_series)
          #   p! proc_results
          #   # proc_results[column_label][row] << 33.as(CellType)
          # else
          #   # p! typeof(key)
          #   # p! value[0]
          #   # p! typeof(value[0])
          #   # p! typeof(value[1])
          #   raise InvalidValue.new("Invalid summary definition key <#{key}>")
          # end
        end
      end
    end

    private def old_populate_parameters
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
          when {:proc, SummaryColRow}
            # when {:proc, Tuple(Int32, Proc(Array(CellType), CellType))}
            row = value[0].as(Int32)
            proc = (value[1]).as(SummaryCol)
            p! typeof(row)
            p! typeof(proc)
            proc_results[column_label][row] = proc.call(data_series[column_label])
            p! proc_results
            # proc_results[column_label][row] = 42.as(CellType)
          when {:proc, SummaryColsRow}
            row = value[0].as(Int32)
            proc = (value[1]).as(SummaryCols)
            p! typeof(row)
            p! typeof(proc)
            proc_results[column_label][row] = proc.call(data_series)
            p! proc_results
            # proc_results[column_label][row] << 33.as(CellType)
          else
            p! typeof(key)
            p! value[0]
            p! typeof(value[0])
            p! typeof(value[1])
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
      row = 0
      loop do
        ok = false
        summary_source = Array.new(table.column_registry.size, nil.as(CellType))
        table.column_registry.each_with_index do |(label, column), column_index|
          if proc_results.has_key?(label)
            proc_results[label].each do |k, v|
              if k == row
                summary_source[column_index] = proc_results[label][k]
                ok = true
              end
            end
          end
        end
        if ok
          summary_sources << summary_source
        else
          break
        end
        row += 1
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
