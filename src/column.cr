require "./types"
require "./cell"

module Tablo
  # Attributes and methods of this class define the presentation of each column.
  # This class is instantiated internally by the method `Table#add_column`
  class Column(T)
    protected property width                   # called from Table, Summary
    protected getter initial_width : Int32 = 0 # called from Table
    protected getter index                     # called from Table
    protected getter extractor                 # called from Table, Summary
    protected getter header                    # called from Table
    protected getter left_padding              # called from Table, Summary
    protected getter right_padding             # called from Table, Summary
    protected getter padding_character         # called from Summary
    protected getter truncation_indicator      # called from Summary

    private getter header_alignment
    private getter header_formatter
    private getter header_styler
    private getter body_alignment
    private getter body_formatter
    private getter body_styler
    private getter wrap_mode

    # :nodoc:
    # Column Primary constructor
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

    # Creates a HeaderCell type cell
    # called from Table
    # Returns a DataCell
    protected def header_cell(bodycell)
      DataCell.new(
        value: header,
        cell_data: bodycell.cell_data,
        left_padding: left_padding,
        right_padding: right_padding,
        padding_character: padding_character,
        alignment: header_alignment,
        styler: header_styler,
        formatter: header_formatter,
        truncation_indicator: truncation_indicator,
        wrap_mode: wrap_mode,
        width: width,
      )
    end

    # Creates a BodyCell type cell
    # called from Table
    # Returns a DataCell
    protected def body_cell(source, row_index, column_index)
      value = body_cell_value(source, row_index)
      cell_data = CellData.new(value, row_index, index)
      DataCell.new(
        value: value,
        cell_data: cell_data,
        left_padding: left_padding,
        right_padding: right_padding,
        padding_character: padding_character,
        alignment: body_alignment,
        styler: body_styler,
        formatter: body_formatter,
        truncation_indicator: truncation_indicator,
        wrap_mode: wrap_mode,
        width: width,
      )
    end

    # Gets a cell value from source or returns the row index
    # As extractor is declared as (T, Int32) -> CellType, block may have at most
    # 2 parameters, but using only one is valid syntax
    # for source, use first block parameter = add_column(...) {|n| n} or {|n, i| n}
    # for row index, use second block parameter = add_column(...) {|n, i| i}
    # called from Table
    protected def body_cell_value(source, row_index)
      extractor.call(source, row_index)
    end

    # Returns total column width (content width + padding widths)
    # called from Table
    protected def padded_width
      width + total_padding
    end

    # Returns total column padding
    # called from Table
    protected def total_padding
      left_padding + right_padding
    end
  end
end
