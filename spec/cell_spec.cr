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
        output = table.to_s
        {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
        if Tablo::Util.styler_allowed
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
        else
          expected_output = <<-OUTPUT
            +--------------------------------------------+
            |                  My Title                  |
            +--------------+--------------+--------------+
            | itself       | itself x 2   | itself x 3   |
            +--------------+--------------+--------------+
            | A            | AA           | A            |
            |              |              | A            |
            |              |              | A            |
            | B            | BB           | B            |
            |              |              | B            |
            |              |              | B            |
            | C            | CC           | C            |
            |              |              | C            |
            |              |              | C            |
            +--------------+--------------+--------------+
            OUTPUT
        end
        output.should eq(expected_output)
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
        output = table.to_s
        {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
        if Tablo::Util.styler_allowed
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
        else
          expected_output = <<-OUTPUT
            +--------------------------------------------+
            |                  My Title                  |
            +--------------+--------------+--------------+
            | itself       | itself x 2   | itself x 3   |
            +--------------+--------------+--------------+
            | A            | AA           | A            |
            |              |              | A            |
            |              |              | A            |
            | B            | BB           | B            |
            |              |              | B            |
            |              |              | B            |
            | C            | CC           | C            |
            |              |              | C            |
            |              |              | C            |
            +--------------+--------------+--------------+          
            OUTPUT
        end
        table.to_s.should eq(expected_output)
      end
    end
  end
end
