require "./types"
require "./config"

module Tablo
  # Each `Border` type is defined by a string of exactly 16 characters, which is
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
  # are not correctly rendered.
  #
  # Below is a detailed representation of each position and meaning:
  #
  # The first 9 characters define the junction or intersection of horizontal and
  # vertical border lines.
  #
  # ```
  # Pos Connector name     Example (using Fancy border name string)
  # --- --------------     ----------------------------------------
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
  # Eight predefined borders, of type `BorderName`, can also be used instead of
  # a definition string.
  #
  # ```
  # | name          | 16 chars string  |
  # | ------------- | ---------------- |
  # | Ascii         | +++++++++|||---- |
  # | ReducedAscii  | E EE EE EE E---- |
  # | ReducedModern | E EE EE EE E──── |
  # | Markdown      |    |||   |||  -  |
  # | Modern        | ┌┬┐├┼┤└┴┘│││──── |
  # | Fancy         | ╭┬╮├┼┤╰┴╯│:│─−-⋅ |
  # | Blank         | SSSSSSSSSSSSSSSS |
  # | Empty         | EEEEEEEEEEEEEEEE |
  # ```
  #
  # For example, the string `"E EE EE EE E───"` is how the `ReducedModern`
  # style is defined.
  #
  # A border can be styled by a user defined proc, of type `BorderStyler` allowing
  # for colorized output, either by using ANSI sequences or the "colorize" module
  # from the stdlib (default: no style).
  struct Border
    protected property top_left : String, top_mid : String, top_right : String
    protected property mid_left : String, mid_mid : String, mid_right : String
    protected property bottom_left : String, bottom_mid : String, bottom_right : String
    protected property vdiv_left : String, vdiv_mid : String, vdiv_right : String
    protected property hdiv_tbs : String, hdiv_grp : String, hdiv_hdr : String
    protected property hdiv_bdy : String

    private getter styler

    # Border predefined strings, enabled by name, described in `enum BorderName`.
    PREDEFINED_BORDERS = {
      BorderName::Ascii         => "+++++++++|||----",
      BorderName::ReducedAscii  => "E EE EE EE E----",
      BorderName::Modern        => "┌┬┐├┼┤└┴┘│││────",
      BorderName::ReducedModern => "E EE EE EE E────",
      BorderName::Markdown      => "   |||   |||  - ",
      BorderName::Fancy         => "╭┬╮├┼┤╰┴╯│:│─−-⋅",
      BorderName::Blank         => "SSSSSSSSSSSSSSSS",
      BorderName::Empty         => "EEEEEEEEEEEEEEEE",
    }

    # Primary constructor, defined by a string or by a hash of predefined strings
    # of connectors and a styler proc. <br />
    # Returns a Border instance.
    #
    # _Optional (named) parameters, with default values_:
    #
    # - `border_type`: type is `String` | `BorderName` <br />
    #   Default value set by `Config.border_type`
    #
    # - `styler`: type is `BorderStyler` <br />
    #   Default value set by `Config.border_styler`
    #
    # Examples :
    # ```
    # border = Tablo::Border.new(Tablo::BorderName::Fancy,
    #   styler: ->(s : String) { s.colorize(:yellow).to_s })
    # ```
    # or
    # ```
    # border = Tablo::Border.new("┌┬┐├┼┤└┴┘│││────",
    #   styler: ->(s : String) { s.colorize.fore(:blue).mode(:bold).to_s })
    # ```
    def initialize(@border_type : String | BorderName = Config.border_type,
                   @styler : BorderStyler = Config.border_styler)
      case @border_type
      when Tablo::BorderName
        @border_string = PREDEFINED_BORDERS[@border_type]
      else
        @border_string = @border_type.as(String)
      end
      raise InvalidConnectorString.new "Invalid border definition <#{@border_string}>" \
                                       "(size != 16)" unless @border_string.size == 16

      ars = @border_string.split("").map { |e|
        case e
        when "E"
          ""
        when "S"
          " "
          # TODO double ("D") or triple ("T") mid vertical separator not ready yet !
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
    protected def horizontal_rule(column_widths, position = Position::Bottom, groups = nil)
      left, middle, right, segment, altmiddle = connectors(position)
      segments = column_widths.map { |width| segment * width }
      # Purpose of the line below ???  Use case not clear, but doesn't hurt though!
      left = right = middle = altmiddle = "" if segments.all?(&.empty?)
      str = if groups.nil?
              segments.join(vdiv_mid.empty? ? "" : middle)
            else
              middles = groups.flat_map { |e|
                Array.new(e.size - 1) { vdiv_mid.empty? ? "" : altmiddle } << middle
              }
              String.build do |s|
                (segments.size - 1).times do |i|
                  s << segments[i] << middles[i]
                end
                s << segments.last
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
      # BorderName::Fancy used as example
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
