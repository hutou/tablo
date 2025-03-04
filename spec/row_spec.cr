require "./spec_helper"

describe Tablo::Row do
  describe "#each" do
    it "loops over defined columns for a given row" do
      table = Tablo::Table.new(["a", "b"]) do |t|
        t.add_column("Char", &.itself)
        t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
          value.as(String).upcase
        }, &.itself.*(5))
        t.add_column("Bool", body_formatter: ->(value : Tablo::CellType) {
          value.as(Bool).to_s.capitalize
        }, &.itself.==("b"))
      end
      output = ""
      table.each do |row|
        row.each do |cell|
          output += cell.value.to_s + "  " + cell.content + "  " +
                    cell.coords.row_index.to_s + "  " + cell.coords.column_index.to_s + "    "
        end
        output += "\n"
      end
      expected_output = "a  a  0  0    aaaaa  AAAAA  0  1    false  False  0  2    \n" +
                        "b  b  1  0    bbbbb  BBBBB  1  1    true  True  1  2    \n"
      output.should eq(expected_output)
    end
  end
  describe "#to_s" do
    it "displays (numbered) rows with their associated headings" do
      table = Tablo::Table.new(["a", "b", "c"],
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true)) do |t|
        t.add_column("Char", &.itself)
        t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
          value.as(String).upcase
        }, &.itself.*(5))
      end
      output = ""
      table.each_with_index do |row, i|
        row.to_s.each_line do |line|
          output += "row #{i} -> #{line}\n"
        end
      end
      expected_output = <<-OUTPUT
        row 0 -> +-----------------------------+
        row 0 -> |            Title            |
        row 0 -> +-----------------------------+
        row 0 -> |           SubTitle          |
        row 0 -> +--------------+--------------+
        row 0 -> | Char         | String       |
        row 0 -> +--------------+--------------+
        row 0 -> | a            | AAAAA        |
        row 1 -> | b            | BBBBB        |
        row 2 -> | c            | CCCCC        |
        row 2 -> +--------------+--------------+
        row 2 -> |            Footer           |
        row 2 -> +-----------------------------+
        OUTPUT
      output.chomp.should eq(expected_output)
    end
  end

  describe "#to_h" do
    it "returns a hash of data cells from a given row" do
      table = Tablo::Table.new(["a"]) do |t|
        t.add_column("Char", &.itself)
        t.add_column("String", body_formatter: ->(value : Tablo::CellType) {
          value.as(String).upcase
        }, &.itself.*(5))
      end
      output = ""
      table.each do |row|
        h = row.to_h
        output += "#{typeof(h)}\n"
        output += h["Char"].value.to_s + "  " + h["Char"].content + "  " +
                  h["Char"].coords.row_index.to_s + "  " +
                  h["Char"].coords.column_index.to_s + "\n"
        output += h["String"].value.to_s + "  " + h["String"].content + "  " +
                  h["String"].coords.row_index.to_s + "  " +
                  h["String"].coords.column_index.to_s
      end
      expected_output = "Hash(Int32 | String | Symbol, Tablo::Cell::Data)\n" +
                        "a  a  0  0\n" +
                        "aaaaa  AAAAA  0  1"
      output.should eq(expected_output)
    end
  end
end
