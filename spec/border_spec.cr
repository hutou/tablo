require "./spec_helper"

describe Tablo::Border do
  describe "Constructors" do
    border = Tablo::Border.new(Tablo::BorderName::Ascii)
    it "correctly creates a border from predefined names" do
      border.should be_a(Tablo::Border)
    end
    it "correctly renders all definition strings from predefined names" do
      {
        Tablo::BorderName::Ascii         => "+++++++++|||----",
        Tablo::BorderName::ReducedAscii  => "E EE EE EE E----",
        Tablo::BorderName::ReducedModern => "E EE EE EE E────",
        Tablo::BorderName::Markdown      => "   |||   |||  - ",
        Tablo::BorderName::Modern        => "┌┬┐├┼┤└┴┘│││────",
        Tablo::BorderName::Fancy         => "╭┬╮├┼┤╰┴╯│:│─−-⋅",
        Tablo::BorderName::Blank         => "EEEEEEEEEEEEEEEE",
      }.each do |k, v|
        Tablo::Border.new(k).border_string.should eq(v)
      end
    end
    it "correctly creates a border from a string of 15 chars" do
      border = Tablo::Border.new("abcdefghijklmnop")
      border.should be_a(Tablo::Border)
    end
    it "raises an exception on incorrect string length definition" do
      expect_raises Tablo::InvalidConnectorString do
        border = Tablo::Border.new("abcdefghijklmnopz")
      end
    end
  end

  describe "#horizontal_rule" do
    it "correctly formats line, without grouped columns" do
      border = Tablo::Border.new(Tablo::BorderName::Modern)
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleTop, groups: nil)
      rule.should eq("┌────────────────────────────────────────────────────────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleBottom, groups: nil)
      rule.should eq("└────────────────────────────────────────────────────────────┘")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::TitleHeader, groups: nil)
      rule.should eq("├────────┬──────┬─────┬────────────┬───────────────┬─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::HeaderTop, groups: nil)
      rule.should eq("┌────────┬──────┬─────┬────────────┬───────────────┬─────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::HeaderBody, groups: nil)
      rule.should eq("├────────┼──────┼─────┼────────────┼───────────────┼─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        position: Tablo::Position::BodyBottom, groups: nil)
      rule.should eq("└────────┴──────┴─────┴────────────┴───────────────┴─────────┘")
    end
    it "correctly formats line, with grouped columns" do
      border = Tablo::Border.new(Tablo::BorderName::Modern)
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
      border = Tablo::Border.new(Tablo::BorderName::Modern,
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
