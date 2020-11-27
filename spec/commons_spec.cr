require "./spec_helper"

describe Tablo do
  describe "Data validation" do
    it "correctly converts a 2D array of some scalar types to DataType" do
      Tablo.validate([[1]]).should be_a(Tablo::DataType)
      Tablo.validate([['1', 2, "Three"], ['4', 5, "Six"]]).should be_a(Tablo::DataType)
    end

    it "raises an error if not a 2d array" do
      expect_raises(Tablo::DataException) do
        Tablo.validate(1).should be_a(Tablo::DataType)
        Tablo.validate([1, 2, 3]).should be_a(Tablo::DataType)
        Tablo.validate([[[1, 2, 3]]]).should be_a(Tablo::DataType)
      end
    end

    it "raises an error if unsupported scalar type" do
      expect_raises(Tablo::DataException) do
        Tablo.validate([[1, 2, 3, nil, 5]]).should be_a(Tablo::DataType)
      end
    end

    it "raises an error if mixed types in columns" do
      expect_raises(Tablo::DataException) do
        Tablo.validate([[1, 2, 3], [4, 5, "six"]]).should be_a(Tablo::DataType)
      end
    end

    it "raises an error if rows of different sizes" do
      expect_raises(Tablo::DataException) do
        Tablo.validate([[1, 2, 3], [4, 5]]).should be_a(Tablo::DataType)
      end
    end
  end

  describe "Borders and connectors" do
    it "correctly returns the proper cross or corner connector from line and column values" do
      Tablo.connector("abcdefghijklmno", Tablo::TLine::Mid, Tablo::TColumn::Right).should eq('f')
    end
    it "correctly returns the proper line connector from horizontal line value" do
      Tablo.connector("abcdefghijklmno", Tablo::TLine::Mid).should eq('n')
    end
    it "correctly returns the proper line connector from vertical line value" do
      Tablo.connector("abcdefghijklmno", Tablo::TColumn::Right).should eq('l')
    end
  end

  # def fpjust(data : Array(Array(Tablo::CellType?)), col, nbdec, mode)
  describe "FP align method" do
    it "correctly format FP adjust - mode = nil" do
      tdata = [[0.0000.as(Tablo::CellType)],
               [0.02000.as(Tablo::CellType)],
               [17.0.as(Tablo::CellType)],
               [1234.5678.as(Tablo::CellType)],
      ]
      Tablo.fpjust(tdata, 0, 4, nil).to_s.should eq(%([["   0.0000"], ["   0.0200"], ["  17.0000"], ["1234.5678"]]))
    end
    it "correctly format FP adjust - mode 0" do
      tdata = [[0.0000.as(Tablo::CellType)],
               [0.02000.as(Tablo::CellType)],
               [17.0.as(Tablo::CellType)],
               [1234.5678.as(Tablo::CellType)],
      ]
      Tablo.fpjust(tdata, 0, 4, 0).to_s.should eq(%([["   0.    "], ["   0.02  "], ["  17.    "], ["1234.5678"]]))
    end
    it "correctly format FP adjust - mode 1" do
      tdata = [[0.0000.as(Tablo::CellType)],
               [0.02000.as(Tablo::CellType)],
               [17.0.as(Tablo::CellType)],
               [1234.5678.as(Tablo::CellType)],
      ]
      Tablo.fpjust(tdata, 0, 2, 1).to_s.should eq(%([["   0   "], ["   0.02"], ["  17   "], ["1234.57"]]))
    end
    it "correctly format FP adjust - mode 2" do
      tdata = [[0.0000.as(Tablo::CellType)],
               [0.02000.as(Tablo::CellType)],
               [17.0.as(Tablo::CellType)],
               [1234.5678.as(Tablo::CellType)],
      ]
      Tablo.fpjust(tdata, 0, 2, 2).to_s.should eq(%([["       "], ["   0.02"], ["  17   "], ["1234.57"]]))
    end
    it "correctly format FP adjust - mode 3" do
      tdata = [[0.0000.as(Tablo::CellType)],
               [0.02000.as(Tablo::CellType)],
               [17.0.as(Tablo::CellType)],
               [1234.5678.as(Tablo::CellType)],
      ]
      Tablo.fpjust(tdata, 0, 2, 3).to_s.should eq(%([["   0.0 "], ["   0.02"], ["  17.0 "], ["1234.57"]]))
    end
  end
end
