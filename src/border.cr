require "./types"
require "./config"

module Tablo
  # The Border class enhances the layout of a data table by separating rows
  # and columns with interconnected horizontal and vertical lines.
  #
  # Various predefined line types are available, but you are free to create your own.
  #
  # A border can be styled by a user defined proc, of type `Styler` allowing
  # for colorized output, either by using ANSI sequences or the "colorize" module
  # from the stdlib (default: no style).
  #
  # A `Border` is defined by a string of exactly 16 characters, which is
  # then converted into 16 strings of up to 1 character each. The definition
  # string can contain any character, but two of them have a special meaning:
  # during conversion, the uppercase E is replaced by an empty string, and the
  # uppercase S character is replaced by a space (a simple space may also be used,
  # of course).
  #
  # _Please note that using the capital E character may cause alignment
  # difficulties._
  #
  # Examples of text or graphic connectors:
  # ```
  # | Name                           | 16 chars string  |
  # | ------------------------------ | ---------------  |
  # | CONNECTORS_SINGLE_ROUNDED      | ╭┬╮├┼┤╰┴╯│││──── |
  # | CONNECTORS_SINGLE              | ┌┬┐├┼┤└┴┘│││──── |
  # | CONNECTORS_DOUBLE              | ╔╦╗╠╬╣╚╩╝║║║════ |
  # | CONNECTORS_SINGLE_DOUBLE       | ╒╤╕╞╪╡╘╧╛│││════ |
  # | CONNECTORS_DOUBLE_SINGLE       | ╓╥╖╟╫╢╙╨╜║║║──── |
  # | CONNECTORS_HEAVY               | ┏┳┓┣╋┫┗┻┛┃┃┃━━━━ |
  # | CONNECTORS_LIGHT_HEAVY         | ┍┯┑┝┿┥┕┷┙│││━━━━ |
  # | CONNECTORS_HEAVY_LIGHT         | ┎┰┒┠╂┨┖┸┚┃┃┃──── |
  # | CONNECTORS_TEXT_CLASSIC        | +++++++++|||---- |
  #
  # ```
  # Mixed graphic character sets, such as:
  # ```
  # | Name                           | 16 chars string  |
  # | ------------------------------ | ---------------  |
  # | CONNECTORS_SINGLE_DOUBLE_MIXED | ╔╤╗╟┼╢╚╧╝║│║═─═- |
  # ```
  # may not be correctly rendered.
  #
  # Below is a detailed representation of each position and meaning:
  #
  # The first 9 characters define the junction or intersection of horizontal and
  # vertical border lines.
  #
  # ```
  # Pos Connector name     Example (using Fancy border preset)
  # --- --------------     -----------------------------------
  #  0  top_left           "┌"
  #  1  top_mid            "┬"
  #  2  top_right          "┐"
  #
  #  3  mid_left           "├"
  #  4  mid_mid            "┼"
  #  5  mid_right          "┤"
  #
  #  6  bottom_left        "└"
  #  7  bottom_mid         "┴"
  #  8  bottom_right       "┘"
  # ```
  #
  # The next three characters define vertical separators in data rows.
  #
  # ```
  #  9  vdiv_left          "│"
  # 10  vdiv_mid           ":"
  # 11  vdiv_right         "│"
  # ```
  #
  # And finally, the last four characters define the different types of horizontal
  # border, depending on the type of data row or types of adjacent data rows.
  #
  # ```
  # 12  hdiv_tbs           "─"     (title or top or bottom or summary)
  # 13  hdiv_grp           "−"     (group)
  # 14  hdiv_hdr           "-"     (header)
  # 15  hdiv_bdy           "⋅"     (body)
  # ```
  #
  # Eight predefined borders, of type `PreSet`, can also be used instead of
  # a definition string.
  #
  # ```
  # | name          | 16 chars string  |
  # | ------------- | ---------------- |
  # | Ascii         | +++++++++|||---- |
  # | ReducedAscii  | ESEESEESEESE---- |
  # | ReducedModern | ESEESEESEESE──── |
  # | Markdown      | SSS|||SSS|||SS-S |
  # | Modern        | ┌┬┐├┼┤└┴┘│││──── |
  # | Fancy         | ╭┬╮├┼┤╰┴╯│:│─−-⋅ |
  # | Blank         | SSSSSSSSSSSSSSSS |
  # | Empty         | EEEEEEEEEEEEEEEE |
  # ```
  #
  # For example, the string `"ESEESEESEESE───"` is how the `ReducedModern`
  # style is defined.
  struct Border
    #  `PreSet` is an `enum` identifying a finite set of strings defining the most
    #  commonly used table layout templates (see `PREDEFINED_BORDERS`).
    enum PreSet
      Ascii
      ReducedAscii
      ReducedModern
      Markdown
      Modern
      Fancy
      Empty
      Blank
    end
    # A border may be styled, either by using ANSI color sequences or using
    # the stdlib colorize module.
    #
    #  `styler` default value is set by `Config.border_styler`
    #
    # Example, to colorize borders in blue :
    # ```
    # require "tablo"
    # require "colorize"
    # table = Tablo::Table.new([1, 2, 3],
    #   border: Tablo::Border.new(Tablo::Border::PreSet::Fancy,
    #     styler: ->(b : String) { b.colorize(:blue).to_s })) do |t|
    #   t.add_column("itself", &.itself)
    # end
    # puts table
    # ```
    #
    # <img src="../../assets/images/api_border_styler.svg" width="400">
    #
    alias Styler = Proc(String, String)

    protected property top_left : String, top_mid : String, top_right : String
    protected property mid_left : String, mid_mid : String, mid_right : String
    protected property bottom_left : String, bottom_mid : String, bottom_right : String
    protected property vdiv_left : String, vdiv_mid : String, vdiv_right : String
    protected property hdiv_tbs : String, hdiv_grp : String, hdiv_hdr : String
    protected property hdiv_bdy : String

    private getter styler

    # `PreSet` border definition hash constant
    PREDEFINED_BORDERS =
      {
        PreSet::Ascii         => "+++++++++|||----",
        PreSet::ReducedAscii  => "ESEESEESEESE----",
        PreSet::Modern        => "┌┬┐├┼┤└┴┘│││────",
        PreSet::ReducedModern => "ESEESEESEESE────",
        PreSet::Markdown      => "SSS|||SSS|||SS-S",
        PreSet::Fancy         => "╭┬╮├┼┤╰┴╯│:│─−-⋅",
        PreSet::Blank         => "SSSSSSSSSSSSSSSS",
        PreSet::Empty         => "EEEEEEEEEEEEEEEE",
      }

    # Border constructor, returning a Border instance.
    #
    # _Optional (named) parameters, with default values_:
    #
    # - `definition`: type is `String` | `PreSet`
    #
    #   Default value is set by `Config.border_definition`
    #
    # - `styler`: type is `Styler`
    #
    #   Default value is set by `Config.border_styler`
    #
    # Examples :
    # ```
    # border = Tablo::Border.new(Tablo::Border::PreSet::Fancy,
    #   styler: ->(s : String) { s.colorize(:yellow).to_s })
    # ```
    # or
    # ```
    # border = Tablo::Border.new("┌┬┐├┼┤└┴┘│││────",
    #   styler: ->(s : String) { s.colorize.fore(:blue).mode(:bold).to_s })
    # ```
    def initialize(definition : String | PreSet = Config.border_definition,
                   @styler : Styler = Config.border_styler)
      if definition.is_a?(PreSet)
        definition = PREDEFINED_BORDERS[definition].as(String)
      end
      unless definition.size == 16
        raise Error::InvalidBorderDefinition.new "Invalid border definition " +
                                                 "<#{definition}> (size != 16)"
      end
      ars = definition.split("").map { |e|
        case e
        when "E"
          ""
        when "S"
          " "
        else
          e
        end
      }
      @top_left = ars[0]; @top_mid = ars[1]; @top_right = ars[2]
      @mid_left = ars[3]; @mid_mid = ars[4]; @mid_right = ars[5]
      @bottom_left = ars[6]; @bottom_mid = ars[7]; @bottom_right = ars[8]
      @vdiv_left = ars[9]; @vdiv_mid = ars[10]; @vdiv_right = ars[11]
      @hdiv_tbs = ars[12]; @hdiv_grp = ars[13]; @hdiv_hdr = ars[14]
      @hdiv_bdy = ars[15]
    end

    # Renders a horizontal rule, depending on its position.
    # (cannot be private, because of call from table.cr)
    protected def horizontal_rule(column_widths, position = Position::Bottom,
                                  groups = [] of Array(Int32)) # nil)
      left, middle, right, segment, altmiddle = connectors(position)
      segments = column_widths.map { |width| segment * width }
      # Purpose of the line below ???  Use case not clear, but doesn't hurt though!
      left = right = middle = altmiddle = "" if segments.all?(&.empty?)
      # str = if groups.nil?
      str = if groups.empty?
              segments.join(vdiv_mid.empty? ? "" : middle)
            else
              middles = groups.flat_map { |e|
                Array.new(e.size - 1) { vdiv_mid.empty? ? "" : altmiddle } << middle
              }
              String.build do |string|
                (segments.size - 1).times do |i|
                  string << segments[i] << middles[i]
                end
                string << segments.last
              end
            end
      style("#{left}#{str}#{right}")
    end

    # Joins elements of a row (styled connectors and column contents).
    # (cannot be private, because of call from table.cr)
    protected def join_cell_contents(cells)
      styled_divider_vertical = style(vdiv_mid)
      styled_edge_left = style(vdiv_left)
      styled_edge_right = style(vdiv_right)
      styled_edge_left + cells.join(styled_divider_vertical) + styled_edge_right
    end

    # Returns a tuple of 5 connector strings, depending on the row position.
    private def connectors(position)
      case position
      # PreSet::Fancy used as example
      # (Fifth connector only used when Group involved)
      in Position::BodyBody      then {mid_left, mid_mid, mid_right, hdiv_bdy, ""}              # ├ ┼ ┤ ⋅ E
      in Position::BodyBottom    then {bottom_left, bottom_mid, bottom_right, hdiv_tbs, ""}     # ╰ ┴ ╯ ─ E
      in Position::BodyFiller    then {vdiv_left, vdiv_mid, vdiv_right, " ", ""}                # │ : │   E
      in Position::BodyGroup     then {mid_left, mid_mid, mid_right, hdiv_grp, bottom_mid}      # ├ ┼ ┤ − ┴
      in Position::BodyHeader    then {mid_left, mid_mid, mid_right, hdiv_hdr, ""}              # ├ ┼ ┤ - E
      in Position::BodyTitle     then {mid_left, bottom_mid, mid_right, hdiv_tbs, ""}           # ├ ┴ ┤ ─ E
      in Position::BodyTop       then {top_left, top_mid, top_right, hdiv_tbs, ""}              # ╭ ┬ ╮ ─ E
      in Position::GroupHeader   then {mid_left, mid_mid, mid_right, hdiv_grp, top_mid}         # ├ ┼ ┤ − ┬
      in Position::GroupTop      then {top_left, top_mid, top_right, hdiv_tbs, hdiv_tbs}        # ╭ ┬ ╮ ─ ─
      in Position::HeaderBody    then {mid_left, mid_mid, mid_right, hdiv_hdr, ""}              # ├ ┼ ┤ - E
      in Position::HeaderTop     then {top_left, top_mid, top_right, hdiv_tbs, ""}              # ╭ ┬ ╮ ─ E
      in Position::SummaryBody   then {mid_left, mid_mid, mid_right, hdiv_tbs, ""}              # ├ ┼ ┤ ─ E
      in Position::SummaryHeader then {mid_left, mid_mid, mid_right, hdiv_tbs, ""}              # ├ ┼ ┤ ─ E
      in Position::TitleBody     then {mid_left, top_mid, mid_right, hdiv_tbs, ""}              # ├ ┬ ┤ ─ E
      in Position::TitleBottom   then {bottom_left, hdiv_tbs, bottom_right, hdiv_tbs, hdiv_tbs} # ╰ ─ ╯ ─ ─
      in Position::TitleGroup    then {mid_left, top_mid, mid_right, hdiv_tbs, hdiv_tbs}        # ├ ┬ ┤ ─ ─
      in Position::TitleHeader   then {mid_left, top_mid, mid_right, hdiv_tbs, ""}              # ├ ┬ ┤ ─ E
      in Position::TitleTitle    then {mid_left, hdiv_tbs, mid_right, hdiv_tbs, ""}             # ├ ─ ┤ ─ E
      in Position::TitleTop      then {top_left, hdiv_tbs, top_right, hdiv_tbs, ""}             # ╭ ─ ╮ ─ E
      end
    end

    # Returns a styled connector, if not empty and styling allowed.
    private def style(s)
      styler && !s.empty? && Util.styler_allowed ? styler.call(s) : s
    end
  end
end
