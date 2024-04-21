require "./types"

module Tablo
  # :nodoc:
  # Data source and column definitions meet here
  class Row(T)
    include Enumerable(CellType)
    # :nodoc:
    getter source

    # :nodoc:
    # Creates a new instance of a `Row` (index in table sources, starts at zero)
    def initialize(@table : Table(T), @source : T, @divider : Bool?, @index : Int32)
    end

    # :nodoc:
    # Calls the given block once for each cell(column) in the `Row`, passing
    # that cell value as parameter.  Each "cell" is just the calculated value
    # for its column (pre-formatting) for this `Row`'s source item.
    #
    # # TODO This method seems unused (except in spec), so What for ???
    #
    def each
      @table.column_registry.each_with_index do |(_, column), column_index|
        yield column.body_cell(source: @source, row_index: @index, column_index: column_index)
      end
    end

    # :nodoc:
    # Returns a string being an "ASCII" graphical representation of the `Row`,
    # including any column (Title/Group/)headers that appear just above it in the `Table`
    # (depending on where this `Row` is in the `Table` and how the `Table` was
    # configured with respect to header frequency).
    # def to_s(io)
    #   if @table.column_registry.any?
    #     io << @table.formatted_body_row(@source, @divider, @index)
    #   else
    #     io << ""
    #   end
    # end
    # def to_s(io : IO)
    #   if !@table.column_registry.empty?
    #     io << @table.all_rendered_rows(@source, @divider, @index)
    #   else
    #     io << ""
    #   end
    # end

    def to_s(io : IO)
      if !@table.column_registry.empty?
        # transitions = @table.transitions(@index)
        # rows = RowGroup.new(@table, @source, @divider, @index, **transitions).run
        rows = RowGroup.new(@table, @source, @divider, @index).run
        # rows = RowGroup.new(@table, @source, @divider, @index).run
        # io << @table.join_lines(rows.reject &.empty?)
        # io << (rows.reject &.empty?).join(NEWLINE)
        # io << (rows.reject &.empty?).map { |e| e == " " ? "" : e }.join(NEWLINE)
        io << rows.join(NEWLINE)
        # io << @table.all_rendered_rows(@source, @divider, @index)
      else
        io << ""
      end
    end

    # :nodoc:
    # Returns a Hash representation of the `Row`, with column labels acting
    # as keys and the calculated cell values (before formatting) providing the values.
    def to_h
      @table.column_registry.map_with_index do |(label, column), column_index|
        [label, column.body_cell(@source, row_index: @index, column_index: column_index).value]
      end.to_h
    end
  end
end
