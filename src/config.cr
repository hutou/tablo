require "./types"

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
    class_property? pack_autosize : Bool = true
    class_property starting_widths : StartingWidths = StartingWidths::AutoSized

    class_property padding_width_range : Range(Int32, Int32) = 0..8
    class_property header_frequency_range : Range(Int32, Int32) = 0..64
    class_property row_divider_frequency_range : Range(Int32, Int32) = 1..8
    class_property header_wrap_range : Range(Int32, Int32) = 1..8
    class_property body_wrap_range : Range(Int32, Int32) = 1..8
    class_property column_width_range : Range(Int32, Int32) = 1..128
  end
end
