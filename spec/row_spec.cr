require "./spec_helper"

describe Tablo::Row do
  # define border type for all tests
  # Tablo::Config.border_type = Tablo::BorderName::Ascii

  table = Tablo::Table.new([["A", "B"], ["C", "D"], ["E", "F"], ["G", "H"], ["I", "J"]],
    border: Tablo::Border.new(Tablo::BorderName::Ascii),
    header_frequency: 0) do |t|
    t.add_column("N") { |n| n[0] }
    t.add_column("Double") { |n| n[0] * 2 }
    t.add_column("Triple") { |n| n[0] * 3 }
  end
  idx = 3
  row = Tablo::Row.new(table, table.sources[idx], false, idx)
  idx = 0
  row_with_header = Tablo::Row.new(table, table.sources[idx], false, idx)

  empty_table = Tablo::Table.new([[0], [1]]) # no defined column
  empty_row = empty_table.first

  describe "Row type validation" do
    it "is an Enumerable" do
      row.is_a?(Enumerable).should be_true
      row.responds_to?(:each).should be_true
      row.responds_to?(:map).should be_true
      row.responds_to?(:to_a).should be_true
    end
  end
  describe "#initialize" do
    it "creates a Tablo::Row" do
      row.should be_a(Tablo::Row(typeof(row.source)))
    end
  end
  describe "#each" do
    it "iterates once for each column in the table" do
      i = 0
      row.each do |_cell|
        i += 1
      end
      i.should eq(3) # 3 columns defined
    end
  end
  it "iterates over the results of calling the column's extractor on the source object" do
    row.each_with_index do |cell, i|
      cell.should be_a(Tablo::DataCell)
      case i
      when 0
        cell.value.should eq("G")
      when 2
        cell.value.should eq("GGG")
      end
    end
  end

  describe "#to_s" do
    context "when row has header attached" do
      it "returns a string showing the column headers and the row contents" do
        row_with_header.to_s.should eq \
          %q(+--------------+--------------+--------------+
             | N            | Double       | Triple       |
             +--------------+--------------+--------------+
             | A            | AA           | AAA          |).gsub(/^ +/m, "")
      end
    end
    context "when row has *no* header attached" do
      it "returns a string showing the row contents without the column headers" do
        # This test needs to be done after the previous one, when row_index == 0,
        # as the rowgroup algorithm expects starting at row index 0
        output = "| G            | GG           | GGG          |"
        row.to_s.should eq output
      end
    end
    context "when the table does not have any columns" do
      it "returns an empty string" do
        empty_row.to_s.should eq("")
      end
    end
  end
  describe "#to_h" do
    it "returns a Hash mapping from column labels to cell values" do
      row.to_h.should eq({"N" => "G", "Double" => "GG", "Triple" => "GGG"})
    end
  end
end
