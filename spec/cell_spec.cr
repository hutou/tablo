require "./spec_helper"

# Redefine protected and private methods for tests
class Tablo::Cell
  getter content_postformat
  getter subcells

  def formatted_content
    previous_def
  end

  def rendered_subcells
    previous_def
  end

  def line_count
    previous_def
  end
end

describe "\n\n#{Tablo::Cell} - Specs for cell.cr" do
  context "specs on subcells" do
  end
  context "Specs on TextCell, with WrapMode::Rune" do
    title_cell = Tablo::TextCell.new(
      value: "This is a rather long line, needed for tests",
      row_type: Tablo::RowType::Title,
      left_padding: 1, right_padding: 1, padding_character: " ",
      alignment: Tablo::Justify::Left,
      formatter: ->(c : Tablo::CellType) { c.to_s },
      styler: ->(s : String) { s },
      truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Rune, width: 12)
    it "cuts the line at appropriate places" do
      subcells = title_cell.rendered_subcells
      subcells.size.should eq(4)
      subcells[1].should eq("ther long li")
      subcells[3].should eq("or tests    ")
    end
  end
  context "Specs on TextCell, with WrapMode::Word" do
    title_cell = Tablo::TextCell.new(
      value: "This is a rather long line, needed for tests",
      row_type: Tablo::RowType::Title,
      left_padding: 1, right_padding: 1, padding_character: " ",
      alignment: Tablo::Justify::Left,
      formatter: ->(c : Tablo::CellType) { c.to_s },
      styler: ->(s : String) { s },
      truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
    it "cuts the line at appropriate places" do
      subcells = title_cell.rendered_subcells
      subcells.size.should eq(5)
      subcells[1].should eq("rather long ")
      subcells[3].should eq("needed for  ")
    end
  end
  #
  context "Specs on DataCell" do
    describe Tablo::DataCell do
      context "With simple float value" do
        describe "#line_count" do
          bodycell = Tablo::DataCell.new(
            value: 3.14, cell_data: Tablo::CellData.new(3.14, 0, 0),
            left_padding: 1, right_padding: 1, padding_character: " ",
            alignment: nil,
            styler: ->(_c : Tablo::CellType, s : String) { s },
            formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
            truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
          it "returns the number of subcells in the cell" do
            bodycell.line_count.should eq(1)
          end
        end
        describe "#content_postformat" do
          bodycell = Tablo::DataCell.new(
            value: 3.14, cell_data: Tablo::CellData.new(3.14, 0, 0),
            left_padding: 1, right_padding: 1, padding_character: " ",
            alignment: nil,
            styler: ->(_c : Tablo::CellType, s : String) { s },
            formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
            truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
          it "correctly apply the formatter" do
            bodycell.line_count
            bodycell.formatted_content.should eq("   3.14")
          end
        end
        describe "#calculate_subcells" do
          bodycell = Tablo::DataCell.new(
            value: 3.14, cell_data: Tablo::CellData.new(3.14, 0, 0),
            left_padding: 1, right_padding: 1, padding_character: " ",
            alignment: nil,
            styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
            formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
            truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
          it "correctly returns an array of formatted and styled subcells" do
            bodycell.line_count
            if Tablo::Util.styler_allowed
              bodycell.rendered_subcells.should eq(["     \e[31m   3.14\e[0m"])
            else
              bodycell.rendered_subcells.should eq(["        3.14"])
            end
          end
        end
      end
    end
    describe Tablo::DataCell do
      header_value = "This is a very long and multiline header " \
                     "for testing formatting, styling and alignment"

      context "With long header text" do
        describe "#line_count" do
          it "returns the correct number of subcells in the cell" do
            headercell = Tablo::DataCell.new(
              value: header_value, cell_data: Tablo::CellData.new(header_value, 0, 0), left_padding: 1,
              right_padding: 1, padding_character: " ", alignment: nil,
              styler: ->(_c : Tablo::CellType, s : String) { s },
              formatter: ->(c : Tablo::CellType) { c.to_s },
              truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
            headercell.line_count.should eq(9)
          end
        end
        describe "#content_postformat" do
          it "correctly apply the formatter" do
            headercell = Tablo::DataCell.new(
              value: header_value, cell_data: Tablo::CellData.new(header_value, 0, 0), left_padding: 1,
              right_padding: 1, padding_character: " ", alignment: nil,
              styler: ->(_c : Tablo::CellType, s : String) { s },
              formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
              truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
            expected_result = "THIS IS A VERY LONG AND MULTILINE HEADER " \
                              "FOR TESTING FORMATTING, STYLING AND ALIGNMENT"
            headercell.line_count
            headercell.formatted_content.should eq(expected_result)
          end
        end
        describe "#calculate_subcells" do
          it "correctly returns an array of formatted and styled subcells, " \
             "left aligned as bodycell value is a string" do
            headercell = Tablo::DataCell.new(
              value: header_value, cell_data: Tablo::CellData.new(header_value, 0, 0), left_padding: 1,
              right_padding: 1, padding_character: " ", alignment: Tablo::Justify::Left,
              styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
              formatter: ->(c : Tablo::CellType) { c.to_s },
              truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
            if Tablo::Util.styler_allowed
              expected_result = ["\e[31mThis is a\e[0m   ", "\e[31mvery long\e[0m   ",
                                 "\e[31mand\e[0m         ", "\e[31mmultiline\e[0m   ",
                                 "\e[31mheader for\e[0m  ", "\e[31mtesting\e[0m     ",
                                 "\e[31mformatting,\e[0m ", "\e[31mstyling and\e[0m ",
                                 "\e[31malignment\e[0m   "]
            else
              expected_result = ["This is a   ", "very long   ",
                                 "and         ", "multiline   ",
                                 "header for  ", "testing     ",
                                 "formatting, ", "styling and ",
                                 "alignment   "]
            end
            headercell.line_count
            headercell.rendered_subcells.should eq(expected_result)
          end

          it "correctly returns an array of formatted and styled subcells, " \
             "center justified" do
            headercell = Tablo::DataCell.new(
              value: header_value, cell_data: Tablo::CellData.new(header_value, 0, 0), left_padding: 1,
              right_padding: 1, padding_character: " ", alignment: Tablo::Justify::Center,
              styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
              formatter: ->(c : Tablo::CellType) { c.to_s },
              truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
            if Tablo::Util.styler_allowed
              expected_result = ["  \e[31mThis is a\e[0m ", "  \e[31mvery long\e[0m ",
                                 "     \e[31mand\e[0m    ", "  \e[31mmultiline\e[0m ",
                                 " \e[31mheader for\e[0m ", "   \e[31mtesting\e[0m  ",
                                 " \e[31mformatting,\e[0m", " \e[31mstyling and\e[0m",
                                 "  \e[31malignment\e[0m "]
            else
              expected_result = ["  This is a ",
                                 "  very long ",
                                 "     and    ",
                                 "  multiline ",
                                 " header for ",
                                 "   testing  ",
                                 " formatting,",
                                 " styling and",
                                 "  alignment "]
            end
            headercell.line_count
            headercell.rendered_subcells.should eq(expected_result)
          end

          it "correctly returns an array of formatted and styled subcells, " \
             "with different styled lines, left aligned as value is string" do
            headercell = Tablo::DataCell.new(
              value: header_value, cell_data: Tablo::CellData.new(header_value, 0, 0), left_padding: 1,
              right_padding: 1, padding_character: " ", alignment: nil,
              styler: ->(_c : Tablo::CellType, _n : Tablo::CellData, s : String, line : Int32) {
                case line
                when 1
                  s.colorize(:red).to_s
                when 3
                  s.colorize(:green).to_s
                when 5
                  s.colorize(:yellow).to_s
                else
                  s.colorize(:white).to_s
                end
              },
              formatter: ->(c : Tablo::CellType) { c.to_s.split("").join(" ") },
              truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
            if Tablo::Util.styler_allowed
              expected_result = ["\e[97mT h i s   i\e[0m ", "\e[31ms   a   v e\e[0m ",
                                 "\e[97mr y   l o n\e[0m ", "\e[32mg   a n d\e[0m   ",
                                 "\e[97mm u l t i l\e[0m ", "\e[33mi n e   h e\e[0m ",
                                 "\e[97ma d e r   f\e[0m ", "\e[97mo r   t e s\e[0m ",
                                 "\e[97mt i n g   f\e[0m ", "\e[97mo r m a t t\e[0m ",
                                 "\e[97mi n g ,   s\e[0m ", "\e[97mt y l i n\e[0m   ",
                                 "\e[97mg   a n d\e[0m   ", "\e[97ma l i g n m\e[0m ",
                                 "\e[97me n t\e[0m       "]
            else
              expected_result = ["T h i s   i ", "s   a   v e ",
                                 "r y   l o n ", "g   a n d   ",
                                 "m u l t i l ", "i n e   h e ",
                                 "a d e r   f ", "o r   t e s ",
                                 "t i n g   f ", "o r m a t t ",
                                 "i n g ,   s ", "t y l i n   ",
                                 "g   a n d   ", "a l i g n m ",
                                 "e n t       "]
            end
            headercell.line_count
            headercell.rendered_subcells.should eq(expected_result)
          end
        end
      end
    end
  end
end
