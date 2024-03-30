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
  # :nodoc:
  # An abstract table is needed to allow assignment on class properties
  # `Table.parent` and `Table.child`, as their type is different :
  # Array(CellType) for `Table.child`, and given T parameter for `Table.parent`.
  abstract class ATable
  end

  # The Table class is Tablo's main class. Its initialization defines the main
  # parameters governing the overall operation of the Tablo library, in particular
  # the data source and column definitions.
  class Table(T) < ATable
    include Enumerable(Row(T))

    struct UsedColumns
      property reordered, indexes

      def initialize(@reordered : Bool, @indexes : Array(Int32))
      end
    end

    protected property parent : ATable? = nil
    protected property child : ATable? = nil
    protected property name : Symbol = :main

    protected getter column_registry = {} of LabelType => Column(T)
    protected property used_columns = UsedColumns.new(false, [] of Int32)

    protected property group_registry = {} of LabelType => TextCell
    protected property group_registry_saved = {} of LabelType => TextCell

    # Array of array (=group) of columns, example : [[1,2,3],[4,5,6,7],[8]]
    protected property column_groups = [] of Array(Int32)
    protected property column_groups_saved = [] of Array(Int32)

    protected property row_count : Int32 = 0

    getter sources
    private setter sources

    private getter group_alignment, group_formatter, group_styler
    private getter left_padding, right_padding, padding_character
    private getter width, truncation_indicator
    private getter row_divider_frequency
    private getter wrap_mode, header_wrap, body_wrap

    # Called from RowGroup
    protected getter title, subtitle, footer
    protected getter header_frequency
    protected getter? masked_headers, omit_last_rule, omit_group_header_rule

    # Called from Summary
    protected getter header_alignment, header_formatter, header_styler
    protected getter border
    protected getter body_alignment, body_formatter, body_styler

    # The `initialize` macro generates two `initialize' methods, one with block_given = true
    # and one with block_given = false
    macro initialize(block_given)

      def initialize(@sources : Enumerable(T), *,
        @title : Title = Config.title,
        @subtitle : SubTitle = Config.subtitle,
        @footer : Footer = Config.footer,
        #
        @border : Border = Border.new(Config.border_type, Config.border_styler),
        #
        @group_alignment : Justify = Config.group_alignment,
        @group_formatter : TextCellFormatter = Config.group_formatter,
        @group_styler : TextCellStyler = Config.group_styler,
        #
        @header_alignment : Justify? = Config.header_alignment,
        @header_formatter : DataCellFormatter = Config.header_formatter,
        @header_styler : DataCellStyler = Config.header_styler,
        #
        @body_alignment : Justify? = Config.body_alignment,
        @body_formatter : DataCellFormatter = Config.body_formatter,
        @body_styler : DataCellStyler = Config.body_styler,
        #
        @left_padding : Int32 = Config.left_padding,
        @right_padding : Int32 = Config.right_padding,
        @padding_character : String = Config.padding_character,
        @truncation_indicator : String = Config.truncation_indicator,
        @width : Int32 = Config.width,
        #
        @header_frequency : Int32? = Config.header_frequency,
        @row_divider_frequency : Int32? = Config.row_divider_frequency ,
        @wrap_mode : WrapMode = Config.wrap_mode,
        @header_wrap : Int32? = Config.header_wrap,
        @body_wrap : Int32? = Config.body_wrap,
        #
        @masked_headers  : Bool = Config.masked_headers?,
        @omit_group_header_rule : Bool = Config.omit_group_header_rule?,
        {% if block_given %}
        @omit_last_rule : Bool = Config.omit_last_rule?, &)
        {% else %}
        @omit_last_rule : Bool = Config.omit_last_rule?)
        {% end %}

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

    # First constructor : Table constructor has two versions to initialize a new Table instance, depending on whether a block is given or not.
    #
    #  ```text
    #  Used constants                | Default values
    #  ----------------------------- | ------------------------------------
    #  DEFAULT_HEADING_ALIGNMENT     | Justify::Center
    #  DEFAULT_FORMATTER             | ->(c : CellType) { c.to_s }
    #  DEFAULT_STYLER                | ->(s : String) { s }
    #  DEFAULT_DATA_DEPENDENT_STYLER | ->(_c : CellType, s : String) { s }
    # ```
    #
    # _Mandatory parameters:_
    #
    # - `sources`: type is Enumerable(T)<br />
    #   Can be any Enumerable data type _(`Range` is currently (Crystal 1.9.2) not correctly supported in this context: use `Range.to_a` instead)_
    #
    # _Optional named parameters, with default values_
    #
    # - `title`: type is `Title`<br />
    #   Default set by `Config.title`<br />
    #   Initializing this class without any argument set its value to `nil`,
    #   so there is nothing to display
    # - `subtitle`: type is `SubTitle`<br />
    #   Default set by `Config.subtitle`<br />
    #   (Initialization: see `title`)
    # - `footer`: type is `Footer`<br />
    #   Default set by `Config.footer`<br />
    #   (Initialization: see `title`)
    # - `border`: type is `Border`<br />
    #   Initalized by `Config.border`, which defaults to `BorderName::Ascii` <br />
    #   Other `BorderName` are `ReducedAscii`, `Modern`,
    #   `ReducedModern`, `Markdown`, `Fancy` and `Blank`. <br />
    #   `border` may also be initialized directly by a string of 16 characters.
    # - `group_alignment`: type is `Justify`<br />
    #   Default value is `DEFAULT_HEADING_ALIGNMENT`
    # - `group_formatter`: type is `TextCellFormatter`<br />
    #   Default value is `DEFAULT_FORMATTER`
    # - `group_styler`: type is `TextCellStyler` <br />
    #   Default value is `DEFAULT_STYLER`
    # - `header_alignment`: type is `Justify?` <br />
    #   Default value is `nil` <br />
    #   (with `nil` as default, alignment
    #   depends on the type of the related body cell value)
    # - `header_formatter`: type is `DataCellFormatter` <br />
    #   Default value is `DEFAULT_FORMATTER`
    # - `header_styler`: type is `DataCellStyler` <br />
    #   Defaut value is `DEFAULT_DATA_DEPENDENT_STYLER`
    # - `body_alignment`: type is `Justify?` <br />
    #   Default value is `nil` <br />
    #   (With `nil` as default, alignment depends on the type of its cell value)
    # - `body_formatter`: type id `DataCellFormatter` <br />
    #   Default value is `DEFAULT_FORMATTER`
    # - `body_styler`: type is `DataCellStyler` <br />
    #   Default value is `DEFAULT_DATA_DEPENDENT_STYLER`
    # - `left_padding`: type is `Int32`<br />
    #   Default value is `1` <br />
    #   Permitted range of values is governed by `Config.padding_width_range` in the `check_padding` method<br />
    #   (raises `InvalidValue` runtime exception if value not in range)
    # - `right_padding`: type is `Int32` <br />
    #   Default value is `1` <br />
    #   Permitted range of values is governed by `Config.padding_width_range` in the `check_padding` method<br />
    #   (raises `InvalidValue` runtime exception if value not in range)
    # - `padding_character`: type is `String`<br />
    #   Default value is `" "` <br />
    #   The `check_padding_character` auxiliairy method ensures the `padding_character` string size is only one <br />
    #   (raises an `InvalidValue` runtime exception otherwise)
    # - `truncation_indicator`: type is `String` <br />
    #   Defaut value is `"~"` <br />
    #   The `check_truncation_indicator` auxiliairy method ensures the `truncation_indicator` string size
    #   is only one (raises an `InvalidValue` runtime exception otherwise)
    # - `width`: type is `Int32` <br />
    #   Default value is `12`<br />
    #   Permitted range of values is governed by `Config.column_width_range` in the
    #   `check_width` auxiliary method (raises `InvalidValue` runtime exception
    #   unless value in range)
    #
    # - `header_frequency`: type is `Int32?` <br />
    #   Default value is `0` <br />
    #   Permitted range of values is governed by `Config.header_frequency_range` in the
    #   `check_header_frequency` auxiliary method (raises `InvalidValue` runtime exception
    #   unless value in range or `nil`)
    #
    #   - If set to `0`, rows of data other than body are displayed
    #     only once, at the beginning for titles and headers, at the end for the footer.
    #   - If set to `n` (positive), group or column headers are repeated every `n`
    #     rows, as are footers, but titles and subtitles are not repeated (unless
    #     title `repeated` attribute is set to `true`)
    #   - If set to `nil`, only body rows are displayed.
    #
    # - `row_divider_frequency`: type is `Int32?` <br />
    #   Default value is `nil` <br />
    #   Permitted range of values is governed by `Config.row_divider_frequency_range` in the
    #   `check_row_divider_frequency` auxiliary method (raises `InvalidValue` runtime
    #   exception unless value in range or `nil`)
    #
    # - `wrap_mode`: type is `WrapMode` <br />
    #   Default value is `WrapMode::Word`<br />
    #   The `WrapMode` enum defines 2 modes :
    #
    #   - `Rune` : long lines can be cut between characters (graphemes)
    #   - `Word` : long lines can be cut between words only
    #
    # - `header_wrap`: type is `Int32?` <br />
    #   Default value is `nil` <br />
    #   Permitted range of values is governed by
    #   `Config.header_wrap_range` in the `check_header_wrap` auxiliary method
    #   (raises `InvalidValue` runtime exception unless value in range or `nil`)
    #
    # - `body_wrap` | `Int32?`<br />
    #   Default value is `nil` <br />
    #   Permitted range of values is governed by
    #   `Config.body_wrap_range` in the `check_body_wrap` auxiliary method (raises
    #   `InvalidValue` runtime exception unless value in range or `nil`)
    #
    # - `masked_headers`: type is `Bool` <br />
    #   Default value is `false` <br />
    #   If `true`, groups and column headers are not displayed <br />
    #   (this does not prevent display of title, subtitle and footer)
    #
    # - `omit_group_header_rule`: type is `Bool` <br />
    #   Default value is `false` <br />
    #   If `true`, the rule between Group and Header rows is not displayed.
    #   This is useful for headers custom rendering.
    #
    # - `omit_last_rule`: type is `Bool` <br />
    #   Default value is `false` <br />
    #   If `true`, the closing rule of table is not displayed.
    #   This is useful for custom rendering (and notably for Detail and Summary tables joining)
    #
    # Returns an instance of `Table(T)`
    initialize(block_given: false)

    # Second constructor, with same parameters as the first one, but with a block given
    initialize(block_given: true)

    # Checks that the parameter setting for `header_frequency` is within the value
    # range defined in `Config.header_frequency_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_header_frequency
      unless (hf = header_frequency).nil?
        unless hf.in?(Config.header_frequency_range)
          raise InvalidValue.new "header frequency must be nil or in range " \
                                 "(#{Config.header_frequency_range})"
        end
      end
    end

    # Checks that the parameter setting for `row_divider_frequency` is within the value
    # range defined in `Config.row_divider_frequency_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_row_divider_frequency
      unless (rdf = row_divider_frequency).nil?
        unless rdf.in?(Config.row_divider_frequency_range)
          raise InvalidValue.new "row divider frequency must be nil or in range " \
                                 "(#{Config.row_divider_frequency_range})"
        end
      end
    end

    # Checks that the parameter setting for `header_wrap` is `nil` or within the
    # value range defined in `Config.header_wrap_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_header_wrap
      unless (hw = header_wrap).nil?
        unless hw.in?(Config.header_wrap_range)
          raise InvalidValue.new "header wrap must be nil or in range " \
                                 "(#{Config.header_wrap_range})"
        end
      end
    end

    # Checks that the parameter setting for `body_wrap` is `nil` or within the
    # value range defined in `Config.body_wrap_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_body_wrap
      unless (bw = body_wrap).nil?
        unless bw.in?(Config.body_wrap_range)
          raise InvalidValue.new "Body wrap must be nil or in range " \
                                 "(#{Config.body_wrap_range})"
        end
      end
    end

    # Checks that the parameter setting for `width` is within the
    # value range defined in `Config.column_width_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_width(width)
      unless width.in?(Config.column_width_range)
        raise InvalidValue.new "Column width must be in range " \
                               "(#{Config.column_width_range})"
      end
    end

    # Checks that the parameter setting for `padding` is within the
    # value range defined in `Config.padding_width_range` <br />
    # Raises InvalidValue or returns `nil`
    private def check_padding(padding)
      unless padding.in?(Config.padding_width_range)
        raise InvalidValue.new "Column padding width must be in range " \
                               "(#{Config.padding_width_range})"
      end
    end

    # Checks that the parameter setting for `padding_character` string is
    # exactly one character.` <br />
    # Raises InvalidValue or returns `nil`
    private def check_padding_character(padding_character)
      raise InvalidValue.new "Padding character string must be exactly" \
                             " *one* character" if padding_character.size != 1
    end

    # Checks that the parameter setting for `truncation_indicator` string is
    # exactly one character.` <br />
    # Raises InvalidValue or returns `nil`
    private def check_truncation_indicator(truncation_indicator)
      raise InvalidValue.new "Truncation indicator string  must be exactly" \
                             " *one* character" if truncation_indicator.size != 1
    end

    # Returns the sources enumerable
    #
    # Replaces existing data source with a new one. <br />
    # _(This could be seen as a hack to do some special form of pagination !)_
    #
    # _Mandatory positional parameter_
    #
    # - `src`: type is `Enumerable(T) (Where T is the same type as at table initialization)
    def reset_sources(to src : Enumerable(T))
      self.child = nil
      self.row_count = src.size
      self.sources = src
    end

    # Returns an instance of `Column(T)`
    #
    # _Mandatory positional parameter:_
    #
    # - `label`: type is `LabelType`<br />
    #   The label identifies the column (`LabelType` is an alias of `Int32 | Symbol | String`)
    #
    # _Optional named parameters, with default values_
    #
    # - `header`: type is `String` <br />
    #   Default value is `label.to_s`<br />
    #   Can be an empty string
    #
    # - `header_alignment`: type is `Justify?`<br />
    #   By default, inherits from table `header_alignment` initializer
    #
    # - `header_formatter`: type is `DataCellFormatter` <br />
    #   By default, inherits from table `header_formatter` initializer
    #
    # - `header_styler`: type is `DataCellStyler` <br />
    #   By default, inherits from table `header_styler` initializer
    #
    # - `body_alignment`: type is `Justify?` <br />
    #   By default, inherits from table `body_alignment` initializer
    #
    # - `body_formatter`: type is `DataCellFormatter` <br />
    #   By default, inherits from table `body_formatter` initializer
    #
    # - `body_styler`: type is `DataCellStyler` <br />
    #   By default, inherits from table `body_styler` initializer
    #
    # - `left_padding`: type is `Int32` <br />
    #   By default, inherits from table `left_padding` initializer
    #
    # - `right_padding`: type is `Int32` <br />
    #   By default, inherits from table `right_padding` initializer
    #
    # - `padding_character`: type is `String` <br />
    #   By default, inherits from table `padding_character` initializer
    #
    # - `width`: type is `Int32` <br />
    #   By default, inherits from table `width` initializer
    #
    # - `truncation_indicator`: type is `String` <br />
    #   By default, inherits from table `truncation_indicator` initializer
    #
    # - `wrap_mode`: type is `WrapMode` <br />
    #   By default, inherits from table `wrap_mode` initializer
    #
    # _Captured block_
    #
    # - `&extractor`: type is `(T | Int32) -> CellType` <br />
    #   Captured block for extracting data from source
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
        raise DuplicateKey.new("Column label already used in this table.")
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

    # Returns an instance of `TextCell`
    #
    # Creates a group including all previous columns not already grouped.
    # After adding the last column, a group is automatically created (with an
    # empty header) if not explicitly specified.
    #
    # _Mandatory positional parameter_
    #
    # - `label`: type is `LabelType` <br />
    #   The label identifies the group.
    #
    # _Optional named parameters, with default values_
    #
    # - `header`: type is `String` <br />
    #   Default value id `label.to_s` <br />
    #   Can be an empty string
    #
    # - `alignment`: type is `Justify` <br />
    #   By default, inherits from table `group_alignment` initializer
    #
    # - `formatter`: type is `TextCellFormatter` <br />
    #   By default, inherits from table `group_formatter` initializer
    #
    # - `styler`: type is `TextCellStyler` <br />
    #   By default, inherits from table `group_styler` initializer
    #
    # - `padding_character`: type is `String` <br />
    #   By default, inherits from table `padding_character` initializer
    #
    # - `truncation_indicator`: type is `String` <br />
    #   By default, inherits from table `truncation_indicator` initializer
    #
    # - `wrap_mode`: type is `WrapMode` <br />
    #   By default, inherits from table `wrap_mode` initializer
    def add_group(label, *,
                  header = label.to_s,
                  alignment = group_alignment,
                  formatter = group_formatter,
                  styler = group_styler,
                  padding_character = padding_character,
                  truncation_indicator = truncation_indicator,
                  wrap_mode = wrap_mode)
      if group_registry.has_key?(label)
        raise DuplicateKey.new("Group label already used in this table.")
      end
      if column_registry.size.zero?
        raise GroupError.new("Group requires at least one column.")
      end
      check_padding_character(padding_character)
      check_truncation_indicator(truncation_indicator)

      column_groups << columns_group
      columns = column_list.select { |e| e.index.in?(column_groups.last) }
      group_width = calc_group_width(columns)

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
        # start_column = column_groups.last.end + 1
        start_column = column_groups.last[-1] + 1
      end
      (start_column..current_column).to_a
    end

    # Calculates the group width from an array of column values
    private def calc_group_width(columns)
      # calculate paddings of group
      left_padding = columns.first.left_padding
      right_padding = columns.last.right_padding
      # and total width of columns, including paddings
      group_width = columns.reduce(0) do |acc, column|
        w = column.width + column.total_padding
        acc + w
      end
      # Add size of middle vertical connectors
      group_width += ((columns.size - 1) * border.vdiv_mid.size) unless border.vdiv_mid.empty?
      # Substract paddings at each end of the group as they are not part of
      # the group width
      group_width -= (left_padding + right_padding)
    end

    # Calculates width of each defined group
    private def update_group_widths
      # Only main is involved (summary has no column_groups)
      self_main = self.name == :main ? self : self.parent.as(ATable)
      gr = self_main.group_registry
      gr.each_with_index do |(_, group), idx|
        # retrieve group columns
        cr = self_main.column_list
        columns = cr.select &.index.in?(self_main.column_groups[idx])
        group.width = calc_group_width(columns)
      end
    end

    # Harmonize widths between main table and summary table
    private def harmonize_widths
      if self.name == :summary
        iter_main = self.parent.as(ATable).column_registry.each
        iter_summary = self.column_registry.each
        harmonize(iter_main, iter_summary)
      else
        iter_main = self.column_registry.each
        unless self.child.nil?
          iter_summary = self.child.as(ATable).column_registry.each
          harmonize(iter_main, iter_summary)
        end
      end
      update_group_widths
    end

    # harmonize by selecting largest width between main and summary
    private def harmonize(itm, its)
      iter = itm.zip(its)
      iter.each do |(_, v_m), (_, v_s)|
        mx = [v_m.width, v_s.width].max
        v_m.width = v_s.width = mx
      end
    end

    # The `add_summary` method creates a summary table, attached to the main table.
    #
    # _Mandatory positional parameters:_
    #
    # - `summary_definition`: type is `Array(<structs>)`<br />
    # where `<structs>` may be one or more instances of `SummaryProc`,
    # `SummaryHeaderColumn`, `HeaderRow`, `SummaryBodyColumn` or `SummaryBodyRow` <br />
    #
    # - `summary_options`: type is `NamedTuple(<Table parameters>)` <br />
    # where `<Table parameters>` is a list of any number of Table initializers (may be empty).
    #
    # Example of `summary_definition` :
    # ```
    # summary_definition = [
    #   Tablo::... TODO
    #   Tablo::SummaryBodyRow.new(:total, 1, ->{ Tablo::Summary.use(:total_sum) }),
    #   Tablo::SummaryBodyColumn.new(:total, alignment: Tablo::Justify::Center),
    # ]
    # ```
    # which means :
    #  1. Sum the `:total` column
    #  2. populate the Summary table with this result in column `:total`, row 1
    #  3. and set column alignment to Center
    #
    # This method is overloaded on the `summary_options` parameter, which can be given as:
    # - a named tuple of Table initializers : { ..., ...,  }  (first form)
    # - a list of Table initializers : ..., ...,  (second form) <br />
    #   (converted into a named tuple by the ** operator)
    #
    # Creates a summary table and sets its parent<br />
    # Returns self (an instance of Table(T)) with an embedded Summary Table
    def add_summary(summary_definition, summary_options)
      self.child = Summary.new(self, summary_definition, summary_options).run
      self.child.as(ATable).parent = self.as(ATable)
    end

    # Second form : `summary_options` given as a list of Table initializers
    def add_summary(summary_definition, **summary_options)
      self.child = Summary.new(self, summary_definition, summary_options).run
      self.child.as(ATable).parent = self.as(ATable)
    end

    # Returns a previously defined summary table
    def summary
      self.child.as(ATable)
    end

    # Returns the table as a formatted string
    def to_s(io)
      # Here, map applies to self, which is Table, using the each method
      # below to create rows, formatting them with (Row)to_s and joining all
      # formatted rows with newline to output the formatted table.
      # debugger
      unless column_registry.empty?
        unless column_groups.empty?
          if column_groups.flatten.size != column_list.size
            add_group(:dummy_last_group, header: "")
          end
        end
        # Line below is equivalent to: rows = self.map { |row| row.to_s }
        rows = map &.to_s
        io << join_lines(rows)
      else
        io << ""
      end
      # Clean up after table display
      unless used_columns.indexes.empty?
        used_columns.indexes.clear
        used_columns.reordered = false
        restore_group_context
      end
    end

    # Returns successive formatted rows, with all corresponding headers and footers,
    # according to the `header_frequency` value.
    #
    # In fact,
    #
    # ```
    # table.each do |r|
    #   puts r
    # end
    # ```
    #
    # is the same as
    #
    # ```
    # puts table
    # ```
    def each(&)
      sources.each_with_index do |source, index|
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
      (cells = group_registry.map { |_, v| v }).each do |c|
        # group cells need to be zapped (ie set to nil) so that
        # group width can be recomputed properly
        c.reset_memoized_rendered_subcells
      end
      format_row(cells, header_wrap)
    end

    protected def rendered_header_row(source, row_index)
      body_cells = row_cells(source, row_index)
      # Use of body_cells is necessary here to automatically justify headers
      # based on body value type
      header_cells = column_list.map_with_index do |column, index|
        column.header_cell(body_cells[index])
      end
      format_row(header_cells, header_wrap)
    end

    # Called by RowGroup
    protected def rendered_body_row(source, index)
      cells = row_cells(source, index)
      format_row(cells, body_wrap)
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
                          {title, title.value}
                        when RowType::SubTitle
                          {subtitle, subtitle.value}
                        else
                          {footer, paginated(footer.value.as(String), page_count)}
                        end
      columns = column_list
      # takes into account the possible internal border
      extra_for_internal_dividers = border.vdiv_mid.size.zero? ? 0 : 1
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
        padding_character: padding_character,
        truncation_indicator: truncation_indicator,
        wrap_mode: wrap_mode,
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
      blank_border = " " # if no frame, no border !!!
      subrows = subcell_stacks.transpose.map do |subrow_components|
        case cell = cells.first
        in TextCell
          if cell.row_type == RowType::Title && title.frame.nil? ||
             cell.row_type == RowType::SubTitle && subtitle.frame.nil? ||
             cell.row_type == RowType::Footer && footer.frame.nil?
            # subrow_components is an array of String (size=1), which
            # is not needed here for headings, but needed for other
            # row types (because of border.join_cell_contents which
            # expects an array)
            # So, we take the value of the first (and only) element
            blank_border + subrow_components.join + blank_border
          else
            border.join_cell_contents(subrow_components)
          end
        in DataCell
          border.join_cell_contents(subrow_components)
        end
      end
      join_lines(subrows)
    end

    # Produce a horizontal dividing line suitable for printing between
    # rendered rows, so as to customize table output.
    #
    # For example, to insert a horizontal line at specific tow positions, we
    # can do :
    # ```
    # table.each_with_index do |row, i|
    #   puts table.horizontal_rule(Tablo::Position::BodyBody) unless i == 0 || i == 2
    #   puts row
    # end
    # ```
    # - Returns a String representing the formatted horizontal rule
    def horizontal_rule(position = Position::Bottom, column_groups = [] of Array(Int32)) # nil)
      # column_groups = column count per group, eg: [3,1,2,4]
      widths = column_list.map { |column| column.width + column.total_padding }
      border.horizontal_rule(widths, position, groups: column_groups)
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
      arlines.join(NEWLINE)
    end

    # `pack` method version 1
    #
    # The `pack` method comes in 3 overloaded versions :
    # - Version 1: all columns are selected for packing
    # - Version 2: some columns are excluded (`except` parameter)
    # - Version 3: only certain columns are selected (`only` parameter)
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
    #
    # Returns `self` (the current Table instance) after modifying its column widths
    #
    # _All named parameters are optional, with default values_
    #
    # - `width`: type is `Int32?` <br />
    #   Default value is `nil` <br />
    #   `width` is the requested total table width. If `nil` and `Config.terminal_capped_width`
    #   is `true` (and output not redirected), `width` finally takes the value of the terminal size.
    #
    # - `starting_widths`: type is `StartingWidths` <br />
    #   Default set by `Config.starting_widths` <br />
    #   `Starting_widths` allows you to specify the starting point for resizing : <br />
    #
    #   - either from the current column width value (`StartingWidths::Current`) <br />
    #   - or from its initial value (`StartingWidths::Initial`) <br />
    #   - or ignore it and directly perform optimized resizing (`StartingWidths::AutoSized`)
    #
    # - `except` or `only` (mutually exclusive named parameters) : (array of) column label(s) <br />
    #
    #   - to be excluded from resizing (`except` named parameter) <br />
    #   - to be selected exclusively for packing (`only` named parameter) <br />
    #
    #   Default to `nil`
    #
    # **Description of the packing algorithm**<br />
    #
    # The resizing algorithm is actually quite simple:<br />
    # If the final value of the `width` parameter is not `nil`, it first compares
    # the table's current width with the requested width, to determine whether this
    # is a reduction or an increase in size. Then, depending on the case, either the
    # widest column is reduced, or the narrowest increased, in steps of 1, until the
    # requested table width is reached.<br />
    # This explains why the final result of resizing depends on the starting column
    # widths.
    def pack(width : Int32? = nil, *,
             starting_widths : StartingWidths = Config.starting_widths)
      # All columns are selected
      packit(width, starting_widths, column_list)
    end

    # `pack` method version 2
    def pack(width : Int32? = nil, *,
             starting_widths : StartingWidths = Config.starting_widths,
             except : (LabelType | Array(LabelType))) # ? = nil)
      except = [except] unless except.is_a?(Array)
      # check if labels in except are valid
      except.each do |key|
        unless column_registry.has_key?(key)
          raise LabelNotFound.new("Pack 'except' error : unknown column label <#{key}>")
        end
      end
      column_labels = column_registry.keys - except
      columns = column_labels.map { |label| column_registry[label] }
      packit(width, starting_widths, columns)
    end

    # `pack` method version 3
    def pack(width : Int32? = nil, *,
             starting_widths : StartingWidths = Config.starting_widths,
             only : (LabelType | Array(LabelType))) # ? = nil)
      only = [only] unless only.is_a?(Array)
      # check if labels in only are valid
      only.each do |key|
        unless column_registry.has_key?(key)
          raise LabelNotFound.new("Pack 'only' error : unknown column label <#{key}>")
        end
      end
      columns = only.map { |label| column_registry[label] }
      packit(width, starting_widths, columns)
    end

    private def packit(width, starting_widths, columns)
      return self if columns.empty?
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
        columns.each do |c|
          c.width = c.initial_width
        end
      in StartingWidths::AutoSized # default
        # all columns, 'except' excepted, have their width set to their
        # largest formatted content size --> Implies browsing all source rows
        autosize_columns(columns)
      end

      unless required_width.nil?
        if total_table_width > required_width
          shrink(required_width, columns)
        else
          expand(required_width, columns)
        end
      end
      harmonize_widths
      self
    end

    # accommodate its header text as well as the formatted content of each cell for
    # the entire collection, together with padding, without wrapping.
    private def autosize_columns(columns)
      sources.each_with_index do |source, row_index|
        columns.each_with_index do |column, column_index|
          # create a DataCell (Body)
          body_cell = column.body_cell(source, row_index: row_index, column_index: column_index)
          if row_index == 0
            # if first row, create a DataCell for Header
            header_cell = column.header_cell(body_cell)
            column.width = wrapped_width(header_cell.formatted_content)
          end
          body_cell_width = wrapped_width(body_cell.formatted_content)
          column.width = ([column.width, body_cell_width].max)
        end
      end
    end

    # The shrink auxiliary method reduces column widths, with one character progressively
    # deducted from the width of the widest column until the target width is reached.
    private def shrink(max_table_width, columns)
      border_padding_width = padding_widths_sum + border_widths_sum
      # compute minimum width of table (given minimum column content width is 1),
      # and taking into account non-shrinkable columns

      # Unshrinkable_width is the total with of ignored columns
      unshrinkable_width = (column_list - columns).sum { |column| column.width }
      # unshrinkable_width = except.sum { |label| column_registry[label].width }

      min_table_width = columns.size + unshrinkable_width + border_padding_width
      # Table width cannot be less than minimum !
      max_width = [min_table_width, max_table_width].max
      # now, we can proceed, if needed (ie required table width is < than current table width)
      required_reduction = [total_table_width - max_width, 0].max
      required_reduction.times do
        widest_column = columns.reduce(columns.first) do |widest, column|
          column.width >= widest.width ? column : widest
        end
        widest_column.width -= 1
      end
    end

    # The expand auxiliary method increases column widths, with one character progressively
    # added to the width of the narrowest column until the target width is reached.
    private def expand(min_table_width, columns)
      return if columns.empty?
      required_increase = [min_table_width - total_table_width, 0].max
      required_increase.times do
        narrowest_column = columns.reduce(columns.first) do |narrowest, column|
          column.width <= narrowest.width ? column : narrowest
        end
        narrowest_column.width += 1
      end
    end

    # TODO TODO TODO TODO TODO I'm here! TODO TODO TODO TODO TODO

    def transpose(opts)
      transpose **opts
    end

    # `transpose(opts = {})` returns a Tablo::Table instance
    #
    # The `transpose` method creates a new Tablo::Table from the current
    # table, transposed, i.e.  rotated 90 degrees with respect to the current
    # table, so that the header names of the current table form the contents
    # of the leftmost column of the new table, and each subsequent column
    # corresponds to one of the source elements of the current table, the
    # header of that column being the string value of that element.
    #
    # Example:
    # ```
    # require "tablo"
    # table = Tablo::Table.new([-1, 0, 1]) do |t|
    #   t.add_column("Even?", &.even?)
    #   t.add_column("Odd?", &.odd?)
    #   t.add_column("Abs", &.abs)
    # end.transpose
    # puts table
    #  ```
    #
    #  ```
    # +-------+--------------+--------------+--------------+
    # |       |      -1      |       0      |       1      |
    # +-------+--------------+--------------+--------------+
    # | Even? |     false    |     true     |     false    |
    # | Odd?  |     true     |     false    |     true     |
    # | Abs   |            1 |            0 |            1 |
    # +-------+--------------+--------------+--------------+
    #  ```
    # By default, the transposed table inherits all the parameters of the
    # current table, with their values, except those appearing in the `opts`
    # parameter of the `transpose` method with a different value.
    #
    # These parameters apply to all columns, with one notable exception: the
    # first column, the leftmost, is special, as it is created from the column
    # headers (field names) of the current table and therefore has its own
    # width and alignment parameters, namely:
    # - `field_names_header_alignment`: default value = `nil`, i.e. alignment
    #   depends on the body data type, in this case, a left-aligned string.
    # - `field_names_body_alignment`: default value = `nil`, i.e. dependent on
    #   data type, i.e. a character string, left-aligned
    # - `field_names_width`: default value = nil, triggering optimal width
    #   calculation based on content
    #
    #  Two other parameters complete the transposed table:
    # - `field_names_header`: default value = `nil`, replaced by an empty
    #   character string
    # - `body_headers` : default value = `nil`, which returns the current
    #   value of `source` in each column
    #
    # All these values can be modified in the `opts` parameter, according to
    # their data type.
    #
    # However, `body_headers` is a special case: if it contains a character
    # string, it will be rendered as such, unless it contains the integer
    # display format `%d`, which will then be replaced by the original row number.
    #
    # Modified previous example:
    #  ```
    # require "tablo"
    # table = Tablo::Table.new([-1, 0, 1],
    #   header_alignment: Tablo::Justify::Center,
    #   body_alignment: Tablo::Justify::Center) do |t|
    #   t.add_column("Even?", &.even?)
    #   t.add_column("Odd?", &.odd?)
    #   t.add_column("Abs", &.abs)
    # end.transpose(
    #   field_names_header_alignment: Tablo::Justify::Right,
    #   field_names_body_alignment: Tablo::Justify::Right,
    #   field_names_header: "Field names",
    #   body_headers: "Row #%d content"
    # )
    # puts table
    #  ```
    #
    #  ```
    # +-------+--------------+--------------+--------------+
    # | Field |    Row #0    |    Row #1    |    Row #2    |
    # | names |    content   |    content   |    content   |
    # +-------+--------------+--------------+--------------+
    # | Even? |     false    |     true     |     false    |
    # |  Odd? |     true     |     false    |     true     |
    # |   Abs |       1      |       0      |       1      |
    # +-------+--------------+--------------+--------------+
    #  ```
    def transpose(**opts)
      # Attributes *not* listed below are initialized to their default Table values
      # In principle, they are all listed except unused group attributes
      inherited_attributes = {
        title:    title,
        subtitle: subtitle,
        footer:   footer,
        border:   border,
        # Groups are ignored in transpose
        # Header
        header_alignment: header_alignment,
        header_formatter: header_formatter,
        header_styler:    header_styler,
        # Body
        body_alignment: body_alignment,
        body_formatter: body_formatter,
        body_styler:    body_styler,
        # padding
        left_padding:         left_padding,
        right_padding:        right_padding,
        padding_character:    padding_character,
        truncation_indicator: truncation_indicator,
        width:                width,
        # miscellaneous
        header_frequency:      header_frequency,
        row_divider_frequency: row_divider_frequency,
        wrap_mode:             wrap_mode,
        header_wrap:           header_wrap,
        body_wrap:             body_wrap,
        #
        masked_headers:         masked_headers?,
        omit_group_header_rule: omit_group_header_rule?,
        omit_last_rule:         omit_last_rule?,
      }

      # field_names_* refer to the 1st column of the transposed table, which
      # contains the headers of the original table
      default_extra_opts = {
        field_names_header_alignment: nil,
        field_names_body_alignment:   nil,
        field_names_width:            nil,
        field_names_header:           nil, # "Field names",
        body_headers:                 nil,
      }
      if opts.nil?
        initializer_opts = inherited_attributes
        extra_opts = default_extra_opts
      else
        initializer_opts = Util.update(inherited_attributes, from: opts)
        # Initializers in default_extra_opts may be overriden by opts
        extra_opts = Util.update(default_extra_opts, from: opts)
      end

      fields = column_registry.values

      table = Table.new(fields, **initializer_opts) do |t|
        # table = Table.new(fields, **opts) do |t|
        width_opt = extra_opts[:field_names_width]
        field_names_width = width_opt.nil? ? fields.map { |f| f.header.size }.max : width_opt
        # field_names_body_styler = fields.map { |f| f.body_styler }

        # Fist, we add a first column for the headers of the original table
        # This is the header of the ex-headers column
        header = extra_opts[:field_names_header]
        header = header.nil? ? "" : header.as(String)
        t.add_column(0,
          body_alignment: extra_opts[:field_names_body_alignment],
          header: header,
          header_alignment: extra_opts[:field_names_header_alignment],
          width: field_names_width,
          &.header)

        # Then, we add as amany columns as there are originam rows
        sources.each_with_index do |source, i|
          header = extra_opts[:body_headers]
          header = if header.nil?
                     # "##{i}"
                     source.to_s
                   else
                     if header =~ /%d/
                       "#{header % i}"
                     else
                       "#{header}"
                     end
                   end
          t.add_column(i + 1,
            # body_alignment: body_alignment,
            # header_alignment: header_alignment,
            # body_alignment: extra_opts[:field_names_body_alignment],
            # header_alignment: extra_opts[:field_names_header_alignment],
            header: header
          ) do |original_column|
            original_column.body_cell_value(source, row_index: i)
          end
        end
      end
      table
    end

    # returns the total actual width of the table as a whole
    def total_table_width
      widths_sum + padding_widths_sum + border_widths_sum
    end

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

    def using_columns(*cols, reordered = false)
      raise InvalidValue.new "No column given" if cols.empty?
      used_columns.reordered = reordered
      cols.each do |e|
        case e
        when LabelType
          idx = column_registry.keys.index(e)
          raise LabelNotFound.new "No such column <#{e}>" if idx.nil?
          used_columns.indexes << idx
        when Tuple(LabelType, LabelType)
          bg = column_registry.keys.index(e[0])
          raise LabelNotFound.new "No such column <#{e[0]}>" if bg.nil?
          nd = column_registry.keys.index(e[1])
          raise LabelNotFound.new "No such column <#{e[1]}>" if nd.nil?
          if bg > nd
            bg.downto nd do |idx|
              used_columns.indexes << idx
            end
          else
            bg.upto nd do |idx|
              used_columns.indexes << idx
            end
          end
        end
      end
      deal_with_groups
      self
    end

    def using_column_indexes(*idx, reordered = false)
      raise InvalidValue.new "No column index given" if idx.empty?
      used_columns.reordered = reordered
      index_range = 0..column_registry.size - 1
      idx.each do |e|
        case e
        when Int32
          raise Exception.new "No such column index <#{e}>" if !e.in?(index_range)
          used_columns.indexes << e
        when Tuple(Int32, Int32)
          bg = e[0]
          raise LabelNotFound.new "No such column index <#{bg}>" if !bg.in?(index_range)
          nd = e[1]
          raise LabelNotFound.new "No such column index <#{nd}>" if !nd.in?(index_range)
          if bg > nd
            bg.downto nd do |idx|
              used_columns.indexes << idx
            end
          else
            bg.upto nd do |idx|
              used_columns.indexes << idx
            end
          end
        else
          raise Exception.new "<#{e}> is not a valid index"
        end
      end
      deal_with_groups
      self
    end

    private def deal_with_groups
      if used_columns.reordered
        save_group_context
        self.column_groups.clear
        self.group_registry.clear
      else
        unless column_groups.empty?
          # first save groups
          save_group_context
          delayed_group_registry_deletes = [] of LabelType
          delayed_column_groups_deletes = [] of Int32
          # then, compute new column_groups
          group_registry.each_with_index do |(k, v), idx|
            cols = column_groups[idx].select { |c| c.in?(used_columns.indexes) }
            if cols.empty?
              # delay deletes, as it is not safe to delete elements
              # inside a loop !
              #
              # group_registry entry is to be deleted  (by key k)
              delayed_group_registry_deletes << k
              # column_groups entry at index idx must also be deleted
              delayed_column_groups_deletes << idx
            else
              # Update current column_groups entry
              # (it may  have lost some columns !!)
              self.column_groups[idx] = cols
            end
          end
          delayed_group_registry_deletes.each do |k|
            group_registry.delete(k)
          end
          delayed_column_groups_deletes.reverse.each do |i|
            column_groups.delete_at(i)
          end
          # column_groups = x
          update_group_widths
        end
      end
    end

    private def save_group_context
      self.group_registry_saved = group_registry.clone
      self.column_groups_saved = column_groups.dup
    end

    private def restore_group_context
      self.group_registry = group_registry_saved # .clone
      self.column_groups = column_groups_saved
      update_group_widths
    end

    protected def column_list
      if used_columns.indexes.empty?
        column_registry.values
      else
        filtered_registry_values = [] of Column(T)
        if used_columns.reordered
          used_columns.indexes.each do |idx|
            filtered_registry_values << column_registry.values[idx]
          end
        else
          filtered_registry_values = column_registry.values.select { |e|
            e.index.in?(used_columns.indexes)
          }
        end
        filtered_registry_values
      end
    end

    # returns the total combined width of vertical border characters
    private def border_widths_sum
      # column_count + 1
      mid = border.vdiv_mid.empty? ? 0 : column_count - 1
      left = border.vdiv_left.empty? ? 0 : 1
      right = border.vdiv_right.empty? ? 0 : 1
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
      lines.join(NEWLINE)
    end

    # returns an array of data for a specific column
    # Used by SummaryProc
    def column_data(column_label : LabelType)
      column_data = [] of CellType
      extractor = column_registry[column_label].extractor
      sources.each_with_index do |source, index|
        column_data << extractor.call(source, index)
      end
      column_data
    end

    # returns a hash of array of data for several columns
    # Used by SummaryProc
    def column_data(column_label : Array(LabelType))
      column_data = {} of LabelType => Array(CellType)
      sources.each_with_index do |source, index|
        column_label.each do |col|
          unless column_data.has_key?(col)
            column_data[col] = [] of CellType
          end
          column_data[col] << column_registry[col].extractor.call(source, index)
        end
      end
      column_data
    end
  end
end
