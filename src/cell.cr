require "./types"

module Tablo
  # Cell is an abstract class representing a single cell inside a Table.<br />
  # Derived concrete cells are : `TextCell` and `DataCell`
  abstract class Cell
    # Common attributes of TextCell and DataCell
    private getter value
    #
    private getter left_padding, right_padding, padding_character
    private getter alignment, truncation_indicator, wrap_mode
    private getter formatter, styler
    protected property width
    # Instance variables used for memoization, dynamically initialized later
    private property memoized_formatted_content : String? = nil
    private property memoized_rendered_subcells : Array(String)? = nil

    private abstract def apply_formatter
    private abstract def apply_styler(content : String, line_index : Int32)
    private abstract def real_alignment

    # Abstract class for subcell formatting, depending on wrap_mode
    #  Non-Roman characters are also supported if the *naqvis/uni_char_width*
    #  library is loaded.
    private abstract class SubCell
      private getter line, width

      private abstract def each(& : String ->)

      def initialize(@line : String, @width : Int32)
      end
    end

    # class helper for rune (~character) string cut
    private class RuneSubCell < SubCell
      protected def each(&)
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
    private class WordSubCell < SubCell
      protected def each(&)
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

    # returns the number of subcells in a cell
    # ie, the number of lines a cell contains
    #
    # This method is the entry point for all cell computations
    # (formatting, aligning and styling !)
    protected def line_count
      rendered_subcells.size
    end

    # Saves the calculated array of subcells and returns it
    #
    # subcells contains the final content of a cell, possibly multiline,
    # ready for output
    protected def rendered_subcells
      self.memoized_rendered_subcells ||= render_subcells
    end

    # For a given Cell, calculate the formatted, aligned and styled subcells
    # it contains.
    #
    # - First, the cell value is formatted
    # - then, the subcells are computed, depending on formatted value size
    # and column width
    # - last, each subcell is aligned and styled
    #
    # Returns the array(String) of subcells
    private def render_subcells
      subcells = [] of String
      line_index = 0
      formatted_content.split(NEWLINE).flat_map do |line|
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
    protected def formatted_content
      self.memoized_formatted_content ||= apply_formatter
    end

    # returns an array of formatted and styled subcells, ready to print,
    # adding a truncator characted at the end of the last line, replacing
    # the first character of right padding, if line count
    # is > than iheader_wrap or body_wrap.
    #
    # called from table.format_row
    protected def padded_truncated_subcells(line_count_max)
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
        inner = subcell_index < line_count ? rendered_subcells[
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

    # Returns the total width of padding
    private def padding(amount)
      padding_character * amount
    end
  end

  # Formatter procs for text cell types (Title, SubTitle, Footer and Group).
  #
  # There are 2 of them, as shown below by their commonly used parameter names
  # and types: <br />
  # - 1st form : (value : `CellType`, column_width : `Int32`)
  # - 2nd form : (value : `CellType`)
  #
  # Return type is String for all of them.
  #
  # Any processing can be done on cell value. For example, if the runtime cell
  # value type is Time, we could format as :
  # ```
  # formatter: ->(value : Tablo::CellType) { "Date: " + value.as(Time).to_s("%Y-%m-%d") }
  # ```
  # Another example, to stretch contents of a cell to its maximum width:
  # ```
  # formatter: ->(value : Tablo::CellType, column_width : Int32) {
  #               Tablo::Util.stretch(value.as(String), width: column_width) }
  # ```
  alias TextCellFormatter = Proc(CellType, Int32, String) |
                            Proc(CellType, String)

  # Styler procs for text cell types.
  #
  # There are 2 of them, as shown below by their commonly used parameter names
  # and types: <br />
  # - 1st form : (content : `String`, line : `Int32`)
  # - 2nd form : (content : `String`)
  #
  # `content` is the formatted cell value, after the formatter has been applied.<br />
  # `line` designates the line number in a (multi-line) cell (0..n).
  #
  # Return type is String for all of them.
  #
  # The first form allows easy conditional styling. For example, to colorize
  # differently each line of the cell:
  # ```
  # styler: ->(content : String, line : Int32) {
  #   case line
  #   when 0 then content.colorize(:blue).to_s
  #   when 1 then content.colorize(:green).to_s
  #   else        content.colorize(:red).to_s
  #   end
  # }
  # ```
  #  or, more simply, to style the whole cell, we use the 2nd form:
  # ```
  # styler: ->(content : String) { content.colorize.fore(:bold).to_s }
  # ```
  alias TextCellStyler = Proc(String, Int32, String) |
                         Proc(String, String)

  # :nodoc: kept public for spec tests
  # Subclass of Cell for TextCell (Headings, group)
  class TextCell < Cell
    # called from Table
    protected getter row_type
    def_clone

    # :nodoc:
    def initialize(@value : CellType,
                   @row_type : RowType,
                   @left_padding : Int32,
                   @right_padding : Int32,
                   @padding_character : String,
                   @alignment : Justify?,
                   @styler : TextCellStyler,
                   @formatter : TextCellFormatter,
                   @truncation_indicator : String,
                   @wrap_mode : WrapMode,
                   @width : Int32)
    end

    # needed for group width recalculation
    protected def reset_memoized_rendered_subcells
      self.memoized_rendered_subcells = nil
    end

    # Format the cell value (type CellType)
    private def apply_formatter
      case f = formatter
      in Proc(CellType, Int32, String)
        f.call(value, width)
      in Proc(CellType, String)
        f.call(value)
      end
    end

    # Style formatted content of cell (type String)
    private def apply_styler(content, line_index)
      return content unless Util.styler_allowed
      case s = styler
      in Proc(String, Int32, String)
        s.call(content, line_index)
      in Proc(String, String)
        s.call(content)
      end
    end

    # Align cell contents
    private def real_alignment
      a = alignment
      a.nil? ? Justify::Center : a
    end
  end

  # This data structure is attached to DataCell cells and therefore only
  # concerns Header and Body row types: it is used in particular for
  # conditional formatting and styling.
  struct CellData
    # Returns the raw value of the Body Cell (useful when dealing with a
    # Header cell)
    getter body_value

    # Returns the index of the row (0..n)
    getter row_index

    # Returns the index of the column (0..n)
    getter column_index

    # Constructor with 3 mandatory parameters.
    def initialize(@body_value : CellType, @row_index : Int32, @column_index : Int32)
    end
  end

  # Formatter Proc for data cell types (Header and Body).
  #
  # There are 4 of them, as shown below by their commonly used parameter names
  # and types: <br />
  # - 1st form : (value : `CellType`, cell_data : `CellData`, column_width : `Int32`)
  # - 2nd form : (value : `CellType`, cell_data : `CellData`)
  # - 3rd form : (value : `CellType`, column_width : `Int32`)
  # - 4th form : (value : `CellType`)
  #
  # Return type is String for all of them.
  #
  # These different forms can be used for conditional formatting.
  #
  # For example, to alternate case after each row, the 2nd form
  # can be used :
  # ```
  # body_formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
  #  if value.is_a?(String)
  #    cell_data.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase
  #  else
  #    value.to_s
  #  end
  # }
  # ```
  # This will have an impact on all text columns. To limit formatting to the
  # second column, for example, you could write:
  # ```
  # body_formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
  #  if value.is_a?(String) && cell_data.column_index == 1
  #    cell_data.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase
  #  else
  #    value.to_s
  #  end
  # }
  # ```
  alias DataCellFormatter = Proc(CellType, CellData, Int32, String) |
                            Proc(CellType, CellData, String) |
                            Proc(CellType, Int32, String) |
                            Proc(CellType, String)

  # Styler procs for data cell types.
  #
  # There are 5 of them, as shown below by their commonly used parameter names
  # and types: <br />
  # - 1st form : (value : `CellType`, cell_data : `CellData`, content : `String`, line_index : `Int32`)
  # - 2nd form : (value : `CellType`, cell_data : `CellData`, content : `String`)
  # - 3rd form : (value : `CellType`, content : `String`)
  # - 4th form : (content : `String`, line_index : `Int32`)
  # - 5th form : (content : `String`)
  #
  # *content* is the formatted value of the cell (after formatter is applied) <br />
  # Return type is String for all of them.
  #
  # These different forms can be used for conditional formatting.
  #
  # In a somewhat contrived example, we could write:
  # ```
  #   body_styler: ->(_value : Tablo::CellType, cell_data : Tablo::CellData, content : String, line_index : Int32) {
  # if line_index > 0
  #   content.colorize(:magenta).mode(:bold).to_s
  # else
  #   if cell_data.row_index % 2 == 0
  #     cell_data.column_index == 0 ? content.colorize(:red).to_s : content.colorize(:yellow).to_s
  #   else
  #     content.colorize(:blue).to_s
  #   end
  # end
  # }
  # ```
  # Or, more simply, to better differentiate between negative and positive values:
  # ```
  # body_styler: ->(value : Tablo::CellType, content : String) {
  #   if value.is_a?(Float64)
  #     if value.as(Float64) < 0.0
  #       content.colorize(:red).to_s
  #     else
  #       content.colorize(:green).to_s
  #     end
  #   else
  #     content
  #   end
  # }
  # ```
  alias DataCellStyler = Proc(CellType, CellData, String, Int32, String) |
                         Proc(CellType, CellData, String, String) |
                         Proc(CellType, String, String) |
                         Proc(String, Int32, String) |
                         Proc(String, String)

  # :nodoc: kept public for spec tests
  # Subclass of Cell for DataCell (Header, Body)
  class DataCell < Cell
    # called from Column
    protected getter cell_data

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

    # Format the cell value (type CellType)
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

    # Style formatted content of cell (type String)
    private def apply_styler(content, line_index)
      return content unless Util.styler_allowed
      case s = styler
      in Proc(CellType, CellData, String, Int32, String)
        s.call(value, cell_data, content, line_index)
      in Proc(CellType, CellData, String, String)
        s.call(value, cell_data, content)
      in Proc(CellType, String, String)
        s.call(value, content)
      in Proc(String, Int32, String)
        s.call(content, line_index)
      in Proc(String, String)
        s.call(content)
      end
    end

    # Align cell contents
    # (Based on runtime body cell value for header and body)
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
