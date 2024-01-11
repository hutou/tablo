require "./types"
require "./table"
require "big"

module Tablo
  class Summary(T, HC, HR, BC, BR, O)
    protected property summary_sources = [] of Array(CellType)
    private getter table

    private getter header_values = {} of LabelType => CellType
    private getter header_alignments = {} of LabelType => Justify
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter header_stylers = {} of LabelType => DataCellStyler

    private getter body_values = {} of LabelType => Hash(Int32, CellType | Proc(CellType))
    private getter body_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler

    private getter aggregations, user_aggregations, header_column, header_row,
      body_column, body_row, options

    private class_property aggr_results = {} of LabelType => Hash(Aggregate, CellType)
    private class_property proc_results = {} of Symbol => CellType

    def self.keep(key_column, key_aggregate, value)
      # # create first hash key if necessary
      unless aggr_results.has_key?(key_column)
        aggr_results[key_column] = {} of Aggregate => CellType
      end
      aggr_results[key_column][key_aggregate] = value
    end

    def self.keep(user_func, value)
      proc_results[user_func] = value
    end

    def self.use(key_column, key_aggregate)
      aggr_results[key_column][key_aggregate]
    end

    def self.use(user_func)
      proc_results[user_func]
    end

    def initialize(@table : Table(T),
                   @aggregations : Hash(LabelType, Array(Aggregate))?,
                   @user_aggregations : Hash(Symbol, Proc(Table(T), CellType) |
                                                     Proc(Enumerable(T), CellType))?,
                   @header_column : HC,
                   @header_row : HR,
                   @body_column : BC,
                   @body_row : BR,
                   @options : O)
    end

    private def compute_user_aggregations(user_aggregations)
      return if user_aggregations.nil? || user_aggregations.empty?
      user_aggregations.each do |key, proc|
        case proc
        in Proc(Table(T), CellType)
          Summary.keep(key, proc.call(table)).as(CellType)
        in Proc(Enumerable(T), CellType)
          Summary.keep(key, proc.call(table.sources)).as(CellType)
        end
      end
    end

    private def compute_aggregations(aggregations)
      return if aggregations.nil? || aggregations.empty?
      running_sum = {} of LabelType => Numbers
      running_min = {} of LabelType => Numbers
      running_max = {} of LabelType => Numbers
      running_count = {} of LabelType => Numbers
      column_aggregates = {} of LabelType => Array(Aggregate)
      aggregations.each do |column_id, aggregates|
        column_aggregates[column_id] = aggregates.as(Array(Aggregate))
      end
      table.sources.each_with_index do |source, index|
        column_aggregates.each do |column_id, aggregates|
          column = table.column_registry[column_id]
          value = column.extractor.call(source, index)
          next if value.nil?
          aggregates.each do |aggregate|
            case aggregate
            when Aggregate::Sum
              if value.is_a?(Number)
                if index.zero?
                  running_sum[column_id] = value
                else
                  running_sum[column_id] += value
                end
              end
            when Aggregate::Count
              if index.zero?
                running_count[column_id] = 1
              else
                running_count[column_id] += 1
              end
            when Aggregate::Min
              if value.is_a?(Number)
                if index.zero?
                  running_min[column_id] = value
                else
                  running_min[column_id] = [running_min[column_id], value].min
                end
              end
            when Aggregate::Max
              if value.is_a?(Number)
                if index.zero?
                  running_max[column_id] = value
                else
                  running_max[column_id] = [running_max[column_id], value].max
                end
              end
            end
          end
        end
      end
      running_count.each do |k, v|
        Summary.keep(k, Aggregate::Count, v).as(CellType)
      end
      running_sum.each do |k, v|
        Summary.keep(k, Aggregate::Sum, v).as(CellType)
      end
      running_min.each do |k, v|
        Summary.keep(k, Aggregate::Min, v).as(CellType)
      end
      running_max.each do |k, v|
        Summary.keep(k, Aggregate::Max, v).as(CellType)
      end
    end

    private def check_keys
      missing = header_column.keys + header_row.keys +
                body_column.keys + body_row.keys - table.column_registry.keys
      unless missing.empty?
        raise LabelNotFound.new "Label #{missing.first} does not exist"
      end
    end

    # Returns the summary table
    def run
      # check columns keys
      check_keys

      # Process aggregations
      compute_aggregations(aggregations)
      compute_user_aggregations(user_aggregations)

      # process header_column
      header_column.each do |column_label, header_attributes|
        header_attributes.each do |attribute, value|
          case {attribute, value}
          when {:alignment, Justify}
            header_alignments[column_label] = value.as(Justify)
          when {:formatter, DataCellFormatter}
            header_formatters[column_label] = value.as(DataCellFormatter)
          when {:styler, DataCellStyler}
            header_stylers[column_label] = value.as(DataCellStyler)
          else
            raise InvalidSummaryDefinition.new("Summary: invalid header column definition !")
          end
        end
      end

      # process header_row
      header_row.each do |column_label, value|
        header_values[column_label] = value.as(CellType)
      end

      # process body_column
      body_column.each do |column_label, body_attributes|
        body_attributes.each do |attribute, value|
          case {attribute, value}
          when {:alignment, Justify}
            body_alignments[column_label] = value.as(Justify)
          when {:formatter, DataCellFormatter}
            body_formatters[column_label] = value.as(DataCellFormatter)
          when {:styler, DataCellStyler}
            body_stylers[column_label] = value.as(DataCellStyler)
          else
            raise InvalidSummaryDefinition.new("Summary: invalid header column definition !")
          end
        end
      end

      # process body_row
      defined_rows = [] of Int32
      body_row.each do |column_label, rows|
        colrow = [] of Int32
        rows.each do |row|
          row_num = row[0]
          row_value = row[1]
          if colrow.index(row_num).nil?
            defined_rows << row_num
            colrow << row_num
          else
            raise DuplicateSummaryColumnRow.new("Summary: body definition conflict (row/col already used).")
          end
          unless body_values.has_key?(column_label)
            body_values[column_label] = {} of Int32 => CellType | Proc(CellType)
          end
          case row_value
          when Proc(CellType)
            body_values[column_label][row_num] = row_value.call.as(CellType)
          when CellType
            body_values[column_label][row_num] = row_value.as(CellType)
          end
        end
      end
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end

      row_number = {} of Int32 => Int32
      defined_rows.sort!.uniq!.each_with_index do |row, index|
        row_number[row] = index
      end

      # Create an array of n columns by p rows of type CellType? = nil
      row_number.size.times do
        summary_sources << Array.new(table.column_registry.size, nil.as(CellType))
      end

      # and fills it with body_values
      #
      body_values.each do |column_label, body_rows|
        body_rows.each do |body_row|
          row = body_row[0]
          value = body_row[1]
          summary_sources[row_number[row]][column_number[column_label]] = value.as(CellType)
        end
      end
      # default_parameters NamedTuple contains parameters copied from the current
      # (main) table instance, which may be default values or given arguments to the
      # Table#initialize method. To ensure optimal styling between :main and :sumary
      # tables, they should be used for summary. However, they can be overriden
      # by summary_options when merging both named tuples.
      default_parameters = {
        border: table.border,

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
      initializers = default_parameters.merge(options)

      # So, in short, :summary_table is initialized by :
      # 1) For the table itself, the initializers variable contents
      # 2) For the columns, either by the parameters existing in summary_def,
      # or by default, those of :summary table, with the exception of some
      # (the last 5 in add_column) which are read from the :main table columns.

      summary_table = Table.new(summary_sources, **initializers)
      # summary_table has no column defined yet,
      # so we use main table for looping over columns
      table.column_registry.each_with_index do |(label, column), column_index|
        header = (header_values[label]? || "").as(String) # label.to_s
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
end
