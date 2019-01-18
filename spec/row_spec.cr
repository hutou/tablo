require "./spec_helper"

describe Tablo::Row do
  table = Tablo::Table.new((1..5).map { |x| [x] }) do |t|
    t.add_column("N") { |n| n[0] }
    t.add_column("Double") { |n| n[0].as(Int32) * 2 }
    t.add_column("Triple") { |n| n[0].as(Int32) * 3 }
  end
  idx = 3
  row = Tablo::Row.new(table, table.sources[idx], idx, with_header: false)
  row_with_header = Tablo::Row.new(table, table.sources[idx], idx, with_header: true)

  empty_table = Tablo::Table.new([[0], [1]])
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
    it "creates a Tabulo::Row" do
      row.should be_a(Tablo::Row)
    end
  end

  describe "#each" do
    it "iterates once for each column in the table" do
      i = 0
      row.each do |cell|
        i += 1
      end
      i.should eq(3)
    end

    it "iterates over the results of calling the column's extractor on the source object" do
      row.each_with_index do |cell, i|
        cell.should be_a(Int32)
        case i
        when 0
          cell.should eq(4)
        when 2
          cell.should eq(12)
        end
      end
    end
  end

  describe "#to_s" do
    context "when row was initialized with `with_header: false`" do
      it "returns a string showing the row contents without the column headers" do
        row.to_s.should eq("|            4 |            8 |           12 |")
      end
    end

    context "when row was initialized with `with_header: true`" do
      it "returns a string showing the column headers and the row contents" do
        row_with_header.to_s.should eq \
          %q(+--------------+--------------+--------------+
            |            N |       Double |       Triple |
            +--------------+--------------+--------------+
            |            4 |            8 |           12 |).gsub(/^ +/m, "")
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
      row.to_h.should eq({"N" => 4, "Double" => 8, "Triple" => 12})
    end
  end
end
