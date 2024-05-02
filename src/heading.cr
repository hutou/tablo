module Tablo
  # The purpose of the Heading struct is to manage page titles, subtitles and
  # footers. It will therefore be used to initialize the corresponding
  # attributes in Tablo::Table, ie: *title*, *subtitle* and *footer*. <br />
  # *(Please note, however, that the display of a subtitle is dependent on the
  # existence of a title).*
  struct Heading
    protected getter line_breaks_before, line_breaks_after
    protected property value
    protected property? framed
    protected getter alignment, formatter, styler

    protected def line_breaks_before=(before)
      unless line_breaks_before.in?(Config::Controls.line_breaks_range)
        raise Error::InvalidValue.new "Line breaks must be in range " \
                                      "(#{Config::Controls.line_breaks_range})"
      end
    end

    protected def line_breaks_after=(after)
      unless line_breaks_after.in?(Config::Controls.line_breaks_range)
        raise Error::InvalidValue.new "Line breaks must be in range " \
                                      "(#{Config::Controls.line_breaks_range})"
      end
    end

    protected property? repeated   # Specific to tiles
    protected property? page_break # specific to footers

    # The struct Heading instantiation can accept up to 9 parameters, all of
    # which have a default value.
    #
    # - *value*: This is the heading's display content <br />
    #   (Default: see `Tablo::Config::Defaults.title` or `Tablo::Config::Defaults.subtitle`
    #   or `Tablo::Config::Defaults.footer`)
    #
    # - *framed*: If true, the heading's content is framed <br />
    #   Default: `false`
    #
    # - *line_breaks_before*: (see below) <br />
    #   Default: `0`
    #
    # - *line_breaks_after*: (see below) <br />
    #   Default: `0`
    #
    #   Permitted range of values for these last 2 parameters is governed by
    #   `Config::Controls.line_breaks_range`. <br />
    #   (an `Error::InvalidValue` exception  is raised if not in range. <br />
    #   (see explanations below for their usage)
    #
    # - *alignment*: content justification <br />
    #   (Default: see `Config::Defaults.heading_alignment`)
    #
    # - *formatter*:  User-defined Proc <br />
    #   (Default: see `Config::Defaults.heading_formatter`)
    #
    # - *styler*:  User-defined Proc <br />
    #   (Default: see `Config::Defaults.heading_styler`)
    #
    # - *repeated*:  This attribute governs the repetition of title and
    #   subtitle when the *header_frequency* attribute of Table is greater than
    #   0 (if `true`, title and subtitle are inserted before the repeated group
    #   and header rows). <br />
    #   *-> only applicable to the title attribute* <br />
    #   (Default: `false`)
    #
    # - *page_break*: If true, a page break is inserted after the footer
    #   content (or after the footer frame, but note that in this case, it
    #   prevents the join with the frame that follows when the value of the
    #   *omit_last_rule* parameter of Table is `true`). <br />
    #   *-> only applicable to the footer attribute* <br />
    #   (Default: `false`)
    #
    # A minimal example could be:
    # ```
    # require "tablo"
    # table = Tablo::Table.new([1, 2, 3],
    #   title: Tablo::Heading.new("My title", framed: true)) do |t|
    #   t.add_column("itself", &.itself)
    # end
    # puts table
    # ```
    #
    # ```
    # +--------------+
    # |   My title   |
    # +--------------+
    # |       itself |
    # +--------------+
    # |            1 |
    # |            2 |
    # |            3 |
    # +--------------+
    # ```
    #
    # __Use of *line_breaks_before* and *line_breaks_after* parameters__
    #
    # These 2 parameters help define the number of line breaks between adjacent
    # framed rows.  The value of this number is the greater of the values
    # between the *line_breaks_after* value of one row and the
    # *line_breaks_before* value of the next, bearing in mind that for Group,
    # Header and Body row types, or unframed Heading types, these values are always equal to 0.
    #
    # In the following example:
    #
    # ```
    # require "tablo"
    # table = Tablo::Table.new([1, 2, 3],
    #   title: Tablo::Heading.new("My title", framed: true,
    #     line_breaks_after: 2),
    #   footer: Tablo::Heading.new("My footer", framed: true,
    #     line_breaks_before: 1)) do |t|
    #   t.add_column("itself", &.itself)
    # end
    # puts table
    # ```
    # we see that the framed title is separated from the table body by one blank line,
    # but two line breaks have been issued. We can also see that the footer is not
    # joined to the last body row because of the *line_breaks_before* parameter set to 1.
    #
    # ```
    # +--------------+
    # |   My title   |
    # +--------------+
    #
    # +--------------+
    # |       itself |
    # +--------------+
    # |            1 |
    # |            2 |
    # |            3 |
    # +--------------+
    # +--------------+
    # |   My footer  |
    # +--------------+
    # ```
    # Compare this with the previous example, where no line breaks were generated.
    def initialize(@value : CellType = nil, *,
                   @framed : Bool = false,
                   @line_breaks_before : Int32 = 0,
                   @line_breaks_after : Int32 = 0,
                   @alignment : Justify = Config::Defaults.heading_alignment,
                   @formatter : Cell::Text::Formatter = Config::Defaults.heading_formatter,
                   @styler : Cell::Text::Styler = Config::Defaults.heading_styler,
                   @repeated : Bool = false,
                   @page_break : Bool = false)
    end
  end

  # struct SubTitle creates a subtitle for the table (**but displayed only  if
  # a title has also been defined**)

  # On the contrary, If the values of `line_breaks_after` and
  # `line_breaks_before` are both equal to 0, no line break is generated and
  # the 2 adjacent frames are joined.
end
