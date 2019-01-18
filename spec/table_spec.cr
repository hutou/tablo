require "./spec_helper"

describe Tablo::Table do
  sources = [[1], [2], [3], [4], [5]]
  table = Tablo::Table.new(sources) do |t|
    t.add_column("N") { |n| n[0].as(Int32) }
    t.add_column("Double") { |n| n[0].as(Int32) * 2 }
  end

  it "is an Enumerable" do
    table.should be_a(Enumerable(Tablo::Row))
    table.responds_to?(:each).should be_true
    table.responds_to?(:map).should be_true
    table.responds_to?(:to_a).should be_true
  end

  describe "header_frequency parameter" do
    context "when table is initialized with `header_frequency` == 0`" do
      table = Tablo::Table.new(sources, header_frequency: 0) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "initializes a table displaying the formatted table with a header" do
        table.should be_a(Tablo::Table)
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when table is initialized with header_frequency: nil" do
      table = Tablo::Table.new(sources, header_frequency: nil) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "initializes a table displaying the formatted table without a header" do
        table.should be_a(Tablo::Table)
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when table is initialized with header_frequency: n > 0" do
      table = Tablo::Table.new(sources, header_frequency: 3) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "initializes a table displaying the formatted table with header at start and then " \
         "before every Nth row thereafter" do
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               +--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when table is initialized with header_frequency: n < 0" do
      table = Tablo::Table.new(sources, header_frequency: -3) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "initializes a table displaying the formatted table with header at start and then " \
         "before every Nth row thereafter" do
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               +--------------+--------------+
               +--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when the table doesn't have any columns" do
      it "#to_s returns an empty string" do
        table = Tablo::Table.new(sources)
        table.to_s.should eq("")
      end
    end
  end

  describe "wrap_header_cells_to parameter" do
    table = Tablo::Table.new(sources, wrap_header_cells_to: nil) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      t.add_column("N" * 26) { |n| n[0] }
    end

    context "when table is initialized with wrap_header_cells_to: nil" do
      it "wraps header cell contents as necessary if they exceed the column width" do
        table.to_s.should eq \
          %q(+--------------+--------------+--------------+
               |            N |       Double | NNNNNNNNNNNN |
               |              |              | NNNNNNNNNNNN |
               |              |              |           NN |
               +--------------+--------------+--------------+
               |            1 |            2 |            1 |
               |            2 |            4 |            2 |
               |            3 |            6 |            3 |
               |            4 |            8 |            4 |
               |            5 |           10 |            5 |
               +--------------+--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when table is initialized with wrap_header_cells_to: <N>" do
      context "when N rows are insufficient to accommodate the header content" do
        table = Tablo::Table.new(sources, wrap_header_cells_to: 2) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("N" * 26) { |n| n[0] }
        end

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "and shows a truncation indicator" do
          table.to_s.should eq \
            %q(+--------------+--------------+--------------+
                 |            N |       Double | NNNNNNNNNNNN |
                 |              |              | NNNNNNNNNNNN~|
                 +--------------+--------------+--------------+
                 |            1 |            2 |            1 |
                 |            2 |            4 |            2 |
                 |            3 |            6 |            3 |
                 |            4 |            8 |            4 |
                 |            5 |           10 |            5 |
                 +--------------+--------------+--------------+).gsub(/^ +/m, "")
        end
      end

      context "when N rows are insufficient to accommodate the header content and padding is 0" do
        table = Tablo::Table.new(sources, wrap_header_cells_to: 2, column_padding: 0) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("N" * 26) { |n| n[0] }
        end

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "but does not show a truncation indicator" do
          table.to_s.should eq \
            %q(+------------+------------+------------+
                |           N|      Double|NNNNNNNNNNNN|
                |            |            |NNNNNNNNNNNN|
                +------------+------------+------------+
                |           1|           2|           1|
                |           2|           4|           2|
                |           3|           6|           3|
                |           4|           8|           4|
                |           5|          10|           5|
                +------------+------------+------------+).gsub(/^ +/m, "")
        end
      end

      context "when N rows are insufficient to accommodate the header content and padding > 1" do
        table = Tablo::Table.new(sources, wrap_header_cells_to: 2, column_padding: 2) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("N" * 26) { |n| n[0] }
        end

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "and shows a single truncation indicator within the padded content" do
          table.to_s.should eq \
            %q(+----------------+----------------+----------------+
                 |             N  |        Double  |  NNNNNNNNNNNN  |
                 |                |                |  NNNNNNNNNNNN~ |
                 +----------------+----------------+----------------+
                 |             1  |             2  |             1  |
                 |             2  |             4  |             2  |
                 |             3  |             6  |             3  |
                 |             4  |             8  |             4  |
                 |             5  |            10  |             5  |
                 +----------------+----------------+----------------+).gsub(/^ +/m, "")
        end
      end

      context "when N rows are just sufficient to accommodate the header content" do
        table = Tablo::Table.new(sources, wrap_header_cells_to: 3) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("N" * 26) { |n| n[0] }
        end

        it "does not truncate the header cells and does not show a truncation indicator" do
          table.to_s.should eq \
            %q(+--------------+--------------+--------------+
                 |            N |       Double | NNNNNNNNNNNN |
                 |              |              | NNNNNNNNNNNN |
                 |              |              |           NN |
                 +--------------+--------------+--------------+
                 |            1 |            2 |            1 |
                 |            2 |            4 |            2 |
                 |            3 |            6 |            3 |
                 |            4 |            8 |            4 |
                 |            5 |           10 |            5 |
                 +--------------+--------------+--------------+).gsub(/^ +/m, "")
        end
      end

      context "when N rows are more than sufficient to accommodate the header content" do
        table = Tablo::Table.new(sources, wrap_header_cells_to: 4) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("N" * 26) { |n| n[0] }
        end

        it "only produces the number of 'subrows' that are necessary to accommodate the contents and does not show a truncation indicator" do
          table.to_s.should eq \
            %q(+--------------+--------------+--------------+
                 |            N |       Double | NNNNNNNNNNNN |
                 |              |              | NNNNNNNNNNNN |
                 |              |              |           NN |
                 +--------------+--------------+--------------+
                 |            1 |            2 |            1 |
                 |            2 |            4 |            2 |
                 |            3 |            6 |            3 |
                 |            4 |            8 |            4 |
                 |            5 |           10 |            5 |
                 +--------------+--------------+--------------+).gsub(/^ +/m, "")
        end
      end
    end
  end

  describe "wrap_body_cells_to parameter" do
    table = Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]], wrap_body_cells_to: nil) do |t|
      t.add_column("N") { |n| n[0].as(Int64) }
      t.add_column("Double") { |n| n[0].as(Int64) * 2 }
    end

    context "when table is initialized with wrap_body_cells_to: nil" do
      it "wraps cell contents as necessary if they exceed the column width" do
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               | 500000000000 | 100000000000 |
               |              |            0 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when table is initialized with wrap_body_cells_to: <N>" do
      context "when N is insufficient to accommodate the cell content" do
        table = Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]], wrap_body_cells_to: 1) do |t|
          t.add_column("N") { |n| n[0].as(Int64) }
          t.add_column("Double") { |n| n[0].as(Int64) * 2 }
        end

        it "truncates body cell contents to N subrows, instead of wrapping them indefinitely" do
          table.to_s.should eq \
            %q(+--------------+--------------+
                 |            N |       Double |
                 +--------------+--------------+
                 |            1 |            2 |
                 |            2 |            4 |
                 | 500000000000 | 100000000000~|
                 +--------------+--------------+).gsub(/^ +/m, "")
        end
      end

      context "when N is just sufficient to accommodate the cell content" do
        table = Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]], wrap_body_cells_to: 2) do |t|
          t.add_column("N") { |n| n[0].as(Int64) }
          t.add_column("Double") { |n| n[0].as(Int64) * 2 }
        end

        it "does not truncate the cell content, and does not show a truncation indicator" do
          table.to_s.should eq \
            %q(+--------------+--------------+
                 |            N |       Double |
                 +--------------+--------------+
                 |            1 |            2 |
                 |            2 |            4 |
                 | 500000000000 | 100000000000 |
                 |              |            0 |
                 +--------------+--------------+).gsub(/^ +/m, "")
        end
      end

      context "when N is more than sufficient to accommodate the cell content" do
        table = Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]], wrap_body_cells_to: 3) do |t|
          t.add_column("N") { |n| n[0].as(Int64) }
          t.add_column("Double") { |n| n[0].as(Int64) * 2 }
        end

        it "does not truncate the cell content, does not show a truncation indicator, and " \
           "produces only just enough subrows to accommodate the content" do
          table.to_s.should eq \
            %q(+--------------+--------------+
                 |            N |       Double |
                 +--------------+--------------+
                 |            1 |            2 |
                 |            2 |            4 |
                 | 500000000000 | 100000000000 |
                 |              |            0 |
                 +--------------+--------------+).gsub(/^ +/m, "")
        end
      end

      context "when N is more than sufficient to accommodate the cell content," \
              "and column_padding is > 1" do
        table = Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]], wrap_body_cells_to: 3, column_padding: 2) do |t|
          t.add_column("N") { |n| n[0].as(Int64) }
          t.add_column("Double") { |n| n[0].as(Int64) * 2 }
        end

        it "does not truncate the cell content, does not show a truncation indicator, and " \
           "produces only just enough subrows to accommodate the content, with column_padding respected" do
          table.to_s.should eq \
            %q(+----------------+----------------+
                 |             N  |        Double  |
                 +----------------+----------------+
                 |             1  |             2  |
                 |             2  |             4  |
                 |  500000000000  |  100000000000  |
                 |                |             0  |
                 +----------------+----------------+).gsub(/^ +/m, "")
        end
      end
    end
  end

  describe "column_width param" do
    table = Tablo::Table.new(sources) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
    end
    context "if not specified or passed nil" do
      it "defaults to 12" do
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when passed an Integer" do
      table = Tablo::Table.new(sources, default_column_width: 9) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("even?", width: 5) { |n| n[0].as(Int32).even? }
      end
      it "causes all column widths to default to the given Integer, unless overridden for " \
         "particular columns" do
        table.to_s.should eq \
          %q(+-----------+-----------+-------+
               |         N |    Double | even? |
               +-----------+-----------+-------+
               |         1 |         2 | false |
               |         2 |         4 |  true |
               |         3 |         6 | false |
               |         4 |         8 |  true |
               |         5 |        10 | false |
               +-----------+-----------+-------+).gsub(/^ +/m, "")
      end
    end
  end

  describe "when there are newlines in headers or body cell contents" do
    context "with unlimited wrapping" do
      it "respects newlines within header and cells and default header alignment" do
        sources = [["Two\nlines"], ["\nInitial"], ["Final\n"], ["Multiple\nnew\nlines"]]
        table = Tablo::Table.new(sources) do |t|
          t.add_column("Firstpart\nsecondpart", width: 7) { |n| n[0] }
          t.add_column("length") { |n| (n[0].as(String)).size }
          t.add_column("Lines\nin\nheader", align_body: Tablo::Justify::Right) { |n| n[0] }
        end

        table.to_s.should eq \
          %q(+---------+--------------+--------------+
               | Firstpa |       length | Lines        |
               | rt      |              | in           |
               | secondp |              | header       |
               | art     |              |              |
               +---------+--------------+--------------+
               | Two     |            9 |          Two |
               | lines   |              |        lines |
               |         |            8 |              |
               | Initial |              |      Initial |
               | Final   |            6 |        Final |
               |         |              |              |
               | Multipl |           18 |     Multiple |
               | e       |              |          new |
               | new     |              |        lines |
               | lines   |              |              |
               +---------+--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "with truncation" do
      it "accounts for newlines within header and cells" do
        sources = [["Two\nlines"], ["\nInitial"], ["Final\n"], ["Multiple\nnew\nlines"]]
        table = Tablo::Table.new(sources, wrap_header_cells_to: 2, wrap_body_cells_to: 1) do |t|
          t.add_column("itself") { |n| n[0] }
          t.add_column("length") { |n| n[0].as(String).size }
          t.add_column("Lines\nin\nheader", align_body: Tablo::Justify::Right) { |n| n[0] }
        end
        table.to_s.should eq \
          %q(+--------------+--------------+--------------+
               | itself       |       length | Lines        |
               |              |              | in          ~|
               +--------------+--------------+--------------+
               | Two         ~|            9 |          Two~|
               |             ~|            8 |             ~|
               | Final       ~|            6 |        Final~|
               | Multiple    ~|           18 |     Multiple~|
               +--------------+--------------+--------------+).gsub(/^ +/m, "")
      end
    end
  end

  describe "Tablo specifics : connectors and styles" do
    context "With invalid length connectors string)" do
      it "raises an error if invalid connectors string (Must 15 chars long)" do
        expect_raises(Tablo::ParamException) do
          Tablo.validate_connectors("A" * 10)
          Tablo.validate_connectors("A" * 20)
          Tablo.validate_connectors("")
        end
      end
    end
    context "With full style (=tl,ml,bl,lc,mc,rc)" do
      table = Tablo::Table.new((1..5).to_a.map { |n| [n] }, connectors: "ABCDEFGHIJKLMNO") do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end
      it "correctly format top horizontal line" do
        table.horizontal_rule(Tablo::TLine::Top).should eq "AMMMMMMMMMMMMMMBMMMMMMMMMMMMMMC"
      end
      it "correctly format middle horizontal line" do
        table.horizontal_rule(Tablo::TLine::Mid).should eq "DNNNNNNNNNNNNNNENNNNNNNNNNNNNNF"
      end
      it "correctly format bottom horizontal line" do
        table.horizontal_rule(Tablo::TLine::Bot).should eq "GOOOOOOOOOOOOOOHOOOOOOOOOOOOOOI"
      end
    end
    context "With special style (=tl,ml,bl) -> no vertical separators" do
      table = Tablo::Table.new((1..5).to_a.map { |n| [n] },
        connectors: "ABCDEFGHIJKLMNO", style: "tl,ml,bl") do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end
      it "correctly format top horizontal line" do
        table.horizontal_rule(Tablo::TLine::Top).should eq "MMMMMMMMMMMMMMMMMMMMMMMMMMMM"
      end
      it "correctly format middle horizontal line" do
        table.horizontal_rule(Tablo::TLine::Mid).should eq "NNNNNNNNNNNNNNNNNNNNNNNNNNNN"
      end
      it "correctly format bottom horizontal line" do
        table.horizontal_rule(Tablo::TLine::Bot).should eq "OOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      end
    end
    context "With special style (=ml,lc,rc)" do
      table = Tablo::Table.new((1..5).to_a.map { |n| [n] },
        style: "ml, lc, rc") do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end
      it "correctly display only requested vertical or horizontal rules" do
        table.to_s.should eq \
          %q(|            N        Double |
               +----------------------------+
               |            1             2 |
               |            2             4 |
               |            3             6 |
               |            4             8 |
               |            5            10 |).gsub(/^ +/m, "")
      end
    end
  end

  describe "truncation_indicator parameter - char type, nil or string not allowed" do
    context "when passed nil" do
      sources = [[400000000000000000], [400000000000000001]]
      table = Tablo::Table.new(sources, wrap_header_cells_to: 1,
        wrap_body_cells_to: 1,
        truncation_indicator: '*') do |t|
        t.add_column("N") { |n| n[0] }
        t.add_column("AAAAAAAAAAAAAAAAAAAA") { |n| n[0].as(Int64) * 2 }
      end

      it "causes the character used for indicating that a cell's content has been truncated, to be that character" do
        table.to_s.should eq \
          %q(+--------------+--------------+
                     |            N | AAAAAAAAAAAA*|
                     +--------------+--------------+
                     | 400000000000*| 800000000000*|
                     | 400000000000*| 800000000000*|
                     +--------------+--------------+).gsub(/^ +/m, "")
      end
    end
  end

  describe "column_padding parameter" do
    sources = [[1], [2], [3], [4], [5]]
    context "by default" do
      table = Tablo::Table.new(sources) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end
      it "determines the amount of padding on either side of each column to be 1" do
        table.to_s.should eq \
          %q(+--------------+--------------+
               |            N |       Double |
               +--------------+--------------+
               |            1 |            2 |
               |            2 |            4 |
               |            3 |            6 |
               |            4 |            8 |
               |            5 |           10 |
               +--------------+--------------+).gsub(/^ +/m, "")
      end
    end

    context "when passed a number greater than 1" do
      table = Tablo::Table.new(sources, column_padding: 2) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "determines the amount of padding on either side of each column to be that number" do
        table.to_s.should eq \
          %q(+----------------+----------------+
               |             N  |        Double  |
               +----------------+----------------+
               |             1  |             2  |
               |             2  |             4  |
               |             3  |             6  |
               |             4  |             8  |
               |             5  |            10  |
               +----------------+----------------+).gsub(/^ +/m, "")
      end
    end

    context "when passed 0" do
      table = Tablo::Table.new(sources, column_padding: 0) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      end

      it "causes there to be no padding on either side of each column" do
        table.to_s.should eq \
          %q(+------------+------------+
               |           N|      Double|
               +------------+------------+
               |           1|           2|
               |           2|           4|
               |           3|           6|
               |           4|           8|
               |           5|          10|
               +------------+------------+).gsub(/^ +/m, "")
      end
    end
  end

  describe "#add_column" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
    end
    it "adds to the table's columns" do
      cnt = table.column_registry.size
      table.add_column("even?") { |n| n[0].as(Int32).even? }
      table.column_registry.size.should eq(cnt + 1)
    end

    describe "header parameter" do
      sources = [[1], [2], [3], [4], [5]]
      table = Tablo::Table.new(sources) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("even?", header: "Armadillo") { |n| n[0].as(Int32).even? }
      end
      it "sets the column header, independently of the `label` argument" do
        ###
        # ## HT Commennt : Under Crystal, keeping both label and header seems
        # ## pointless, as the to_proc method does not exists !
        ###
        table.to_s.should eq \
          %q(+--------------+--------------+--------------+
           |            N |       Double |   Armadillo  |
           +--------------+--------------+--------------+
           |            1 |            2 |     false    |
           |            2 |            4 |     true     |
           |            3 |            6 |     false    |
           |            4 |            8 |     true     |
           |            5 |           10 |     false    |
           +--------------+--------------+--------------+).gsub(/^ +/m, "")
      end
    end
  end
  describe "column alignment" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources, default_column_width: 8) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("N_to_s") { |n| n[0].as(Int32).to_s }
      t.add_column("even?") { |n| n[0].as(Int32).even? }
    end

    it "by default, aligns text left, booleans center and numbers right, with header aligned accordingly" do
      table.to_s.should eq \
        %q(+----------+----------+----------+
             |        N | N_to_s   |   even?  |
             +----------+----------+----------+
             |        1 | 1        |   false  |
             |        2 | 2        |   true   |
             |        3 | 3        |   false  |
             |        4 | 4        |   true   |
             |        5 | 5        |   false  |
             +----------+----------+----------+).gsub(/^ +/m, "")
    end
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources, default_column_width: 8,
      default_header_alignment: Tablo::Justify::Center) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("N_to_s") { |n| n[0].as(Int32).to_s }
      t.add_column("even?") { |n| n[0].as(Int32).even? }
    end
    it "by default, aligns text left, booleans center and numbers right, with header aligned accordingly, unless default_header_alignment is set" do
      table.to_s.should eq \
        %q(+----------+----------+----------+
             |     N    |  N_to_s  |   even?  |
             +----------+----------+----------+
             |        1 | 1        |   false  |
             |        2 | 2        |   true   |
             |        3 | 3        |   false  |
             |        4 | 4        |   true   |
             |        5 | 5        |   false  |
             +----------+----------+----------+).gsub(/^ +/m, "")
    end

    context "when align_header and align_body are passed left, center or right" do
      it "aligns header and body accordingly, overriding the default alignments" do
        sources = [[1], [2], [3], [4], [5]]
        table = Tablo::Table.new(sources, default_column_width: 8,
          default_header_alignment: Tablo::Justify::Center) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("to_s", align_header: Tablo::Justify::Left, align_body: Tablo::Justify::Center) { |n| n[0].as(Int32).to_s }
          t.add_column("even?", align_header: Tablo::Justify::Left, align_body: Tablo::Justify::Right) { |n| n[0].as(Int32).even? }
          t.add_column("to_f", align_header: Tablo::Justify::Right, align_body: Tablo::Justify::Left) { |n| n[0].as(Int32).to_f }
        end
        table.to_s.should eq \
          %q(+----------+----------+----------+----------+----------+
                |     N    |  Double  | to_s     | even?    |     to_f |
                +----------+----------+----------+----------+----------+
                |        1 |        2 |     1    |    false | 1.0      |
                |        2 |        4 |     2    |     true | 2.0      |
                |        3 |        6 |     3    |    false | 3.0      |
                |        4 |        8 |     4    |     true | 4.0      |
                |        5 |       10 |     5    |    false | 5.0      |
                +----------+----------+----------+----------+----------+).gsub(/^ +/m, "")
      end
    end
  end
  describe "`width` param" do
    it "fixes the column width at the passed value (not including padding), overriding the default column width for the table" do
      sources = [[1], [2], [3], [4], [5]]
      table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("Triple", width: 16) { |n| n[0].as(Int32) * 3 }
      end
      table.to_s.should eq \
        %q(+--------------+--------------+------------------+
             |       N      |    Double    |      Triple      |
             +--------------+--------------+------------------+
             |            1 |            2 |                3 |
             |            2 |            4 |                6 |
             |            3 |            6 |                9 |
             |            4 |            8 |               12 |
             |            5 |           10 |               15 |
             +--------------+--------------+------------------+).gsub(/^ +/m, "")
    end
  end
  describe "`formatter` param" do
    it "formats the cell value for display, without changing the underlying cell value or its default alignment" do
      sources = [[1], [2], [3], [4], [5]]
      table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("Triple", formatter: ->(val : Tablo::CellType) { "%.2f" % val }) { |n| n[0].as(Int32) * 3 }
      end
      table.to_s.should eq \
        %q(+--------------+--------------+--------------+
             |       N      |    Double    |    Triple    |
             +--------------+--------------+--------------+
             |            1 |            2 |         3.00 |
             |            2 |            4 |         6.00 |
             |            3 |            6 |         9.00 |
             |            4 |            8 |        12.00 |
             |            5 |           10 |        15.00 |
             +--------------+--------------+--------------+).gsub(/^ +/m, "")
      top_right_body_cell = table.first.to_a.last
      top_right_body_cell.should eq(3)
      top_right_body_cell.should be_a(Int32)
    end
  end

  describe "`extractor` parameter is mandatory and must be provided as a block" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("x 2") { |n| n[0].as(Int32) * 2 }
      t.add_column("x 3") { |n| n[0].as(Int32) * 3 }
      t.add_column("x 4") { |n| n[0].as(Int32) * 4 }
      t.add_column("x 5") { |n| n[0].as(Int32) * 5 }
    end

    it "accepts a block, extract value from an array of CellType and \
      optionaly do some processing on extracted data" do
      table.to_s.should eq \
        %q(+--------------+--------------+--------------+--------------+--------------+
               |       N      |      x 2     |      x 3     |      x 4     |      x 5     |
               +--------------+--------------+--------------+--------------+--------------+
               |            1 |            2 |            3 |            4 |            5 |
               |            2 |            4 |            6 |            8 |           10 |
               |            3 |            6 |            9 |           12 |           15 |
               |            4 |            8 |           12 |           16 |           20 |
               |            5 |           10 |           15 |           20 |           25 |
               +--------------+--------------+--------------+--------------+--------------+).gsub(/^ +/m, "")
    end
  end
  context "when the column label is not unique (even if one was passed \
  a String and the other a Symbol)" do
    it "raises Tablo::InvalidColumnLabelError" do
      expect_raises(Tablo::InvalidColumnLabelError) do
        sources = [[1], [2], [3], [4], [5]]
        table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
          t.add_column("N") { |n| n[0].as(Int32) }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        end
      end
    end
  end

  context "when column label differs from that of an existing column only in regards to case" do
    it "does not raise an exception" do
      sources = [[1], [2], [3], [4], [5]]
      table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
        t.add_column("N") { |n| n[0].as(Int32) }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("DoublE") { |n| n[0].as(Int32) * 2 }
      end
      table.should be_a(Tablo::Table)
    end
  end

  describe "#each" do
    it "iterates once for each row of the table's source data" do
      i = 0
      table.each do |row|
        i += 1
      end
      i.should eq(5)
    end

    it "iterates over instances of Tablo::Row" do
      table.each do |row|
        row.should be_a(Tablo::Row)
      end
    end
  end
  ###
  describe "#formatted_header" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
    end
    it "returns a string representing a header row for the table" do
      table.formatted_header.should eq("|       N      |    Double    |")
    end
  end

  describe "#horizontal_rule" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources) do |t|
      t.add_column("N") { |n| n[0].as(Int32) }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
    end
    it "returns a horizontal line made up of the horizontal rule character, and appropriately placed \
       corner characters, of an appropriate width for the table" do
      table.horizontal_rule(Tablo::TLine::Top).should eq("+--------------+--------------+")
    end
  end

  describe "#shrinkwrap" do
    sources = [[1], [2], [3], [4], [5]]
    table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center, default_column_width: 8) do |t|
      t.add_column("N") { |n| n[0] }
      t.add_column("Double") { |n| n[0].as(Int32) * 2 }
      t.add_column("to_s") { |n| n[0].as(Int32).to_s }
      t.add_column("Is it\neven?") { |n| n[0].as(Int32).even? }
      t.add_column("dec", formatter: ->(n : Tablo::CellType) { "%.#{n}f" % n }) { |n| n[0].as(Int32) }
      t.add_column("word\nyep", width: 5) { |n| "w" * n[0].as(Int32) * 2 }
      t.add_column("cool") { |n| n[0].as(Int32) == 3 ? "two\nlines" : "" }
    end
    context "Before shrinkwrap" do
      it "format the table with given or default column width" do
        table.to_s.should eq \
          %q(+----------+----------+----------+----------+----------+-------+----------+
             |     N    |  Double  |   to_s   |   Is it  |    dec   |  word |   cool   |
             |          |          |          |   even?  |          |  yep  |          |
             +----------+----------+----------+----------+----------+-------+----------+
             |        1 |        2 | 1        |   false  |      1.0 | ww    |          |
             |        2 |        4 | 2        |   true   |     2.00 | wwww  |          |
             |        3 |        6 | 3        |   false  |    3.000 | wwwww | two      |
             |          |          |          |          |          | w     | lines    |
             |        4 |        8 | 4        |   true   |   4.0000 | wwwww |          |
             |          |          |          |          |          | www   |          |
             |        5 |       10 | 5        |   false  |  5.00000 | wwwww |          |
             |          |          |          |          |          | wwwww |          |
             +----------+----------+----------+----------+----------+-------+----------+).gsub(/^ +/m, "")
      end
    end
    context "After shrinkwrap" do
      it "expands or contracts the column widths of the table as necessary so that they just " \
         "accommodate their header and formatted body contents without wrapping (assuming " \
         "source data is constant), except insofar as is required to honour newlines within " \
         "the cell content" do
        table.shrinkwrap!
        table.to_s.should eq \
          %q(+---+--------+------+-------+---------+------------+-------+
             | N | Double | to_s | Is it |   dec   |    word    |  cool |
             |   |        |      | even? |         |     yep    |       |
             +---+--------+------+-------+---------+------------+-------+
             | 1 |      2 | 1    | false |     1.0 | ww         |       |
             | 2 |      4 | 2    |  true |    2.00 | wwww       |       |
             | 3 |      6 | 3    | false |   3.000 | wwwwww     | two   |
             |   |        |      |       |         |            | lines |
             | 4 |      8 | 4    |  true |  4.0000 | wwwwwwww   |       |
             | 5 |     10 | 5    | false | 5.00000 | wwwwwwwwww |       |
             +---+--------+------+-------+---------+------------+-------+).gsub(/^ +/m, "")
        it "honors the maximum table width passed to shrinkwrap!" do
          table.shrinkwrap!(50)
          table.to_s.should eq \
            %q(+---+-------+------+-------+-------+------+------+
            | N | Doubl | to_s | Is it |  dec  | word | cool |
            |   |   e   |      | even? |       |  yep |      |
            +---+-------+------+-------+-------+------+------+
            | 1 |     2 | 1    | false |   1.0 | ww   |      |
            | 2 |     4 | 2    |  true |  2.00 | wwww |      |
            | 3 |     6 | 3    | false | 3.000 | wwww | two  |
            |   |       |      |       |       | ww   | line |
            |   |       |      |       |       |      | s    |
            | 4 |     8 | 4    |  true | 4.000 | wwww |      |
            |   |       |      |       |     0 | wwww |      |
            | 5 |    10 | 5    | false | 5.000 | wwww |      |
            |   |       |      |       |    00 | wwww |      |
            |   |       |      |       |       | ww   |      |
            +---+-------+------+-------+-------+------+------+).gsub(/^ +/m, "")
        end
      end
      it "returns the Table itself" do
        table.shrinkwrap!(max_table_width: [nil, 54, 47].sample).to_s.should eq(table.to_s)
      end
    end
    context "shrinkwrap! with padding > 1" do
      table = Tablo::Table.new(sources, default_header_alignment: Tablo::Justify::Center,
        default_column_width: 8, column_padding: 2) do |t|
        t.add_column("N") { |n| n[0] }
        t.add_column("Double") { |n| n[0].as(Int32) * 2 }
        t.add_column("to_s") { |n| n[0].as(Int32).to_s }
        t.add_column("Is it\neven?") { |n| n[0].as(Int32).even? }
        t.add_column("dec", formatter: ->(n : Tablo::CellType) { "%.#{n}f" % n }) { |n| n[0].as(Int32) }
        t.add_column("word\nyep", width: 5) { |n| "w" * n[0].as(Int32) * 2 }
        t.add_column("cool") { |n| n[0].as(Int32) == 3 ? "two\nlines" : "" }
      end
      it "honors the maximum table width passed to shrinkwrap!, including
        padding > 1" do
        # puts "\n", table
        # puts "table.width=#{table.horizontal_rule(Tablo::TLine::Mid).size}"
        table.shrinkwrap!(70)
        table.to_s.should eq \
          %q(+-----+----------+--------+---------+-----------+----------+---------+
            |  N  |  Double  |  to_s  |  Is it  |    dec    |   word   |   cool  |
            |     |          |        |  even?  |           |    yep   |         |
            +-----+----------+--------+---------+-----------+----------+---------+
            |  1  |       2  |  1     |  false  |      1.0  |  ww      |         |
            |  2  |       4  |  2     |   true  |     2.00  |  wwww    |         |
            |  3  |       6  |  3     |  false  |    3.000  |  wwwwww  |  two    |
            |     |          |        |         |           |          |  lines  |
            |  4  |       8  |  4     |   true  |   4.0000  |  wwwwww  |         |
            |     |          |        |         |           |  ww      |         |
            |  5  |      10  |  5     |  false  |  5.00000  |  wwwwww  |         |
            |     |          |        |         |           |  wwww    |         |
            +-----+----------+--------+---------+-----------+----------+---------+).gsub(/^ +/m, "")

        # puts "\n", table
        # puts "table.width=#{table.horizontal_rule(Tablo::TLine::Mid).size}"
      end
    end
  end
  describe "#formatted_body_row" do
    context "when passed `with_header: true`" do
      describe "header_frequency parameter" do
        context "when table is initialized with `header_frequency` == 0`" do
          sources = [[1], [2], [3], [4], [5]]
          table = Tablo::Table.new(sources, header_frequency: 0,
            default_header_alignment: Tablo::Justify::Center) do |t|
            t.add_column("N") { |n| n[0].as(Int32) }
            t.add_column("Double") { |n| n[0].as(Int32) * 2 }
          end

          it "returns a string representing a row in the body of the table, with a header" do
            table.formatted_body_row(Tablo.cast(sources[2]), with_header: true, index: 2).should eq \
              %q(+--------------+--------------+
             |       N      |    Double    |
             +--------------+--------------+
             |            3 |            6 |).gsub(/^ +/m, "")
          end
        end

        context "when passed `with_header: false" do
          it "returns a string representing a row in the body of the table, without a header" do
            table.formatted_body_row(Tablo.cast(sources[2]),
              with_header: false, index: 2).should eq \
              %q(|            3 |            6 |)
          end
        end
      end
    end
  end
end # End of Table_spec
# ##  describe "#shrinkwrap" do
# ##    let(:column_width) { 8 }
###
# ##    before(:each) do
# ##      table.add_column(:to_s)
# ##      table.add_column("Is it\neven?") { |n| n.even? }
# ##      table.add_column("dec", formatter: -> (n) { "%.#{n}f" % n }) { |n| n }
# ##      table.add_column("word\nyep", width: 5) { |n| "w" * n * 2 }
# ##      table.add_column("cool") { |n| "two\nlines" if n == 3 }
# ##    end
###
# ##    it "returns the Table itself" do
# ##      expect(table.shrinkwrap!(max_table_width: [nil, 64, 47].sample)).to eq(table)
# ##    end
###
# ##    context "when `max_table_width` is not provided" do
# ##      it "expands or contracts the column widths of the table as necessary so that they just "\
# ##        "accommodate their header and formatted body contents without wrapping (assuming "\
# ##        "source data is constant), except insofar as is required to honour newlines within "\
# ##        "the cell content", :aggregate_failures do
###
# ##        # Check that it adjusts column widths by shrinking
# ##        expect { table.shrinkwrap! }.to change(table, :to_s).from(
# ##          %q(+----------+----------+----------+----------+----------+-------+----------+
# ##             |     N    |   Double |   to_s   |   Is it  |    dec   |  word |   cool   |
# ##             |          |          |          |   even?  |          |  yep  |          |
# ##             +----------+----------+----------+----------+----------+-------+----------+
# ##             |        1 |        2 | 1        |   false  |      1.0 | ww    |          |
# ##             |        2 |        4 | 2        |   true   |     2.00 | wwww  |          |
# ##             |        3 |        6 | 3        |   false  |    3.000 | wwwww | two      |
# ##             |          |          |          |          |          | w     | lines    |
# ##             |        4 |        8 | 4        |   true   |   4.0000 | wwwww |          |
# ##             |          |          |          |          |          | www   |          |
# ##             |        5 |       10 | 5        |   false  |  5.00000 | wwwww |          |
# ##             |          |          |          |          |          | wwwww |          |).gsub(/^ +/, "")
###
# ##        ).to(
# ##          %q(+---+---------+------+-------+---------+------------+-------+
# ##             | N | Doubled | to_s | Is it |   dec   |    word    |  cool |
# ##             |   |         |      | even? |         |     yep    |       |
# ##             +---+---------+------+-------+---------+------------+-------+
# ##             | 1 |       2 | 1    | false |     1.0 | ww         |       |
# ##             | 2 |       4 | 2    |  true |    2.00 | wwww       |       |
# ##             | 3 |       6 | 3    | false |   3.000 | wwwwww     | two   |
# ##             |   |         |      |       |         |            | lines |
# ##             | 4 |       8 | 4    |  true |  4.0000 | wwwwwwww   |       |
# ##             | 5 |      10 | 5    | false | 5.00000 | wwwwwwwwww |       |).gsub(/^ +/, "")
# ##        )
###
# ##        # Let's do a quick check to make sure that it will also expand the total table width if required.
# ##        small_table = Tabulo::Table.new(%w(hello goodbye), column_width: 3) do |t|
# ##          t.add_column(:itself) { |s| s }
# ##        end
# ##        expect { small_table.shrinkwrap! }.to change(small_table, :to_s).from(
# ##          %q(+-----+
# ##             | its |
# ##             | elf |
# ##             +-----+
# ##             | hel |
# ##             | lo  |
# ##             | goo |
# ##             | dby |
# ##             | e   |).gsub(/^ +/, "")
# ##        ).to(
# ##          %q(+---------+
# ##             |  itself |
# ##             +---------+
# ##             | hello   |
# ##             | goodbye |).gsub(/^ +/, "")
# ##        )
# ##      end
# ##    end
###
# ##    context "when `max_table_width` is not provided" do
# ##      context "when column_padding is > 1" do
# ##        let(:column_padding) { 2 }
###
# ##        it "expands or contracts the column widths of the table as necessary so that they just "\
# ##          "accommodate their header and formatted body contents without wrapping (assuming "\
# ##          "source data is constant), inclusive of additional padding, except insofar as is "\
# ##          "required to honour newlines within the cell content" do
###
# ##          # Check that it adjusts column widths by shrinking
# ##          expect { table.shrinkwrap! }.to change(table, :to_s).to(
# ##            %q(+-----+-----------+--------+---------+-----------+--------------+---------+
# ##               |  N  |  Doubled  |  to_s  |  Is it  |    dec    |     word     |   cool  |
# ##               |     |           |        |  even?  |           |      yep     |         |
# ##               +-----+-----------+--------+---------+-----------+--------------+---------+
# ##               |  1  |        2  |  1     |  false  |      1.0  |  ww          |         |
# ##               |  2  |        4  |  2     |   true  |     2.00  |  wwww        |         |
# ##               |  3  |        6  |  3     |  false  |    3.000  |  wwwwww      |  two    |
# ##               |     |           |        |         |           |              |  lines  |
# ##               |  4  |        8  |  4     |   true  |   4.0000  |  wwwwwwww    |         |
# ##               |  5  |       10  |  5     |  false  |  5.00000  |  wwwwwwwwww  |         |).gsub(/^ +/, "")
# ##          )
# ##        end
# ##      end
# ##    end
###
# ##    context "when `max_table_width` is provided (assuming source data is constant)" do
# ##      context "when `max_table_width` is wider than the existing table width" do
# ##        it "amends the column widths of the table so that they just accommodate their header and "\
# ##          "formatted body contents without wrapping (assuming source data is constant), except "\
# ##          "insofar as is required to honour newlines within the cell content " do
###
# ##          expect { table.shrinkwrap!(max_table_width: 64) }.to change(table, :to_s).from(
# ##            %q(+----------+----------+----------+----------+----------+-------+----------+
# ##               |     N    |  Doubled |   to_s   |   Is it  |    dec   |  word |   cool   |
# ##               |          |          |          |   even?  |          |  yep  |          |
# ##               +----------+----------+----------+----------+----------+-------+----------+
# ##               |        1 |        2 | 1        |   false  |      1.0 | ww    |          |
# ##               |        2 |        4 | 2        |   true   |     2.00 | wwww  |          |
# ##               |        3 |        6 | 3        |   false  |    3.000 | wwwww | two      |
# ##               |          |          |          |          |          | w     | lines    |
# ##               |        4 |        8 | 4        |   true   |   4.0000 | wwwww |          |
# ##               |          |          |          |          |          | www   |          |
# ##               |        5 |       10 | 5        |   false  |  5.00000 | wwwww |          |
# ##               |          |          |          |          |          | wwwww |          |).gsub(/^ +/, "")
###
# ##          ).to(
# ##            %q(+---+---------+------+-------+---------+------------+-------+
# ##               | N | Doubled | to_s | Is it |   dec   |    word    |  cool |
# ##               |   |         |      | even? |         |     yep    |       |
# ##               +---+---------+------+-------+---------+------------+-------+
# ##               | 1 |       2 | 1    | false |     1.0 | ww         |       |
# ##               | 2 |       4 | 2    |  true |    2.00 | wwww       |       |
# ##               | 3 |       6 | 3    | false |   3.000 | wwwwww     | two   |
# ##               |   |         |      |       |         |            | lines |
# ##               | 4 |       8 | 4    |  true |  4.0000 | wwwwwwww   |       |
# ##               | 5 |      10 | 5    | false | 5.00000 | wwwwwwwwww |       |).gsub(/^ +/, "")
###
# ##          )
# ##        end
# ##      end
###
# ##      context "when `max_table_width` is too narrow to accommodate the shrinkwrapped columns" do
# ##        it "amends the column widths of the table so that they just accommodate their header and "\
# ##          "formatted body contents (assuming source data is constant) (except insofar as it required "\
# ##          "to honour newlines within existing cell content), except that width is progressively "\
# ##          "removed from the widest column until the table fits the passed width" do
###
# ##          expect { table.shrinkwrap!(max_table_width: 55) }.to change(table, :to_s).from(
# ##            %q(+----------+----------+----------+----------+----------+-------+----------+
# ##               |     N    |  Doubled |   to_s   |   Is it  |    dec   |  word |   cool   |
# ##               |          |          |          |   even?  |          |  yep  |          |
# ##               +----------+----------+----------+----------+----------+-------+----------+
# ##               |        1 |        2 | 1        |   false  |      1.0 | ww    |          |
# ##               |        2 |        4 | 2        |   true   |     2.00 | wwww  |          |
# ##               |        3 |        6 | 3        |   false  |    3.000 | wwwww | two      |
# ##               |          |          |          |          |          | w     | lines    |
# ##               |        4 |        8 | 4        |   true   |   4.0000 | wwwww |          |
# ##               |          |          |          |          |          | www   |          |
# ##               |        5 |       10 | 5        |   false  |  5.00000 | wwwww |          |
# ##               |          |          |          |          |          | wwwww |          |).gsub(/^ +/, "")
# ##          ).to(
# ##            %q(+---+--------+------+-------+--------+--------+-------+
# ##               | N | Double | to_s | Is it |   dec  |  word  |  cool |
# ##               |   |    d   |      | even? |        |   yep  |       |
# ##               +---+--------+------+-------+--------+--------+-------+
# ##               | 1 |      2 | 1    | false |    1.0 | ww     |       |
# ##               | 2 |      4 | 2    |  true |   2.00 | wwww   |       |
# ##               | 3 |      6 | 3    | false |  3.000 | wwwwww | two   |
# ##               |   |        |      |       |        |        | lines |
# ##               | 4 |      8 | 4    |  true | 4.0000 | wwwwww |       |
# ##               |   |        |      |       |        | ww     |       |
# ##               | 5 |     10 | 5    | false | 5.0000 | wwwwww |       |
# ##               |   |        |      |       |      0 | wwww   |       |).gsub(/^ +/, "")
# ##          )
# ##        end
###
# ##        context "when column_padding is > 1" do
# ##          let(:column_padding) { 2 }
###
# ##          it "amends the column widths of the table so that they just accommodate their header and "\
# ##            "formatted body contents (assuming source data is constant) (except insofar as it required "\
# ##            "to honour newlines within existing cell content), including additional padding, except "\
# ##            "that width is progressively removed from the widest column until the table fits the "\
# ##            "passed width" do
###
# ##            expect { table.shrinkwrap!(max_table_width: 69) }.to change(table, :to_s).from(
# ##              %q(+------------+------------+------------+------------+------------+---------+------------+
# ##                 |      N     |   Doubled  |    to_s    |    Is it   |     dec    |   word  |    cool    |
# ##                 |            |            |            |    even?   |            |   yep   |            |
# ##                 +------------+------------+------------+------------+------------+---------+------------+
# ##                 |         1  |         2  |  1         |    false   |       1.0  |  ww     |            |
# ##                 |         2  |         4  |  2         |    true    |      2.00  |  wwww   |            |
# ##                 |         3  |         6  |  3         |    false   |     3.000  |  wwwww  |  two       |
# ##                 |            |            |            |            |            |  w      |  lines     |
# ##                 |         4  |         8  |  4         |    true    |    4.0000  |  wwwww  |            |
# ##                 |            |            |            |            |            |  www    |            |
# ##                 |         5  |        10  |  5         |    false   |   5.00000  |  wwwww  |            |
# ##                 |            |            |            |            |            |  wwwww  |            |).gsub(/^ +/, "")
# ##            ).to(
# ##              %q(+-----+----------+--------+---------+----------+----------+---------+
# ##                 |  N  |  Double  |  to_s  |  Is it  |    dec   |   word   |   cool  |
# ##                 |     |     d    |        |  even?  |          |    yep   |         |
# ##                 +-----+----------+--------+---------+----------+----------+---------+
# ##                 |  1  |       2  |  1     |  false  |     1.0  |  ww      |         |
# ##                 |  2  |       4  |  2     |   true  |    2.00  |  wwww    |         |
# ##                 |  3  |       6  |  3     |  false  |   3.000  |  wwwwww  |  two    |
# ##                 |     |          |        |         |          |          |  lines  |
# ##                 |  4  |       8  |  4     |   true  |  4.0000  |  wwwwww  |         |
# ##                 |     |          |        |         |          |  ww      |         |
# ##                 |  5  |      10  |  5     |  false  |  5.0000  |  wwwwww  |         |
# ##                 |     |          |        |         |       0  |  wwww    |         |).gsub(/^ +/, "")
# ##            )
# ##          end
# ##        end
###
# ##        context "when column_padding is 0" do
# ##          let(:column_padding) { 0 }
###
# ##          it "amends the column widths of the table so that they just accommodate their header and "\
# ##            "formatted body contents (assuming source data is constant) (except insofar as it required "\
# ##            "to honour newlines within existing cell content), with no padding, except "\
# ##            "that width is progressively removed from the widest column until the table fits the "\
# ##            "passed width" do
###
# ##            expect { table.shrinkwrap!(max_table_width: 41) }.to change(table, :to_s).from(
# ##              %q(+--------+--------+--------+--------+--------+-----+--------+
# ##                 |    N   | Doubled|  to_s  |  Is it |   dec  | word|  cool  |
# ##                 |        |        |        |  even? |        | yep |        |
# ##                 +--------+--------+--------+--------+--------+-----+--------+
# ##                 |       1|       2|1       |  false |     1.0|ww   |        |
# ##                 |       2|       4|2       |  true  |    2.00|wwww |        |
# ##                 |       3|       6|3       |  false |   3.000|wwwww|two     |
# ##                 |        |        |        |        |        |w    |lines   |
# ##                 |       4|       8|4       |  true  |  4.0000|wwwww|        |
# ##                 |        |        |        |        |        |www  |        |
# ##                 |       5|      10|5       |  false | 5.00000|wwwww|        |
# ##                 |        |        |        |        |        |wwwww|        |).gsub(/^ +/, "")
# ##            ).to(
# ##              %q(+-+------+----+-----+------+------+-----+
# ##                 |N|Double|to_s|Is it|  dec | word | cool|
# ##                 | |   d  |    |even?|      |  yep |     |
# ##                 +-+------+----+-----+------+------+-----+
# ##                 |1|     2|1   |false|   1.0|ww    |     |
# ##                 |2|     4|2   | true|  2.00|wwww  |     |
# ##                 |3|     6|3   |false| 3.000|wwwwww|two  |
# ##                 | |      |    |     |      |      |lines|
# ##                 |4|     8|4   | true|4.0000|wwwwww|     |
# ##                 | |      |    |     |      |ww    |     |
# ##                 |5|    10|5   |false|5.0000|wwwwww|     |
# ##                 | |      |    |     |     0|wwww  |     |).gsub(/^ +/, "")
# ##            )
# ##          end
# ##        end
# ##      end
###
# ##      context "when `max_table_width` is very small" do
# ##        it "only reduces column widths to the extent that there is at least a character's width "\
# ##          "available in each column for content, plus one character of padding on either side" do
# ##          table = Tabulo::Table.new(%w(hi there)) do |t|
# ##            t.add_column(:itself) { |s| s }
# ##            t.add_column(:length)
# ##          end
# ##          table.shrinkwrap!(max_table_width: 3)
###
# ##          expect(table.to_s).to eq \
# ##            %q(+---+---+
# ##               | i | l |
# ##               | t | e |
# ##               | s | n |
# ##               | e | g |
# ##               | l | t |
# ##               | f | h |
# ##               +---+---+
# ##               | h | 2 |
# ##               | i |   |
# ##               | t | 5 |
# ##               | h |   |
# ##               | e |   |
# ##               | r |   |
# ##               | e |   |).gsub(/^ +/, "")
# ##        end
# ##      end
# ##    end
# ##  end
###
# ##end
