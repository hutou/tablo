require "./types"
require "./table"
require "big"

module Tablo
  class Summary(T, U, V)
    getter summary_definition, summary_options, table
    property summary_sources = [] of Array(CellType)

    private getter header_values = {} of LabelType => CellType
    private getter header_alignments = {} of LabelType => Justify
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter header_stylers = {} of LabelType => DataCellStyler

    private getter body_values = {} of LabelType => Hash(Int32, CellType | Proc(CellType))
    private getter body_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler

    protected class_property aggr_results = {} of LabelType => Hash(Aggregate, CellType)
    protected class_property proc_results = {} of Symbol | String => CellType

    enum HeaderOrBody
      Header
      Body
    end

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
                   @summary_definition : U,
                   @summary_options : V)
    end

    def build_summary
      # Important : summary_definition keys must be processed by order of priority
      # :aggregation and :user_aggregation first, other keys next

      summary_definition_keys = summary_definition.keys

      if summary_definition.has_key?(:aggregation)
        build_aggregation(summary_definition[:aggregation])
        summary_definition_keys -= [:aggregation]
      end

      if summary_definition.has_key?(:user_aggregation)
        build_user_aggregation(summary_definition[:user_aggregation])
        summary_definition_keys -= [:user_aggregation]
      end

      if summary_definition.has_key?(:header_column)
        build_header_body_column(summary_definition[:header_column], HeaderOrBody::Header)
        summary_definition_keys -= [:header_column]
      end

      if summary_definition.has_key?(:header_row)
        build_header_row(summary_definition[:header_row])
        summary_definition_keys -= [:header_row]
      end

      if summary_definition.has_key?(:body_column)
        build_header_body_column(summary_definition[:body_column], HeaderOrBody::Body)
        summary_definition_keys -= [:body_column]
      end

      body_row_key = false # body_row *must* be defined !
      if summary_definition.has_key?(:body_row)
        body_row_key = true
        build_body_row(summary_definition[:body_row])
        summary_definition_keys -= [:body_row]
      end

      unless body_row_key
        raise InvalidSummaryDefinition.new(
          "Summary: invalid definition (:body_row key missing)")
      end
      unless summary_definition_keys.empty?
        raise InvalidSummaryDefinition.new(
          "Summary: invalid definition key(s) <#{summary_definition_keys.join(", ")}>")
      end
    end

    def build_aggregation(aggregation)
      running_sum = {} of LabelType => Numbers
      running_min = {} of LabelType => Numbers
      running_max = {} of LabelType => Numbers
      running_count = {} of LabelType => Numbers
      column_aggregates = {} of LabelType => Array(Aggregate)
      aggregation.each do |column_id, aggregates|
        # debug! column_id
        # debug! aggregates
        case {column_id, aggregates}
        when {LabelType, Array(Aggregate)}
          column_aggregates[column_id] = aggregates.as(Array(Aggregate))
        else
          raise "Error on aggregates"
        end
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

    def build_user_aggregation(user_aggregation)
      debug! user_aggregation
      return if user_aggregation.nil? || user_aggregation.empty?
      user_aggregation.each do |key, proc|
        case proc
        when Proc(Table(T), CellType)
          Summary.keep(key, proc.call(table)).as(CellType)
        when Proc(Enumerable(T), CellType)
          Summary.keep(key, proc.call(table.sources)).as(CellType)
        else
          raise InvalidSummaryDefinition.new(
            "Summary: invalid user_aggregation definition <#{key}>")
        end
      end
    end

    def build_header_row(header_row)
      # debug! header_row
      header_row.each do |column_label, row|
        # debug! row
        case row
        when CellType
          header_values[column_label] = row.as(CellType)
        else
          raise InvalidSummaryDefinition.new(
            "Summary: invalid header row definition <#{row}>")
        end
      end
    end

    def build_body_row(body_row)
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end
      defined_rows = [] of Int32
      body_row.each do |column_label, rows|
        colrow = [] of Int32
        case rows
        when Hash(Int32, CellType | Proc(CellType)),
             Hash(Int32, Proc(CellType)),
             Hash(Int32, CellType)
          rows.each do |row_num, row_value|
            if colrow.index(row_num).nil?
              defined_rows << row_num
              colrow << row_num
            else
              raise DuplicateSummaryColumnRow.new(
                "Summary: body definition conflict (row/col already used).")
            end
            case row_value
            when CellType
              unless body_values.has_key?(column_label)
                body_values[column_label] = {} of Int32 => CellType | Proc(CellType)
              end
              body_values[column_label][row_num] = row_value.as(CellType)
            when Proc(CellType)
              unless body_values.has_key?(column_label)
                body_values[column_label] = {} of Int32 => CellType | Proc(CellType)
              end
              body_values[column_label][row_num] = row_value.call.as(CellType)
            end
          end
        else
          raise InvalidSummaryDefinition.new(
            "Summary: invalid body row definition <#{rows}>")
        end
      end

      row_number = {} of Int32 => Int32
      defined_rows.sort!.uniq!.each_with_index do |row, index|
        row_number[row] = index
      end

      row_number.size.times do
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

    def build_header_body_column(header_body_column, rowtype)
      header_body_column.each do |column_label, columns|
        case columns
        when Hash(Symbol, Tablo::Justify), # alignment
        # Formatters
             Hash(Symbol, Proc(CellType, CellData, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, String)),
             Hash(Symbol, Proc(CellType, Int32, String)),
             Hash(Symbol, Proc(CellType, String)),
        # Stylers
             Hash(Symbol, Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, String, String)),
             Hash(Symbol, Proc(CellType, String, String)),
             Hash(Symbol, Proc(String, Int32, String)),
             Hash(Symbol, Proc(String, String)),
        # alignment and Formatters
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String)),
        # alignment and stylers
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(String, String)),
        # Formatters and stylers
             Hash(Symbol, Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Proc(CellType, CellData, Int32, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, Int32, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Proc(CellType, CellData, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Proc(CellType, CellData, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Proc(CellType, CellData, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Proc(CellType, CellData, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Proc(CellType, Int32, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Proc(CellType, Int32, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Proc(CellType, Int32, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Proc(CellType, Int32, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Proc(CellType, Int32, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Proc(CellType, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Proc(CellType, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Proc(CellType, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Proc(CellType, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Proc(CellType, String) |
                          Proc(String, String)),
        # alignment, formatters and stylers
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, Int32, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, CellData, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, Int32, String) |
                          Proc(String, String)),
        #
             Hash(Symbol, Tablo::Justify | Proc(CellType, String) |
                          Proc(CellType, CellData, String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String) |
                          Proc(CellType, CellData, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String) |
                          Proc(CellType, String, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String) |
                          Proc(String, Int32, String)),
             Hash(Symbol, Tablo::Justify | Proc(CellType, String) |
                          Proc(String, String))
          columns.each do |k, v|
            case {k, v}
            when {:alignment, Justify}
              case rowtype
              in HeaderOrBody::Body
                body_alignments[column_label] = v.as(Justify)
              in HeaderOrBody::Header
                header_alignments[column_label] = v.as(Justify)
              end
            when {:formatter, DataCellFormatter}
              case rowtype
              in HeaderOrBody::Body
                body_formatters[column_label] = v.as(DataCellFormatter)
              in HeaderOrBody::Header
                header_formatters[column_label] = v.as(DataCellFormatter)
              end
            when {:styler, DataCellStyler}
              case rowtype
              in HeaderOrBody::Body
                body_stylers[column_label] = v.as(DataCellStyler)
              in HeaderOrBody::Header
                header_stylers[column_label] = v.as(DataCellStyler)
              end
            else
              raise InvalidSummaryDefinition.new(
                "Summary: invalid <#{rowtype}> column definition <#{k}>")
            end
          end
        end
      end
    end

    # Returns the summary table
    def run
      build_summary
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
