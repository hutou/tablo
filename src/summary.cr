require "./types"
require "./table"

module Tablo
  class Summary(T, U, V)
    private getter summary_definition, summary_options, table
    private getter summary_sources = [] of Array(CellType)

    private getter header_values = {} of LabelType => CellType
    private getter header_alignments = {} of LabelType => Justify
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter header_stylers = {} of LabelType => DataCellStyler

    private getter body_values = {} of LabelType => Hash(Int32, CellType | Proc(CellType))
    private getter body_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler

    private class_property aggr_results = {} of LabelType => Hash(Aggregate, CellType)
    private class_property proc_results = {} of Symbol | String => CellType

    # Constructor
    #
    def initialize(@table : Table(T),
                   @summary_definition : U,
                   @summary_options : V)
    end

    def self.keep(key_column, key_aggregate, value)
      # # create first hash key if necessary
      unless aggr_results.has_key?(key_column)
        aggr_results[key_column] = {} of Aggregate => CellType
      end
      aggr_results[key_column][key_aggregate] = value.as(CellType)
    end

    def self.keep(user_func, value)
      proc_results[user_func] = value.as(CellType)
    end

    def self.use(key_column, key_aggregate)
      aggr_results[key_column][key_aggregate]
    end

    def self.use(user_func)
      proc_results[user_func]
    end

    def build_summary
      aggregations = [] of Aggregation
      user_aggregations = [] of UserAggregation(T)
      body_rows = [] of BodyRow
      body_columns = [] of BodyColumn
      header_rows = [] of HeaderRow
      header_columns = [] of HeaderColumn
      summary_definition.each do |sd|
        case sd
        when Aggregation
          aggregations << sd
        when UserAggregation(T)
          user_aggregations << sd
        when BodyRow
          body_rows << sd
        when BodyColumn
          body_columns << sd
        when HeaderRow
          header_rows << sd
        when HeaderColumn
          header_columns << sd
        end
      end
      unless aggregations.empty?
        build_aggregations(aggregations)
      end
      unless user_aggregations.empty?
        build_user_aggregations(user_aggregations)
      end
      unless body_rows.empty?
        build_body_rows(body_rows)
      end
      unless header_rows.empty?
        build_header_rows(header_rows)
      end
      unless body_columns.empty?
        build_body_columns(body_columns)
      end
      unless header_columns.empty?
        build_header_columns(header_columns)
      end
    end

    def build_aggregations(aggregations)
      running_sum = {} of LabelType => Int32
      running_min = {} of LabelType => Nums
      running_max = {} of LabelType => Nums
      running_count = {} of LabelType => Int32
      column_aggregates = {} of LabelType => Array(Aggregate)
      duplicates = {} of {LabelType, Aggregate} => Int32
      aggregations.each do |entry|
        if entry.column.is_a?(Array)
          cols = entry.column.as(Array(LabelType))
        else
          cols = [entry.column.as(LabelType)].as(Array(LabelType))
        end
        cols.each do |col|
          if entry.aggregate.is_a?(Array)
            aggregates = entry.aggregate.as(Array(Aggregate))
          else
            aggregates = [entry.aggregate.as(Aggregate)].as(Array(Aggregate))
          end
          aggregates.each do |aggregate|
            if duplicates.has_key?({col, aggregate})
              raise DuplicateInSummaryDefinition.new "Duplicate error on aggregations : <#{aggregate}> for <#{col}>"
            else
              duplicates[{col.as(LabelType), aggregate}] = 1
            end
          end
          column_aggregates[col.as(LabelType)] = aggregates
        end
      end
      table.sources.each_with_index do |source, index|
        column_aggregates.each do |column_id, aggregates|
          column = table.column_registry[column_id]
          value = column.extractor.call(source, index)
          next if value.nil?
          aggregates.each do |aggregate|
            case aggregate
            in Aggregate::Sum
              if value.is_a?(Nums)
                if running_sum.has_key?(column_id)
                  running_sum[column_id] += value.as(Int32)
                else
                  running_sum[column_id] = value.as(Int32)
                end
              end
            in Aggregate::Count
              if running_count.has_key?(column_id)
                running_count[column_id] += 1
              else
                running_count[column_id] = 1
              end
            in Aggregate::Min
              if value.is_a?(Nums)
                if running_min.has_key?(column_id)
                  running_min[column_id] = [running_min[column_id], value].min.as(Nums)
                else
                  running_min[column_id] = value.as(Nums)
                end
              end
            in Aggregate::Max
              if value.is_a?(Nums)
                if running_max.has_key?(column_id)
                  running_max[column_id] = [running_max[column_id], value].max.as(Nums)
                else
                  running_max[column_id] = value.as(Nums)
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

    def build_user_aggregations(user_aggregations)
      user_aggregations.each do |entry|
        Summary.keep(entry.ident, entry.proc.call(table).as(CellType))
      end
    end

    def build_header_rows(header_rows)
      duplicates = {} of LabelType => Int32
      header_rows.each do |entry|
        if duplicates.has_key?(entry.column)
          raise DuplicateInSummaryDefinition.new(
            "Summary: duplicate header definition for column<#{entry.column}>")
        else
          header_values[entry.column] = entry.content
          duplicates[entry.column] = 1
        end
      end
    end

    def build_body_rows(body_rows)
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end
      defined_rows = [] of Int32
      duplicates = {} of {LabelType, Int32} => Int32
      body_rows.each do |entry|
        if duplicates.has_key?({entry.column, entry.row})
          raise DuplicateInSummaryDefinition.new(
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

    def build_body_columns(body_columns)
      duplicates = {} of LabelType => Int32
      body_columns.each do |entry|
        if duplicates.has_key?(entry.column)
          raise DuplicateInSummaryDefinition.new(
            "Summary: duplicate body column definition for column<#{entry.column}>")
        else
          duplicates[entry.column] = 1
          unless entry.alignment.nil?
            body_alignments[entry.column] = entry.alignment.as(Justify)
          end
          unless entry.formatter.nil?
            body_formatters[entry.column] = entry.formatter.as(DataCellFormatter)
          end
          unless entry.styler.nil?
            body_stylers[entry.column] = entry.styler.as(DataCellStyler)
          end
        end
      end
    end

    def build_header_columns(header_columns)
      duplicates = {} of LabelType => Int32
      header_columns.each do |entry|
        if duplicates.has_key?(entry.column)
          raise DuplicateInSummaryDefinition.new(
            "Summary: duplicate header column definition for column<#{entry.column}>")
        else
          duplicates[entry.column] = 1
          unless entry.alignment.nil?
            header_alignments[entry.column] = entry.alignment.as(Justify)
          end
          unless entry.formatter.nil?
            header_formatters[entry.column] = entry.formatter.as(DataCellFormatter)
          end
          unless entry.styler.nil?
            header_stylers[entry.column] = entry.styler.as(DataCellStyler)
          end
        end
      end
    end

    # Returns the summary table
    def run
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
        header = header_values.has_key?(label) ? header_values[label].as(String) : ""
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
