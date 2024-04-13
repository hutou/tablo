require "./types"
require "./heading"
require "./border"

module Tablo
  # The `Config` module define global getters and setters, to be used as default values
  # for all class instantiation parameters.
  module Config
    # Checks whether styling is allowed when output is redirected.
    # - `true` : styling not allowed
    # - `false` : styling allowed
    STYLER_TTY_ONLY = true
    class_property? styler_tty_only : Bool = STYLER_TTY_ONLY

    # Checks whether terminal size is used as table total width when packing is
    # called without a specified width.
    # - `true` : table width is capped to terminal size
    # - `false` : terminal size is ignored <br />
    TERMINAL_CAPPED_WIDTH = false
    class_property? terminal_capped_width : Bool = TERMINAL_CAPPED_WIDTH

    # Default control values for Table and/or Column initialization,
    # with associated getters and setters.
    module Controls
      # Default range of allowable values for paddings (left or right)<br />
      # Check is done by the `Table#check_padding` private method, when
      # initializing a Table or Column.
      PADDING_WIDTH_RANGE = 0..8
      class_property padding_width_range : Range(Int32, Int32) = PADDING_WIDTH_RANGE

      # Default range of allowable values for header frequency<br />
      # Check is done by the `Table#check_header_frequency` private method, when
      # initializing a Table.
      HEADER_FREQUENCY_RANGE = 0..64
      class_property header_frequency_range : Range(Int32, Int32) = HEADER_FREQUENCY_RANGE

      # Default range of allowable values for `row_divider_frequency`  <br />
      # Check is done by the `Table#check_row_divider_frequency` private method, when
      # initializing a Table.
      ROW_DIVIDER_FREQUENCY_RANGE = 1..8
      class_property row_divider_frequency_range : Range(Int32, Int32) = ROW_DIVIDER_FREQUENCY_RANGE

      # Default range of allowable values for `header_wrap`  <br />
      # Check is done by the `Table#check_header_wrap` private method, when
      # initializing a Table.
      HEADER_WRAP_RANGE = 1..8
      class_property header_wrap_range : Range(Int32, Int32) = HEADER_WRAP_RANGE

      # Default range of allowable values for `body_wrap`  <br />
      # Check is done by the `Table#check_body_wrap` private method, when
      # initializing a Table.
      BODY_WRAP_RANGE = 1..8
      class_property body_wrap_range : Range(Int32, Int32) = BODY_WRAP_RANGE

      # Default range of allowable values for column `width`  <br />
      # Check is done by the `Table#check_width` private method, when
      # initializing a Table.
      COLUMN_WIDTH_RANGE = 1..128
      class_property column_width_range : Range(Int32, Int32) = COLUMN_WIDTH_RANGE

      # Default range of allowable values for `line_breaks_before` and
      # `line_breaks_after` attributes <br />
      #  Check is done in 'Tablo::Frame` struct
      LINE_BREAKS_RANGE = 0..8
      class_property line_breaks_range : Range(Int32, Int32) = LINE_BREAKS_RANGE
    end

    # Default values for Table and/or Column initialization,
    # with associated getters and setters.
    module Defaults
      # A default value of `nil` makes alignment dependent on data source type
      BODY_ALIGNMENT = nil
      class_property body_alignment : Justify? = BODY_ALIGNMENT

      # Creates an instance of `Heading::Title` struct with default parameters <br />
      # (Default `Heading::Title` `value` attribute is `nil`, so nothing to display)
      TITLE = Heading::Title.new
      class_property title : Heading::Title = TITLE

      # Creates an instance of `Heading::SubTitle` struct with default parameters <br />
      # (Default `Heading::SubTitle` `value` attribute is `nil`, so nothing to display)
      SUBTITLE = Heading::SubTitle.new
      class_property subtitle : Heading::SubTitle = SUBTITLE

      # Creates an instance of `Heading::Footer` struct with default parameters <br />
      # (Default `Heading::Footer` `value` attribute is `nil`, so nothing to display)
      FOOTER = Heading::Footer.new
      class_property footer : Heading::Footer = FOOTER

      # Default value for Border definition
      BORDER_DEFINITION = Border::PreSet::Ascii
      class_property border_definition : String | Border::PreSet = Border::PreSet::Ascii

      # Default styler for Border
      BORDER_STYLER = DEFAULT_STYLER
      class_property border_styler : Border::Styler = BORDER_STYLER

      # Default heading alignment
      HEADING_ALIGNMENT = DEFAULT_HEADING_ALIGNMENT
      class_property heading_alignment : Justify = HEADING_ALIGNMENT

      # Default group alignment
      GROUP_ALIGNMENT = DEFAULT_HEADING_ALIGNMENT
      class_property group_alignment : Justify = GROUP_ALIGNMENT

      # Default header alignment <br />
      # A default value of `nil` makes alignment dependent on data source type
      HEADER_ALIGNMENT = nil
      class_property header_alignment : Justify? = HEADER_ALIGNMENT

      # Default heading formatter
      HEADING_FORMATTER = DEFAULT_FORMATTER
      class_property heading_formatter : Cell::Text::Formatter = HEADING_FORMATTER

      # Default group formatter
      GROUP_FORMATTER = DEFAULT_FORMATTER
      class_property group_formatter : Cell::Text::Formatter = GROUP_FORMATTER

      # Default header formatter
      HEADER_FORMATTER = DEFAULT_FORMATTER
      class_property header_formatter : Cell::Data::Formatter = HEADER_FORMATTER

      # Default body formatter
      BODY_FORMATTER = DEFAULT_FORMATTER
      class_property body_formatter : Cell::Data::Formatter = BODY_FORMATTER

      # Default heading styler
      HEADING_STYLER = DEFAULT_STYLER
      class_property heading_styler : Cell::Text::Styler = HEADING_STYLER

      # Default group styler
      GROUP_STYLER = DEFAULT_STYLER
      class_property group_styler : Cell::Text::Styler = GROUP_STYLER

      # Default header styler
      HEADER_STYLER = DEFAULT_DATA_DEPENDENT_STYLER
      class_property header_styler : Cell::Data::Styler = HEADER_STYLER

      # Default body styler
      BODY_STYLER = DEFAULT_DATA_DEPENDENT_STYLER
      class_property body_styler : Cell::Data::Styler = BODY_STYLER

      # Default left padding
      LEFT_PADDING = 1
      class_property left_padding : Int32 = LEFT_PADDING

      # Default right padding
      RIGHT_PADDING = 1
      class_property right_padding : Int32 = RIGHT_PADDING

      # Default padding character (a String.size of 1 !)
      PADDING_CHARACTER = " "
      class_property padding_character : String = PADDING_CHARACTER

      # Defaut truncation indicator
      TRUNCATION_INDICATOR = "~"
      class_property truncation_indicator : String = TRUNCATION_INDICATOR

      # Defaut column width
      COLUMN_WIDTH = 12
      class_property column_width : Int32 = COLUMN_WIDTH

      # Defaut header frequency
      HEADER_FREQUENCY = 0
      class_property header_frequency : Int32? = HEADER_FREQUENCY

      # Defaut row divider frequency
      ROW_DIVIDER_FREQUENCY = nil
      class_property row_divider_frequency : Int32? = ROW_DIVIDER_FREQUENCY

      # Defaut wrap mode (cut line at word boundary, see `WrapMode`)
      WRAP_MODE = WrapMode::Word
      class_property wrap_mode : WrapMode = WRAP_MODE

      # Defaut wrapping value for multiline headers
      # nil = no limit, n = limit to n lines
      HEADER_WRAP = nil
      class_property header_wrap : Int32? = HEADER_WRAP

      # Defaut wrapping value for multiline bodies
      # nil = no limit, n = limit to n lines
      BODY_WRAP = nil
      class_property body_wrap : Int32? = BODY_WRAP

      # Defaut value for masked headers
      MASKED_HEADERS = false
      class_property? masked_headers : Bool = MASKED_HEADERS

      # Defaut value for omit_group_header_rule
      OMIT_GROUP_HEADER_RULE = false
      class_property? omit_group_header_rule : Bool = OMIT_GROUP_HEADER_RULE

      # Defaut value for omit_last_rule
      # Omitting last rule allows joiniing of parent and child tables
      OMIT_LAST_RULE = false
      class_property? omit_last_rule : Bool = OMIT_LAST_RULE
    end
  end
end
