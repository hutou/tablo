require "./types"
require "./heading"
require "./border"

module Tablo
  # The `Config` module define global getters and setters, to be used as default values
  # for all class instantiation parameters.
  module Config
    # Tests whether styling is allowed when output is redirected.
    #
    # - `true` : styling not allowed
    # - `false` : styling allowed <br />
    # (Default `true`)
    class_getter? styler_tty_only : Bool = true
    # Allows styling (`false`) or not (`true`) when output is redirected.
    class_setter styler_tty_only : Bool

    # Tests whether terminal size is used as table total width when packing is
    # called without a specified width.
    #
    # - `true` : table width is capped to terminal size
    # - `false` : terminal size is ignored <br />
    # (Default `false`)
    class_getter? terminal_capped_width : Bool = false
    # Sets the value of `terminal_capped_width` to control table width
    # (`true`) or not (`false`) when packing if called without a specified width
    class_setter terminal_capped_width : Bool

    # Returns the value of `StartingWidths`  <br />
    # (Default `StartingWidths::AutoSized`) <br />
    # *See `Table#pack` for details*
    class_getter starting_widths : StartingWidths = StartingWidths::AutoSized
    # Sets the value of `StartingWidths`
    class_setter starting_widths : StartingWidths

    #
    #
    # -------------- Control values for Table and Column initialize ----------------
    #

    # Returns the range of allowable values for `left_padding` and
    # `right_padding` width <br />
    # Check is done by the `check_padding` private method, when
    # initializing Table or Column.
    class_getter padding_width_range : Range(Int32, Int32)
    # Sets the range of allowable values for padding width. <br />
    # (Default 0..8)
    class_setter padding_width_range : Range(Int32, Int32) = 0..8

    # Returns the range of allowable values for Table `header_frequency` <br />
    class_getter header_frequency_range : Range(Int32, Int32)
    # Sets the range of allowable values for Table `header_frequency` <br />
    # (Default 0..64)
    class_setter header_frequency_range : Range(Int32, Int32) = 0..64

    # Returns the range of allowable values for `row_divider_frequency`  <br />
    class_getter row_divider_frequency_range : Range(Int32, Int32)
    # Sets the range of allowable values for `row_divider_frequency`  <br />
    # (Default 1..8)
    class_setter row_divider_frequency_range : Range(Int32, Int32) = 1..8

    # Returns the range of allowable values for `header_wrap`  <br />
    class_getter header_wrap_range : Range(Int32, Int32)
    # Sets the range of allowable values for `header_wrap`  <br />
    # (Default 1..8)
    class_setter header_wrap_range : Range(Int32, Int32) = 1..8

    # Returns the range of allowable values for `body_wrap`  <br />
    class_getter body_wrap_range : Range(Int32, Int32)
    # Sets the range of allowable values for `body_wrap`  <br />
    # (Default 1..8)
    class_setter body_wrap_range : Range(Int32, Int32) = 1..8

    # Returns the range of allowable values for column `width`  <br />
    class_getter column_width_range : Range(Int32, Int32)
    # Sets the range of allowable values for column `width`  <br />
    # (Default 1..128)
    class_setter column_width_range : Range(Int32, Int32) = 1..128

    # Returns the range of allowable values for `line_breaks_before` and
    # `line_breaks_after` attributes in `Heading::Frame` struct <br />
    class_getter line_breaks_range : Range(Int32, Int32)
    # Sets the range of allowable values for `line_breaks_before` and
    # `line_breaks_after`  <br />
    # Default 0..8)
    class_setter line_breaks_range : Range(Int32, Int32) = 0..8

    #
    #
    # -------------- Default values for Table initialize method --------------------
    #

    # Returns the Title struct
    class_getter title : Title
    # Creates an instance of Title struct with default parameters  <br />
    # (Default struct Title has a nil value, so nothing to display)
    class_setter title : Title = Title.new

    # Returns the SubTitle struct
    class_getter subtitle : SubTitle
    # Creates an instance of SubTitle struct with default parameters  <br />
    # (Default struct SubTitle has a nil value, so nothing to display)
    class_setter subtitle : SubTitle = SubTitle.new

    # Returns the Footer struct
    class_getter footer : Footer
    # Creates an instance of Footer struct with default parameters  <br />
    # (Default struct Footer has a nil value, so nothing to display)
    class_setter footer : Footer = Footer.new

    # TODO I'm here! TODO
    #
    class_getter border_type : String | Border::Name
    class_setter border_type : String | Border::Name = Border::Name::Ascii

    class_getter border_styler : Border::Styler
    class_setter border_styler : Border::Styler = DEFAULT_STYLER

    class_getter heading_alignment : Justify
    class_setter heading_alignment : Justify = DEFAULT_HEADING_ALIGNMENT

    class_getter heading_formatter : Cell::Text::Formatter
    class_setter heading_formatter : Cell::Text::Formatter = DEFAULT_FORMATTER

    class_getter heading_styler : Cell::Text::Styler
    class_setter heading_styler : Cell::Text::Styler = DEFAULT_STYLER

    class_getter group_alignment : Justify
    class_setter group_alignment : Justify = DEFAULT_HEADING_ALIGNMENT

    class_getter group_formatter : Cell::Text::Formatter
    class_setter group_formatter : Cell::Text::Formatter = DEFAULT_FORMATTER

    class_getter group_styler : Cell::Text::Styler
    class_setter group_styler : Cell::Text::Styler = DEFAULT_STYLER

    #
    class_getter header_alignment : Justify?
    class_setter header_alignment : Justify? = nil

    class_getter header_formatter : Cell::Data::Formatter
    class_setter header_formatter : Cell::Data::Formatter = DEFAULT_FORMATTER

    class_getter header_styler : Cell::Data::Styler
    class_setter header_styler : Cell::Data::Styler = DEFAULT_DATA_DEPENDENT_STYLER

    # Returns `.body_alignment`
    class_getter body_alignment : Justify?
    # Set default `body_alignment` to `nil` <br />
    # (Default `nil` => alignment depends on body cell value datatype)
    class_setter body_alignment : Justify? = nil

    class_getter body_formatter : Cell::Data::Formatter
    class_setter body_formatter : Cell::Data::Formatter = DEFAULT_FORMATTER

    class_getter body_styler : Cell::Data::Styler
    class_setter body_styler : Cell::Data::Styler = DEFAULT_DATA_DEPENDENT_STYLER
    #
    class_getter left_padding : Int32
    class_setter left_padding : Int32 = 1

    class_getter right_padding : Int32
    class_setter right_padding : Int32 = 1

    class_getter padding_character : String
    class_setter padding_character : String = " "

    class_getter truncation_indicator : String
    class_setter truncation_indicator : String = "~"

    class_getter width : Int32
    class_setter width : Int32 = 12
    #
    class_getter header_frequency : Int32?
    class_setter header_frequency : Int32? = 0

    class_getter row_divider_frequency : Int32?
    class_setter row_divider_frequency : Int32? = nil

    class_getter wrap_mode : WrapMode
    class_setter wrap_mode : WrapMode = WrapMode::Word

    class_getter header_wrap : Int32?
    class_setter header_wrap : Int32? = nil

    class_getter body_wrap : Int32?
    class_setter body_wrap : Int32? = nil

    class_getter? masked_headers : Bool
    class_setter masked_headers : Bool = false

    class_getter? omit_group_header_rule : Bool
    class_setter omit_group_header_rule : Bool = false

    class_getter? omit_last_rule : Bool
    class_setter omit_last_rule : Bool = false
  end
end
