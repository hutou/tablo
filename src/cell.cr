require "./types"

module Tablo
  # -------------- class SubCell --------------------------------------------------
  #
  #

  # Abstract class for subcell formatting, depending on wrap_mode
  abstract class SubCell
    include Enumerable(String)

    getter line, width

    abstract def each(& : String ->)

    def initialize(@line : String, @width : Int32)
    end
  end

  # class helper for rune (~character) string cut
  class RuneSubCell < SubCell
    def each(&)
      subcell_width = 0
      subcell = String::Builder.new
      line.scan(/\X/).each do |matchdata|
        rune = matchdata[0]
        rune_width = rune.size
        {% if @top_level.has_constant?("UnicodeCharWidth") %}
          rune_width = UnicodeCharWidth.width(rune)
        {% end %}
        if subcell_width + rune_width > width
          s = subcell.to_s
          yield s unless s.strip.empty?
          subcell_width = 0
          subcell = String::Builder.new
        end

        subcell << rune
        subcell_width += rune_width
      end
      s = subcell.to_s
      yield s unless s.strip.empty?
    end
  end

  # class helper for word string cut
  class WordSubCell < SubCell
    def each(&)
      subcell_width = 0
      subcell = String::Builder.new
      # split line on :
      # - space or
      # - dash (minus sign), when not followed by digits or
      # - EM dash or
      # - EN dash followed by &NoBreak
      line.split(/(?<= |\-(?=\D+)|\—|\–⁠)\b/).each do |word|
        word_width = word.size
        {% if @top_level.has_constant?("UnicodeCharWidth") %}
          word_width = UnicodeCharWidth.width(word)
        {% end %}
        combined_width = subcell_width + word_width
        if combined_width - 1 == width && word[-1] == " "
          # do nothing, as we're on the final word of the line and
          # the space at the end will be chopped off.
        elsif combined_width > width
          s = subcell.to_s
          yield s unless s.strip.empty?
          subcell_width = 0
          subcell = String::Builder.new
        end
        if word_width >= width
          RuneSubCell.new(word, width).each do |rune_subcell|
            yield rune_subcell
          end
        else
          subcell << word
          subcell_width += word_width
        end
      end
      s = subcell.to_s
      yield s unless s.strip.empty?
    end
  end

  # -------------- class Cell -----------------------------------------------------
  #
  #

  # Cell is an abstract class representing a single cell inside a Table.
  # Derived concrete cells are : TextCell and DataCell
  abstract class Cell
    include CellType
    # Common attributes of TextCell and DataCell
    getter value, left_padding, right_padding, padding_character
    getter alignment, truncation_indicator, wrap_mode
    getter formatter, styler
    property width
    # Instance variables used for memoization, dynamically initialized later
    property formatted_value : String? = nil
    property rendered_subcells : Array(String)? = nil

    abstract def apply_formatter
    abstract def apply_styler(content : String, line_index : Int32)
    abstract def real_alignment

    # returns the number of subcells in a cell
    # ie, the number of lines a cell contains
    #
    # This method is the entry point for all cell computations
    # (formatting, aligning and styling !)
    def line_count
      memoized_rendered_subcells.size
    end

    # Saves the calculated array of subcells and returns it
    #
    # subcells contains the final content of a cell, possibly multiline,
    # ready for output
    private def memoized_rendered_subcells
      if rendered_subcells.nil?
        self.rendered_subcells = render_subcells
      else
        rendered_subcells.as(Array(String))
      end
    end

    # For a given Cell, calculate the formatted, aligned and styled subcells
    # it contains.
    # - First, the cell value is formatted
    # - then, the subcells are computed, depending on formatted value size
    # and column width
    # - last, each subcell is aligned and styled
    #
    # Returns the array(String) of subcells
    private def render_subcells
      subcells = [] of String
      line_index = 0
      memoized_formatted_value.split(NEWLINE).flat_map do |line|
        if line =~ /^\s*$/
          # Allows for blank lines, but use an EMPTY one
          parsed_subcell = [""]
        else
          parsed_subcell = case wrap_mode
                           in WrapMode::Rune
                             RuneSubCell.new(line, width)
                           in WrapMode::Word
                             WordSubCell.new(line, width)
                           end
        end
        parsed_subcell.each do |subcell|
          subcells << render_subcell(subcell, line_index)
          line_index += 1
        end
      end
      subcells
    end

    # Returns the formatted value of the Cell, after applying the formatter
    # for this Column (but without applying any wrapping or the styler).
    def memoized_formatted_value
      if formatted_value.nil?
        self.formatted_value = apply_formatter
      else
        formatted_value.as(String)
      end
    end

    # returns an array of formatted and styled subcells, ready to print,
    # adding a truncator characted at the end of the last line, replacing
    # the first character of right padding, if line count
    # is > than iheader_wrap or body_wrap.
    #
    # called from table.format_row
    def padded_truncated_subcells(line_count_max)
      truncated = (line_count > line_count_max)
      (0...line_count_max).map do |subcell_index|
        append_truncator = (truncated && !right_padding.zero? &&
                            (subcell_index + 1 == line_count_max))
        if append_truncator
          rpad = apply_styler(truncation_indicator, subcell_index) +
                 padding(right_padding - 1)
        else
          rpad = padding(right_padding)
        end
        inner = subcell_index < line_count ? memoized_rendered_subcells[
          subcell_index] : padding(width)
        "#{padding(left_padding)}#{inner}#{rpad}"
      end
    end

    # Method to style and align formatted data **inside** cell data area,
    # **excluding** padding areas.
    private def render_subcell(subcell, line_index)
      if wrap_mode == WrapMode::Word
        # preserve dot alignment format if number
        subcell = subcell.strip if value.is_a?(String)
      end

      spacing = [width - subcell.size, 0].max
      {% if @top_level.has_constant?("UnicodeCharWidth") %}
        spacing = [width - UnicodeCharWidth.width(subcell), 0].max
      {% end %}
      left_spacing, right_spacing = case real_alignment
                                    in Justify::Center
                                      half_spacing = spacing // 2
                                      [spacing - half_spacing, half_spacing]
                                    in Justify::Left
                                      [0, spacing]
                                    in Justify::Right
                                      [spacing, 0]
                                    end
      String.build do |str|
        str << padding(left_spacing)
        str << apply_styler(subcell, line_index)
        str << padding(right_spacing)
      end
    end

    private def padding(amount)
      padding_character * amount
    end
  end

  # -------------- class TextCell -------------------------------------------------
  #
  #

  # Subclass of Cell for TextCell (Headings, group)
  class TextCell < Cell
    getter row_type

    def initialize(@value : CellType,
                   @row_type : RowType,

                   @left_padding : Int32,
                   @right_padding : Int32,
                   @padding_character : String,

                   @alignment : Justify,
                   @styler : TextCellStyler,

                   @formatter : TextCellFormatter,
                   @truncation_indicator : String,
                   @wrap_mode : WrapMode,
                   @width : Int32)
    end

    # needed for group width recalculation
    def reset_rendered_subcells
      self.rendered_subcells = nil
    end

    private def apply_formatter
      case f = formatter
      in Proc(CellType, Int32, String)
        f.call(value, width)
      in Proc(CellType, String)
        f.call(value)
      end
    end

    private def apply_styler(content, line_index)
      return content unless Util.styler_allowed
      case s = styler
      in Proc(String, Int32, String)
        s.call(content, line_index)
      in Proc(String, String)
        s.call(content)
      end
    end

    private def real_alignment
      a = alignment
      a.nil? ? Justify::Center : a
    end
  end

  # -------------- class DataCell -------------------------------------------------
  #
  #

  # Subclass of Cell for DataCell (Header, Body)
  class DataCell < Cell
    getter cell_data

    def initialize(@value : CellType,
                   @cell_data : CellData,

                   @left_padding : Int32,
                   @right_padding : Int32,
                   @padding_character : String,

                   @alignment : Justify?,
                   @styler : DataCellStyler,

                   @formatter : DataCellFormatter,
                   @truncation_indicator : String,
                   @wrap_mode : WrapMode,
                   @width : Int32)
    end

    private def apply_formatter
      case f = formatter
      in Proc(CellType, CellData, Int32, String)
        f.call(value, cell_data, width)
      in Proc(CellType, CellData, String)
        f.call(value, cell_data)
      in Proc(CellType, Int32, String)
        f.call(value, width)
      in Proc(CellType, String)
        f.call(value)
      end
    end

    private def apply_styler(content, line_index)
      return content unless Util.styler_allowed
      case s = styler
      in Proc(CellType, CellData, String, Int32, String)
        s.call(value, cell_data, content, line_index)
      in Proc(CellType, CellData, String, String)
        s.call(value, cell_data, content)
      in Proc(CellType, String, String)
        s.call(value, content)
      in Proc(String, String)
        s.call(content)
      end
    end

    private def real_alignment
      a = alignment
      return a unless a.nil?
      case cell_data.body_value
      when Number
        Justify::Right
      when Bool
        Justify::Center
      else
        Justify::Left
      end
    end
  end
end
