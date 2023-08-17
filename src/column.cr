require "./types"
require "./cell"

module Tablo
  # :nodoc:
  # Attributes and methods of this class define the presentation of each column.
  # This class is instantiated by the method `Table#add_column`
  class Column(T)
    # :nodoc:
    property width
    @initial_width : Int32 = 0

    # :nodoc:
    getter header, index

    # :nodoc:
    protected getter left_padding, right_padding, padding_character, truncation_indicator
    protected getter header_alignment, body_alignment
    protected getter body_formatter, header_formatter
    protected getter body_styler, header_styler
    protected getter header
    protected getter initial_width

    # -------------- special getters / setters --------------------------------------
    #
    #

    # # # :nodoc:
    # def width
    #   @width.to_i
    # end

    # ---------- def initialize -----------------------------------------------------
    #
    #

    # :nodoc:
    # Primary constructor
    #
    # See parameter's definitions at call site : `Table#add_column`
    # where their use if fully explained
    def initialize(@header : String,
                   #
                   @header_alignment : Justify?,
                   @header_formatter : DataCellFormatter,
                   @header_styler : DataCellStyler,
                   #
                   @body_alignment : Justify?,
                   @body_formatter : DataCellFormatter,
                   @body_styler : DataCellStyler,
                   #
                   @left_padding : Int32,
                   @right_padding : Int32,
                   @padding_character : String,
                   #
                   @width : Int32,
                   @truncation_indicator : String,
                   @wrap_mode : WrapMode,
                   @extractor : (T, Int32) -> CellType,
                   @index : Int32)
      @initial_width = @width
    end

    # ---------- def header_cell ----------------------------------------------------
    #
    #

    # :nodoc:
    # Creates a HeaderCell type cell
    def header_cell(bodycell)
      DataCell.new(
        value: @header,
        cell_data: bodycell.cell_data,
        left_padding: @left_padding,
        right_padding: @right_padding,
        padding_character: @padding_character,
        alignment: @header_alignment,
        styler: @header_styler,
        formatter: @header_formatter,
        truncation_indicator: @truncation_indicator,
        wrap_mode: @wrap_mode,
        width: width,
      )
    end

    # :nodoc:
    # Creates a BodyCell type cell
    def body_cell(source, row_index, column_index)
      value = body_cell_value(source, row_index)
      cell_data = CellData.new(value, row_index, @index)
      DataCell.new(
        value: value,
        cell_data: cell_data,
        left_padding: @left_padding,
        right_padding: @right_padding,
        padding_character: @padding_character,
        alignment: @body_alignment,
        styler: @body_styler,
        formatter: @body_formatter,
        truncation_indicator: @truncation_indicator,
        wrap_mode: @wrap_mode,
        width: width,
      )
    end

    # :nodoc:
    # Gets a cell value from source or returns the row index
    # As extractor is declared as (T, Int32) -> CellType, block may have at most
    # 2 parameters, but using only one is valid syntax
    # for source, use first block parameter = add_column(...) {|n| n} or {|n, i| n}
    # for row index, use second block parameter = add_column(...) {|n, i| i}
    def body_cell_value(source, row_index)
      @extractor.call(source, row_index)
    end

    # :nodoc:
    def padded_width
      width + total_padding
    end

    # :nodoc:
    def total_padding
      @left_padding + @right_padding
    end
  end
end
