require "./spec_helper"

describe Tablo::Column do
  column = Tablo::Column.new(
    header: "N",
    width: 10,
    align_header: Tablo::Justify::Left,
    align_body: Tablo::Justify::Left,
    formatter: ->(n : Tablo::CellType) { "%.2f" % n.as(Int32) },
    extractor: ->(n : Array(Tablo::CellType)) { n[0].as(Tablo::CellType) })

  describe "#initialize" do
    it "create a Column" do
      column.should be_a(Tablo::Column)
    end
  end

  describe "#header_subcells" do
    it "returns an array of strings representing the components of the header cell" do
      column.header_subcells.should eq(["N         "])
    end
  end

  describe "#body_subcells" do
    it "returns an array of strings representing the components of the body cell" do
      column.body_subcells([3].map &.as(Tablo::CellType)).should eq(["3.00      "])
    end
  end

  describe "#formatted_cell_content" do
    it "returns the formatted content for this column, without internal padding" do
      column.formatted_cell_content([3].map &.as(Tablo::CellType)).should eq("3.00")
    end
  end

  describe "#body_cell_value" do
    it "returns the underlying value in this column for the passed source item" do
      column.body_cell_value([3].map &.as(Tablo::CellType)).should eq(3)
    end
  end
end
