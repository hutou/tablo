module Tablo
  # TODO: Write documentation for `Tablo`

  class Table
    include Enumerable(Row)

    DEFAULT_COLUMN_WIDTH         = 12
    DEFAULT_COLUMN_PADDING       =  1
    DEFAULT_TRUNCATION_INDICATOR = '~'
    PADDING_CHARACTER            = ' '
    @sources : DataType
    # :nodoc:
    getter sources, column_registry, connectors, style

    # Creates a new Table instance, *with* block
    #
    # `sources` is the only mandatory parameter, all other have default values
    #
    def initialize(sources,
                   @default_column_width : Int32 = DEFAULT_COLUMN_WIDTH,
                   @column_padding : Int32 = DEFAULT_COLUMN_PADDING,
                   @header_frequency : Int32? = 0,
                   @wrap_header_cells_to : Int32? = nil,
                   @wrap_body_cells_to : Int32? = nil,
                   @default_header_alignment : Justify = Justify::None,
                   @truncation_indicator : Char = DEFAULT_TRUNCATION_INDICATOR,
                   connectors : String = CONNECTORS_TEXT_CLASSIC,
                   @style : String = STYLE_ALL_BORDERS)
      @column_registry = {} of String => Column
      @sources = Tablo.validate(sources)
      @connectors = Tablo.validate_connectors(connectors)
      yield self
    end

    # Creates a new Table instance, *without* block
    def initialize(sources,
                   @default_column_width : Int32 = DEFAULT_COLUMN_WIDTH,
                   @column_padding : Int32 = DEFAULT_COLUMN_PADDING,
                   @header_frequency : Int32? = 0,
                   @wrap_header_cells_to : Int32? = nil,
                   @wrap_body_cells_to : Int32? = nil,
                   @default_header_alignment : Justify = Justify::None,
                   @truncation_indicator : Char = DEFAULT_TRUNCATION_INDICATOR,
                   connectors : String = CONNECTORS_TEXT_CLASSIC,
                   @style : String = STYLE_ALL_BORDERS)
      @column_registry = {} of String => Column
      @sources = Tablo.validate(sources)
      @connectors = Tablo.validate_connectors(connectors)
    end

    # Add a column to the table
    #
    # This method must be used with a block defining the extracting logic
    def add_column(label, header = nil, align_header = Justify::None,
                   align_body = Justify::None, width = nil,
                   formatter : CellType -> String = ->(n : CellType) { n.to_s },
                   &extractor : Array(CellType) -> CellType)
      if column_registry.has_key?(label)
        raise InvalidColumnLabelError.new("Column label already used in this table.")
      end
      align_header = @default_header_alignment if align_header.none?
      @column_registry[label] = Column.new(
        header || label,
        width || @default_column_width,
        align_header,
        align_body,
        formatter,
        extractor
      )
    end

    # Returns graphical "ASCII" representation of the Table, suitable for
    # display in a fixed-width font.
    def to_s(io)
      if column_registry.any?
        # Here, map applies to self, which is Table, using the each method
        # below to create rows, formatting them with (Row)to_s and joining all
        # formatted rows with newline to output the formatted table
        io << join_lines(map &.to_s)
        # io << "\n" << horizontal_rule(TLine::Bot) if @style =~ /BL/i
        io << "\n" << horizontal_rule(TLine::Bot) if @style =~ /BL/i
      else
        io << ""
      end
    end

    # Calls the given block once for each {Row} in the Table, passing that {Row} as parameter.
    #
    # When printed, the first row will visually include the headers (assuming these
    # were not disabled when the Table was initialized).
    # Iterates on source elements, creating formatted rows dynamically
    def each
      @sources.each_with_index do |source, index|
        include_header =
          case @header_frequency
          # when :start
          #  index == 0
          when Int
            x = @header_frequency.as(Int32)
            if x.zero?
              index == 0
              # false
            else
              (index *= x.sign) % x == 0
            end
          else
            false # @header_frequency
          end
        yield body_row(source, index, with_header = include_header)
      end
    end

    # Reset all the column widths so that each column is *just* wide enough to accommodate
    # its header text as well as the formatted content of each of its cells for the entire
    # collection, together with a single character of padding on either side of the column,
    # without any wrapping.
    #
    # Note that calling this method will cause the entire source to
    # be traversed and all the column extractors and formatters to be applied in order
    # to calculate the required widths.
    def shrinkwrap!(max_table_width = nil)
      return self if column_registry.none?
      columns = column_registry.values

      # Adjust column header width to its minimum by calling the `wrapped_with`
      # method
      columns.each do |column|
        column.width = wrapped_width(column.header)
      end

      # Adjust column data width to its minimum by calling the `wrapped_with`
      # on each source row
      @sources.each do |source|
        columns.each do |column|
          width = wrapped_width(column.formatted_cell_content(source))
          column.width = width if width > column.width
        end
      end

      if max_table_width
        total_columns_width = columns.reduce(0) { |sum, column| sum + column.width }
        total_padding = column_registry.size * @column_padding * 2
        total_borders = column_registry.size + 1
        unadjusted_table_width = total_columns_width + total_padding + total_borders

        # Ensure max table width is at least wide enough to accommodate table borders and padding
        # and one character of content.
        min_table_width = total_padding + total_borders + column_registry.size
        max_table_width = min_table_width if min_table_width > max_table_width

        required_reduction = [unadjusted_table_width - max_table_width, 0].max

        required_reduction.times do
          widest_column = columns.reduce(columns.first) do |widest, column|
            column.width >= widest.width ? column : widest
          end

          widest_column.width -= 1
        end
      end

      self
    end

    # Returns an "ASCII" graphical representation of the Table column
    # (possibly multilines) headers.
    def formatted_header
      cells = column_registry.map { |_, column| column.header_subcells }
      format_row(cells, @wrap_header_cells_to)
    end

    # Returns a formatted body row, including headers where appropriate
    def formatted_body_row(source, index, with_header = false)
      cells = column_registry.map { |_, column| column.body_subcells(source) }
      inner = format_row(cells, @wrap_body_cells_to)

      outs = [] of String
      if with_header
        if index < 0
          outs << horizontal_rule(TLine::Bot) if @style =~ /BL/i
          outs << horizontal_rule(TLine::Top) if @style =~ /TL/i
        elsif index == 0
          outs << horizontal_rule(TLine::Top) if @style =~ /TL/i
        else
          outs << horizontal_rule(TLine::Mid) if @style =~ /ML/i
        end
        outs << formatted_header
        outs << horizontal_rule(TLine::Mid) if @style =~ /ML/i
        outs << inner
      else
        outs << horizontal_rule(TLine::Top) if @style =~ /TL/i && index.zero?
        outs << inner
      end
      join_lines(outs)
    end

    # Compute horizontal rule, with connectors depending on line type
    def horizontal_rule(line : TLine)
      hc = Tablo.connector(@connectors, line)
      inner = column_registry.map do |_, column|
        hc.to_s * (column.width + @column_padding * 2)
      end
      lc = @style =~ /LC/i ? Tablo.connector(@connectors, line, TColumn::Left) : ""
      rc = @style =~ /RC/i ? Tablo.connector(@connectors, line, TColumn::Right) : ""
      mc = @style =~ /MC/i ? Tablo.connector(@connectors, line, TColumn::Mid) : ""
      outstr = "#{lc}#{inner.join(mc)}#{rc}"
    end

    # Creates a new row
    private def body_row(source, index, with_header : (Bool | Int32 | Symbol) = false)
      # pp! "Table.body_row method", typeof(source), source.class, source
      Row.new(self, source, index, with_header: with_header)
    end

    private def join_lines(lines)
      lines.join("\n")
    end

    # Formats a single header row or body row as a String.
    private def format_row(cells, wrap_cells_to)
      row_height = ([wrap_cells_to, cells.map(&.size).max].compact.min || 1)

      subrows = (0...row_height).map do |subrow_index|
        subrow_components = cells.zip(column_registry.values).map do |cell, column|
          num_subcells = cell.size
          cell_truncated = (num_subcells > row_height)
          append_truncator = (cell_truncated && subrow_index + 1 == row_height)

          lpad = PADDING_CHARACTER.to_s * @column_padding
          rpad =
            if append_truncator && @column_padding != 0
              @truncation_indicator + PADDING_CHARACTER.to_s * (@column_padding - 1)
            else
              PADDING_CHARACTER.to_s * @column_padding
            end

          inner =
            if subrow_index < num_subcells
              cell[subrow_index]
            else
              PADDING_CHARACTER.to_s * column.width
            end

          "#{lpad}#{inner}#{rpad}"
        end

        lc = @style =~ /LC/i ? Tablo.connector(@connectors, TColumn::Left) : ""
        rc = @style =~ /RC/i ? Tablo.connector(@connectors, TColumn::Right) : ""
        mc = @style =~ /MC/i ? Tablo.connector(@connectors, TColumn::Mid) : ""
        "#{lc}#{subrow_components.join(mc)}#{rc}"
      end

      join_lines(subrows)
    end

    # Returns the length of the longest segment of str when split by newlines
    private def wrapped_width(str)
      segments = str.split("\n")
      segments.reduce(1) do |size, segment|
        size > segment.size ? size : segment.size
      end
    end
  end
end
