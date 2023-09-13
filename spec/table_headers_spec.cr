require "./spec_helper"

# For these specs, border_type if BorderName::Fancy, to better see
# border transitions between rows

# test_data definitions
#
# record Person, name : String, age : Int32

# class Numbers
#   include Enumerable(Int32)

#   def each(&)
#     yield 1
#     yield 7
#     yield 10
#     yield 13
#     yield 42
#     yield 43
#     yield 59
#     yield 66
#   end
# end

test_data_numbers = Numbers.new
# test_data_array_3_int32 = [1, 2, 3]
# test_data_array_10_int32 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# test_data_hash_string_int32 = {"A" => 1, "B" => 2, "C" => 3}

# test_data_range_int32 = 1..3

# test_data_struct_person = [] of Person
# test_data_struct_person << Person.new("Albert", 76)
# test_data_struct_person << Person.new("Karl", 61)
# test_data_struct_person << Person.new("Joseph", 56)

describe "#{Tablo::Table} -> Title and headers variations on initialization, " +
         "based on Numbers class" do
  describe "#initialize with 'header_frequency' = nil" do
    context "with only column header, no group, no title" do
      it "displays the table without any header" do
        table = Tablo::Table.new(Numbers.new,
          border_type: Tablo::BorderName::Fancy,
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q( ╭──────────────┬──────────────╮
              │            1 :     false    │
              │            7 :     false    │
              │           10 :     true     │
              │           13 :     false    │
              │           42 :     true     │
              │           43 :     false    │
              │           59 :     false    │
              │           66 :     true     │
              ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column header and table title" do
      it "displays the table without any header or title" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭──────────────┬──────────────╮
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column header and table title and subtitle" do
      it "displays the table without any header, title or subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭──────────────┬──────────────╮
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column header, title, subtitle and footer" do
      it "displays the table without any header, title, subtitle or footer" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          subtitle: Tablo::SubTitle.new("table subtitle", frame: Tablo::Frame.new),
          footer: Tablo::Footer.new("Table footer", frame: Tablo::Frame.new),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭──────────────┬──────────────╮
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
  end
  describe "#initialize with 'header_frequency' = 0" do
    context "with only column headers, no group, no title" do
      it "displays the table with column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and title" do
      it "displays the table with column headers and title attached" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          # all Heading <booleans> default are false
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭─────────────────────────────╮
             │         Table title         │
             ├──────────────┬──────────────┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column header, title and subtitle" do
      it "displays the table with headers, and un_framed title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          "          Table title          " + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title *framed* and subtitle" do
      it "displays the table with headers, title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭─────────────────────────────╮
             │         Table title         │
             ╰─────────────────────────────╯).gsub(/^ */m, "") + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title *framed* and subtitle and footer" do
      it "displays the table with headers, title, subtitle and footer" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          footer: Tablo::Footer.new("Table footer"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭─────────────────────────────╮
             │         Table title         │
             ╰─────────────────────────────╯).gsub(/^ */m, "") + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "") + "\n" +
          "          Table footer         "
      end
    end
  end
  describe "#initialize with 'header_frequency' > 0 (=3)" do
    context "with only column headers, no group, no title" do
      it "displays the table with column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ├--------------┼--------------┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ├--------------┼--------------┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title" do
      it "displays the table with title and repeated column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          "          Table title          " + "\n" +
          %q(╭──────────────┬──────────────╮
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ├--------------┼--------------┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ├--------------┼--------------┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with group, column headers and table title" do
      it "displays the table with title and repeated group and column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          "          Table title          " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title and subtitle" do
      it "displays the table with headers, title but no subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title"),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        # puts "\n#{table}"
        table.to_s.should eq \
          "          Table title          " + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title *framed* and subtitle" do
      it "displays the table with headers, title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭─────────────────────────────╮
             │         Table title         │
             ╰─────────────────────────────╯).gsub(/^ */m, "") + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "")
      end
    end
    context "with column headers and table title *framed* and subtitle and footer" do
      it "displays the table with headers, title, subtitle and footer" do
        table = Tablo::Table.new(test_data_numbers,
          border_type: Tablo::BorderName::Fancy,
          title: Tablo::Title.new("Table title", frame: Tablo::Frame.new),
          subtitle: Tablo::SubTitle.new("table subtitle"),
          footer: Tablo::Footer.new("Table footer"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        # puts "\n#{table}"
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq \
          %q(╭─────────────────────────────╮
             │         Table title         │
             ╰─────────────────────────────╯).gsub(/^ */m, "") + "\n" +
          "         table subtitle        " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │            1 :     false    │
             │            7 :     false    │
             │           10 :     true     │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "") + "\n" +
          "          Table footer         " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           13 :     false    │
             │           42 :     true     │
             │           43 :     false    │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "") + "\n" +
          "          Table footer         " + "\n" +
          %q(╭─────────────────────────────╮
             │            Group            │
             ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
             │       itself :     even?    │
             ├--------------┼--------------┤
             │           59 :     false    │
             │           66 :     true     │
             │              :              │
             ╰──────────────┴──────────────╯).gsub(/^ */m, "") + "\n" +
          "          Table footer         "
      end
    end
  end
end
