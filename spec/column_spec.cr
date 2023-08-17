require "./spec_helper"

describe Tablo::Column do
  column = Tablo::Column(Int32).new(
    header: "Double",
    header_alignment: Tablo::Justify::Right,
    header_styler: ->(_c : Tablo::CellType, s : String) { s },
    body_alignment: Tablo::Justify::Right,
    body_styler: ->(_c : Tablo::CellType, s : String) { s },
    #
    left_padding: 3,
    right_padding: 5,
    padding_character: " ",
    width: 13,
    #
    header_formatter: ->(c : Tablo::CellType) { c.to_s },
    body_formatter: ->(c : Tablo::CellType) { c.to_s },
    truncation_indicator: "~",
    wrap_mode: Tablo::WrapMode::Word,
    extractor: ->(n : Int32, _irow : Int32) { n.as(Tablo::CellType) },
    index: 2)

  describe "#initialize" do
    it "create a Column" do
      column.should be_a(Tablo::Column(Int32))
    end
  end

  source = 17
  bodycell = column.body_cell(source, 0, 0)
  describe "#body_cell" do
    it "instanciates a cell of type DataCell" do
      bodycell.should be_a(Tablo::DataCell)
    end
    it "correctly retrieves cell value from extractor call on source" do
      bodycell.value.should eq(17)
      column.body_cell_value(source, 0).should eq(17)
    end
  end
  headercell = column.header_cell(bodycell)
  describe "#header_cell" do
    it "instanciates a cell of type DataCell" do
      headercell.should be_a(Tablo::DataCell)
    end
    it "correctly retrieves cell value from header field" do
      headercell.value.should eq("Double")
    end
  end
  describe ".padded_width" do
    it "correctly returns padded width" do
      column.padded_width.should eq(21)
    end
  end
  describe ".total_padding" do
    it "correctly returns total_padding" do
      column.total_padding.should eq(8)
    end
  end
end
