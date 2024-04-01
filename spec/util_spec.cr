require "./spec_helper"

describe Tablo::Util do
  describe ".update" do
    nt1 = {x: 1, y: 2, z: 3}
    nt2 = {a: 33, z: 42}
    it "correctly update fields of first namedtuple from second namedtuple" do
      Tablo::Util.update(nt1, nt2).should eq({x: 1, y: 2, z: 42})
    end
  end
  describe ".stretch" do
    # def self.stretch(str : String, width : Int32, insert_char : Char = ' ',
    #                  gap : Int32? = nil, left_margin : String = "",
    #                  right_margin : String = "")
    it "correctly stretch the multiline string" do
      string = "This is a line\nto be stretched !"
      output = "<-         T h i s   i s   a   l i n e          ->" + "\n" +
               "<-      t o   b e   s t r e t c h e d   !       ->"
      Tablo::Util.stretch(string, 50, ' ', 2, "<-", "->").should eq(output)

      # Why not a struct ???
      # stretched_string = Tablo::Stretch.new(string, 50).to_s
    end
  end
  pending ".dot_align" do
  end
end
