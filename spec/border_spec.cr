require "./spec_helper"

# Redefine protected and private methods for tests
module Tablo
  struct Border
    def horizontal_rule(column_widths, ruletype = Tablo::RuleType::Bottom,
                        groups = [] of Array(Int32))
      previous_def
    end

    def connectors(ruletype)
      previous_def
    end

    def definition
      [@top_left, @top_mid, @top_right, @mid_left, @mid_mid, @mid_right,
       @bottom_left, @bottom_mid, @bottom_right, @vdiv_left, @vdiv_mid,
       @vdiv_right, @hdiv_tbs, @hdiv_grp, @hdiv_hdr, @hdiv_bdy]
        .map { |n| n.size.zero? ? "E" : (n == " " ? "S" : n) }.join
    end
  end
end

describe Tablo::Border do
  describe "Constructors" do
    it "correctly creates a border from predefined names" do
      border = Tablo::Border.new(Tablo::Border::PreSet::Ascii)
      border.should be_a(Tablo::Border)
    end
    it "correctly creates a border from a string of 16 chars" do
      border = Tablo::Border.new("abcdefghijklmnop")
      border.should be_a(Tablo::Border)
    end
    it "correctly renders all definition strings from predefined names" do
      {
        Tablo::Border::PreSet::Ascii         => "+++++++++|||----",
        Tablo::Border::PreSet::ReducedAscii  => "ESEESEESEESE----",
        Tablo::Border::PreSet::Modern        => "┌┬┐├┼┤└┴┘│││────",
        Tablo::Border::PreSet::ReducedModern => "ESEESEESEESE────",
        Tablo::Border::PreSet::Markdown      => "SSS|||SSS|||SS-S",
        Tablo::Border::PreSet::Fancy         => "╭┬╮├┼┤╰┴╯│:│─−-⋅",
        Tablo::Border::PreSet::Blank         => "SSSSSSSSSSSSSSSS",
        Tablo::Border::PreSet::Empty         => "EEEEEEEEEEEEEEEE",
      }.each do |k, v|
        Tablo::Border.new(k).definition.should eq(v)
      end
    end
    it "raises an exception on incorrect string length definition" do
      expect_raises Tablo::Error::InvalidBorderDefinition do
        border = Tablo::Border.new("abcdefghijklmnopz")
      end
    end
  end

  describe "#horizontal_rule" do
    it "correctly formats line, without grouped columns" do
      border = Tablo::Border.new(Tablo::Border::PreSet::Modern)
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::TitleTop, groups: [] of Array(Int32))
      rule.should eq("┌────────────────────────────────────────────────────────────┐")
      border.connectors(Tablo::RuleType::BodyBody).should eq({"├", "┼", "┤", "─", ""})
      border.definition.should eq("┌┬┐├┼┤└┴┘│││────")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::TitleBottom, groups: [] of Array(Int32))
      rule.should eq("└────────────────────────────────────────────────────────────┘")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::TitleHeader, groups: [] of Array(Int32))
      rule.should eq("├────────┬──────┬─────┬────────────┬───────────────┬─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::HeaderTop, groups: [] of Array(Int32))
      rule.should eq("┌────────┬──────┬─────┬────────────┬───────────────┬─────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::HeaderBody, groups: [] of Array(Int32))
      rule.should eq("├────────┼──────┼─────┼────────────┼───────────────┼─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::BodyBottom, groups: [] of Array(Int32))
      rule.should eq("└────────┴──────┴─────┴────────────┴───────────────┴─────────┘")
    end
    it "correctly formats line, with grouped columns" do
      border = Tablo::Border.new(Tablo::Border::PreSet::Modern)
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::TitleGroup, groups: [[1, 2], [3], [4, 5], [6]])
      rule.should eq("├───────────────┬─────┬────────────────────────────┬─────────┤")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::GroupTop, groups: [[1, 2], [3], [4, 5], [6]])
      rule.should eq("┌───────────────┬─────┬────────────────────────────┬─────────┐")
      rule = border.horizontal_rule([8, 6, 5, 12, 15, 9],
        ruletype: Tablo::RuleType::GroupHeader, groups: [[1, 2], [3], [4, 5], [6]])
      rule.should eq("├────────┬──────┼─────┼────────────┬───────────────┼─────────┤")
    end
    it "correctly styles line" do
      border = Tablo::Border.new(Tablo::Border::PreSet::Modern,
        styler: ->(s : String) { s.colorize(:red).to_s })
      rule = border.horizontal_rule([8, 6],
        ruletype: Tablo::RuleType::GroupHeader, groups: [[1, 2]])
      if Tablo::Util.styler_allowed
        rule.should eq("\e[31m├────────┬──────┤\e[0m")
      else
        rule.should eq("├────────┬──────┤")
      end
    end
  end
end
