require "./spec_helper"
require "colorize"
require "uniwidth"

# Specs for src/cell.cr are very limited, as most of its code is not public
# Validation of this code is done essentially by table.to_s rendering, and also
# by row#each and row#to_h methods for Cell::Data type
#
#

describe Tablo::Cell do
  # Formatted content cutting location for content size exceeding column size,
  # depending on WrapMode and language type (non romanic)
  # 1. Using romanic languages
  #    a. WrapMode = Rune (~Char)
  #    b. WrapMode = Word
  # 2. using non-romanic languages
  #    a. WrapMode = Rune (~Char)
  #    b. WrapMode = Word
  context "(Multi)Line cut location for romanic languages" do
    context "Using Rune wrap mode" do
      it "cuts lines at appropriate locations and set truncation indicator" do
        table = Tablo::Table.new(["This is a rather long line, needed for tests"],
          truncation_indicator: "~",
          wrap_mode: Tablo::WrapMode::Rune,
          body_wrap: 3,
          width: 12) do |t|
          t.add_column("String", &.itself)
        end
        expected_output = <<-OUTPUT
          +--------------+
          | String       |
          +--------------+
          | This is a ra |
          | ther long li |
          | ne, needed f~|
          +--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
    context "Using Word wrap mode" do
      it "cuts lines at appropriate locations and set truncation indicator" do
        table = Tablo::Table.new(["This is a rather long line, needed for tests"],
          truncation_indicator: "~",
          wrap_mode: Tablo::WrapMode::Word,
          body_wrap: 3,
          width: 12) do |t|
          t.add_column("String", &.itself)
        end
        expected_output = <<-OUTPUT
          +--------------+
          | String       |
          +--------------+
          | This is a    |
          | rather long  |
          | line,       ~|
          +--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
  end
  context "Line cut location for *NON* romanic languages (In japaneese, no spacing between words)" do
    context "Using Rune wrap mode (same as Word for Japaneese)" do
      it "cuts lines at appropriate locations and set truncation indicator" do
        table = Tablo::Table.new(["クリスタルのコンピューター言語は本当に素晴らしい！"],
          truncation_indicator: "~",
          wrap_mode: Tablo::WrapMode::Rune,
          body_wrap: 3,
          width: 12) do |t|
          t.add_column("String", &.itself)
        end
        expected_output = <<-OUTPUT
          +--------------+
          | String       |
          +--------------+
          | クリスタルの |
          | コンピュータ |
          | ー言語は本当~|
          +--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
    context "Using Word wrap mode (same as Rune for Japaneese)" do
      it "cuts lines at appropriate locations and set truncation indicator" do
        table = Tablo::Table.new(["クリスタルのコンピューター言語は本当に素晴らしい！"],
          truncation_indicator: "~",
          wrap_mode: Tablo::WrapMode::Word,
          body_wrap: 3,
          width: 12) do |t|
          t.add_column("String", &.itself)
        end
        expected_output = <<-OUTPUT
          +--------------+
          | String       |
          +--------------+
          | クリスタルの |
          | コンピュータ |
          | ー言語は本当~|
          +--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
  end

  describe Tablo::Cell::Text do
    # formatter and styler procs
    context "Check use of cell value in formatter proc" do
      it "renders table, based on cell'a value, globally" do
        table = Tablo::Table.new(["A", "B", "C"],
          body_formatter: ->(value : Tablo::CellType) {
            if value.is_a?(String)
              value.as(String).downcase
            else
              value.to_s
            end
          }) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2", &.*(2))
          t.add_column("itself x 3", &.*(3))
        end
        expected_output = <<-OUTPUT
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | a            | aa           | aaa          |
          | b            | bb           | bbb          |
          | c            | cc           | ccc          |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
      it "renders table, based on cell'a value, at column level" do
        table = Tablo::Table.new(["A", "B", "C"]) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2",
            body_formatter: ->(value : Tablo::CellType) {
              if value.is_a?(String)
                value.as(String).downcase
              else
                value.to_s
              end
            }, &.*(2)
          )
          t.add_column("itself x 3", &.*(3))
        end
        expected_output = <<-OUTPUT
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | A            | aa           | AAA          |
          | B            | bb           | BBB          |
          | C            | cc           | CCC          |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
    context "Check use of cell value in styler proc" do
      it "renders colorized table, based on formatted content and cell line number" do
        table = Tablo::Table.new(["A", "B", "C"],
          title: Tablo::Heading.new("My Title", framed: true),
          body_styler: ->(content : String, line_index : Int32) {
            case line_index
            when 0 then content.colorize(:magenta).mode(:bold).to_s
            when 1 then content.colorize(:blue).mode(:bold).to_s
            when 2 then content.colorize(:green).mode(:bold).to_s
            else
              content
            end
          }
        ) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2", &.*(2))
          t.add_column("itself x 3", &.*(3).chars.join("\n"))
        end
        expected_output = <<-OUTPUT
          +--------------------------------------------+
          |                  My Title                  |
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | \e[35;1mA\e[0m            | \e[35;1mAA\e[0m           | \e[35;1mA\e[0m            |
          |              |              | \e[34;1mA\e[0m            |
          |              |              | \e[32;1mA\e[0m            |
          | \e[35;1mB\e[0m            | \e[35;1mBB\e[0m           | \e[35;1mB\e[0m            |
          |              |              | \e[34;1mB\e[0m            |
          |              |              | \e[32;1mB\e[0m            |
          | \e[35;1mC\e[0m            | \e[35;1mCC\e[0m           | \e[35;1mC\e[0m            |
          |              |              | \e[34;1mC\e[0m            |
          |              |              | \e[32;1mC\e[0m            |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
  end

  describe Tablo::Cell::Data do
    context "Check use of cell coords and value in formatter proc" do
      it "renders table, based on cell'a value and coords, globally" do
        table = Tablo::Table.new(["A", "B", "C"],
          body_formatter: ->(value : Tablo::CellType, coords : Tablo::Cell::Data::Coords) {
            if value.is_a?(String)
              coords.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase
            else
              value.to_s
            end
          }) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2", &.*(2))
          t.add_column("itself x 3", &.*(3))
        end
        expected_output = <<-OUTPUT
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | A            | AA           | AAA          |
          | b            | bb           | bbb          |
          | C            | CC           | CCC          |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
      it "renders table, based on cell'a value and coords, at column level" do
        table = Tablo::Table.new(["A", "B", "C"]) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2",
            body_formatter: ->(value : Tablo::CellType, coords : Tablo::Cell::Data::Coords) {
              if value.is_a?(String)
                coords.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase
              else
                value.to_s
              end
            }, &.*(2)
          )
          t.add_column("itself x 3", &.*(3))
        end
        expected_output = <<-OUTPUT
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | A            | AA           | AAA          |
          | B            | bb           | BBB          |
          | C            | CC           | CCC          |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
    context "Check use of cell coords, formatted content and value in styler proc" do
      it "renders colorized table, based on cell'a value, formatted content and coords" do
        table = Tablo::Table.new(["A", "B", "C"],
          title: Tablo::Heading.new("My Title", framed: true),
          body_styler: ->(_value : Tablo::CellType, coords : Tablo::Cell::Data::Coords, content : String, line_index : Int32) {
            if line_index > 0
              content.colorize(:magenta).mode(:bold).to_s
            else
              if coords.row_index % 2 == 0
                coords.column_index == 0 ? content.colorize(:red).to_s : content.colorize(:green).to_s
              else
                content.colorize(:blue).to_s
              end
            end
          }
        ) do |t|
          t.add_column("itself", &.itself)
          t.add_column("itself x 2", &.*(2))
          t.add_column("itself x 3", &.*(3).chars.join("\n"))
        end
        expected_output = <<-OUTPUT
          +--------------------------------------------+
          |                  My Title                  |
          +--------------+--------------+--------------+
          | itself       | itself x 2   | itself x 3   |
          +--------------+--------------+--------------+
          | \e[31mA\e[0m            | \e[32mAA\e[0m           | \e[32mA\e[0m            |
          |              |              | \e[35;1mA\e[0m            |
          |              |              | \e[35;1mA\e[0m            |
          | \e[34mB\e[0m            | \e[34mBB\e[0m           | \e[34mB\e[0m            |
          |              |              | \e[35;1mB\e[0m            |
          |              |              | \e[35;1mB\e[0m            |
          | \e[31mC\e[0m            | \e[32mCC\e[0m           | \e[32mC\e[0m            |
          |              |              | \e[35;1mC\e[0m            |
          |              |              | \e[35;1mC\e[0m            |
          +--------------+--------------+--------------+
          OUTPUT
        table.to_s.should eq(expected_output)
      end
    end
  end
end

# Redefine protected and private methods for tests
# class Tablo::Cell
#   getter content_postformat
#   getter subcells

#   def content
#     previous_def
#   end

#   def rendered_subcells
#     previous_def
#   end

#   def line_count
#     previous_def
#   end
# end

# describe "\n\n#{Tablo::Cell} - Specs for cell.cr" do
#   context "Specs on Cell::Text" do
#     context "with WrapMode::Rune" do
#       title_cell = Tablo::Cell::Text.new(
#         value: "This is a rather long line, needed for tests",
#         row_type: Tablo::RowType::Title,
#         left_padding: 1, right_padding: 1, padding_character: " ",
#         alignment: Tablo::Justify::Left,
#         formatter: ->(c : Tablo::CellType) { c.to_s },
#         styler: ->(s : String) { s },
#         truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Rune, width: 12)
#       it "cuts the line at appropriate places" do
#         subcells = title_cell.rendered_subcells
#         subcells.size.should eq(4)
#         subcells[1].should eq("ther long li")
#         subcells[3].should eq("or tests    ")
#       end
#     end

#     context "with WrapMode::Word" do
#       title_cell = Tablo::Cell::Text.new(
#         value: "This is a rather long line, needed for tests",
#         row_type: Tablo::RowType::Title,
#         left_padding: 1, right_padding: 1, padding_character: " ",
#         alignment: Tablo::Justify::Left,
#         formatter: ->(c : Tablo::CellType) { c.to_s },
#         styler: ->(s : String) { s },
#         truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#       it "cuts the line at appropriate places" do
#         subcells = title_cell.rendered_subcells
#         subcells.size.should eq(5)
#         subcells[1].should eq("rather long ")
#         subcells[3].should eq("needed for  ")
#       end
#     end
#   end

#   context "Specs on Cell::Data" do
#     context "With simple float value" do
#       describe "#line_count" do
#         bodycell = Tablo::Cell::Data.new(
#           value: 3.14, coords: Tablo::Cell::Data::Coords.new(3.14, 0, 0),
#           left_padding: 1, right_padding: 1, padding_character: " ",
#           alignment: nil,
#           styler: ->(_c : Tablo::CellType, s : String) { s },
#           formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
#           truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#         it "returns the number of subcells in the cell" do
#           bodycell.line_count.should eq(1)
#         end
#       end

#       describe "#content_postformat" do
#         bodycell = Tablo::Cell::Data.new(
#           value: 3.14, coords: Tablo::Cell::Data::Coords.new(3.14, 0, 0),
#           left_padding: 1, right_padding: 1, padding_character: " ",
#           alignment: nil,
#           styler: ->(_c : Tablo::CellType, s : String) { s },
#           formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
#           truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#         it "applies the formatter" do
#           bodycell.line_count
#           bodycell.content.should eq("   3.14")
#         end
#       end

#       describe "#calculate_subcells" do
#         bodycell = Tablo::Cell::Data.new(
#           value: 3.14, coords: Tablo::Cell::Data::Coords.new(3.14, 0, 0),
#           left_padding: 1, right_padding: 1, padding_character: " ",
#           alignment: nil,
#           styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
#           formatter: ->(c : Tablo::CellType) { "%7.2f" % c },
#           truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#         it "returns an array of formatted and styled subcells" do
#           bodycell.line_count
#           if Tablo::Util.styler_allowed
#             bodycell.rendered_subcells.should eq(["     \e[31m   3.14\e[0m"])
#           else
#             bodycell.rendered_subcells.should eq(["        3.14"])
#           end
#         end
#       end
#     end

#     context "With long header text" do
#       header_value = "This is a very long and multiline header " \
#                      "for testing formatting, styling and alignment"
#       describe "#line_count" do
#         it "returns the correct number of subcells in the cell" do
#           headercell = Tablo::Cell::Data.new(
#             value: header_value, coords: Tablo::Cell::Data::Coords.new(header_value, 0, 0),
#             left_padding: 1, right_padding: 1, padding_character: " ", alignment: nil,
#             styler: ->(_c : Tablo::CellType, s : String) { s },
#             formatter: ->(c : Tablo::CellType) { c.to_s },
#             truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#           headercell.line_count.should eq(9)
#         end
#       end

#       describe "#content_postformat" do
#         it "applies the formatter" do
#           headercell = Tablo::Cell::Data.new(
#             value: header_value, coords: Tablo::Cell::Data::Coords.new(header_value, 0, 0),
#             left_padding: 1, right_padding: 1, padding_character: " ", alignment: nil,
#             styler: ->(_c : Tablo::CellType, s : String) { s },
#             formatter: ->(c : Tablo::CellType) { c.to_s.upcase },
#             truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#           expected_result = "THIS IS A VERY LONG AND MULTILINE HEADER " \
#                             "FOR TESTING FORMATTING, STYLING AND ALIGNMENT"
#           headercell.line_count
#           headercell.content.should eq(expected_result)
#         end
#       end

#       describe "#calculate_subcells" do
#         it "returns an array of formatted and styled subcells, " \
#            "left aligned as bodycell value is a string" do
#           headercell = Tablo::Cell::Data.new(
#             value: header_value, coords: Tablo::Cell::Data::Coords.new(header_value, 0, 0),
#             left_padding: 1, right_padding: 1, padding_character: " ",
#             alignment: nil, # Tablo::Justify::Left,
#             styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
#             formatter: ->(c : Tablo::CellType) { c.to_s },
#             truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#           if Tablo::Util.styler_allowed
#             expected_result = ["\e[31mThis is a\e[0m   ", "\e[31mvery long\e[0m   ",
#                                "\e[31mand\e[0m         ", "\e[31mmultiline\e[0m   ",
#                                "\e[31mheader for\e[0m  ", "\e[31mtesting\e[0m     ",
#                                "\e[31mformatting,\e[0m ", "\e[31mstyling and\e[0m ",
#                                "\e[31malignment\e[0m   "]
#           else
#             expected_result = ["This is a   ", "very long   ",
#                                "and         ", "multiline   ",
#                                "header for  ", "testing     ",
#                                "formatting, ", "styling and ",
#                                "alignment   "]
#           end
#           headercell.line_count
#           headercell.rendered_subcells.should eq(expected_result)
#         end

#         it "returns an array of formatted and styled subcells, " \
#            "center justified" do
#           headercell = Tablo::Cell::Data.new(
#             value: header_value, coords: Tablo::Cell::Data::Coords.new(header_value, 0, 0),
#             left_padding: 1, right_padding: 1, padding_character: " ", alignment: Tablo::Justify::Center,
#             styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
#             formatter: ->(c : Tablo::CellType) { c.to_s },
#             truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#           if Tablo::Util.styler_allowed
#             expected_result = ["  \e[31mThis is a\e[0m ", "  \e[31mvery long\e[0m ",
#                                "     \e[31mand\e[0m    ", "  \e[31mmultiline\e[0m ",
#                                " \e[31mheader for\e[0m ", "   \e[31mtesting\e[0m  ",
#                                " \e[31mformatting,\e[0m", " \e[31mstyling and\e[0m",
#                                "  \e[31malignment\e[0m "]
#           else
#             expected_result = ["  This is a ",
#                                "  very long ",
#                                "     and    ",
#                                "  multiline ",
#                                " header for ",
#                                "   testing  ",
#                                " formatting,",
#                                " styling and",
#                                "  alignment "]
#           end
#           headercell.line_count
#           headercell.rendered_subcells.should eq(expected_result)
#         end

#         it "returns an array of formatted and styled subcells, " \
#            "with different styled lines, left aligned as value is string" do
#           headercell = Tablo::Cell::Data.new(
#             value: header_value, coords: Tablo::Cell::Data::Coords.new(header_value, 0, 0),
#             left_padding: 1, right_padding: 1, padding_character: " ", alignment: nil,
#             styler: ->(_c : Tablo::CellType, _n : Tablo::Cell::Data::Coords, s : String, line : Int32) {
#               case line
#               when 1
#                 s.colorize(:red).to_s
#               when 3
#                 s.colorize(:green).to_s
#               when 5
#                 s.colorize(:yellow).to_s
#               else
#                 s.colorize(:white).to_s
#               end
#             },
#             formatter: ->(c : Tablo::CellType) { c.to_s.split("").join(" ") },
#             truncation_indicator: "~", wrap_mode: Tablo::WrapMode::Word, width: 12)
#           if Tablo::Util.styler_allowed
#             expected_result = ["\e[97mT h i s   i\e[0m ", "\e[31ms   a   v e\e[0m ",
#                                "\e[97mr y   l o n\e[0m ", "\e[32mg   a n d\e[0m   ",
#                                "\e[97mm u l t i l\e[0m ", "\e[33mi n e   h e\e[0m ",
#                                "\e[97ma d e r   f\e[0m ", "\e[97mo r   t e s\e[0m ",
#                                "\e[97mt i n g   f\e[0m ", "\e[97mo r m a t t\e[0m ",
#                                "\e[97mi n g ,   s\e[0m ", "\e[97mt y l i n\e[0m   ",
#                                "\e[97mg   a n d\e[0m   ", "\e[97ma l i g n m\e[0m ",
#                                "\e[97me n t\e[0m       "]
#           else
#             expected_result = ["T h i s   i ", "s   a   v e ",
#                                "r y   l o n ", "g   a n d   ",
#                                "m u l t i l ", "i n e   h e ",
#                                "a d e r   f ", "o r   t e s ",
#                                "t i n g   f ", "o r m a t t ",
#                                "i n g ,   s ", "t y l i n   ",
#                                "g   a n d   ", "a l i g n m ",
#                                "e n t       "]
#           end
#           headercell.line_count
#           headercell.rendered_subcells.should eq(expected_result)
#         end
#       end
#     end
# end
# end
