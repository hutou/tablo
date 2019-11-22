require "./spec_helper"

# >>>>> Table without any column
describe "Tablo::Table" do
  t1 = mktable_5i32()
  it "is an Enumerable" do
    t1.should be_a(Enumerable(Tablo::Row))
    t1.responds_to?(:each).should be_true
    t1.responds_to?(:map).should be_true
    t1.responds_to?(:to_a).should be_true
  end
  context "when the table doesn't have any columns" do
    it "#to_s returns an empty string" do
      t1.to_s.should eq("")
    end
  end
  # <<<<< Table without any column
  # >>>>> Table empty
  context "when the table doesn't have any data" do
    t1 = mktable_empty()
    it "#to_s returns an empty string" do
      t1.to_s.should eq("")
    end
  end
  # <<<<< Table empty

  # >>>>> header_frequency parameter
  describe "header_frequency parameter" do
    context "when table is initialized with 'header_frequency = 0'" do
      t2a = add_columns_nd(mktable_5i32(header_frequency: 0))

      it "initializes a table displaying the formatted table with a header" do
        t2a.should be_a(Tablo::Table)
        t2a.to_s.should eq \
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
    context "when table is initialized with 'header_frequency = nil'" do
      t2b = add_columns_nd(mktable_5i32(header_frequency: nil))

      it "initializes a table displaying the formatted table without a header" do
        t2b.to_s.should eq \
          %q(+--------------+--------------+
           |            1 |            2 |
           |            2 |            4 |
           |            3 |            6 |
           |            4 |            8 |
           |            5 |           10 |
           +--------------+--------------+).gsub(/^ +/m, "")
      end
    end
    context "when table is initialized with 'header_frequency > 0'" do
      t2c = add_columns_nd(mktable_5i32(header_frequency: 3))

      it "initializes a table displaying the formatted table with header at start and then " \
         "before every Nth row thereafter" do
        t2c.to_s.should eq \
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
    context "when table is initialized with 'header_frequency < 0'" do
      t2d = add_columns_nd(mktable_5i32(header_frequency: -3))

      it "initializes a table displaying the formatted table with header at start and then " \
         "before every Nth row thereafter, separating blocks" do
        t2d.to_s.should eq \
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
  end
  # <<<<< header_frequency parameter

  # >>>>> wrap_header_cells_to parameter
  describe "wrap_header_cells_to parameter" do
    context "when table is initialized with 'wrap_header_cells_to = nil'" do
      t3a = add_columns_ndn(mktable_5i32(wrap_header_cells_to: nil))
      it "wraps header cell contents as necessary if they exceed the column width" do
        t3a.to_s.should eq \
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
    context "when table is initialized with 'wrap_header_cells_to = N'" do
      context "when N rows are insufficient to accommodate the header content" do
        t3b = add_columns_ndn(mktable_5i32(wrap_header_cells_to: 2))

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "and shows a truncation indicator" do
          t3b.to_s.should eq \
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
      context "when N rows are insufficient to accommodate the header content and 'padding = 0'" do
        t3c = add_columns_ndn(mktable_5i32(wrap_header_cells_to: 2, column_padding: 0))

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "but does not show a truncation indicator" do
          t3c.to_s.should eq \
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
      context "when N rows are insufficient to accommodate the header content and 'padding > 1'" do
        t3d = add_columns_ndn(mktable_5i32(wrap_header_cells_to: 2, column_padding: 2))

        it "truncates header cell contents to N subrows, instead of wrapping them indefinitely, " \
           "and shows a single truncation indicator within the padded content" do
          t3d.to_s.should eq \
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
        t3e = add_columns_ndn(mktable_5i32(wrap_header_cells_to: 3))

        it "does not truncate the header cells and does not show a truncation indicator" do
          t3e.to_s.should eq \
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
        t3f = add_columns_ndn(mktable_5i32(wrap_header_cells_to: 4))

        it "only produces the number of 'subrows' that are necessary to " \
           "accommodate the contents and does not show a truncation indicator" do
          t3f.to_s.should eq \
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
  # <<<<< wrap_header_cells_to parameter

  # >>>>> "wrap_body_cells_to parameter
  describe "wrap_body_cells_to parameter" do
    context "when table is initialized with 'wrap_body_cells_to = nil'" do
      t4a = add_columns_nd(mktable_3i64(wrap_body_cells_to: nil))
      it "wraps cell contents as necessary if they exceed the column width" do
        t4a.to_s.should eq \
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
    context "when table is initialized with 'wrap_body_cells_to = N'" do
      context "when N is insufficient to accommodate the cell content" do
        t4b = add_columns_nd(mktable_3i64(wrap_body_cells_to: 1))

        it "truncates body cell contents to N subrows, instead of wrapping them indefinitely" do
          t4b.to_s.should eq \
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
        t4c = add_columns_nd(mktable_3i64(wrap_body_cells_to: 2))

        it "does not truncate the cell content, and does not show a truncation indicator" do
          t4c.to_s.should eq \
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
        t4d = add_columns_nd(mktable_3i64(wrap_body_cells_to: 3))

        it "does not truncate the cell content, does not show a truncation indicator, and " \
           "produces only just enough subrows to accommodate the content" do
          t4d.to_s.should eq \
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
        t4e = add_columns_nd(mktable_3i64(wrap_body_cells_to: 3, column_padding: 2))

        it "does not truncate the cell content, does not show a truncation indicator, and " \
           "produces only just enough subrows to accommodate the content, with column_padding respected" do
          t4e.to_s.should eq \
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
  # <<<<< wrap_body_cells_to parameter

  # >>>>> column_width parameter
  describe "column_width param" do
    context "if not specified or passed nil" do
      t5a = add_columns_nd(mktable_5i32())
      it "defaults to 12" do
        t5a.to_s.should eq \
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
      t5b = add_columns_nd(mktable_5i32(default_column_width: 9))
      t5b.add_column("even?", width: 5) { |n| n[0].as(Int).even? }
      it "causes all column widths to default to the given Integer, unless overridden for " \
         "particular columns" do
        t5b.to_s.should eq \
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
  # <<<<< column_width parameter

  # >>>>> newlines in header or body
  describe "newlines in headers or body cell contents" do
    context "with unlimited wrapping" do
      it "respects newlines within header and cells and default header alignment" do
        t6a = add_columns_sss(mktable_4string())
        t6a.to_s.should eq \
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
      t6b = add_columns_sss(mktable_4string(wrap_header_cells_to: 2, wrap_body_cells_to: 1))
      it "accounts for newlines within header and cells" do
        t6b.to_s.should eq \
          %q(+---------+--------------+--------------+
           | Firstpa |       length | Lines        |
           | rt     ~|              | in          ~|
           +---------+--------------+--------------+
           | Two    ~|            9 |          Two~|
           |        ~|            8 |             ~|
           | Final  ~|            6 |        Final~|
           | Multipl~|           18 |     Multiple~|
           +---------+--------------+--------------+).gsub(/^ +/m, "")
      end
    end
  end
  # <<<<< newlines in header or body
  #
  # >>>>> Connectors and styles
  describe "Connectors and styles" do
    context "When invalid length connectors string)" do
      it "raises an error if invalid connectors string (Must 15 chars long)" do
        expect_raises(Tablo::ParamException) do
          Tablo.validate_connectors("A" * 10)
          Tablo.validate_connectors("A" * 20)
          Tablo.validate_connectors("")
        end
      end
    end
    context "When full style (=tl,ml,bl,lc,mc,rc)" do
      t7a = add_columns_nd(mktable_5i32(connectors: "ABCDEFGHIJKLMNO"))
      it "correctly format top horizontal line" do
        t7a.horizontal_rule(Tablo::TLine::Top).should eq "AMMMMMMMMMMMMMMBMMMMMMMMMMMMMMC"
      end
      it "correctly format middle horizontal line" do
        t7a.horizontal_rule(Tablo::TLine::Mid).should eq "DNNNNNNNNNNNNNNENNNNNNNNNNNNNNF"
      end
      it "correctly format bottom horizontal line" do
        t7a.horizontal_rule(Tablo::TLine::Bot).should eq "GOOOOOOOOOOOOOOHOOOOOOOOOOOOOOI"
      end
    end
    context "When user defined style (=tl,ml,bl -> no vertical separators)" do
      t7b = add_columns_nd(mktable_5i32(connectors: "ABCDEFGHIJKLMNO", style: "tl,ml,bl"))
      it "correctly format top horizontal line" do
        t7b.horizontal_rule(Tablo::TLine::Top).should eq "MMMMMMMMMMMMMMMMMMMMMMMMMMMM"
      end
      it "correctly format middle horizontal line" do
        t7b.horizontal_rule(Tablo::TLine::Mid).should eq "NNNNNNNNNNNNNNNNNNNNNNNNNNNN"
      end
      it "correctly format bottom horizontal line" do
        t7b.horizontal_rule(Tablo::TLine::Bot).should eq "OOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      end
    end
    context "When user defined style (=ml,lc,rc)" do
      t7c = add_columns_nd(mktable_5i32(style: "ml,lc,rc"))
      it "correctly display only requested vertical or horizontal rules" do
        t7c.to_s.should eq \
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
  # <<<<< Tablo specifics : connectors and styles

  # >>>>> Truncation indicator parameter
  describe "truncation_indicator parameter = char type (nil or string not allowed)" do
    t8a = add_columns_nd2(mktable_2i64(wrap_header_cells_to: 1, wrap_body_cells_to: 1, truncation_indicator: '*'))

    it "causes the character used for indicating that a cell's content has been truncated, to be that character" do
      t8a.to_s.should eq \
        %q(+--------------+--------------+
         |            N | AAAAAAAAAAAA*|
         +--------------+--------------+
         | 400000000000*| 800000000000*|
         | 400000000000*| 800000000000*|
         +--------------+--------------+).gsub(/^ +/m, "")
    end
  end
  # <<<<< Truncation indicator parameter

  # >>>>> Column padding parameter
  describe "column_padding parameter" do
    context "by default" do
      t9a = add_columns_nd(mktable_5i32())
      it "determines the amount of padding on either side of each column to be 1" do
        t9a.to_s.should eq \
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
      t9b = add_columns_nd(mktable_5i32(column_padding: 2))
      it "determines the amount of padding on either side of each column to be that number" do
        t9b.to_s.should eq \
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
      t9c = add_columns_nd(mktable_5i32(column_padding: 0))
      it "causes there to be no padding on either side of each column" do
        t9c.to_s.should eq \
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

  # >>>>> #add_column²
  describe "#add_column" do
    context "check add column method" do
      t10a = add_columns_nd(mktable_5i32())
      it "adds to the table's columns" do
        cnt = t10a.column_registry.size
        t10a.add_column("even?") { |n| n[0].as(Int32).even? }
        t10a.column_registry.size.should eq(cnt + 1)
      end
    end

    context "header parameter" do
      t10b = add_columns_nd(mktable_5i32())
      t10b.add_column("even?", header: "Armadillo") { |n| n[0].as(Int).even? }
      it "sets the column header, independently of the `label` argument" do
        ###
        # ## HT Commennt : Under Crystal, keeping both label and header seems
        # ## pointless, as the to_proc method does not exists !
        ###
        t10b.to_s.should eq \
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

    # >>>>> column alignment
    describe "column alignment" do
      t11a = add_columns_nse(mktable_5i32(default_column_width: 8))
      it "by default, aligns text left, booleans center and numbers right, with header aligned accordingly" do
        t11a.to_s.should eq \
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

      t11b = add_columns_nse(mktable_5i32(default_column_width: 8, default_header_alignment: Tablo::Justify::Center))
      it "by default, aligns text left, booleans center and numbers right, with header aligned accordingly, unless default_header_alignment is set" do
        t11b.to_s.should eq \
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
          t11c = add_columns_ndsef(mktable_5i32(default_column_width: 8, default_header_alignment: Tablo::Justify::Center))
          t11c.to_s.should eq \
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
    # <<<<< column alignment

    # >>>>> width parameter
    describe "`width` param" do
      it "fixes the column width at the passed value (not including padding), overriding the default column width for the table" do
        t12a = add_columns_ndt(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
        t12a.to_s.should eq \
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
    # <<<<< width parameter

    # >>>>> formatter parameter
    describe "`formatter` param" do
      it "formats the cell value for display, without changing the underlying cell value or its default alignment" do
        t13a = add_columns_ndf(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
        t13a.to_s.should eq \
          %q(+--------------+--------------+--------------+
         |       N      |    Double    |    Triple    |
         +--------------+--------------+--------------+
         |            1 |            2 |         3.00 |
         |            2 |            4 |         6.00 |
         |            3 |            6 |         9.00 |
         |            4 |            8 |        12.00 |
         |            5 |           10 |        15.00 |
         +--------------+--------------+--------------+).gsub(/^ +/m, "")
        top_right_body_cell = t13a.first.to_a.last
        top_right_body_cell.should eq(3)
        top_right_body_cell.should be_a(Int32)
      end
    end
    # <<<<< formatter parameter

    # >>>>> extractor parameter
    describe "'extractor' parameter is mandatory and must be provided as a block" do
      t14a = add_columns_5n(mktable_5i32(default_header_alignment: Tablo::Justify::Center))

      it "accepts a block, extract value from an array of CellType and \
      optionaly do some processing on extracted data" do
        t14a.to_s.should eq \
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
    # <<<<< extractor parameter

    # >>>>> Column label not unique
    context "when the column label is not unique (even if one was passed \
  a String and the other a Symbol)" do
      t15a = add_columns_nd(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
      it "raises Tablo::InvalidColumnLabelError" do
        expect_raises(Tablo::InvalidColumnLabelError) do
          t15a.add_column("Double") { |n| n[0].as(Number) * 2 }
        end
      end
    end
    # <<<<< Column label not unique

    # >>>>> Column label not unique, but different case
    context "when column label differs from that of an existing column only in regards to case" do
      t16a = add_columns_nd(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
      t16a.add_column("DoublE") { |n| n[0].as(Number) * 2 }
      it "does not raise an exception" do
        t16a.should be_a(Tablo::Table)
      end
    end
    # <<<<< Column label not unique, but different case
  end
  # <<<<< #add_column

  # >>>>> Row iteration
  describe "#each (Row iteration)" do
    t17a = add_columns_nd(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
    it "iterates once for each row of the table's source data" do
      i = 0
      t17a.each do |row|
        i += 1
      end
      i.should eq(5)
    end

    it "iterates over instances of Tablo::Row" do
      t17a.each do |row|
        row.should be_a(Tablo::Row)
      end
    end
  end
  # <<<<< Row iteration

  # >>>>> formatted header
  describe "#formatted_header" do
    t18a = add_columns_nd(mktable_5i32(default_header_alignment: Tablo::Justify::Center))
    it "returns a string representing a header row for the table" do
      t18a.formatted_header.should eq("|       N      |    Double    |")
    end
  end
  # <<<<< formatted header

  # >>>>> horizontal rule
  describe "#horizontal_rule" do
    t19a = add_columns_nd(mktable_5i32())
    it "returns a horizontal line made up of the horizontal rule character, and appropriately placed " \
       "corner characters, of an appropriate width for the table" do
      t19a.horizontal_rule(Tablo::TLine::Top).should eq("+--------------+--------------+")
    end
  end
  # <<<<< horizontal rule

  # >>>>> shrinkwrap
  describe "#shrinkwrap" do
    # ------------------------------------
    context "Before shrinkwrap" do
      t20a = add_columns_7m(mktable_5i32(default_header_alignment: Tablo::Justify::Center, default_column_width: 8))
      it "format the table with given or default column width" do
        t20a.to_s.should eq \
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
      t21a = add_columns_7m(mktable_5i32(default_header_alignment: Tablo::Justify::Center, default_column_width: 8))
      sources041 = [[1], [2], [3], [4], [5]]
      it "expands or contracts the column widths of the table as necessary so that they just " \
         "accommodate their header and formatted body contents without wrapping (assuming " \
         "source data is constant), except insofar as is required to honour newlines within " \
         "the cell content" do
        t21a.shrinkwrap!
        t21a.to_s.should eq \
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
      end

      t22a = add_columns_7m(mktable_5i32(default_header_alignment: Tablo::Justify::Center, default_column_width: 8))
      it "honors the maximum table width passed to shrinkwrap!" do
        t22a.shrinkwrap!(50)
        t22a.to_s.should eq \
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

      t23a = add_columns_7m(mktable_5i32(default_header_alignment: Tablo::Justify::Center, default_column_width: 8))
      it "returns the Table itself" do
        t23a.shrinkwrap!(max_table_width: [nil, 54, 47].sample).to_s.should eq(t23a.to_s)
      end
    end

    context "shrinkwrap! with padding > 1" do
      t24a = add_columns_7m(mktable_5i32(default_header_alignment: Tablo::Justify::Center, default_column_width: 8, column_padding: 2))
      it "honors the maximum table width passed to shrinkwrap!, including padding > 1" do
        t24a.shrinkwrap!(70)
        t24a.to_s.should eq \
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
      end
    end
  end
  # <<<<< shrinkwrap

  # >>>>> formatted body row
  describe "#formatted_body_row" do
    context "when passed `with_header: true`" do
      describe "header_frequency parameter" do
        context "when table is initialized with `header_frequency` == 0`" do
          t25a = add_columns_nd(mktable_5i32(header_frequency: 0, default_header_alignment: Tablo::Justify::Center))
          it "returns a string representing a row in the body of the table, with a header" do
            t25a.formatted_body_row(Tablo.cast([3]), with_header: true, index: 2).should eq \
              %q(+--------------+--------------+
             |       N      |    Double    |
             +--------------+--------------+
             |            3 |            6 |).gsub(/^ +/m, "")
          end
        end

        context "when passed `with_header: false" do
          t26a = add_columns_nd(mktable_5i32(header_frequency: 0, default_header_alignment: Tablo::Justify::Center))
          it "returns a string representing a row in the body of the table, without a header" do
            t26a.formatted_body_row(Tablo.cast([3]),
              with_header: false, index: 2).should eq \
              %q(|            3 |            6 |)
          end
        end
      end
    end
  end
  # <<<<< formatted body row

  # Spec.after_suite {
  #  # t11b = addcol_test(mktable_5i32_2col())
  #  puts ""
  #  # puts columns_test(mktable_5i32_2col())
  #  # t11b = mktable_5i32_2col(); columns_test(t11b)
  #  t11b = columns_test(mktable_5i32_2col())
  #  puts t11b
  # }
  # <<<<< #add_column²
  exit

  ###########################################
  # ############ OLD SPECS ###################
  ###########################################

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
end
