require "./types"

module Tablo
  #
  # :nodoc:
  # This source code file does not contain any useful information for the
  # usage of the Tablo Library.
  #
  # :nodoc:
  # Cell is an abstract class representing a single cell inside a Table
  # Derived concrete cells are : TitleCell, GroupCell, HeaderCell and BodyCell
  abstract class Cell
    include CellType
    # Instance variables used for memoization, dynamically initialized later
    @formatted_value : String? = nil
    @rendered_subcells : Array(String)? = nil

    # :nodoc:
    # @return the underlying raw value (CellType) for this Cell
    getter value

    # property width

    # :nodoc:
    abstract def apply_formatter
    # :nodoc:
    abstract def apply_styler(content : String, line_index : Int32)
    # :nodoc:
    abstract def real_alignment

    # Abstract class for subcell formatting, depending on
    # parameter wrap_mode
    # :nodoc:
    abstract class SubCell
      include Enumerable(String)

      abstract def each(& : String ->)

      def initialize(@line : String, @width : Int32)
      end
    end

    # :nodoc:
    # class helper for rune (~character) string cut
    class RuneSubCell < SubCell
      def each(&)
        subcell_width = 0
        subcell = String::Builder.new
        @line.scan(/\X/).each do |matchdata|
          rune = matchdata[0]
          rune_width = rune.size
          {% if @top_level.has_constant?("UnicodeCharWidth") %}
            rune_width = UnicodeCharWidth.width(rune)
          {% end %}
          if subcell_width + rune_width > @width
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

    # :nodoc:
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
        @line.split(/(?<= |\-(?=\D+)|\—|\–⁠)\b/).each do |word|
          word_width = word.size
          {% if @top_level.has_constant?("UnicodeCharWidth") %}
            word_width = UnicodeCharWidth.width(word)
          {% end %}
          combined_width = subcell_width + word_width
          if combined_width - 1 == @width && word[-1] == " "
            # do nothing, as we're on the final word of the line and
            # the space at the end will be chopped off.
          elsif combined_width > @width
            s = subcell.to_s
            yield s unless s.strip.empty?
            subcell_width = 0
            subcell = String::Builder.new
          end
          if word_width >= @width
            RuneSubCell.new(word, @width).each do |rune_subcell|
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

    # :nodoc:
    # returns the number of subcells in a cell
    # ie, the number of lines a cell contains
    #
    # This method is the entry point for all cell computations
    # (formatting, aligning ans styling !)
    def line_count
      memoized_rendered_subcells.size
    end

    # :nodoc:
    # Saves the calculated array of subcells and returns it
    #
    # @subcells contains the final content of a cell, possibly multiline,
    # ready for output
    private def memoized_rendered_subcells
      @rendered_subcells ||= rendered_subcells
    end

    # :nodoc:
    # For a given Cell, calculate the formatted, aligned and styled subcells
    # it contains.
    # - First, the cell value is formatted
    # - then, the subcells are computed, depending on formatted value size
    # and column width
    # - last, each subcell is aligned and styled
    #
    # Returns the array(String) of subcells
    def rendered_subcells
      rendered_subcells = [] of String
      line_index = 0
      memoized_formatted_value.split(NEWLINE).flat_map do |line|
        if line =~ /^\s*$/
          # Allows for blank lines
          parsed_subcell = [line]
        else
          parsed_subcell = case @wrap_mode
                           in WrapMode::Rune
                             RuneSubCell.new(line, @width)
                           in WrapMode::Word
                             WordSubCell.new(line, @width)
                           end
        end
        parsed_subcell.each do |subcell|
          rendered_subcells << rendered_subcell(subcell, line_index)
          line_index += 1
        end
      end
      rendered_subcells
    end

    # :nodoc:
    # Returns the formatted value of the Cell, after applying the formatter
    # for this Column (but without applying any wrapping or the styler).
    def memoized_formatted_value
      @formatted_value ||= apply_formatter
    end

    # :nodoc:
    # returns an array of formatted and styled subcells, ready to print
    # adding a truncator characted at the end of the last line, replacing
    # the first character of right padding, if line count
    # is > than wrap_<header|body>_cells_to.
    # called from table : format_row or formatted_title
    # but title has no limit on row line_count (so, no wrap_cells_to) !
    def padded_truncated_subcells(line_count_max)
      truncated = (line_count > line_count_max)
      (0...line_count_max).map do |subcell_index|
        append_truncator = (truncated && !@right_padding.zero? &&
                            (subcell_index + 1 == line_count_max))
        if append_truncator
          rpad = apply_styler(@truncation_indicator, subcell_index) +
                 padding(@right_padding - 1)
        else
          rpad = padding(@right_padding)
        end
        inner = subcell_index < line_count ? memoized_rendered_subcells[
          subcell_index] : padding(@width)
        "#{padding(@left_padding)}#{inner}#{rpad}"
      end
    end

    # :nodoc:
    # Method to style and align formatted data **inside** cell data area,
    # **excluding** padding areas.
    private def rendered_subcell(subcell, line_index)
      if @wrap_mode == WrapMode::Word
        # preserve dot alignment format if number
        subcell = subcell.strip if @value.is_a?(String)
      end

      spacing = [@width - subcell.size, 0].max
      {% if @top_level.has_constant?("UnicodeCharWidth") %}
        spacing = [@width - UnicodeCharWidth.width(subcell), 0].max
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

    # :nodoc:
    # calc padding (or spacing)
    private def padding(amount)
      @padding_character * amount
    end
  end

  # :nodoc:
  class TextCell < Cell
    # :nodoc:
    property width
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

    # :nodoc:
    def zap_rendered_subcells
      @rendered_subcells = nil
    end

    # :nodoc:
    def apply_formatter
      # @formatter.call(@value)
      case formatter = @formatter
      in Proc(CellType, Int32, String)
        formatter.call(@value, @width)
      in Proc(CellType, String)
        formatter.call(@value)
      end
    end

    # :nodoc:
    def apply_styler(content, line_index)
      # debug!(Util.styler_allowed)
      return content unless Util.styler_allowed
      case styler = @styler
      in Proc(String, Int32, String)
        styler.call(content, line_index)
      in Proc(String, String)
        styler.call(content)
      end
    end

    # :nodoc:
    private def real_alignment
      alignment = @alignment
      alignment.nil? ? Justify::Center : alignment
    end
  end

  # :nodoc:
  class DataCell < Cell
    getter cell_data
    # :nodoc:
    @column_index : Int32? = nil

    # :nodoc:
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

    # :nodoc:
    def apply_formatter
      case formatter = @formatter
      in Proc(CellType, CellData, String)
        formatter.call(@value, @cell_data)
      in Proc(CellType, Int32, String)
        formatter.call(@value, @width)
      in Proc(CellType, String)
        formatter.call(@value)
      end
    end

    # :nodoc:
    def apply_styler(content, line_index)
      # debug!(Util.styler_allowed)
      return content unless Util.styler_allowed
      case styler = @styler
      in Proc(CellType, String, CellData, Int32, String)
        styler.call(@value, content, @cell_data, line_index)
      in Proc(CellType, String, CellData, String)
        styler.call(@value, content, @cell_data)
      in Proc(CellType, String, String)
        styler.call(@value, content)
      end
    end

    # :nodoc:
    private def real_alignment
      alignment = @alignment
      return alignment unless alignment.nil?
      case @cell_data.value
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
