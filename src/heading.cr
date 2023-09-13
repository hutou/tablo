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
  # - *line_breaks_after* of the previous row
  # - *line_breaks_before* of the current row
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

  # struct UnFramedHeading
  #   getter? framed = false
  #   getter value, alignment, formatter, styler

  #   def initialize(@value : CellType = nil, *,
  #                  @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
  #                  @formatter : TextCellFormatter = DEFAULT_FORMATTER,
  #                  @styler : TextCellStyler = DEFAULT_STYLER)
  #   end
  # end

  # struct FramedHeading
  #   getter? framed = true
  #   getter value, line_breaks_before, line_breaks_after, alignment, formatter, styler

  #   def initialize(@value : CellType = nil, *,
  #                  @line_breaks_before : Int32 = 0,
  #                  @line_breaks_after : Int32 = 0,
  #                  @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
  #                  @formatter : TextCellFormatter = DEFAULT_FORMATTER,
  #                  @styler : TextCellStyler = DEFAULT_STYLER)
  #   end
  # end

  struct Frame
    getter line_breaks_before, line_breaks_after

    def initialize(@line_breaks_before : Int32 = 0,
                   @line_breaks_after : Int32 = 0)
      unless line_breaks_before.in?(Config.line_breaks_range) &&
             line_breaks_after.in?(Config.line_breaks_range)
        raise InvalidValue.new "Line breaks must be in range " \
                               "(#{Config.line_breaks_range})"
      end
    end
  end

  abstract struct Heading
    getter value, frame, alignment, formatter, styler

    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end

    def framed?
      !frame.nil?
    end
  end

  struct Title < Heading
    getter? repeated

    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @repeated : Bool = false,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end
  end

  struct SubTitle < Heading
    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end
  end

  struct Footer < Heading
    getter? page_break

    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @page_break : Bool = false,
                   @alignment : Justify = DEFAULT_HEADING_ALIGNMENT,
                   @formatter : TextCellFormatter = DEFAULT_FORMATTER,
                   @styler : TextCellStyler = DEFAULT_STYLER)
    end
  end
end
