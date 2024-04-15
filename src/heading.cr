require "./types"

module Tablo
  # struct Frame creates a frame around titles, subtitles or footers, with
  # optional line breaks before and after.
  struct Frame
    # Called from RowGroup
    protected getter line_breaks_before, line_breaks_after

    # The Frame struct is to be used within a Heading instantiation (see
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
    # `Config::Controls.line_breaks_range` (an `Error::InvalidValue` exception is raised if not
    # in range)
    #
    # These 2 parameters help define the number of line breaks between adjacent
    # framed rows.  The value of this number is the greater of the values
    # between the `line_breaks_after` value of one row and the
    # `line_breaks_before` value of the next, bearing in mind that for Group,
    # Header and Body row types, or unframed Heading types, these values are always equal to 0.
    #
    # In the following example:
    # ```
    # require "tablo"
    # table = Tablo::Table.new([1, 2, 3],
    #   title: Tablo::Heading::Title.new("My Title",
    #     frame: Tablo::Frame.new(0, 2))) do |t|
    #   t.add_column("itself", &.itself)
    # end
    # puts table
    # ```
    # we see that the framed title is separated from the table body by one blank line,
    # but two linebreaks have been issued.
    #
    # ```
    # +--------------+
    # |   My Title   |
    # +--------------+
    #
    # +--------------+
    # |       itself |
    # +--------------+
    # |            1 |
    # |            2 |
    # |            3 |
    # +--------------+
    # ```
    # On the contrary, If the values of `line_breaks_after` and
    # `line_breaks_before` are both equal to 0, no line break is generated and
    # the 2 adjacent frames are joined.
    # ```
    # require "tablo"
    # table = Tablo::Table.new([1, 2, 3],
    #   title: Tablo::Heading::Title.new("My Title",
    #     frame: Tablo::Frame.new(0, line_breaks_after: 0))) do |t|
    #   t.add_column("itself", &.itself)
    # end
    # puts table
    # ```
    # Here, `line_breaks_after` is set to 0 for the title Frame, and the
    # `line_breaks_before` is also equal to 0 (as is always the case for group,
    # header and body)
    # ```
    # +--------------+
    # |   My Title   |
    # +--------------+
    # |       itself |
    # +--------------+
    # |            1 |
    # |            2 |
    # |            3 |
    # +--------------+
    # ```
    def initialize(@line_breaks_before : Int32 = 0,
                   @line_breaks_after : Int32 = 0)
      unless line_breaks_before.in?(Config::Controls.line_breaks_range) &&
             line_breaks_after.in?(Config::Controls.line_breaks_range)
        raise Error::InvalidValue.new "Line breaks must be in range " \
                                      "(#{Config::Controls.line_breaks_range})"
      end
    end
  end

  # The sole purpose of the Heading module is to group together the Title,
  # SubTitle and Footer structs.
  module Heading
    protected getter line_breaks_before, line_breaks_after
    # Called from  Table,RowGroup
    protected property value, frame
    # Called from Table
    protected getter alignment, formatter, styler

    # Called from RowGroup
    #
    def framed?
      !frame.nil?
    end

    # struct Title creates a title for the table.
    struct Title
      include Heading
      protected property? repeated

      # Returns an instance of Title.
      #
      # Example:
      # ```
      # Tablo::Table.new((1, 2, 3],
      #   title: Tablo::Heading::Title.new("My title", frame: Tablo::Frame.new(1, 1), repeated: true)
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
      #   By default, as defined in `Config::Defaults.heading_alignment` (but this can be
      #   modified), title content is centered.
      # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
      #   Default value is set by `Config::Defaults.heading_formatter`
      # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
      #   Default value is set by `Config::Defaults.heading_styler`
      # - `repeated`: type is `Bool` <br />
      #   Default value is `false` <br />
      #   This attribute governs the repetition of the title and subtitle when the
      #   `header_frequency` attribute of `Table` is greater than 0 (if `true`, title and subtitle
      #   are inserted before the repeated group and header rows).
      def initialize(@value : CellType = nil,
                     @frame : Frame? = nil,
                     @alignment : Justify = Config::Defaults.heading_alignment,
                     @formatter : Cell::Text::Formatter = Config::Defaults.heading_formatter,
                     @styler : Cell::Text::Styler = Config::Defaults.heading_styler,
                     @repeated : Bool = false)
      end
    end

    # struct SubTitle creates a subtitle for the table (**but displayed only  if
    # a title has also been defined**)
    struct SubTitle
      include Heading

      # Returns an instance of SubTitle
      #
      # Example:
      # ```
      # Tablo::Table.new((1, 2, 3],
      #   subtitle: Tablo::Heading::SubTitle.new("My subtitle", frame: Tablo::Frame.new(1, 1),
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
      #   By default, as defined in `Config::Defaults.heading_alignment` (but this can be
      #   modified), subtitle content is centered.
      # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
      #   Default value is set by `Config::Defaults.heading_formatter`
      # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
      #   Default value is set by `Config::Defaults.heading_styler`
      def initialize(@value : CellType = nil,
                     @frame : Frame? = nil,
                     @alignment : Justify = Config::Defaults.heading_alignment,
                     @formatter : Cell::Text::Formatter = Config::Defaults.heading_formatter,
                     @styler : Cell::Text::Styler = Config::Defaults.heading_styler)
      end
    end

    struct Footer
      include Heading
      protected property? page_break

      # Returns an instance of Footer.
      #
      # Example:
      # ```
      # require "tablo"
      # table = Tablo::Table.new([1, 2, 3],
      #   footer: Tablo::Heading::Footer.new("My footer",
      #     frame: Tablo::Frame.new(1, 1), page_break: true)) do |t|
      #   t.add_column("itself", &.itself)
      # end
      # puts table
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
      #   By default, as defined in `Config::Defaults.heading_alignment` (but this can be
      #   modified), footer content is centered.
      # - `formatter`:  a Proc whose type is `Cell::Text::Formatter` <br />
      #   Default value is set by `Config::Defaults.heading_formatter`
      # - `styler`:  a Proc whose type is `Cell::Text::Styler` <br />
      #   Default value is set by `Config::Defaults.heading_styler`
      # - `page_break`: type is `Bool` <br />
      #   Default value is `false` <br />
      # If true, a page break is inserted after the footer content (or after the
      # footer frame, but note that in this case, it prevents the join with the
      # frame that follows when the value of the `omit_last_rule` parameter of
      # `Table` is `true`).
      def initialize(@value : CellType = nil,
                     @frame : Frame? = nil,
                     @alignment : Justify = Config::Defaults.heading_alignment,
                     @formatter : Cell::Text::Formatter = Config::Defaults.heading_formatter,
                     @styler : Cell::Text::Styler = Config::Defaults.heading_styler,
                     @page_break : Bool = false)
      end
    end
  end
end
