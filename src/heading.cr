require "./types"

module Tablo
  # struct Frame creates a frame around a `Heading` (`Title`,
  # `SubTitle` or `Footer`)
  struct Frame
    # Called from RowGroup
    protected getter line_breaks_before, line_breaks_after

    # Returns a Frame instance
    #
    # The Frame struct must be used within a Heading instantiation (see
    # examples below).
    #
    # _Optional named parameters, with default values_
    #
    # - `line_breaks_before`: type is `Int32`<br />
    #   Default value is 0
    # - `line_breaks_after`: type is `Int32`<br />
    #   Default value is 0
    #
    # Permitted range of values for these 2 parameters is governed by
    # `Config.line_breaks_range` (an `InvalidValue` exception is raised if not
    # in range)
    #
    # These 2 parameters help define the number of line breaks between adjacent
    # framed rows.  The value of this number is the greater of the values
    # between the `line_breaks_after` value of one row and the
    # `line_breaks_before` value of the next, bearing in mind that for Group,
    # Header and Body row types, these values are always equal to 0.
    #
    # iThe following example:
    # ```
    # Title.new("My title", Frame.new(1, 1))
    # SubTitle.new("Another title", Frame.new(line_breaks_before: 3))
    # ```
    # would result in 3 line breaks between the title and the subtitle (ie
    # 2 blank lines)
    #
    # If the values of `line_breaks_after` and `line_breaks_before` are both equal
    # to 0, no line break is generated and the 2 frames are joined.
    #    # TODO I'm here ! TODO
    def initialize(@line_breaks_before : Int32 = 0,
                   @line_breaks_after : Int32 = 0)
      unless line_breaks_before.in?(Config.line_breaks_range) &&
             line_breaks_after.in?(Config.line_breaks_range)
        raise InvalidValue.new "Line breaks must be in range " \
                               "(#{Config.line_breaks_range})"
      end
    end
  end

  # The Heading struct is used to define three table layout elements : the title,
  # the subtitle and the footer.
  #
  # The common parameters between title, subtitle and footer are :
  # - `value`: type is `CellType?`  <br />
  #   Default value is `nil` (nothing to display)
  # - `frame`: type is `Frame?`  <br />
  #   Default value is `nil` (no frame)
  #
  # The parameters co
  # For each of them, all parameters are optional
  # (default is `nil` for the `value` parameter, which means no display)
  #
  # Spacing between the different row types (see `RowType`) is done by taking
  # the maximum of the 2 following values (max) :
  # - *line_breaks_after* of the current row
  # - *line_breaks_before* of the next row
  # knowing that spacing (either before or after) of the row types Group, Header
  # and Body is always 0.
  #
  # When both rows (current and next) are framed (row types Group, Header
  # or Body are always framed), and max is zero, the frames
  # are joined (proper rendering depends on border type).
  #
  # if `max > 0`, `max - 1` empty lines are inserted between current and next rows.
  abstract struct Heading
    # Called from  Table,RowGroup
    protected property value, frame

    # Called from Table
    # protected getter alignment : Justify, formatter, styler

    # protected getter alignment : Justify = Config.heading_alignment,
    #   formatter : TextCellFormatter = Config.heading_formatter,
    #   styler : TextCellStyler = Config.heading_styler

    # Called from  Table,RowGroup
    # Is the heading framed ?
    protected def framed?
      !frame.nil?
    end
  end

  struct Title < Heading
    # Called from RowGroup
    protected property? repeated
    # Called from Table
    protected getter alignment, formatter, styler

    # Returns an instance of Title
    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : TextCellFormatter = Config.heading_formatter,
                   @styler : TextCellStyler = Config.heading_styler,
                   @repeated : Bool = false)
      # check_value
    end
  end

  struct SubTitle < Heading
    # Called from Table
    protected getter alignment, formatter, styler

    # Returns an instance of SubTitle
    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : TextCellFormatter = Config.heading_formatter,
                   @styler : TextCellStyler = Config.heading_styler)
      check_value
    end
  end

  struct Footer < Heading
    # Called from RowGroup
    protected property? page_break
    # Called from Table
    protected getter alignment, formatter, styler

    # Returns an instance of Footer
    def initialize(@value : CellType? = nil, *,
                   @frame : Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : TextCellFormatter = Config.heading_formatter,
                   @styler : TextCellStyler = Config.heading_styler,
                   @page_break : Bool = false)
      check_value
    end
  end
end
