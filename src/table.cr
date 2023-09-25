require "./tablo"
require "./util"
require "./types"
require "./config"
require "./border"
require "./column"
require "./row"
require "./rowgroup"
require "./heading"
require "./summary"

module Tablo
  class Table(T)
    include Enumerable(Row(T))
    # Class properties to manage row types framing and summary table linking
    # for summary table
    #
    # Class property to manage transition betwen :main and :summary tables
    class_property transition_footer : Footer? = nil
    # class property to manage transition between successive rows issued from data source
    class_property rowtype_memory : RowType? = nil

    # -------------- Table management attributes ------------------------------------
    #
    #

    protected getter column_registry = {} of LabelType => Column(T)
    protected getter group_registry = {} of LabelType => TextCell
    protected getter groups = [] of Range(Int32, Int32)
    protected property row_count : Int32 = 0
    protected property summary_table : Table(Array(Float64 | Int32 | String | Nil))? = nil
    protected property name : Symbol = :main

    # Table parameters
    getter sources
    private setter sources
    protected getter title, subtitle, footer
    protected getter group_alignment, group_formatter, group_styler
    protected getter header_alignment, header_formatter, header_styler
    protected getter body_alignment, body_formatter, body_styler
    protected getter border, border_type, border_styler
    protected getter left_padding, right_padding, padding_character
    protected getter width, truncation_indicator
    protected getter header_frequency, row_divider_frequency
    protected getter wrap_mode, header_wrap, body_wrap
    protected getter? masked_headers, omit_last_rule, title_repeated, footer_page_break

    # -------------- initialize -----------------------------------------------------
    #
    #

    # The `initialize` macro generates two `initialize' method, one with block_given = true
    # and one with block_given = false
    macro initialize(block_given)

       def initialize(@sources : Enumerable(T), *,
          #@title : UnFramedHeading | FramedHeading = FramedHeading.new,
          #@subtitle : UnFramedHeading | FramedHeading = FramedHeading.new,
          #@footer : UnFramedHeading | FramedHeading = FramedHeading.new,
          @title : Title = Title.new,
          @subtitle : SubTitle = SubTitle.new,
          @footer : Footer = Footer.new,
          #
          @group_alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
          @group_formatter : TextCellFormatter = DEFAULT_FORMATTER,
          @group_styler : TextCellStyler = DEFAULT_STYLER,
          #
          @header_alignment : Justify? = nil,
          @header_formatter : DataCellFormatter = DEFAULT_FORMATTER,
          @header_styler : DataCellStyler = DEFAULT_DATA_DEPENDENT_STYLER,
          #
          @body_alignment : Justify? = nil,
          @body_formatter : DataCellFormatter = DEFAULT_FORMATTER,
          @body_styler : DataCellStyler = DEFAULT_DATA_DEPENDENT_STYLER,
          #
          @border_type : BorderType = BorderName::Ascii,
          @border_styler : BorderStyler = DEFAULT_STYLER,
          #
          @left_padding : Int32 = 1,
          @right_padding : Int32 = 1,
          @padding_character : String = " ",
          @truncation_indicator : String = "~",
          @width : Int32 = 12,
          #
          @header_frequency : Int32? = 0,
          @row_divider_frequency : Int32? = nil,
          @wrap_mode : WrapMode = WrapMode::Word,
          @header_wrap : Int32? = nil,
          @body_wrap : Int32? = nil,
          #
          @masked_headers  : Bool = false,
          @omit_last_rule : Bool = false,
          @title_repeated : Bool = false,
          {% if block_given %}
            @footer_page_break : Bool = false, &)
          {% else %}
            @footer_page_break : Bool = false)
          {% end %}

        @border = Border.new(border_type, border_styler)
        self.row_count = sources.size
        {% if block_given == true %}
          yield self
        {% end %}
        # Table checks
        check_header_frequency
        check_row_divider_frequency
        check_header_wrap
        check_body_wrap
        # Table & column checks
        check_width(width)
        check_padding(left_padding)
        check_padding(right_padding)
        check_padding_character(padding_character)
        check_truncation_indicator(truncation_indicator)
      end
    end

    # Primary constructor, without block given. Table constructor has two versions to initialize a new Table instance, depending on whether a block is given or not.
    #
    # Without a block :
    # ```
    # tbl = Tablo::Table.new(...)
    # tbl.add_column(...)
    # tbl.add_column(...)
    # ```
    # With a block
    # ```
    # tbl = Tablo::Table.new(...) do |t|
    #   t.add_column(...)
    #   t.add_column(...)
    # end
    # ```
    # **Mandatory parameter:**
    #
    # - *sources* is the **only (positional) mandatory parameter**. Its type is `Enumerable(T)`,
    # where `T` is any (union) type. Any `Enumerable` is accepted (Array, Hash, etc.)(*).
    # For example, `[1, 3.14, "ABC"]` or `{"A" => [1,2], "B" => [3,4]}` or
    # `[{"A" => [1,2]}, {"B" => [3,4]}]` are valid sources.
    #
    # (*) Presently (Crystal 1.8.2+), a compiler bug prevents the use of the `Range` type.
    # Use `to_a` to convert to an array first. See Crystal issue 10518
    #
    # **Optional named parameters:**
    #
    # All parameters below are optional and have commonly used defaults.
    #
    # - Headings attributes
    #   - *title*, *subtitle* and *footer* are optional parts of the table layout and
    #     their type is `Tablo::Heading`. Their default value is `nil` (no display)
    #
    # - Group attributes : these are default attributes applied to every group
    #   header, unless specific values are set at the group level (in the `add_group` method)
    #   - _group_alignment_ : text justification, of type `Tablo::Justify` (default :center)
    #   - _group_formatter_ :  a Proc to apply some formatting to the value of the cell (see  `TextCellFormatter`
    #   - _group_styler_ :  a Proc to apply some style (color) to the formatted cell contents (see  `TextCellStyler`
    #
    # - Column header attributes : same logic as for groups
    #   - _header_alignment_ : default value is `nil`, meaning alignment is determined by the body cell value running type (numbers are right aligned, booleans are centered, others are left aligned)
    #   - _header_formatter_ : `Tablo::DataCellFormatter`
    #   - _header_styler_ : `Tablo::DataCellStyler`
    #
    # - Body:
    #   - *body_alignment*: set alignment for all body cells, default to `nil` (see column header)
    #   - _body_formatter_ : `Tablo::DataCellFormatter`
    #   - *body_styler*:  : `Tablo::DataCellStyler`
    #
    # - Border:
    #   - *border_type*: define table border. Type is `BorderName | String`, default to `BorderName::Ascii`
    #   - *border_styler*: Proc to style (colorize) border, type is `Tablo::BorderStyler`, default : do nothing
    #
    # - Miscellaneaous:
    #   - *left_padding*: an `Int32`, default to 1
    #   - *right_padding*: an `Int32`, default to 1
    #   - *padding_character*: a `String`, default to " " (a space)
    #   - *width*: an `Int32`, default to 12
    #   - *truncation_indicator*: A string appended at end of cell content to indicate truncation, default value : "~"
    #   - *header_frequency*: an `Int32` or `nil`
    #     - `nil` : no headers at all
    #     - n == 0 : Headers (including title,...) are automatically displayed before the first row (default)
    #     - n > 0 : Headers are repeated every n rows
    #   - *row_divider_frequency* : `nil` or a positive `Int32` n, for inclusion of a row divider rule between body lines every n rows
    #   - *wrap_mode*: mode of cutting content to fit into cell width (type `Tablo::WrapMode`)
    #     - Rune : cut line between graphemes
    #     - Word : cut line between words (default)
    #   - *header_wrap*: `nil` or a positive `Int32` to set the maximum number of lines a header cell may contains (defaults to `nil` : no limit)
    #   - *body_wrap*: same as above, for body (raise an `Tablo::InvalidValue` exception if zero or negative values are given to body_wrap or header_wrap)
    #   - *masked_headers* : `bool` = `false`. keep all headers from being displayed
    #   - *omit_last_rule* : `bool` = `false`. If `true`, the last closing rule of table is not displayed. This is useful for custom rendering (and notably for table linking)
    #   - *title_repeated* : `bool` = `false`. If `true`, Title heading (and subtitle) are repeated depending on `header_frequency` value.
    #   - *footer_page_break* : `bool` = `false`. If `true`, display a formfeed after footer.
    #
    # **return value:**
    # An instance of class Table
    initialize(block_given: false)

    # Second constructor, with same parameters as the first one, but with a block given
    initialize(block_given: true)

    # -------------- parameters checks  ---------------------------------------------
    #
    #

    private def check_header_frequency
      unless (hf = header_frequency).nil?
        unless hf.in?(Config.header_frequency_range)
          raise InvalidValue.new "header frequency must be nil or in range " \
                                 "(#{Config.header_frequency_range})"
        end
      end
    end

    private def check_row_divider_frequency
      unless (rdf = row_divider_frequency).nil?
        unless rdf.in?(Config.row_divider_frequency_range)
          raise InvalidValue.new "row divider frequency must be nil or in range " \
                                 "(#{Config.row_divider_frequency_range})"
        end
      end
    end

    private def check_header_wrap
      unless (hw = header_wrap).nil?
        unless hw.in?(Config.header_wrap_range)
          raise InvalidValue.new "header wrap must be nil or in range " \
                                 "(#{Config.header_wrap_range})"
        end
      end
    end

    private def check_body_wrap
      unless (bw = body_wrap).nil?
        unless bw.in?(Config.body_wrap_range)
          raise InvalidValue.new "Body wrap must be nil or in range " \
                                 "(#{Config.body_wrap_range})"
        end
      end
    end

    # -------------- check table & column parameters --------------------------------
    #
    #

    private def check_width(width)
      unless width.in?(Config.column_width_range)
        raise InvalidValue.new "Column width must be in range " \
                               "(#{Config.column_width_range})"
      end
    end

    private def check_padding(padding)
      unless padding.in?(Config.padding_width_range)
        raise InvalidValue.new "Column padding width must be in range " \
                               "(#{Config.padding_width_range})"
      end
    end

    private def check_padding_character(padding_string)
      raise InvalidValue.new "Padding string must be exactly" \
                             " *one* character" if padding_string.size != 1
    end

    private def check_truncation_indicator(truncation_string)
      raise InvalidValue.new "Truncation string  must be exactly" \
                             " *one* character" if truncation_string.size != 1
    end

    # -------------- reset_sources --------------------------------------------------
    #
    #

    # Changes the sources data used by the table
    #
    # - reset the summary table to nil
    # - returns the new sources
    def reset_sources(to src : Enumerable(T))
      self.summary_table = nil
      self.row_count = src.size
      self.sources = src
    end

    # -------------- add_column -----------------------------------------------------
    #
    #

    # Adds a column to the table
    #
    # **Parameters:**
    #
    # - *label* is the only (positional) mandatory parameter, of type `LabelType`
    #
    # - A block (*&extractor*) must be provided to the method call to extract the cell raw data
    # from the source. Extractor type is `Proc(T, Int32, CellType)`.
    #
    # All other are optional named parameters, and have default values taken from
    # Table parameters, except *header* which defaults to *label*
    #
    # Returns an instance of class Column(T)
    def add_column(label : LabelType, *,
                   header = label.to_s,
                   #
                   header_alignment = header_alignment,
                   header_formatter = header_formatter,
                   header_styler = header_styler,
                   #
                   body_alignment = body_alignment,
                   body_formatter = body_formatter,
                   body_styler = body_styler,
                   #
                   left_padding = left_padding,
                   right_padding = right_padding,
                   padding_character = padding_character,
                   #
                   width = width,
                   truncation_indicator = truncation_indicator,
                   wrap_mode = wrap_mode,
                   &extractor : (T, Int32) -> CellType)
      if column_registry.has_key?(label)
        raise DuplicateLabel.new("Column label already used in this table.")
      end
      check_width(width)
      check_padding(left_padding)
      check_padding(right_padding)
      check_padding_character(padding_character)
      check_truncation_indicator(truncation_indicator)

      column_registry[label] = Column(T).new(
        header: header,
        #
        header_alignment: header_alignment,
        header_formatter: header_formatter,
        header_styler: header_styler,
        #
        body_alignment: body_alignment,
        body_formatter: body_formatter,
        body_styler: body_styler,
        #
        left_padding: left_padding,
        right_padding: right_padding,
        padding_character: padding_character,
        #
        width: width,
        truncation_indicator: truncation_indicator,
        wrap_mode: wrap_mode,
        extractor: Proc(T, Int32, CellType).new { |row, index|
          extractor.call(row, index).as(CellType)
        },
        index: column_registry.size,
      )
    end

    # -------------- add_group ------------------------------------------------------
    #
    #

    # Adds a group to the table
    #
    # A group is the set of the last defined columns not attached to a group yet.
    #
    # **Parameters:**
    #
    # - *label* is the only (positional) mandatory parameter, of type `LabelType`
    #
    # All other are optional named parameters, and have default values taken from
    # Table parameters, except *header* which defaults to *label*
    #
    # Returns an instance of class `TextCell`
    def add_group(label, *,
                  header = label.to_s,
                  alignment = group_alignment,
                  formatter = group_formatter,
                  styler = group_styler,
                  padding_character = padding_character,
                  truncation_indicator = truncation_indicator,
                  wrap_mode = wrap_mode)
      if group_registry.has_key?(label)
        raise DuplicateLabel.new("Group label already used in this table.")
      end
      if column_registry.size.zero?
        raise GroupError.new("Group requires at least one column.")
      end
      check_padding_character(padding_character)
      check_truncation_indicator(truncation_indicator)

      groups << columns_group

      columns = column_list[groups.last]
      left_padding = columns.first.left_padding
      right_padding = columns.last.right_padding
      group_width = columns.reduce(0) do |acc, column|
        width = column.width + column.total_padding
        acc + width
      end
      group_width -= (left_padding + right_padding)
      group_width += (groups.last.size - 1) unless border.vdiv_mid.empty?

      group_registry[label] = TextCell.new(
        value: header,
        row_type: RowType::Group,
        alignment: alignment,
        formatter: formatter,
        styler: styler,
        left_padding: left_padding,
        right_padding: right_padding,
        padding_character: padding_character,
        truncation_indicator: truncation_indicator,
        wrap_mode: wrap_mode,
        width: group_width,
      )
    end

    # returns the column range for the current group being defined
    private def columns_group
      current_column = column_registry.size - 1
      if group_registry.size.zero?
        start_column = 0
      else
        start_column = groups.last.end + 1
      end
      start_column..current_column
    end

    private def group_width(column_range)
      columns_keys = column_registry.keys[column_range]
      columns = columns_keys.map { |k| column_registry[k] }
      left_padding = columns.first.left_padding
      right_padding = columns.last.right_padding
      group_width = columns.reduce(0) do |acc, column|
        width = column.width + column.total_padding
        acc + width
      end
      group_width -= (left_padding + right_padding)
      group_width += (columns.size - 1) unless border.vdiv_mid.empty?
      group_width
    end

    private def update_group_widths
      # unless (gr = group_registry).size.zero?
      unless (gr = group_registry).empty?
        gr.each_with_index do |(_, group), index|
          group.width = group_width(groups[index])
        end
      end
    end

    # -------------- summary --------------------------------------------------------
    #
    #

    # The summary method, with two parameters, is used to define a new SummaryTable
    # by applying user-defined functions to the numerical values of columns,
    # such as Sum or Average functions.
    #
    # **parameters:**
    #
    #  - *summary_def*, of type `Hash(LabelType, NamedTuple)` allows you to define
    #  column content and formatting.
    #
    #  Permitted NamedTuple keys and value types are :
    #   - body_alignment: `Justify`
    #   - header_alignment: `Justify`
    #   - header: `String`
    #   - body_formatter: `DataCellFormatter`
    #   - header_formatter: `DataCellFormatter`
    #   - body_styler: `DataCellStyler`
    #   - header_styler: `DataCellStyler`     \
    # and
    #   - any (unique) key: `SummaryNumCol` or `SummaryNumCols`
    #
    # for example:
    # ```
    # {
    #   "A" => {
    #     header:           "Sum",
    #     header_formatter: ->(c : Tablo::CellType) { c.to_s.downcase },
    #     body_styler:      ->(c : Tablo::CellType, s : String) { s.colorize(:yellow).to_s },
    #     proc:             ->(ary : Tablo::NumCol) { ary.sum.to_i },
    #   },
    #   "B" => {
    #     header: "Sum/Avg",
    #     proc1:  ->(ary : Tablo::NumCol) { ary.sum.to_i },
    #     proc2:  ->(ary : Tablo::NumCols) { ary["B"].size > 0 ? (ary["B"].sum/ary["B"].size).to_s : "NA" },
    #   },
    # }
    # ```
    #
    #  - *summary_options* , of type `Hash(LabelType, NamedTuple)` allows you to
    #  redefine table initialization parameters. By default, the current parameters
    #  of the main table are used.
    #  ```plain
    #  Parameters             | Default values
    #  -----------------------+------------------------------
    #  title                  | default Table value
    #  subtitle               |       idem
    #  footer                 |       idem
    #  footer                 |       idem
    #  ```
    # Returns the summary table
    def summary(summary_def, **summary_options)
      self.summary_table = Summary.new(self, summary_def, summary_options).run
    end

    # Returns a previously defined summary table
    def summary
      summary_table
    end

    # :nodoc:
    # Dynamically output formatted table
    #
    # Here, map applies to self, which is Table, using the each method
    # below to create rows, formatting them with (Row)to_s and joining all
    # formatted rows with newline to output the formatted table
    # If a summary definition is given, insert the resulting table at the end
    # kind of recursive !
    def to_s(io)
      if !column_registry.empty?
        unless @groups.empty?
          if @groups.last.end != @column_registry.size - 1
            add_group(:dummy_last_group, header: "")
          end
        end
        rows = map &.to_s
        io << join_lines(rows)
      else
        io << ""
      end
    end

    # :nodoc:
    # Calls the given block once for each {Row} in the table, passing
    # that {Row} as parameter.
    #
    # When printed, the first row will visually include the headers
    # (depending on the "@header_frquency* value, however).
    # Iterates on source elements, creating formatted rows dynamically
    # show_divider is true if
    # - rdf not nil
    # - index > 0 (not first row)
    # - rdf % index == 0
    # - hf % index != 0 (not matching hf row)
    # TODO to be checked
    def each(&)
      @sources.each_with_index do |source, index|
        show_divider = false
        unless (rdf = row_divider_frequency).nil?
          show_divider = (index > 0) && (index % rdf == 0)
          unless (hf = header_frequency).nil?
            show_divider &&= (index % hf != 0) if hf > 0
          end
        end
        yield Row.new(table: self, source: source, divider: show_divider, index: index)
      end
    end

    protected def rendered_group_row
      (cells = @group_registry.map { |_, v| v }).each do |c|
        # group cells need to be zapped (ie set to nil) so that
        # group width can be recomputed properly
        c.reset_rendered_subcells
      end
      format_row(cells, @header_wrap)
    end

    protected def rendered_header_row(source, row_index)
      body_cells = row_cells(source, row_index)
      # Use of body_cells is necessary here to automatically justify headers
      # based on body value type
      header_cells = column_list.map_with_index do |column, index|
        column.header_cell(body_cells[index])
      end
      format_row(header_cells, @header_wrap)
    end

    protected def rendered_body_row(source, index)
      cells = row_cells(source, index)
      format_row(cells, @body_wrap)
    end

    protected def rendered_title_row
      rendered_heading_row(RowType::Title)
    end

    protected def rendered_subtitle_row
      rendered_heading_row(RowType::SubTitle)
    end

    protected def rendered_footer_row(page_count)
      rendered_heading_row(RowType::Footer, page_count)
    end

    private def rendered_heading_row(row_type, page_count = 0)
      row_name, value = case row_type
                        when RowType::Title
                          {@title, @title.value}
                        when RowType::SubTitle
                          {@subtitle, @subtitle.value}
                        else
                          {@footer, paginated(@footer.value.as(String), page_count)}
                        end
      columns = column_list
      # takes into account the possible internal border
      extra_for_internal_dividers = @border.vdiv_mid.size.zero? ? 0 : 1
      heading_cell_width = columns.reduce(0) do |total_width, column|
        total_width + column.padded_width + extra_for_internal_dividers
      end
      heading_cell_width -= (columns.first.left_padding + columns.last.right_padding +
                             extra_for_internal_dividers)
      heading_cell = TextCell.new(value: value.as(CellType),
        row_type: row_type, alignment: row_name.alignment,
        formatter: row_name.formatter, styler: row_name.styler,
        left_padding: columns.first.left_padding,
        right_padding: columns.last.right_padding,
        padding_character: @padding_character,
        truncation_indicator: @truncation_indicator,
        wrap_mode: @wrap_mode,
        width: heading_cell_width,
      )
      format_row([heading_cell], nil)
    end

    private def format_row(cells, wrap_cells_to)
      # The line below does the whole job of formatting and styling cells
      line_count_max = cells.map(&.line_count).max
      # Array.compact removes all nil elements
      row_line_count = ([wrap_cells_to, line_count_max].compact.min || 1)
      subcell_stacks = cells.map do |cell|
        cell.padded_truncated_subcells(row_line_count)
      end
      # TODO to be optimized !
      subrows = subcell_stacks.transpose.map do |subrow_components|
        case cell = cells.first
        in TextCell
          # if cell.row_type == RowType::SubTitle && !@subtitle.framed?
          if cell.row_type == RowType::SubTitle && @subtitle.frame.nil?
            " " + subrow_components.join(" ") + " "
            # elsif cell.row_type == RowType::Title && !@title.framed?
          elsif cell.row_type == RowType::Title && @title.frame.nil?
            " " + subrow_components.join(" ") + " "
            # elsif cell.row_type == RowType::Footer && !@footer.framed?
          elsif cell.row_type == RowType::Footer && @footer.frame.nil?
            " " + subrow_components.join(" ") + " "
          else
            @border.join_cell_contents(subrow_components)
          end
        in DataCell
          @border.join_cell_contents(subrow_components)
        end
      end
      join_lines(subrows)
    end

    # Produce a horizontal dividing line suitable for printing at the top,
    # bottom or middle of the table, or before or after the table title, if any.
    #
    # This method is also suitable to customize output of a table, for example,
    # to list a table with an horizontal rule between rows, as in :
    # ```
    # table.each_with_index do |row, i|
    #   puts table.horizontal_rule(Tablo::Position::Middle) unless i == 0
    #   puts row
    # end
    # puts table.horizontal_rule(Tablo::Position::Bottom)
    # ```
    #
    # The method calculates an array of column widths (including padding), passing
    # it to the `Border.horizontal_rule` method.
    #
    # - *position* indicates the type of horizontal rule expected
    #
    # - Returns a String representing the formatted horizontal rule
    def horizontal_rule(position = Position::Bottom, groups = nil)
      # groups = column count per group, eg: [3,1,2,4]
      widths = column_list.map { |column| column.width + column.total_padding }
      @border.horizontal_rule(widths, position, groups: groups)
    end

    private def row_cells(source, index)
      column_list.map_with_index { |c, i|
        c.body_cell(source, row_index: index, column_index: i)
      }
    end

    private def paginated(lines, page_count)
      arlines = [] of String
      lines.each_line do |line|
        if line =~ /%\d*d/
          arlines << line % page_count
        else
          arlines << line
        end
      end
      arlines.join("\n")
    end

    # -------------- Pack and its auxiliary methods----------------------------------
    #
    #

    # The `pack` method allows for adapting the total width of the table.
    # It accepts 3 parameters, all optional:
    #
    # - `width`: total width required for the formatted table. If no `width` is
    #   given and if the value of parameter `Config.terminal_capped_width` is true,
    #   the value of `width` is read from the size of the terminal, otherwise its
    #   value is `nil` and in that case, only `starting_widths == AutoSized` has an
    #   effect.
    #
    # - `starting_widths` : column widths taken as starting point for resizing, possible
    #   values are :
    #   * `Current` : resizing starts from columns current width
    #   * `Initial` : current values are reset to their initial values, at column
    #     definition time
    #   * `AutoSized` : current values are set to their 'best fit' values, ie they are
    #     automatically adapted to their largest content
    #
    # - `except`: column or array of columns excluded from being resized,
    #   identified by their label
    #
    # The following examples will illustrate the behaviour of the different
    # parameters values, starting from the 'standard' one, with all column widths to
    # their default value : 12 characters.
    #
    # returns the Table itself
    def pack(width : Int32? = nil, *,
             starting_widths : StartingWidths = Config.starting_widths,
             except : Except? = nil)
      required_width = case width
                       in Nil
                         if STDOUT.tty? && Config.terminal_capped_width?
                           Util.get_terminal_lines_and_columns[1]
                         else
                           nil
                         end
                       in Int32
                         width
                       end

      case starting_widths
      in StartingWidths::Current
        # no change to current column widths before packing
      in StartingWidths::Initial
        # all columns, 'except' excepted, have their width reset to their initial value
        column_list(except: except).each do |c|
          c.width = c.initial_width
        end
      in StartingWidths::AutoSized # default
        # all columns, 'except' excepted, have their width set to their
        # largest formatted content size --> Implies browsing all source rows
        autosize_columns(except: except)
      end

      unless required_width.nil?
        if total_table_width > required_width
          shrink(required_width, except)
        else
          expand(required_width, except)
        end
      end
      # Here we need also to update widths of summary, if it exists
      # TODO To be studied
      # update_summary_widths
      update_group_widths
      self
    end

    # Resets all the column widths so that each column is *just* wide enough to
    # accommodate its header text as well as the formatted content of each cell for
    # the entire collection, together with padding, without wrapping.
    private def autosize_columns(except = nil)
      columns = column_list(except: except)
      @sources.each_with_index do |source, row_index|
        columns.each_with_index do |column, column_index|
          # create a DataCell (Body)
          body_cell = column.body_cell(source, row_index: row_index, column_index: column_index)
          if row_index == 0
            # if first row, create a DataCell for Header
            header_cell = column.header_cell(body_cell)
            column.width = wrapped_width(header_cell.memoized_formatted_value)
          end
          body_cell_width = wrapped_width(body_cell.memoized_formatted_value)
          column.width = ([column.width, body_cell_width].max)
        end
      end
    end

    # The shrink auxiliary method reduces column widths, with one character progressively
    # deducted from the width of the widest column until the target width is reached.
    private def shrink(max_table_width, except)
      border_padding_width = padding_widths_sum + border_widths_sum
      shrinkable_columns = column_list(except: except)
      return self if shrinkable_columns.empty?
      # compute minimum width of table (given minimum column content width is 1),
      # and taking into account non-shrinkable columns
      if except.nil?
        min_table_width = column_count + border_padding_width
      else
        except = [except] unless except.is_a?(Array)
        unshrinkable_width = except.sum { |label| column_registry[label].width }
        min_table_width = column_count - except.size +
                          unshrinkable_width + border_padding_width
      end
      # Table width cannot be less than minimum !
      max_width = [min_table_width, max_table_width].max
      # now, we can proceed, if needed (ie required table width is < than current table width)
      required_reduction = [total_table_width - max_width, 0].max
      required_reduction.times do
        widest_column = shrinkable_columns.reduce(shrinkable_columns.first) do |widest, column|
          column.width >= widest.width ? column : widest
        end
        widest_column.width -= 1
      end
    end

    # The expand auxiliary method increases column widths, with one character progressively
    # added to the width of the narrowest column until the target width is reached.
    private def expand(min_table_width, except)
      expandable_columns = column_list(except: except)
      return if expandable_columns.empty?
      required_increase = [min_table_width - total_table_width, 0].max
      required_increase.times do
        narrowest_column = expandable_columns.reduce(expandable_columns.first) do |narrowest, column|
          column.width <= narrowest.width ? column : narrowest
        end
        narrowest_column.width += 1
      end
    end

    # -------------- Transpose method -----------------------------------------------
    #
    #

    def transpose(**opts)
      default_opts = {
        title: @title,
        # align
        body_alignment:   @body_alignment,
        header_alignment: @header_alignment,
        header_formatter: @header_formatter,
        body_formatter:   @body_formatter,
        header_styler:    @header_styler,
        body_styler:      @body_styler,
        border_styler:    @border_styler,
        # padding
        left_padding:  @left_padding,
        right_padding: @right_padding,
        width:         @width,
        # miscellaneous
        border_type:          @border_type, # (border)
        header_frequency:     @header_frequency,
        truncation_indicator: @truncation_indicator,
        body_wrap:            @body_wrap,
        header_wrap:          @header_wrap,
      }

      default_extra_opts = {
        field_names_body_alignment:   nil, # Justify::Right,
        field_names_header:           "",
        field_names_header_alignment: nil, # Justify::Left,
        field_names_width:            nil,
        headers:                      "#",
      }
      if opts.nil?
        initializer_opts = default_opts
        extra_opts = default_extra_opts
      else
        initializer_opts = Util.update(default_opts, from: opts)
        extra_opts = Util.update(default_extra_opts, from: opts)
      end

      fields = column_registry.values

      table = Table.new(fields, **initializer_opts) do |t|
        # table = Table.new(fields, **opts) do |t|
        width_opt = extra_opts[:field_names_width]
        field_names_width = width_opt.nil? ? fields.map { |f| f.header.size }.max : width_opt
        # field_names_body_styler = fields.map { |f| f.body_styler }
        t.add_column(:dummy,
          body_alignment: extra_opts[:field_names_body_alignment],
          header_alignment: extra_opts[:field_names_header_alignment],
          header: extra_opts[:field_names_header],
          width: field_names_width, &.header)
        @sources.each_with_index do |source, i|
          header = extra_opts[:headers]
          header = if header.nil?
                     source.to_s
                   else
                     "#{header}##{i}"
                   end
          t.add_column(i,
            body_alignment: extra_opts[:field_names_body_alignment],
            header_alignment: extra_opts[:field_names_header_alignment],
            header: header
          ) do |original_column|
            original_column.body_cell_value(source, row_index: i)
          end
        end
      end
      table
    end

    # -------------- Public auxiliary methods ---------------------------------------
    #
    #

    # returns the total actual width of the table as a whole
    # TODO : to be renamed to 'width' ???
    #        but wait for global refactoring and renaming
    def total_table_width
      widths_sum + padding_widths_sum + border_widths_sum
    end

    # -------------- private auxiliary methods---------------------------------------
    #
    #

    # Returns the length of the longest segment of str when split by newlines
    private def wrapped_width(str)
      return 0 if str.empty?
      segments = str.split(NEWLINE)
      segments.reduce(1) do |size, segment|
        {% if @top_level.has_constant?("UnicodeCharWidth") %}
          [size, UnicodeCharWidth.width(segment)].max
        {% else %}
          [size, segment.size].max
        {% end %}
      end
    end

    # Returns an array of Column instances, after possibly filtering on label exceptions
    private def column_list(except : Except? = nil)
      if except.nil?
        column_registry.values
      else
        except = [except] unless except.is_a?(Array)
        column_labels = column_registry.keys - except
        column_labels.map { |label| column_registry[label] }
      end
    end

    # returns the total combined width of vertical border characters
    private def border_widths_sum
      # column_count + 1
      mid = @border.vdiv_mid.empty? ? 0 : column_count - 1
      left = @border.vdiv_left.empty? ? 0 : 1
      right = @border.vdiv_right.empty? ? 0 : 1
      left + mid + right
    end

    # returns the total combined width of padding characters
    private def padding_widths_sum
      column_list.reduce(0) { |sum, column| sum + column.total_padding }
    end

    # returns the count of defined columns
    private def column_count
      column_registry.size
    end

    # returns the total combined width of column contents (excludes border and padding)
    private def widths_sum
      column_list.reduce(0) { |sum, column| sum + column.width }
    end

    # returns the string of joined lines by newline
    private def join_lines(lines)
      # TODO what if Windows \n\r ?
      lines.join("\n")
    end

    # -------------- unused, old or obsolete mrthods --------------------------------
    #
    #

    def zzz_update_summary_widths
      unless (st = summary_table).nil?
        widths = @column_registry.map { |k, v| v.width }
        st.column_registry.each_with_index do |(k, v), i|
          v.width = widths[i]
        end
      end
    end

    def old_pack(width : TableWidth? = GetWidthFrom::Screen, *,
                 init : PackInit? = PackInit::AutoSize,
                 except : Except? = nil)
      case init
      in Nil
        # no change to current column widths before packing
      in PackInit::Reset
        # all columns, 'except' excepted, have their width reset to their initial value
        column_list(except: except).each do |c|
          c.width = c.initial_width
        end
      in PackInit::AutoSize # default
        # all columns, 'except' excepted, have their width set to their
        # largest formatted content size --> Implies browsing all source rows
        autosize_columns(except: except)
      end

      max_width = case width
                  in Nil
                    nil
                  in GetWidthFrom
                    if width == GetWidthFrom::Screen && STDOUT.tty? &&
                       Config.terminal_capped_width?
                      Util.get_terminal_lines_and_columns[1]
                    else
                      nil
                    end
                  in Int32
                    width
                  end
      unless max_width.nil?
        if max_width < 0
          if total_table_width > max_width.abs
            shrink(max_width.abs, except)
          else
            expand(max_width.abs, except)
          end
        else
          shrink(max_width, except)
        end
      end
      # Here we need also to update widths of summary, if it exists
      # TODO To be studied
      # update_summary_widths
      update_group_widths
      self
    end

    def old2_pack(width : TableWidth? = GetWidthFrom::Screen, *,
                  starting_widths : StartingWidths = Config.starting_widths,
                  except : Except? = nil)
      required_width = case width
                       in Nil
                         nil
                       in GetWidthFrom
                         if width == GetWidthFrom::Screen && STDOUT.tty? &&
                            Config.terminal_capped_width?
                           Util.get_terminal_lines_and_columns[1]
                         else
                           nil
                         end
                       in Int32
                         width
                       end

      case starting_widths
      in StartingWidths::Current
        # no change to current column widths before packing
      in StartingWidths::Initial
        # all columns, 'except' excepted, have their width reset to their initial value
        column_list(except: except).each do |c|
          c.width = c.initial_width
        end
      in StartingWidths::AutoSized # default
        # all columns, 'except' excepted, have their width set to their
        # largest formatted content size --> Implies browsing all source rows
        autosize_columns(except: except)
      end

      unless required_width.nil?
        if total_table_width > required_width
          shrink(required_width, except)
        else
          expand(required_width, except)
        end
      end
      # Here we need also to update widths of summary, if it exists
      # TODO To be studied
      # update_summary_widths
      update_group_widths
      self
    end

    def old_each(&)
      @sources.each_with_index do |source, index|
        show_divider = false
        if !(row_divider_frequency = @row_divider_frequency).nil? &&
           !row_divider_frequency.zero?
          show_divider = (index != 0) && (index % row_divider_frequency == 0)
          if !(header_frequency = @header_frequency).nil? && !header_frequency.zero?
            show_divider &&= (index % header_frequency != 0)
          end
        end
        yield Row.new(table: self, source: source, divider: show_divider, index: index)
      end
    end
  end
end
