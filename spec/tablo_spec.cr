require "./spec_helper"

describe "Tablo.align_on_dot" do
  context "Using a value of 0.0 and 3 decimals" do
    it "returns a correct result with AlignOnDot::Blank" do
      Tablo.align_on_dot(0.0, 3, :blank).should eq("    ")
    end
    it "returns a correct result with AlignOnDot::NoDot" do
      Tablo.align_on_dot(0.0, 3, :no_dot).should eq("0    ")
    end
    it "returns a correct result with AlignOnDot::DotOnly" do
      Tablo.align_on_dot(0.0, 3, :dot_only).should eq("0.   ")
    end
    it "returns a correct result with AlignOnDot::DotZero" do
      Tablo.align_on_dot(0.0, 3, :dot_zero).should eq("0.0  ")
    end
  end
  context "Using a value of 3.14 and 3 decimals" do
    it "returns a correct result with AlignOnDot::Blank" do
      Tablo.align_on_dot(3.14, 3, :blank).should eq("3.14 ")
    end
    it "returns a correct result with AlignOnDot::NoDot" do
      Tablo.align_on_dot(3.14, 3, :no_dot).should eq("3.14 ")
    end
    it "returns a correct result with AlignOnDot::DotOnly" do
      Tablo.align_on_dot(3.14, 3, :dot_only).should eq("3.14 ")
    end
    it "returns a correct result with AlignOnDot::DotZero" do
      Tablo.align_on_dot(3.14, 3, :dot_zero).should eq("3.14 ")
    end
  end
  context "Using a value of 2.1 and 3 decimals" do
    it "returns a correct result with AlignOnDot::Blank" do
      Tablo.align_on_dot(2.1, 3, :blank).should eq("2.1  ")
    end
    it "returns a correct result with AlignOnDot::NoDot" do
      Tablo.align_on_dot(2.1, 3, :no_dot).should eq("2.1  ")
    end
    it "returns a correct result with AlignOnDot::DotOnly" do
      Tablo.align_on_dot(2.1, 3, :dot_only).should eq("2.1  ")
    end
    it "returns a correct result with AlignOnDot::DotZero" do
      Tablo.align_on_dot(2.1, 3, :dot_zero).should eq("2.1  ")
    end
  end

  context "Using a value of 123.0 and 3 decimals" do
    it "returns a correct result with AlignOnDot::Blank" do
      Tablo.align_on_dot(123.0, 3, :blank).should eq("123    ")
    end
    it "returns a correct result with AlignOnDot::NoDot" do
      Tablo.align_on_dot(123.0, 3, :no_dot).should eq("123    ")
    end
    it "returns a correct result with AlignOnDot::DotOnly" do
      Tablo.align_on_dot(123.0, 3, :dot_only).should eq("123.   ")
    end
    it "returns a correct result with AlignOnDot::DotZero" do
      Tablo.align_on_dot(123.0, 3, :dot_zero).should eq("123.0  ")
    end
  end
end

describe "Tablo.stretch" do
  it "correctly renders the stretched string with default parameters" do
    Tablo.stretch("Hello\nThis is a test", 50).should eq <<-EOS
                        H  e  l  l  o                   
           T  h  i  s     i  s     a     t  e  s  t     
      EOS
  end
  it "correctly renders the stretched string with a fill char" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-').should eq <<-EOS
                        H--e--l--l--o                   
           T--h--i--s-- --i--s-- --a-- --t--e--s--t     
      EOS
  end
  it "correctly renders the stretched string with a max fill" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      max_fill: 1).should eq <<-EOS
                          H-e-l-l-o                     
                 T-h-i-s- -i-s- -a- -t-e-s-t            
      EOS
  end
  it "correctly renders the stretched string with a max fill " +
     "and fixed prefixes and suffixes" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      max_fill: 1, prefix: "ABC ", suffix: " CBA").should eq <<-EOS
      ABC                 H-e-l-l-o                  CBA
      ABC        T-h-i-s- -i-s- -a- -t-e-s-t         CBA
      EOS
  end
  it "correctly renders the stretched string with a max fill " +
     "and fixed prefixes and suffixes, wifth mac_fill = 0" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC ", suffix: " CBA", max_fill: 0).should eq <<-EOS
      ABC                   Hello                    CBA
      ABC               This is a test               CBA
      EOS
  end
  it "correctly renders the stretched string with  max_fill = 3\n" +
     "\tand fixed and long variable prefixes and suffixes" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC{....................} ",
      suffix: " {....................}CBA", max_fill: 3).should eq <<-EOS
      ABC.              H--e--l--l--o               .CBA
      ABC. T--h--i--s-- --i--s-- --a-- --t--e--s--t .CBA
      EOS
  end
  # +------------------------------------------------+
  # 0        1         2         3         4         5
  # 1---5----0----5----0----5----0----5----0----5----+
  #
  it "correctly renders the stretched string with  max_fill = 3\n" +
     "\tand fixed and long variable prefixes only" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "ABC{....................} ",
      suffix: "", max_fill: 3).should eq <<-EOS
      ABC......              H--e--l--l--o              
      ABC...... T--h--i--s-- --i--s-- --a-- --t--e--s--t
      EOS
  end
  it "correctly renders the stretched string with  max_fill = 3\n" +
     "\tand fixed and long variable suffixes only" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-', prefix: "",
      suffix: " {....................}CBA", max_fill: 3).should eq <<-EOS
                   H--e--l--l--o               ......CBA
      T--h--i--s-- --i--s-- --a-- --t--e--s--t ......CBA
      EOS
  end
  it "correctly renders the stretched string with  max_fill = 3\n" +
     "\tand fixed prefixes suffixes fill all space" do
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "------------------",
      suffix: "------------------",
      max_fill: 3).should eq <<-EOS
      ------------------    Hello     ------------------
      ------------------This is a test------------------
      EOS
  end
  it "correctly returns unchanged text when constraints connot be met" do
    # In this test, available space for stretching is negative !
    Tablo.stretch("Hello\nThis is a test", 50, fill_char: '-',
      prefix: "A------------------",
      suffix: "------------------",
      max_fill: 3).should eq "Hello\nThis is a test"
  end
  # 1--------------------------------------------------------------------+
  # 0        1         2         3         4         5         6         7
  # 1---5----0----5----0----5----0----5----0----5----0----5----0----5----+
end
