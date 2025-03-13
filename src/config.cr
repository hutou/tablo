module Tablo
  # The `Config` module define global getters and setters, to be used as default values
  # for all class instantiation parameters.
  module Config
    # Checks whether styling is allowed when output is redirected.
    # - `true` : styling not allowed (Default)
    # - `false` : styling allowed
    STYLER_TTY_ONLY = true
    # see `STYLER_TTY_ONLY`
    class_property? styler_tty_only : Bool = STYLER_TTY_ONLY

    # Checks whether terminal size is used as table total width when packing is
    # called without a specified width.
    # - `true` : table width is capped to terminal size
    # - `false` : terminal size is ignored (Default) <br />
    TERMINAL_CAPPED_WIDTH = false
    # see `TERMINAL_CAPPED_WIDTH`
    class_property? terminal_capped_width : Bool = TERMINAL_CAPPED_WIDTH

    # Default control values for Table and/or Column initialization,
    # with associated getters and setters.
    module Controls
      # Default range of allowable values for paddings (left or right)<br />
      # Check is done by the `Table#check_padding` private method, when
      # initializing a Table or Column.
      PADDING_WIDTH_RANGE = 0..8
      # See `PADDING_WIDTH_RANGE`
      class_property padding_width_range : Range(Int32, Int32) = PADDING_WIDTH_RANGE

      # Default range of allowable values for header frequency<br />
      # Check is done by the `Table#check_header_frequency` private method, when
      # initializing a Table.
      HEADER_FREQUENCY_RANGE = 0..64
      # See `HEADER_FREQUENCY_RANGE`
      class_property header_frequency_range : Range(Int32, Int32) = HEADER_FREQUENCY_RANGE

      # Default range of allowable values for `row_divider_frequency`  <br />
      # Check is done by the `Table#check_row_divider_frequency` private method, when
      # initializing a Table.
      ROW_DIVIDER_FREQUENCY_RANGE = 1..8
      # See `ROW_DIVIDER_FREQUENCY_RANGE`
      class_property row_divider_frequency_range : Range(Int32, Int32) = ROW_DIVIDER_FREQUENCY_RANGE

      # Default range of allowable values for `header_wrap`  <br />
      # Check is done by the `Table#check_header_wrap` private method, when
      # initializing a Table.
      HEADER_WRAP_RANGE = 1..8
      # See `HEADER_WRAP_RANGE`
      class_property header_wrap_range : Range(Int32, Int32) = HEADER_WRAP_RANGE

      # Default range of allowable values for `body_wrap`  <br />
      # Check is done by the `Table#check_body_wrap` private method, when
      # initializing a Table.
      BODY_WRAP_RANGE = 1..8
      # See `BODY_WRAP_RANGE`
      class_property body_wrap_range : Range(Int32, Int32) = BODY_WRAP_RANGE

      # Default range of allowable values for column `width`  <br />
      # Check is done by the `Table#check_width` private method, when
      # initializing a Table.
      COLUMN_WIDTH_RANGE = 1..128
      # See `COLUMN_WIDTH_RANGE`
      class_property column_width_range : Range(Int32, Int32) = COLUMN_WIDTH_RANGE

      # Default range of allowable values for `line_breaks_before` and
      # `line_breaks_after` attributes <br />
      #  Check is done in 'Tablo::Frame` struct
      LINE_BREAKS_RANGE = 0..8
      # See `LINE_BREAKS_RANGE`
      class_property line_breaks_range : Range(Int32, Int32) = LINE_BREAKS_RANGE

      # Default range of allowable values for rounding in `Tablo::Functions.fp_align` <br />
      #  Check is done inside `Tablo::Functions.fp_align` method
      ROUNDING_RANGE = -8..8
      # see `ROUNDING_RANGE`
      class_property rounding_range : Range(Int32, Int32) = ROUNDING_RANGE
    end

    # Default values for Table and/or Column initialization,
    # with associated getters and setters.
    module Defaults
      # A default value of `nil` makes alignment dependent on data source type
      BODY_ALIGNMENT = nil
      # (Default: see `BODY_ALIGNMENT`)
      class_property body_alignment : Justify? = BODY_ALIGNMENT

      # Creates an instance of `Heading` struct with default parameters,
      # where the *value* attribute is `nil`, so there is nothing to display
      TITLE = Heading.new
      # (Default: see `TITLE`)
      class_property title : Heading = TITLE

      # Creates an instance of `Heading` struct with default parameters,
      # where the *value* attribute is `nil`, so there is nothing to display
      SUBTITLE = Heading.new
      # (Default: see `SUBTITLE`)
      class_property subtitle : Heading = SUBTITLE

      # Creates an instance of `Heading` struct with default parameters,
      # where the *value* attribute is `nil`, so there is nothing to display
      FOOTER = Heading.new
      # (Default: see `FOOTER`)
      class_property footer : Heading = FOOTER

      # Default value for Border definition
      BORDER_DEFINITION = Border::PreSet::Ascii
      # (Default: see `BORDER_DEFINITION`)
      class_property border_definition : String | Border::PreSet = Border::PreSet::Ascii

      # (see `DEFAULT_STYLER`)
      BORDER_STYLER = DEFAULT_STYLER
      # Default: see `BORDER_STYLER`)
      class_property border_styler : Border::Styler = BORDER_STYLER

      # (see `DEFAULT_HEADING_ALIGNMENT`)
      HEADING_ALIGNMENT = DEFAULT_HEADING_ALIGNMENT
      # Default: see `HEADING_ALIGNMENT`)
      class_property heading_alignment : Justify = HEADING_ALIGNMENT

      # (see `DEFAULT_HEADING_ALIGNMENT`)
      GROUP_ALIGNMENT = DEFAULT_HEADING_ALIGNMENT
      # Default: see `GROUP_ALIGNMENT`)
      class_property group_alignment : Justify = GROUP_ALIGNMENT

      # A default value of `nil` makes alignment dependent on data source type
      HEADER_ALIGNMENT = nil
      # (Default: see `HEADER_ALIGNMENT`)
      class_property header_alignment : Justify? = HEADER_ALIGNMENT

      # (see `DEFAULT_FORMATTER`)
      HEADING_FORMATTER = DEFAULT_FORMATTER
      # Default: see `HEADING_FORMATTER`)
      class_property heading_formatter : Cell::Text::Formatter = HEADING_FORMATTER

      # (see `DEFAULT_FORMATTER`)
      GROUP_FORMATTER = DEFAULT_FORMATTER
      # Default: see `GROUP_FORMATTER`)
      class_property group_formatter : Cell::Text::Formatter = GROUP_FORMATTER

      # (see `DEFAULT_FORMATTER`)
      HEADER_FORMATTER = DEFAULT_FORMATTER
      # Default: see `HEADER_FORMATTER`)
      class_property header_formatter : Cell::Data::Formatter = HEADER_FORMATTER

      # (see `DEFAULT_FORMATTER`)
      BODY_FORMATTER = DEFAULT_FORMATTER
      # (Default: see `BODY_FORMATTER`)
      class_property body_formatter : Cell::Data::Formatter = BODY_FORMATTER

      # (see `DEFAULT_STYLER`)
      HEADING_STYLER = DEFAULT_STYLER
      # Default: see `HEADING_STYLER`)
      class_property heading_styler : Cell::Text::Styler = HEADING_STYLER

      # (see `DEFAULT_STYLER`)
      GROUP_STYLER = DEFAULT_STYLER
      # Default: see `GROUP_STYLER`)
      class_property group_styler : Cell::Text::Styler = GROUP_STYLER

      # (see `DEFAULT_STYLER`)
      HEADER_STYLER = DEFAULT_STYLER
      # Default: see `HEADER_STYLER`)
      class_property header_styler : Cell::Data::Styler = HEADER_STYLER

      # (see `DEFAULT_STYLER`)
      BODY_STYLER = DEFAULT_STYLER
      # (Default: see `BODY_STYLER`)
      class_property body_styler : Cell::Data::Styler = BODY_STYLER

      # Default left padding
      LEFT_PADDING = 1
      # (Default: see `LEFT_PADDING`)
      class_property left_padding : Int32 = LEFT_PADDING

      # Default right padding
      RIGHT_PADDING = 1
      # (Default: see `RIGHT_PADDING`)
      class_property right_padding : Int32 = RIGHT_PADDING

      # Default padding character (a String, size 1)
      PADDING_CHARACTER = " "
      # (Default: see `PADDING_CHARACTER`)
      class_property padding_character : String = PADDING_CHARACTER

      # Defaut truncation indicator (a string, size 1)
      TRUNCATION_INDICATOR = "~"
      # (Default: see `TRUNCATION_INDICATOR`)
      class_property truncation_indicator : String = TRUNCATION_INDICATOR

      # Defaut column width
      COLUMN_WIDTH = 12
      # (Default: see `COLUMN_WIDTH`)
      class_property column_width : Int32 = COLUMN_WIDTH

      # Defaut header frequency (see *header_frequency* parameter in `Table.new`)
      HEADER_FREQUENCY = 0
      # (Default: see `HEADER_FREQUENCY`)
      class_property header_frequency : Int32? = HEADER_FREQUENCY

      # Defaut row divider frequency
      ROW_DIVIDER_FREQUENCY = nil
      # (Default: see `ROW_DIVIDER_FREQUENCY`)
      class_property row_divider_frequency : Int32? = ROW_DIVIDER_FREQUENCY

      # Defaut wrap mode (see `WrapMode`)
      WRAP_MODE = WrapMode::Word
      # (Default: see `WRAP_MODE`)
      class_property wrap_mode : WrapMode = WRAP_MODE

      # Defaut wrapping value for multiline headers
      # `nil` = no limit, `n` = limit to `n` lines
      HEADER_WRAP = nil
      # (Default: see `HEADER_WRAP`)
      class_property header_wrap : Int32? = HEADER_WRAP

      # Defaut wrapping value for multiline bodies <br />
      # `nil` = no limit, `n` = limit to `n` lines
      BODY_WRAP = nil
      # (Default: see `BODY_WRAP`)
      class_property body_wrap : Int32? = BODY_WRAP

      # Defaut value for masked headers
      MASKED_HEADERS = false
      # (Default: see `MASKED_HEADERS`)
      class_property? masked_headers : Bool = MASKED_HEADERS

      # Defaut value for *omit_group_header_rule*
      OMIT_GROUP_HEADER_RULE = false
      # (Default: see `OMIT_GROUP_HEADER_RULE`
      class_property? omit_group_header_rule : Bool = OMIT_GROUP_HEADER_RULE

      # Defaut value for *omit_last_rule* <br />
      # Omitting last rule allows joining of parent and child tables
      OMIT_LAST_RULE = false
      # Default: see `OMIT_LAST_RULE`)
      class_property? omit_last_rule : Bool = OMIT_LAST_RULE
    end
  end
end
