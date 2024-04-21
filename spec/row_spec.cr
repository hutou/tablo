require "./spec_helper"

class Tablo::Cell
  getter value
end

describe Tablo::Row do
  # define border type for all tests
  # Tablo::Config::Defaults.border_definition = Tablo::Border::PreSet::Ascii

  table = Tablo::Table.new([["A", "B"], ["C", "D"], ["E", "F"], ["G", "H"], ["I", "J"]],
    border: Tablo::Border.new(Tablo::Border::PreSet::Ascii),
    header_frequency: 0) do |t|
    t.add_column("N", &.[0])
    t.add_column("Double") { |n| n[0] * 2 }
    t.add_column("Triple") { |n| n[0] * 3 }
  end

  body_row = ""
  header_row = ""
  test_row = nil
  table.each_with_index do |row, idx|
    if idx == 0
      header_row = row.to_s
    elsif idx == 3
      body_row = row.to_s
      test_row = row
    else
      row.to_s # **MANDATORY** so that RowGroup be happy !
      # A possible solution : check in RowGroup the sequence of source rows
      # They must be contiguous !!!
    end
  end

  empty_table = Tablo::Table.new([[0], [1]]) # no defined column
  empty_row = empty_table.first

  context "Row type validation" do
    it "is an Enumerable" do
      test_row.is_a?(Enumerable).should be_true
      test_row.responds_to?(:each).should be_true
      test_row.responds_to?(:map).should be_true
      test_row.responds_to?(:to_a).should be_true
    end
  end
  context "#initialize" do
    it "creates a Tablo::Row" do
      test_row.should be_a(Tablo::Row(typeof(test_row.as(Tablo::Row).source)))
    end
  end
  context "#each" do
    it "iterates once for each column in the table" do
      i = 0
      test_row.as(Tablo::Row).each do |_cell|
        i += 1
      end
      i.should eq(3) # 3 columns defined
    end
    it "iterates over the results of calling the column's extractor on the source object" do
      test_row.as(Tablo::Row).each_with_index do |cell, i|
        cell.should be_a(Tablo::Cell::Data)
        case i
        when 0
          cell.value.should eq("G")
        when 2
          cell.value.should eq("GGG")
        end
      end
    end
  end

  context "#to_s" do
    context "row.to_s generates a spec failure... To be investigated ! *** NOT ANYMORE ! ***" do
      context "when row has header attached" do
        it "returns a string showing the column headers and the row contents" do
          header_row.should eq <<-EOS
            +--------------+--------------+--------------+
            | N            | Double       | Triple       |
            +--------------+--------------+--------------+
            | A            | AA           | AAA          |
            EOS
        end
      end
      context "when row has *no* header attached" do
        it "returns a string showing the row contents without the column headers" do
          # This test needs to be done after the previous one, when row_index == 0,
          # as the rowgroup algorithm expects starting at row index 0
          body_row.should eq <<-EOS
            | G            | GG           | GGG          |
            EOS
        end
      end
    end
    context "when the table does not have any columns" do
      it "returns an empty string" do
        empty_row.to_s.should eq("")
      end
    end
    describe "#to_h" do
      it "returns a Hash mapping from column labels to cell values" do
        test_row.as(Tablo::Row).to_h.should eq({"N" => "G", "Double" => "GG", "Triple" => "GGG"})
      end
    end
  end
end
