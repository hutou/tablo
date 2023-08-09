require "./spec_helper"

describe Tablo::Util do
  describe ".update" do
    nt1 = {x: 1, y: 2, z: 3}
    nt2 = {a: 33, z: 42}
    it "correctly update fields of first namedtuple from second namedtuple" do
      Tablo::Util.update(nt1, nt2).should eq({x: 1, y: 2, z: 42})
    end
  end
end
