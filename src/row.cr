require "./commons.cr"

module Tablo
  class Row
    include Enumerable(CellType)

    # Creates a new instance of a `Row`
    def initialize(@table : Table, @source : Array(CellType), @idx : Int32,
                   @with_header : Bool = true)
    end

    # Calls the given block once for each cell(column) in the `Row`, passing
    # that cell value as parameter.  Each "cell" is just the calculated value
    # for its column (pre-formatting) for this `Row`'s source item.
    def each
      @table.column_registry.each do |_, column|
        yield column.body_cell_value(@source)
      end
    end

    # Returns a string being an "ASCII" graphical representation of the `Row`,
    # including any column headers that appear just above it in the `Table`
    # (depending on where this `Row` is in the `Table` and how the `Table` was
    # configured with respect to header frequency).
    def to_s(io)
      if @table.column_registry.any?
        io << @table.formatted_body_row(@source, @idx, @with_header)
      else
        io << ""
      end
    end

    # Returns a Hash representation of the `Row`, with column labels acting
    # as keys and the calculated cell values (before formatting) providing the values.
    def to_h
      @table.column_registry.map { |label, column|
        [label, column.body_cell_value(@source)]
      }.to_h
    end
  end
end
