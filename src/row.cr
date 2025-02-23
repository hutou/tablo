module Tablo
  # Data source and column definitions meet here
  class Row(T)
    include Enumerable(Tablo::Cell::Data)
    # :nodoc:
    getter source

    # :nodoc:
    # Creates a new instance of a row
    def initialize(@table : Table(T), @source : T, @divider : Bool?, @index : Int32)
    end

    # Calls the given block once for each column in the row and returns
    # the corresponding cell as parameter, giving access to its raw value,
    # formatted_content and coords attributes
    #
    # ```
    # require "tablo"
    # table = Tablo::Table.new(["a", "b", "c"]) do |t|
    #   t.add_column("Char", &.itself)
    #   t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
    #     value.as(String).upcase
    #   }, &.itself.*(5))
    # end
    # table.each do |row|
    #   row.each do |cell|
    #     print cell.value.to_s, "  ", cell.formatted_content, "  ",
    #       cell.coords.row_index, "  ", cell.coords.column_index, "    "
    #   end
    #   puts
    # end
    # ```
    #
    # ```
    # a  a  0  0    aaaaa  AAAAA  0  1
    # b  b  1  0    bbbbb  BBBBB  1  1
    # c  c  2  0    ccccc  CCCCC  2  1
    # ```
    def each(&)
      @table.column_registry.each_with_index do |(_, column), column_index|
        yield column.body_cell(source: @source, row_index: @index, column_index: column_index)
      end
    end

    # Returns a character string in the form of an “Ascii” graphic representation
    # of the row, including the column headers (with title, subtitle and group
    # where appropriate) that appear just above and the footer for the last row.
    #
    # ```
    # require "tablo"
    # table = Tablo::Table.new(["a", "b", "c"],
    #   title: Tablo::Heading.new("Title", framed: true),
    #   subtitle: Tablo::Heading.new("SubTitle", framed: true),
    #   footer: Tablo::Heading.new("Footer", framed: true)) do |t|
    #   t.add_column("Char", &.itself)
    #   t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
    #     value.as(String).upcase
    #   }, &.itself.*(5))
    # end
    # table.each_with_index do |row, i|
    #   row.to_s.each_line do |line|
    #     puts "row #{i} -> #{line}"
    #   end
    # end
    # ```
    #
    # ```
    # row 0 -> +-----------------------------+
    # row 0 -> |            Title            |
    # row 0 -> +-----------------------------+
    # row 0 -> |           SubTitle          |
    # row 0 -> +--------------+--------------+
    # row 0 -> | Char         | String       |
    # row 0 -> +--------------+--------------+
    # row 0 -> | a            | AAAAA        |
    # row 1 -> | b            | BBBBB        |
    # row 2 -> | c            | CCCCC        |
    # row 2 -> +--------------+--------------+
    # row 2 -> |            Footer           |
    # row 2 -> +-----------------------------+
    # ```
    def to_s(io : IO)
      if !@table.column_registry.empty?
        rows = RowGroup.new(@table, @source, @divider, @index).run
        io << rows.join(NEWLINE)
      else
        io << ""
      end
    end

    # Returns a Hash representation of the row, with column label acting
    # as key and the associated cell as value.
    # ```
    # require "tablo"
    # table = Tablo::Table.new(["a"]) do |t|
    #   t.add_column("Char", &.itself)
    #   t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
    #     value.as(String).upcase
    #   }, &.itself.*(5))
    # end
    # table.each do |row|
    #   h = row.to_h
    #   puts typeof(h)
    #   print h["String"].value, "  ", h["String"].formatted_content, "  ",
    #     h["String"].coords.row_index, "  ", h["String"].coords.column_index, "\n"
    # end
    # ```
    #
    # ```
    # Hash(Int32 | String | Symbol, Tablo::Cell::Data)
    # aaaaa  AAAAA  0  1
    # ```
    def to_h
      hash = {} of LabelType => Cell::Data
      @table.column_registry.map_with_index do |(label, column), column_index|
        hash[label.as(LabelType)] = column.body_cell(@source, row_index: @index,
          column_index: column_index).as(Cell::Data)
      end
      hash
    end
  end
end
