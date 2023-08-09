require "./types"

module Tablo
  # The Heading struct is used to define three table layout elements : the title,
  # the subtitle and the footer. Each of them is optional, with its value set to `nil`
  # by default (no display).
  #
  # The empty string raises an `InvalidValue` exception (if an empty frame is nonetheless
  # wanted, assign a space to *value*).
  #
  # Spacing between the different row types (see `RowType`) is done by taking
  # the maximum of the 2 following values (max) :
  # - *spacing_after* of the previous row
  # - *spacing_before* of the current row
  # knowing that spacing (either before or after) of the row types Group, Header
  # and Body is always 0.
  #
  # When both rows (previous and current) are framed (row types Group, Header
  # or Body are always framed), and max is zero, the frames
  # are linked (proper rendering depends on border type).
  #
  # if `max > 0`, `max - 1` empty lines are inserted between previous and current rows.
  # abstract struct HeadingA
  #   getter value, alignment, formatter, styler

  #   def initialize(@value : CellType = nil, *,
  #                  @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
  #                  @formatter : TextCellFormatter = DEFAULT_FORMATTER,
  #                  @styler : TextCellStyler = DEFAULT_STYLER)
  #     if !value.nil?
  #       if value.is_a?(String) && value.empty?
  #         raise InvalidValue.new "Heading string value cannot be empty!"
  #       end
  #     end
  #   end
  # end

  struct HeadingFree
    getter? framed = false
    getter value, alignment, formatter, styler

    def initialize(@value : CellType = nil, *,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end
  end

  struct HeadingFramed
    getter? framed = true
    getter value, spacing_before, spacing_after, alignment, formatter, styler

    def initialize(@value : CellType = nil, *,
                   @spacing_before : Int32 = 0,
                   @spacing_after : Int32 = 0,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end
  end

  struct Heading
    getter? framed
    getter value, spacing_before, spacing_after, alignment, formatter, styler

    # Constructor
    # Raise an exception if *value* is an empty string.
    #
    # Parameters:
    #
    # - *value* : the only positional parameter, of type `CellType`(default: `nil`)
    # - *framed* : a boolean, indicating if the heading is boxed or not : default: `false`
    # - *spacing_before* : an Int32, whose value is >= 0, default: 0
    # - *spacing_after* : an Int32, whose value is >= 0, default: 0
    # - *alignment* : the alignment of *value*, of type `Justify`, default: `Justify::Center`
    # - *formatter* : a Proc to format the heading (see `TextCellFormatter`)
    # - *styler* : a Proc to style the heading (see `TextCellStyler`)
    def initialize(@value : CellType = nil, *,
                   @framed : Bool = false,
                   @spacing_before : Int32 = 0,
                   @spacing_after : Int32 = 0,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
      if !value.nil?
        if value.is_a?(String) && value.empty?
          raise InvalidValue.new "Heading string value cannot be empty!"
        end
      end
    end
  end
end
