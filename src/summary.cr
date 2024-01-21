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
      aggregations = [] of Aggregation
      user_aggregations = [] of UserAggregation(T)
      body_rows = [] of BodyRow
      body_columns = [] of BodyColumn
      header_rows = [] of HeaderRow
      header_columns = [] of HeaderColumn
      summary_definition.each do |sd|
        debug! sd
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
      debug! aggregations.size
      debug! user_aggregations.size
      debug! body_rows.size
      debug! body_columns.size
      debug! header_rows.size
      debug! header_columns.size
    end

    def build_aggregations(aggregations)
      running_sum = {} of LabelType => Numbers
      running_min = {} of LabelType => Numbers
      running_max = {} of LabelType => Numbers
      running_count = {} of LabelType => Numbers
      column_aggregates = {} of LabelType => Array(Aggregate)
      duplicates = {} of LabelType => Hash(Aggregate, Int32)
      debug! aggregations
      aggregations.each do |entry|
        debug! entry
        if entry.column.is_a?(Array)
          cols = entry.column.as(Array(LabelType))
        else
          cols = [entry.column.as(LabelType)].as(Array(LabelType))
        end
        debug! cols
        cols.each do |col|
          debug! col
          debug! entry.aggregate
          if entry.aggregate.is_a?(Array)
            aggregates = entry.aggregate.as(Array(Aggregate))
          else
            aggregates = [entry.aggregate.as(Aggregate)].as(Array(Aggregate))
          end
          # entry.aggregates.each do |aggregate|
          aggregates.each do |aggregate|
            unless duplicates.has_key?(col)
              duplicates[col] = {} of Aggregate => Int32
            end
            if duplicates[col].has_key?(aggregate)
              raise DuplicateInSummaryDefinition.new "Duplicate error on aggregations : <#{aggregate}> for <#{col}>"
            else
              duplicates[col.as(LabelType)][aggregate] = 1
            end
          end
          column_aggregates[col.as(LabelType)] = aggregates
          # entry.aggregates.as(Array(Aggregate))
          # else
          #   column_aggregates[col.as(LabelType)] = [entry.aggregates.as(Aggregate)].as(Array(Aggregate))
          # end
        end
      end
      debug! column_aggregates
      table.sources.each_with_index do |source, index|
        column_aggregates.each do |column_id, aggregates|
          column = table.column_registry[column_id]
          value = column.extractor.call(source, index)
          next if value.nil?

          aggregates.each do |aggregate|
            #
            # cols = (entry.column.is_a?(Array) ? entry.column : [entry.column]).as(Array(LabelType))
            # cols = entry.column.is_a?(Array) ? entry.column : [entry.column]
            # debug! cols
            case aggregate
            in Aggregate::Sum
              if value.is_a?(Number)
                if running_sum.has_key?(column_id)
                  running_sum[column_id] += value
                else
                  running_sum[column_id] = value
                end
              end
            in Aggregate::Count
              if running_count.has_key?(column_id)
                running_count[column_id] += 1
              else
                running_count[column_id] = 1
              end
            in Aggregate::Min
              if value.is_a?(Number)
                if running_min.has_key?(column_id)
                  running_min[column_id] = [running_min[column_id], value].min
                else
                  running_min[column_id] = value
                end
              end
            in Aggregate::Max
              if value.is_a?(Number)
                if running_max.has_key?(column_id)
                  running_max[column_id] = [running_max[column_id], value].max
                else
                  running_max[column_id] = value
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
      debug! Summary.aggr_results
    end

    def build_user_aggregations(user_aggregations)
      debug! user_aggregations
      user_aggregations.each do |entry|
        debug! entry
        #   debug! entry.proc
        # entry.proc.call(table) # .as(Tablo::Table(CellType)))
        Summary.keep(entry.ident, entry.proc.call(table).as(CellType))
        # case entry.proc
        # in Proc(Enumerable(CellType), CellType)
        # Summary.keep(entry.ident, entry.proc.call(table.sources).as(CellType))
        # Summary.keep(entry.ident, entry.proc.as(Proc(Enumerable(CellType), CellType)).call(table.sources.as(Enumerable(CellType))).as(CellType))
        # in Proc(Table(CellType), CellType)
        # Summary.keep(entry.ident, entry.proc.call(table).as(CellType))
        # Summary.keep(entry.ident, entry.proc.call(table.as(Tablo::Table(Tablo::CellType))).as(CellType))
      end
      # end
      debug! Summary.proc_results
      #     Summary.keep(key, proc.call(table.sources)).as(CellType)
      #   else
      #     raise InvalidSummaryDefinition.new(
      #       "Summary: invalid user_aggregation definition <#{key}>")
      #   end
      # end
    end

    def build_header_rows(header_rows)
      header_rows.each do |entry|
        header_values[entry.column] = entry.content
      end
      debug! header_values
    end

    def build_body_rows(body_rows)
      debug! summary_sources
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end
      defined_rows = [] of Int32
      colrow = [] of Int32
      body_rows.each do |entry|
        debug! entry
        row_num = entry.row
        if colrow.index(entry.row).nil?
          defined_rows << entry.row
          colrow << entry.row
        else
          raise DuplicateInSummaryDefinition.new(
            "Summary: body definition conflict (row/col already used).")
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
      debug! colrow
      debug! defined_rows
      debug! body_values

      row_number = {} of Int32 => Int32
      defined_rows.sort!.uniq!.each_with_index do |row, index|
        row_number[row] = index
      end
      debug! row_number

      debug! summary_sources
      row_number.size.times do |i|
        debug! i
        summary_sources << Array.new(table.column_registry.size, nil.as(CellType))
      end
      debug! summary_sources

      body_values.each do |column_label, body_rows|
        body_rows.each do |body_row|
          row = body_row[0]
          value = body_row[1]
          summary_sources[row_number[row]][column_number[column_label]] = value.as(CellType)
        end
      end
      debug! summary_sources
    end

    def build_body_columns(body_columns)
      debug! body_columns
      body_columns.each do |entry|
        column_label = entry.column
        unless entry.alignment.nil?
          body_alignments[column_label] = entry.alignment.as(Justify)
        end
        unless entry.formatter.nil?
          body_formatters[column_label] = entry.formatter.as(DataCellFormatter)
        end
        unless entry.styler.nil?
          body_stylers[column_label] = entry.styler.as(DataCellStyler)
        end
      end
      debug! body_alignments
      debug! body_formatters
      debug! body_stylers
    end

    def build_header_columns(header_columns)
      debug! header_columns
      header_columns.each do |entry|
        column_label = entry.column
        unless entry.alignment.nil?
          header_alignments[column_label] = entry.alignment.as(Justify)
        end
        unless entry.formatter.nil?
          header_formatters[column_label] = entry.formatter.as(DataCellFormatter)
        end
        unless entry.styler.nil?
          header_stylers[column_label] = entry.styler.as(DataCellStyler)
        end
      end
      debug! header_alignments
      debug! header_formatters
      debug! header_stylers
    end

    # Returns the summary table
    def run
      build_summary
      # build_aggregation(summary_definition.aggregation)
      # build_user_aggregation(summary_definition.user_aggregation)
      # build_header_row(summary_definition.header_row)
      # build_body_row(summary_definition.body_row)
      # build_body_column(summary_definition.body_column)
      # build_header_column(summary_definition.header_column)
      # return
      # build_summary
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
