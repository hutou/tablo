require "./spec_helper"

# Redefine protected and private methods for tests
module Tablo
  struct Border
    def horizontal_rule(column_widths, position = Tablo::Position::Bottom,
                        groups = [] of Array(Int32))
      previous_def
    end

    def connectors(position)
      previous_def
    end

    getter border_string
  end
end

describe Tablo::Border do
  describe "Constructors" do
    border = Tablo::Border.new(Tablo::Border::Name::Ascii)
    it "correctly creates a border from predefined names" do
      border.should be_a(Tablo::Border)
    end
    it "correctly renders all definition strings from predefined names" do
      {
        Tablo::Border::Name::Ascii         => "+++++++++|||----",
        Tablo::Border::Name::ReducedAscii  => "E EE EE EE E----",
        Tablo::Border::Name::ReducedModern => "E EE EE EE E────",
        Tablo::Border::Name::Markdown      => "   |||   |||  - ",
        Tablo::Border::Name::Modern        => "┌┬┐├┼┤└┴┘│││────",
        Tablo::Border::Name::Fancy         => "╭┬╮├┼┤╰┴╯│:│─−-⋅",
        Tablo::Border::Name::Blank         => "SSSSSSSSSSSSSSSS",
        Tablo::Border::Name::Empty         => "EEEEEEEEEEEEEEEE",
      }.each do |k, v|
        Tablo::Border.new(k).border_string.should eq(v)
      end
    end
    it "correctly creates a border from a string of 15 chars" do
      border = Tablo::Border.new("abcdefghijklmnop")
      border.should be_a(Tablo::Border)
    end
    it "raises an exception on incorrect string length definition" do
      expect_raises Tablo::Error::InvalidBorderDefinition do
        border = Tablo::Border.new("abcdefghijklmnopz")
      end
    end
  end

  describe "#horizontal_rule" do
    it "correctly formats line, without grouped columns" do
      border = Tablo::Border.new(Tablo::Border::Name::Modern)
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleTop, groups: [] of Array(Int32))
      rule.should eq("┌────────────────────────────────────────────────────────────┐")
      border.connectors(Tablo::Position::BodyBody).should eq({"├", "┼", "┤", "─", ""})
      border.border_string.should eq("┌┬┐├┼┤└┴┘│││────")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleBottom, groups: [] of Array(Int32))
      rule.should eq("└────────────────────────────────────────────────────────────┘")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleHeader, groups: [] of Array(Int32))
      rule.should eq("├────────┬──────┬─────┬────────────┬───────────────┬─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::HeaderTop, groups: [] of Array(Int32))
      rule.should eq("┌────────┬──────┬─────┬────────────┬───────────────┬─────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::HeaderBody, groups: [] of Array(Int32))
      rule.should eq("├────────┼──────┼─────┼────────────┼───────────────┼─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::BodyBottom, groups: [] of Array(Int32))
      rule.should eq("└────────┴──────┴─────┴────────────┴───────────────┴─────────┘")
    end
    it "correctly formats line, with grouped columns" do
      border = Tablo::Border.new(Tablo::Border::Name::Modern)
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        # position: Tablo::Position::TitleGroup, groups: [2, 1, 2, 1])
        position: Tablo::Position::TitleGroup, groups: [1..2, 3..3, 4..5, 6..6])
      rule.should eq("├───────────────┬─────┬────────────────────────────┬─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::GroupTop, groups: [1..2, 3..3, 4..5, 6..6])
      rule.should eq("┌───────────────┬─────┬────────────────────────────┬─────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::GroupHeader, groups: [1..2, 3..3, 4..5, 6..6])
      rule.should eq("├────────┬──────┼─────┼────────────┬───────────────┼─────────┤")
    end
    it "correctly styles line" do
      border = Tablo::Border.new(Tablo::Border::Name::Modern,
        styler: ->(s : String) { s.colorize(:red).to_s })
      rule = border.horizontal_rule([8, 6],
        position: Tablo::Position::GroupHeader, groups: [1..2])
      if Tablo::Util.styler_allowed
        rule.should eq("\e[31m├────────┬──────┤\e[0m")
      else
        rule.should eq("├────────┬──────┤")
      end
    end
  end
end
