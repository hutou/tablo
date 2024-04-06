require "./types"

module Tablo
  # struct Heading::Frame creates a frame around titles, subtitles or footers
  struct Heading
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
      def initialize(@line_breaks_before : Int32 = 0,
                     @line_breaks_after : Int32 = 0)
        unless line_breaks_before.in?(Config.line_breaks_range) &&
               line_breaks_after.in?(Config.line_breaks_range)
          raise InvalidValue.new "Line breaks must be in range " \
                                 "(#{Config.line_breaks_range})"
        end
      end
    end
  end

  # struct Title creates a title for the table.
  struct Title
    # Called from  Table,RowGroup
    protected property value, frame
    # Called from Table
    protected getter alignment, formatter, styler
    # Called from RowGroup
    protected property? repeated

    # Returns an instance of Title.
    #
    # Example:
    # ```
    # Tablo::Table.new((1, 2, 3],
    #   title: Tablo::Title.new("My title", frame: Tablo::Frame.new(1, 1), repeated: true)
    # ```
    #
    # _All (named) parameters are optional, with default values_
    #
    # - `value`: type is `CellType` <br />
    #   Default value is `nil` <br />
    # This is the title's display content.
    # - `frame`: type is `Frame?` <br />
    #   Default value is `nil` <br />
    #   If a Frame instance is created, the title is framed.
    # - `alignment`: type is `Justify` <br />
    #   By default, as defined in `Config.heading_alignment` (but this can be
    #   modified), title content is centered.
    # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
    #   Default value is set by `Config.heading_formatter`
    # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
    #   Default value is set by `Config.heading_styler`
    # - `repeated`: type is `Bool` <br />
    #   Default value is `false` <br />
    #   This attribute governs the repetition of the title and subtitle when the
    #   `header_frequency` attribute of `Table` is greater than 0 (if `true`, title and subtitle
    #   are inserted before the repeated group and header rows).
    def initialize(@value : CellType = nil,
                   @frame : Heading::Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : Cell::Text::Formatter = Config.heading_formatter,
                   @styler : Cell::Text::Styler = Config.heading_styler,
                   @repeated : Bool = false)
    end

    protected def framed?
      !frame.nil?
    end
  end

  # struct SubTitle creates a subtitle for the table (**but displayed only  if
  # a title has also been defined**)
  struct SubTitle
    # Called from  Table,RowGroup
    protected property value, frame
    # Called from Table
    protected getter alignment, formatter, styler

    # Returns an instance of SubTitle
    #
    # Example:
    # ```
    # Tablo::Table.new((1, 2, 3],
    #   subtitle: Tablo::SubTitle.new("My subtitle", frame: Tablo::Frame.new(1, 1),
    #     alignment: Tablo::Justify::Left)
    # ```
    #
    # _All (named) parameters are optional, with default values_
    #
    # - `value`: type is `CellType` <br />
    #   Default value is `nil` <br />
    # This is the subtitle's display content.
    # - `frame`: type is `Frame?` <br />
    #   Default value is `nil` <br />
    #   If a Frame instance is created, the subtitle is framed.
    # - `alignment`: type is `Justify` <br />
    #   By default, as defined in `Config.heading_alignment` (but this can be
    #   modified), subtitle content is centered.
    # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
    #   Default value is set by `Config.heading_formatter`
    # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
    #   Default value is set by `Config.heading_styler`
    def initialize(@value : CellType = nil,
                   @frame : Heading::Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : Cell::Text::Formatter = Config.heading_formatter,
                   @styler : Cell::Text::Styler = Config.heading_styler)
    end

    protected def framed?
      !frame.nil?
    end
  end

  struct Footer
    # Called from  Table,RowGroup
    protected property value, frame
    # Called from Table
    protected getter alignment, formatter, styler
    # Called from RowGroup
    protected property? page_break

    # Returns an instance of Footer.
    #
    # Example:
    # ```
    # Tablo::Table.new((1, 2, 3],
    #   footer: Tablo::Footer.new("My footer", frame: Tablo::Frame.new(1, 1), page_break: true)
    # ```
    #
    # _All (named) parameters are optional, with default values_
    #
    # - `value`: type is `CellType` <br />
    #   Default value is `nil` <br />
    # This is the footer's display content.
    # - `frame`: type is `Frame?` <br />
    #   Default value is `nil` <br />
    #   If a Frame instance is created, the footer is framed.
    # - `alignment`: type is `Justify` <br />
    #   By default, as defined in `Config.heading_alignment` (but this can be
    #   modified), footer content is centered.
    # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
    #   Default value is set by `Config.heading_formatter`
    # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
    #   Default value is set by `Config.heading_styler`
    # - `page_break`: type is `Bool` <br />
    #   Default value is `false` <br />
    # If true, a page break is inserted after the footer content (or after the
    # footer frame, but note that in this case, it prevents the join with the
    # frame that follows when the value of the `omit_last_rule` parameter of
    # `Table` is `true`).
    def initialize(@value : CellType = nil,
                   @frame : Heading::Frame? = nil,
                   @alignment : Justify = Config.heading_alignment,
                   @formatter : Cell::Text::Formatter = Config.heading_formatter,
                   @styler : Cell::Text::Styler = Config.heading_styler,
                   @page_break : Bool = false)
    end

    protected def framed?
      !frame.nil?
    end
  end
end
