require "./spec_helper"

describe "Tablo::Functions.fp_align" do
  context "Using a value of 0.0 and 3 decimals" do
    it "returns a correct result with DotAlign::Blank" do
      Tablo::Functions.fp_align(0.0, 3, :blank).should eq("    ")
    end
    it "returns a correct result with DotAlign::NoDot" do
      Tablo::Functions.fp_align(0.0, 3, :no_dot).should eq("0    ")
    end
    it "returns a correct result with DotAlign::DotOnly" do
      Tablo::Functions.fp_align(0.0, 3, :dot_only).should eq("0.   ")
    end
    it "returns a correct result with DotAlign::DotZero" do
      Tablo::Functions.fp_align(0.0, 3, :dot_zero).should eq("0.0  ")
    end
  end
  context "Using a value of 3.14 and 3 decimals" do
    it "returns a correct result with DotAlign::Blank" do
      Tablo::Functions.fp_align(3.14, 3, :blank).should eq("3.14 ")
    end
    it "returns a correct result with DotAlign::NoDot" do
      Tablo::Functions.fp_align(3.14, 3, :no_dot).should eq("3.14 ")
    end
    it "returns a correct result with DotAlign::DotOnly" do
      Tablo::Functions.fp_align(3.14, 3, :dot_only).should eq("3.14 ")
    end
    it "returns a correct result with DotAlign::DotZero" do
      Tablo::Functions.fp_align(3.14, 3, :dot_zero).should eq("3.14 ")
    end
  end
  context "Using a value of 2.1 and 3 decimals" do
    it "returns a correct result with DotAlign::Blank" do
      Tablo::Functions.fp_align(2.1, 3, :blank).should eq("2.1  ")
    end
    it "returns a correct result with DotAlign::NoDot" do
      Tablo::Functions.fp_align(2.1, 3, :no_dot).should eq("2.1  ")
    end
    it "returns a correct result with DotAlign::DotOnly" do
      Tablo::Functions.fp_align(2.1, 3, :dot_only).should eq("2.1  ")
    end
    it "returns a correct result with DotAlign::DotZero" do
      Tablo::Functions.fp_align(2.1, 3, :dot_zero).should eq("2.1  ")
    end
  end

  context "Using a value of 123.0 and 3 decimals" do
    it "returns a correct result with DotAlign::Blank" do
      Tablo::Functions.fp_align(123.0, 3, :blank).should eq("123    ")
    end
    it "returns a correct result with DotAlign::NoDot" do
      Tablo::Functions.fp_align(123.0, 3, :no_dot).should eq("123    ")
    end
    it "returns a correct result with DotAlign::DotOnly" do
      Tablo::Functions.fp_align(123.0, 3, :dot_only).should eq("123.   ")
    end
    it "returns a correct result with DotAlign::DotZero" do
      Tablo::Functions.fp_align(123.0, 3, :dot_zero).should eq("123.0  ")
    end
  end
end

describe "Tablo::Functions.stretch" do
  it "renders the stretched string with default parameters" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50).should eq <<-OUTPUT
                        H  e  l  l  o                   
           T  h  i  s     i  s     a     t  e  s  t     
      OUTPUT
  end
  it "renders the stretched string with a fill char" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-').should eq <<-OUTPUT
                        H--e--l--l--o                   
           T--h--i--s-- --i--s-- --a-- --t--e--s--t     
      OUTPUT
  end
  it "renders the stretched string with max fill = 1" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      max_fill: 1).should eq <<-OUTPUT
                          H-e-l-l-o                     
                 T-h-i-s- -i-s- -a- -t-e-s-t            
      OUTPUT
  end
  it "renders the stretched string with max fill = 1 and fixed prefixes and suffixes" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      max_fill: 1, prefix: "ABC ", suffix: " CBA").should eq <<-OUTPUT
      ABC                 H-e-l-l-o                  CBA
      ABC        T-h-i-s- -i-s- -a- -t-e-s-t         CBA
      OUTPUT
  end
  it "renders the stretched string with max_fill = 0 and fixed prefixes and suffixes" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC ", suffix: " CBA", max_fill: 0).should eq <<-OUTPUT
      ABC                   Hello                    CBA
      ABC               This is a test               CBA
      OUTPUT
  end
  it "renders the stretched string with max_fill = 3 and fixed and long variable prefixes and suffixes" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC{....................} ",
      suffix: " {....................}CBA", max_fill: 3).should eq <<-OUTPUT
      ABC.              H--e--l--l--o               .CBA
      ABC. T--h--i--s-- --i--s-- --a-- --t--e--s--t .CBA
      OUTPUT
  end
  # +------------------------------------------------+
  # 0        1         2         3         4         5
  # 1---5----0----5----0----5----0----5----0----5----+
  #
  it "renders the stretched string with max_fill = 3 and fixed and long variable prefixes only" do
    # it "renders the stretched string with  max_fill = 3\n" +
    #    "\tand fixed and long variable prefixes only" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC{....................} ",
      suffix: "", max_fill: 3).should eq <<-OUTPUT
      ABC......              H--e--l--l--o              
      ABC...... T--h--i--s-- --i--s-- --a-- --t--e--s--t
      OUTPUT
  end
  it "renders the stretched string with max_fill = 3 and fixed and long variable suffixes only" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-', prefix: "",
      suffix: " {....................}CBA", max_fill: 3).should eq <<-OUTPUT
                   H--e--l--l--o               ......CBA
      T--h--i--s-- --i--s-- --a-- --t--e--s--t ......CBA
      OUTPUT
  end
  it "renders the stretched string with max_fill = 3 and fixed prefixes and suffixes fill all space" do
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "------------------",
      suffix: "------------------",
      max_fill: 3).should eq <<-OUTPUT
      ------------------    Hello     ------------------
      ------------------This is a test------------------
      OUTPUT
  end
  it "returns unchanged text when constraints connot be met" do
    # In this test, available space for stretching is negative !
    Tablo::Functions.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "A------------------",
      suffix: "------------------",
      max_fill: 3).should eq "Hello\nThis is a test"
  end
  # 1--------------------------------------------------------------------+
  # 0        1         2         3         4         5         6         7
  # 1---5----0----5----0----5----0----5----0----5----0----5----0----5----+
end
