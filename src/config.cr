require "./types"
require "./heading"
require "./border"

module Tablo
  # The `Config` module define global properties.
  # These properties are mutable and are applicable to all Table instantiations
  # that follow.
  module Config
    # get/set control table styling when output is redirected to a file.
    #
    # - `true` : no styling
    # - `false` : styling allowed
    class_property? styler_tty_only : Bool = true

    # get/set control table width to be capped by terminal width.
    #
    # - `true` : table width is capped to terminal size
    # - `false` : terminal size is ignored
    class_property? terminal_capped_width : Bool = false
    # class_property? pack_autosize : Bool = true
    class_property starting_widths : StartingWidths = StartingWidths::AutoSized

    #
    #
    # -------------- Control values for Table and Column initialize ----------------
    #
    #
    class_property padding_width_range : Range(Int32, Int32) = 0..8
    class_property header_frequency_range : Range(Int32, Int32) = 0..64
    class_property row_divider_frequency_range : Range(Int32, Int32) = 1..8
    class_property header_wrap_range : Range(Int32, Int32) = 1..8
    class_property body_wrap_range : Range(Int32, Int32) = 1..8
    class_property column_width_range : Range(Int32, Int32) = 1..128
    class_property line_breaks_range : Range(Int32, Int32) = 0..8

    #
    #
    # -------------- Default values for Table initialize method --------------------
    #
    #
    class_property title : Title = Title.new
    class_property subtitle : SubTitle = SubTitle.new
    class_property footer : Footer = Footer.new
    #
    class_property border_type : String | BorderName = BorderName::Ascii
    class_property border_styler : BorderStyler = DEFAULT_STYLER
    #
    class_property heading_alignment : Justify = DEFAULT_HEADING_ALIGNMENT
    class_property heading_formatter : TextCellFormatter = DEFAULT_FORMATTER
    class_property heading_styler : TextCellStyler = DEFAULT_STYLER
    #
    class_property group_alignment : Justify = DEFAULT_HEADING_ALIGNMENT
    class_property group_formatter : TextCellFormatter = DEFAULT_FORMATTER
    class_property group_styler : TextCellStyler = DEFAULT_STYLER
    #
    class_property header_alignment : Justify? = nil
    class_property header_formatter : DataCellFormatter = DEFAULT_FORMATTER
    class_property header_styler : DataCellStyler = DEFAULT_DATA_DEPENDENT_STYLER
    #
    class_property body_alignment : Justify? = nil
    class_property body_formatter : DataCellFormatter = DEFAULT_FORMATTER
    class_property body_styler : DataCellStyler = DEFAULT_DATA_DEPENDENT_STYLER
    #
    class_property left_padding : Int32 = 1
    class_property right_padding : Int32 = 1
    class_property padding_character : String = " "
    class_property truncation_indicator : String = "~"
    class_property width : Int32 = 12
    #
    class_property header_frequency : Int32? = 0
    class_property row_divider_frequency : Int32? = nil
    class_property wrap_mode : WrapMode = WrapMode::Word
    class_property header_wrap : Int32? = nil
    class_property body_wrap : Int32? = nil
    class_property? masked_headers : Bool = false
    class_property? omit_group_header_rule : Bool = false
    class_property? omit_last_rule : Bool = false
  end
end
