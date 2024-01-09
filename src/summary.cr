require "./types"
require "./table"
require "big"

module Tablo
  class Summary(T, HC, HR, BC, BR, O)
    # private getter data_series = {} of LabelType => Array(CellType)
    # private getter proc_results = {} of LabelType => Hash(Int32, CellType)
    private property summary_sources = [] of Array(CellType)
    # private getter body_alignments = {} of LabelType => Justify
    # private getter header_alignments = {} of LabelType => Justify
    # private getter body_formatters = {} of LabelType => DataCellFormatter
    # private getter header_formatters = {} of LabelType => DataCellFormatter
    # private getter body_stylers = {} of LabelType => DataCellStyler
    # private getter headers_styler = {} of LabelType => DataCellStyler
    private getter headers = {} of LabelType => String
    private getter summary_options, options
    private getter table

    private getter header_values = {} of LabelType => CellType
    private getter header_alignments = {} of LabelType => Justify
    private getter header_formatters = {} of LabelType => DataCellFormatter
    private getter header_stylers = {} of LabelType => DataCellStyler

    private getter body_values = {} of LabelType => Hash(Int32, CellType | Proc(CellType))
    # private getter body_alignments = {} of LabelType => Hash(Int32, Justify)
    # private getter body_formatters = {} of LabelType => Hash(Int32, DataCellFormatter)
    # private getter body_stylers = {} of LabelType => Hash(Int32, DataCellStyler)
    private getter body_alignments = {} of LabelType => Justify
    private getter body_formatters = {} of LabelType => DataCellFormatter
    private getter body_stylers = {} of LabelType => DataCellStyler

    private getter aggregations, user_aggregations, header_column, header_row,
      body_column, body_row, options

    class_property aggr_results = {} of LabelType => Hash(Aggregate, Numbers)
    class_property proc_results = {} of Symbol => Numbers

    def self.keep(key_column, key_aggregate, value)
      # # create first hash key if necessary
      unless aggr_results.has_key?(key_column)
        aggr_results[key_column] = {} of Aggregate => Numbers
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
                   @user_aggregations : Hash(Symbol, Proc(Table(T), Numbers) |
                                                     Proc(Enumerable(T), Numbers))?,
                   @header_column : HC,
                   @header_row : HR,
                   @body_column : BC,
                   @body_row : BR,
                   @options : O)
    end

    def compute_user_aggregations(user_aggregations)
      return if user_aggregations.nil? || user_aggregations.empty?
      user_aggregations.each do |key, proc|
        case proc
        in Proc(Table(T), Numbers)
          Summary.keep(key, proc.call(table))
        in Proc(Enumerable(T), Numbers)
          Summary.keep(key, proc.call(table.sources))
        end
      end
    end

    def compute_aggregations(aggregations)
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
        Summary.keep(k, Aggregate::Count, v)
      end
      running_sum.each do |k, v|
        Summary.keep(k, Aggregate::Sum, v)
      end
      running_min.each do |k, v|
        Summary.keep(k, Aggregate::Min, v)
      end
      running_max.each do |k, v|
        Summary.keep(k, Aggregate::Max, v)
      end
    end

    private def check_keys
      missing = header_column.keys + header_row.keys +
                body_column.keys + body_row.keys - table.column_registry.keys
      unless missing.empty?
        raise LabelNotFound.new "Label #{missing.first} does not exist"
      end
    end

    # Initialize arrays of input and output data, by column
    # Returns nil
    # private def initialize_arrays
    #   summary_def.each do |label, _|
    #     data_series[label] = [] of CellType
    #     proc_results[label] = Hash(Int32, CellType).new
    #   end
    # end

    # Browse source data and summary def columns to compute an array of numeric
    # values only (Float64 or Int32)
    # Returns nil
    # private def calculate_data_series
    #   # for each row of data
    #   table.sources.each_with_index do |source, row_index|
    #     # for each column used in summary
    #     summary_def.each do |label, _|
    #       data_series[label] << table.column_registry[label].body_cell_value(source,
    #         row_index: row_index).as(CellType)
    #     end
    #   end
    # end

    # Browse each column defined in summary def and:
    # - store key parameters for use in summary_table build (add_column)
    # - calculate results of applying summary function procs to input data
    # Returns nil
    # private def new_populate_parameters
    #   summary_def.each do |column_label, column_def|
    #     # column_defs is a hash of named tuples for a given columns,
    #     # it may have several summary data lines  (=several procs)
    #     column_def.each do |key, value|
    #       case {key, value}
    #       when {:header, String}
    #         headers[column_label] = value
    #       when {:header_alignment, Justify}
    #         header_alignments[column_label] = value
    #       when {:header_formatter, DataCellFormatter}
    #         header_formatters[column_label] = value
    #       when {:header_styler, DataCellStyler}
    #         headers_styler[column_label] = value
    #       when {:body_alignment, Justify}
    #         body_alignments[column_label] = value
    #       when {:body_formatter, DataCellFormatter}
    #         body_formatters[column_label] = value
    #       when {:body_styler, DataCellStyler}
    #         body_stylers[column_label] = value
    #         # when {:proc, SummaryProcs}
    #         # when {:proc, {Int32, Proc(Array(CellType), CellType)} |
    #         #   {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)} |
    #         #   Array({Int32, Proc(Array(CellType), CellType)}) |
    #         #   Array({Int32, Proc(Hash(LabelType, Array(CellType)), CellType)}) |
    #         #   Array({Int32, Proc(Array(CellType), CellType)} |
    #         #         {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})}
    #       when {:proc, {Int32, Proc(Array(CellType), CellType)}},
    #            {:proc, {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)}},
    #            {:proc, Array({Int32, Proc(Array(CellType), CellType)})},
    #            {:proc, Array({Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})},
    #            {:proc, Array({Int32, Proc(Array(CellType), CellType) | Proc(Hash(LabelType, Array(CellType)), CellType)})}
    #         # {:proc, Array({Int32, Proc(Array(CellType), CellType)} |
    #         # {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})}
    #         # when {:proc, SummaryProcs}
    #         # debug! typeof(value)
    #         puts "\nvalue=#{value}"
    #         (value.is_a?(Array) ? value : [value]).each do |rowproc|
    #           puts "\nrowproc=#{rowproc}"
    #           # debug! rowproc
    #           row = rowproc.as(Array(Tuple(Int32, Proc(Array(CellType), CellType))) |
    #                            Array(Tuple(Int32, Proc(Hash(LabelType, Array(CellType)), CellType))))[0]
    #           puts "\nrow=#{row}"
    #           # if proc_results[column_label].has_key?(row)
    #           #   raise DuplicateRow.new "Summary: Row <#{row}> has already been " \
    #           #                          "used for column <#{column_label}>"
    #           # end
    #           # proc = rowproc[1]
    #           # case proc
    #           # # when SummaryProcAll
    #           # when Proc(Hash(LabelType, Array(CellType)), CellType)
    #           #   proc_results[column_label][row] = proc.call(data_series)
    #           #   # when SummaryProcCurrent
    #           # when Proc(Array(CellType), CellType)
    #           #   proc_results[column_label][row] = proc.call((data_series)[column_label])
    #           # end
    #         end
    #       else
    #         puts "\nvalue=#{value}"
    #         puts "\ntypeof(value==#{typeof(value)}"
    #         raise InvalidValue.new("Invalid summary definition key <#{key}>")
    #       end
    #     end
    #   end
    # end

    # private def populate_parameters
    #   summary_def.each do |column_label, column_def|
    #     # column_defs is a hash of named tuples for a given columns,
    #     # it may have several summary data lines  (=several procs)
    #     column_def.each do |key, value|
    #       case {key, value}
    #       when {:header, String}
    #         headers[column_label] = value
    #       when {:header_alignment, Justify}
    #         header_alignments[column_label] = value
    #       when {:header_formatter, DataCellFormatter}
    #         header_formatters[column_label] = value
    #       when {:header_styler, DataCellStyler}
    #         headers_styler[column_label] = value
    #       when {:body_alignment, Justify}
    #         body_alignments[column_label] = value
    #       when {:body_formatter, DataCellFormatter}
    #         body_formatters[column_label] = value
    #       when {:body_styler, DataCellStyler}
    #         body_stylers[column_label] = value
    #         # when {:proc, SummaryProcs}
    #         # when {:proc, {Int32, Proc(Array(CellType), CellType)} |
    #         #   {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)} |
    #         #   Array({Int32, Proc(Array(CellType), CellType)}) |
    #         #   Array({Int32, Proc(Hash(LabelType, Array(CellType)), CellType)}) |
    #         #   Array({Int32, Proc(Array(CellType), CellType)} |
    #         #         {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})}
    #         # when {:proc, {Int32, Proc(Array(CellType), CellType)}},
    #         #      {:proc, {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)}},
    #         #      {:proc, Array({Int32, Proc(Array(CellType), CellType)})},
    #         #      {:proc, Array({Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})},
    #         #      {:proc, Array({Int32, Proc(Array(CellType), CellType)} |
    #         #                    {Int32, Proc(Hash(LabelType, Array(CellType)), CellType)})}
    #       when {:proc, SummaryProcs}
    #         debug! typeof(value)
    #         (value.is_a?(Array) ? value : [value]).each do |rowproc|
    #           row = rowproc[0]
    #           if proc_results[column_label].has_key?(row)
    #             raise DuplicateRow.new "Summary: Row <#{row}> has already been " \
    #                                    "used for column <#{column_label}>"
    #           end
    #           proc = rowproc[1]
    #           case proc
    #           # when SummaryProcAll
    #           when Proc(Hash(LabelType, Array(CellType)), CellType)
    #             proc_results[column_label][row] = proc.call(data_series)
    #             # when SummaryProcCurrent
    #           when Proc(Array(CellType), CellType)
    #             proc_results[column_label][row] = proc.call((data_series)[column_label])
    #           end
    #         end
    #       else
    #         raise InvalidValue.new("Invalid summary definition key <#{key}>")
    #       end
    #     end
    #   end
    # end

    # Reformat results computed by summary functions to summary_table expected
    # sources format
    # Returns nil
    # private def calculate_sources
    #   # puts all summary results them in colum/row matrix for output
    #   # Sort results by row, column
    #   summary_source = Array.new(table.column_registry.size, nil.as(CellType))
    #   trios = [] of {row: Int32, column: Int32, value: CellType}
    #   # Browse columns in table :main
    #   table.column_registry.each_with_index do |(label, column), column_index|
    #     # Is there a summary for this column ?
    #     if proc_results.has_key?(label)
    #       # yes, for each pair, create a trio, adding column_index
    #       proc_results[label].each do |row, value|
    #         trios << {row: row, column: column_index, value: value}
    #       end
    #     end
    #   end
    #   # sort trios in place on row
    #   trios.sort! { |a, b| a[:row].as(Int32) <=> b[:row].as(Int32) }
    #   # and feed summary_sources
    #   old_row = 0
    #   trios.each_with_index do |trio, row_index|
    #     if row_index == 0
    #       summary_source[trio[:column].as(Int32)] = trio[:value]
    #       old_row = trio[:row]
    #     else
    #       if trio[:row] == old_row
    #         summary_source[trio[:column].as(Int32)] = trio[:value]
    #       else
    #         self.summary_sources << summary_source
    #         summary_source = Array.new(table.column_registry.size, nil.as(CellType))
    #         summary_source[trio[:column].as(Int32)] = trio[:value]
    #         old_row = trio[:row]
    #       end
    #     end
    #   end
    #   self.summary_sources << summary_source unless summary_source.compact.empty?
    # end

    # Returns the summary table
    def run
      # check columns keys
      check_keys

      # Process aggregations
      compute_aggregations(aggregations)
      compute_user_aggregations(user_aggregations)

      # process header_column
      header_column.each do |column_label, header_attributes|
        # p! column_label, header_attributes
        header_attributes.each do |attribute, value|
          case {attribute, value}
          when {:alignment, Justify}
            header_alignments[column_label] = value.as(Justify)
          when {:formatter, DataCellFormatter}
            header_formatters[column_label] = value.as(DataCellFormatter)
          when {:styler, DataCellStyler}
            header_stylers[column_label] = value.as(DataCellStyler)
          else
            raise "Bad Summary headers definition !"
          end
        end
      end
      p! header_alignments
      p! header_formatters
      p! header_stylers
      puts

      # process header_row
      header_row.each do |column_label, value|
        # p! column_label, value
        header_values[column_label] = value.as(CellType)
      end
      p! header_values
      puts

      # process body_column
      body_column.each do |column_label, body_attributes|
        # p! column_label, body_attributes
        body_attributes.each do |attribute, value|
          case {attribute, value}
          when {:alignment, Justify}
            body_alignments[column_label] = value.as(Justify)
          when {:formatter, DataCellFormatter}
            body_formatters[column_label] = value.as(DataCellFormatter)
          when {:styler, DataCellStyler}
            body_stylers[column_label] = value.as(DataCellStyler)
          else
            raise "Bad Summary bodys definition !"
          end
        end
      end
      p! body_alignments
      p! body_formatters
      p! body_stylers
      puts

      # body_row = {
      #   "Product" => {
      #     1 => "Total excl.".as(Tablo::CellType),
      #     3 => "Total incl.".as(Tablo::CellType),
      #   },
      #   :tax => {
      #     2 => ->{ Tablo::Summary.use(:tax, Tablo::Aggregate::Sum).as(Tablo::CellType) },
      #   },
      defined_rows = [] of Int32
      body_row.each do |column_label, rows|
        p! column_label, rows
        rows.each do |row|
          p! row
          row_num = row[0]
          row_value = row[1]
          defined_rows << row_num
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
        # body_values[column_label] = value.as(CellType)
      end
      p! body_values
      puts
      # return
      ##
      # defined_rows = [] of Int32
      # summary_bodies.each do |column_label, body|
      #  # initialize hashes
      #  body_values[column_label] = {} of Int32 => CellType
      #  p! column_label, body
      #  body.each do |attribute, attribute_value|
      #    puts
      #    p! attribute, attribute_value
      #    case {attribute, attribute_value}
      #    when {:alignment, Justify}
      #      body_alignments[column_label] = attribute_value.as(Justify)
      #    when {:formatter, DataCellFormatter}
      #      body_formatters[column_label] = attribute_value.as(DataCellFormatter)
      #    when {:styler, DataCellStyler}
      #      body_stylers[column_label] = attribute_value.as(DataCellStyler)
      #    else
      #      case attribute
      #      when :rows
      #        p! "inside value"
      #        p! attribute_value
      #        p! typeof(attribute_value)
      #        # p! attribute_value[0]
      #        # attribute_value.each do |row|
      #        #   case row
      #        #   when Hash(Int32, NamedTuple(value: Proc(CellType)))
      #        #     p! row
      #        #   when Hash(Int32, NamedTuple(value: CellType))
      #        #     p! row
      #        #   else
      #        #   end
      #        # end
      #      else
      #        raise "error : unknown attribute"
      #      end
      #    end
      #  end
      #  # body_alignments[column_label] = {} of Int32 => Justify
      #  # body_formatters[column_label] = {} of Int32 => DataCellFormatter
      #  # body_stylers[column_label] = {} of Int32 => DataCellStyler
      #  # p! column_label, body_rows
      #  # body_rows.each do |row, body_attributes|
      #  #   p! row, body_attributes
      #  #   # defined_rows << row
      #  #   body_attributes.each do |attribute, value|
      #  #     p! attribute, value
      #  #     case {attribute, value}
      #  #     when {:alignment, Justify}
      #  #       body_alignments[column_label] = value.as(Justify)
      #  #     when {:formatter, DataCellFormatter}
      #  #       body_formatters[column_label] = value.as(DataCellFormatter)
      #  #     when {:styler, DataCellStyler}
      #  #       body_stylers[column_label] = value.as(DataCellStyler)
      #  #     else
      #  #       case attribute
      #  #       when :value
      #  #         p! value
      #  #         p! typeof(value)
      #  #       else
      #  #         raise "error : unknown attribute"
      #  #       end
      #  #       # when {:value, Proc(CellType)}
      #  #       #   body_values[column_label][row] = (value.as(Proc(CellType)).call).as(CellType)
      #  #       # when {:value, CellType}
      #  #       #   body_values[column_label][row] = value.as(CellType)
      #  #     end
      #  #   end
      #  # end
      # end
      # return
      # summary_bodies.each do |column_label, body_rows|
      #   # initialize hashes
      #   body_values[column_label] = {} of Int32 => CellType
      #   body_alignments[column_label] = {} of Int32 => Justify
      #   body_formatters[column_label] = {} of Int32 => DataCellFormatter
      #   body_stylers[column_label] = {} of Int32 => DataCellStyler
      #   # p! column_label, body_rows
      #   body_rows.each do |row, body_attributes|
      #     # p! row, body_attributes
      #     defined_rows << row
      #     body_attributes.each do |attribute, value|
      #       # p! attribute, value
      #       case {attribute, value}
      #       when {:value, Proc(CellType)}
      #         body_values[column_label][row] = (value.as(Proc(CellType)).call).as(CellType)
      #       when {:value, CellType}
      #         body_values[column_label][row] = value.as(CellType)
      #       when {:alignment, Justify}
      #         body_alignments[column_label][row] = value.as(Justify)
      #       when {:formatter, DataCellFormatter}
      #         body_formatters[column_label][row] = value.as(DataCellFormatter)
      #       when {:styler, DataCellStyler}
      #         body_stylers[column_label][row] = value.as(DataCellStyler)
      #       end
      #     end
      #   end
      # end
      # p! body_values
      # p! body_alignments
      # p! body_formatters
      # p! body_stylers
      #
      # calculate rows and columns
      row_number = {} of Int32 => Int32
      defined_rows.sort!.uniq!.each_with_index do |row, index|
        row_number[row] = index
      end
      column_number = {} of LabelType => Int32
      table.column_registry.keys.each_with_index do |column_label, column_index|
        column_number[column_label] = column_index
      end
      p! column_number
      p! row_number

      # Create an array of n columns by p rows of type CellType? = nil
      summary_sources = [] of Array(CellType)
      row_number.size.times do
        summary_sources << Array.new(table.column_registry.size, nil.as(CellType))
      end
      p! summary_sources

      # and fills it with body_values
      body_values.each do |column_label, body_rows|
        p! column_label, body_rows
        body_rows.each do |body_row|
          row = body_row[0]
          value = body_row[1]
          summary_sources[row_number[row]][column_number[column_label]] = value.as(CellType)
        end
      end
      p! summary_sources
      p! typeof(summary_sources)
      p! summary_sources[0][2].class
      # return
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
      p! summary_table.body_alignment
      # summary_table has no column defined yet,
      # so we use main table for looping over columns
      table.column_registry.each_with_index do |(label, column), column_index|
        header = (header_values[label]? || "").as(String) # label.to_s
        header_alignment = header_alignments[label]? || summary_table.header_alignment
        header_formatter = header_formatters[label]? || summary_table.header_formatter
        header_styler = header_stylers[label]? || summary_table.header_styler
        body_alignment = body_alignments[label]? || summary_table.body_alignment
        # body_alignment = summary_table.body_alignment
        body_formatter = body_formatters[label]? || summary_table.body_formatter
        # body_formatter = summary_table.body_formatter
        # body_styler = body_stylers[label]? || summary_table.body_styler
        body_styler = summary_table.body_styler
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
