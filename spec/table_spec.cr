require "./spec_helper"

# test_data definitions
#
record Person, name : String, age : Int32

class FloatSamples
  include Enumerable(Float64)

  def each(&)
    yield 0.0
    yield -10.3
    yield 43.606
    yield -909.0302
    yield 1024.0
  end
end

class IntSamples
  include Enumerable(Int32)
  def_clone

  def each(&)
    # yield 0
    yield 1
    yield 7
    yield 10
    yield 13
    yield 42
    yield 43
    yield 59
    yield 66
  end
end

class OddSamples
  include Enumerable(Int32)

  def each(&)
    yield 1
    yield 7
    yield 13
    yield 43
    yield 59
  end
end

test_data_struct_person = [] of Person
test_data_struct_person << Person.new("Albert", 76)
test_data_struct_person << Person.new("Karl", 61)
test_data_struct_person << Person.new("Joseph", 56)
test_data_array_int32 = [1, 2, 3]
test_data_hash_string_int32 = {"A" => 1, "B" => 2, "C" => 3}
test_data_range_int32 = 1..3

# Tablo::Config::Defaults.border_definition = Tablo::Border::PreSet::Fancy
# border = Tablo::Border.new(Tablo::Border::PreSet::Fancy)

describe Tablo::Table do
  context "Initialization with different types of Enumerable" do
    context "#initialize with block given" do
      context "from an Array(Int32)" do
        it "creates a new table from Array(Int32)" do
          table = Tablo::Table.new(test_data_array_int32) do |t|
            t.add_column("itself", &.itself)
          end
          table.should be_a(Tablo::Table(Int32))
        end
      end
      context "from a hash(String, Int32)" do
        it "creates a new table from Hash(String, Int32)" do
          table = Tablo::Table.new(test_data_hash_string_int32) do |t|
            t.add_column("Key") { |(k, v)| k }
            t.add_column("Value") { |(k, v)| v }
          end
          table.should be_a(Tablo::Table(Tuple(String, Int32)))
        end
      end
      context "from a Range(Int32)" do
        it "creates a new table from Range(Int32..Int32)" do
          table = Tablo::Table.new(test_data_range_int32) do |t|
            t.add_column("itself") { |n| n }
          end
          table.should be_a(Tablo::Table(Int32))
        end
      end
      context "from an array of Struct" do
        it "creates a new table from Array(Person)" do
          table = Tablo::Table.new(test_data_struct_person) do |t|
            t.add_column("Row") { |_, row_index| row_index }
            t.add_column("Name", &.name)
            t.add_column("Age", &.age)
          end
          table.should be_a(Tablo::Table(Person))
        end
      end
      context "from a user defined enumerable class" do
        it "creates a new table from OddSamples enumerable class" do
          table = Tablo::Table.new(OddSamples.new) do |t|
            t.add_column("Row") { |_, row_index| row_index }
            t.add_column("Number", &.itself)
          end
          table.should be_a(Tablo::Table(Int32))
        end
      end
    end
    context "#initialize *without* block given" do
      context "from an Array(Int32)" do
        it "creates a new table from Array(Int32)" do
          table = Tablo::Table.new(test_data_array_int32)
          table.add_column("itself", &.itself)
          table.should be_a(Tablo::Table(Int32))
        end
      end
      context "from a hash(String, Int32)" do
        it "creates a new table from Hash(String, Int32)" do
          table = Tablo::Table.new(test_data_hash_string_int32)
          table.add_column("Key") { |(k, v)| k }
          table.add_column("Value") { |(k, v)| v }
          table.should be_a(Tablo::Table(Tuple(String, Int32)))
        end
      end
      context "from a Range(Int32)" do
        it "creates a new table from Range(Int32..Int32)" do
          table = Tablo::Table.new(test_data_range_int32)
          table.add_column("itself") { |n| n }
          table.should be_a(Tablo::Table(Int32))
        end
      end
      context "from an array of Struct" do
        it "creates a new table from Array(Person)" do
          table = Tablo::Table.new(test_data_struct_person)
          table.add_column("Row") { |_, row_index| row_index }
          table.add_column("Name", &.name)
          table.add_column("Age", &.age)
          table.should be_a(Tablo::Table(Person))
        end
      end
      context "from a user defined enumerable class" do
        it "creates a new table from OddSamples enumerable class" do
          table = Tablo::Table.new(OddSamples.new)
          table.add_column("Row") { |_, row_index| row_index }
          table.add_column("Number", &.itself)
          table.should be_a(Tablo::Table(Int32))
        end
      end
    end
  end

  context "Title and headers variations on initialization, " +
          "based on IntSamples class" do
    context "#initialize with 'header_frequency' = nil" do
      context "with only column header, no group, no title" do
        it "displays the table without any header" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            header_frequency: nil) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
            │            1 :     false    │
            │            7 :     false    │
            │           10 :     true     │
            │           13 :     false    │
            │           42 :     true     │
            │           43 :     false    │
            │           59 :     false    │
            │           66 :     true     │
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column header and table title" do
        it "displays the table without any header or title" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            header_frequency: nil) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
            │            1 :     false    │
            │            7 :     false    │
            │           10 :     true     │
            │           13 :     false    │
            │           42 :     true     │
            │           43 :     false    │
            │           59 :     false    │
            │           66 :     true     │
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column header and table title and subtitle" do
        it "displays the table without any header, title or subtitle" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            subtitle: Tablo::Heading.new("table subtitle"),
            header_frequency: nil) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
            │            1 :     false    │
            │            7 :     false    │
            │           10 :     true     │
            │           13 :     false    │
            │           42 :     true     │
            │           43 :     false    │
            │           59 :     false    │
            │           66 :     true     │
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column header, title, subtitle and footer" do
        it "displays the table without any header, title, subtitle or footer" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            subtitle: Tablo::Heading.new("table subtitle", framed: true),
            footer: Tablo::Heading.new("Table footer", framed: true),
            header_frequency: nil) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
            │            1 :     false    │
            │            7 :     false    │
            │           10 :     true     │
            │           13 :     false    │
            │           42 :     true     │
            │           43 :     false    │
            │           59 :     false    │
            │           66 :     true     │
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end
    describe "#initialize with 'header_frequency' = 0" do
      context "with only column headers, no group, no title" do
        it "displays the table with column headers" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and title" do
        it "displays the table with column headers and title attached" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column header, title and subtitle" do
        it "displays the table with headers, and un_framed title and subtitle" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            subtitle: Tablo::Heading.new("table subtitle"),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
                      Table title          
                     table subtitle        
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title *framed* and subtitle" do
        it "displays the table with headers, title and subtitle" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            subtitle: Tablo::Heading.new("table subtitle"),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
            │         Table title         │
            ╰─────────────────────────────╯
                     table subtitle        
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title *framed* and subtitle and footer" do
        it "displays the table with headers, title, subtitle and footer" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            subtitle: Tablo::Heading.new("table subtitle"),
            footer: Tablo::Heading.new("Table footer"),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
            │         Table title         │
            ╰─────────────────────────────╯
                     table subtitle        
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
                      Table footer         
            OUTPUT
          output.should eq expected_output
        end
      end
    end
    describe "#initialize with 'header_frequency' > 0 (=3)" do
      context "with only column headers, no group, no title" do
        it "displays the table with column headers" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title" do
        it "displays the table with title and repeated column headers" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
                      Table title          
            ╭──────────────┬──────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with group, column headers and table title" do
        it "displays the table with title and repeated group and column headers" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
            t.add_group("Group")
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
                      Table title          
            ╭─────────────────────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title and subtitle" do
        it "displays the table with headers, title but no subtitle" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title"),
            subtitle: Tablo::Heading.new("table subtitle"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
            t.add_group("Group")
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
                      Table title          
                     table subtitle        
            ╭─────────────────────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title *framed* and subtitle" do
        it "displays the table with headers, title and subtitle" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            subtitle: Tablo::Heading.new("table subtitle"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
            t.add_group("Group")
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
            │         Table title         │
            ╰─────────────────────────────╯
                     table subtitle        
            ╭─────────────────────────────╮
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
            ╰──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "with column headers and table title *framed* and subtitle and footer" do
        it "displays the table with headers, title, subtitle and footer" do
          table = Tablo::Table.new(IntSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Table title", framed: true),
            subtitle: Tablo::Heading.new("table subtitle"),
            footer: Tablo::Heading.new("Table footer"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("even?", &.even?)
            t.add_group("Group")
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
            │         Table title         │
            ╰─────────────────────────────╯
                     table subtitle        
            ╭─────────────────────────────╮
            │            Group            │
            ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
            │       itself :     even?    │
            ├--------------┼--------------┤
            │            1 :     false    │
            │            7 :     false    │
            │           10 :     true     │
            ╰──────────────┴──────────────╯
                      Table footer         
            ╭─────────────────────────────╮
            │            Group            │
            ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
            │       itself :     even?    │
            ├--------------┼--------------┤
            │           13 :     false    │
            │           42 :     true     │
            │           43 :     false    │
            ╰──────────────┴──────────────╯
                      Table footer         
            ╭─────────────────────────────╮
            │            Group            │
            ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
            │       itself :     even?    │
            ├--------------┼--------------┤
            │           59 :     false    │
            │           66 :     true     │
            │              :              │
            ╰──────────────┴──────────────╯
                      Table footer         
            OUTPUT
          output.should eq expected_output
        end
      end
    end
  end

  subtitle = Tablo::Heading.new("A very simple subtitle", framed: true)
  title = Tablo::Heading.new("This a very long text to be displayed as title heading", framed: true)
  footer = Tablo::Heading.new("Do you need a footer?", framed: true)

  context "Packing method", tags: "pack" do
    context "PackingMode::AutoSized as default" do
      context "call = table.pack" do
        it "adapts columns size to their largest value for header" \
           " and body and adapts headings contents inside" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("medium") { |n| n[1] }
            t.add_group("Short and medium")
            t.add_column("long") { |n| n[2] }
            t.add_group("Long")
          end
          output = table.pack.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────────────────────────────────────╮
            │  This a very long text to be displayed as title  │
            │                      heading                     │
            ├──────────────────────────────────────────────────┤
            │              A very simple subtitle              │
            ├──────────────────────┬───────────────────────────┤
            │   Short and medium   :            Long           │
            ├−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−−−−−−−−−−−−−−┤
            │ short : medium       : long                      │
            ├-------┼--------------┼---------------------------┤
            │ abc   : not so large : Very long column contents │
            ├───────┴──────────────┴───────────────────────────┤
            │               Do you need a footer?              │
            ╰──────────────────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end

      context "call = table.pack(requested total width = 30)" do
        it "After autosizing columns, shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(30).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭────────────────────────────╮
            │  This a very long text to  │
            │    be displayed as title   │
            │           heading          │
            ├────────────────────────────┤
            │   A very simple subtitle   │
            ├───────┬────────────────────┤
            │ short : long               │
            ├-------┼--------------------┤
            │ abc   : Very long column   │
            │       : contents           │
            ├───────┴────────────────────┤
            │    Do you need a footer?   │
            ╰────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end

      context "call = table.pack(requested total width = 60)" do
        it "After autosizing columns, expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(60).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────────────────────────────────────────────╮
            │  This a very long text to be displayed as title heading  │
            ├──────────────────────────────────────────────────────────┤
            │                  A very simple subtitle                  │
            ├────────────────────────────┬─────────────────────────────┤
            │ short                      : long                        │
            ├----------------------------┼-----------------------------┤
            │ abc                        : Very long column contents   │
            ├────────────────────────────┴─────────────────────────────┤
            │                   Do you need a footer?                  │
            ╰──────────────────────────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end
    context "PackingMode::InitialWidths as default" do
      describe "call = table.pack" do
        it "should not do any packing, just reset current column widths " \
           "to their initial value" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
              ╭─────────────────────────────╮
              │   This a very long text to  │
              │    be displayed as title    │
              │           heading           │
              ├─────────────────────────────┤
              │    A very simple subtitle   │
              ├──────────────┬──────────────┤
              │ short        : long         │
              ├--------------┼--------------┤
              │ abc          : Very long    │
              │              : column       │
              │              : contents     │
              ├──────────────┴──────────────┤
              │    Do you need a footer?    │
              ╰─────────────────────────────╯
              OUTPUT
          output.should eq expected_output
        end
      end

      describe "call = table.pack(#{requested_size = 30})" do
        it "resets current column widths to their initial values " \
           "and shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(30, autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭────────────────────────────╮
            │  This a very long text to  │
            │    be displayed as title   │
            │           heading          │
            ├────────────────────────────┤
            │   A very simple subtitle   │
            ├──────────────┬─────────────┤
            │ short        : long        │
            ├--------------┼-------------┤
            │ abc          : Very long   │
            │              : column      │
            │              : contents    │
            ├──────────────┴─────────────┤
            │    Do you need a footer?   │
            ╰────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end

      describe "call = table.pack(60)" do
        it "resets current column widths to their initial values " \
           "and expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(60, autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────────────────────────────────────────────╮
            │  This a very long text to be displayed as title heading  │
            ├──────────────────────────────────────────────────────────┤
            │                  A very simple subtitle                  │
            ├────────────────────────────┬─────────────────────────────┤
            │ short                      : long                        │
            ├----------------------------┼-----------------------------┤
            │ abc                        : Very long column contents   │
            ├────────────────────────────┴─────────────────────────────┤
            │                   Do you need a footer?                  │
            ╰──────────────────────────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end

    context "PackingMode::CurrentWidths as default" do
      describe "call = table.pack" do
        it "should not do anything !" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────╮
            │   This a very long text to  │
            │    be displayed as title    │
            │           heading           │
            ├─────────────────────────────┤
            │    A very simple subtitle   │
            ├──────────────┬──────────────┤
            │ short        : long         │
            ├--------------┼--------------┤
            │ abc          : Very long    │
            │              : column       │
            │              : contents     │
            ├──────────────┴──────────────┤
            │    Do you need a footer?    │
            ╰─────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end

      describe "call = table.pack(30)" do
        it "shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(30, autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭────────────────────────────╮
            │  This a very long text to  │
            │    be displayed as title   │
            │           heading          │
            ├────────────────────────────┤
            │   A very simple subtitle   │
            ├──────────────┬─────────────┤
            │ short        : long        │
            ├--------------┼-------------┤
            │ abc          : Very long   │
            │              : column      │
            │              : contents    │
            ├──────────────┴─────────────┤
            │    Do you need a footer?   │
            ╰────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end

      describe "call = table.pack(60)" do
        it "expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          output = table.pack(60, autosize: false).to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────────────────────────────────────────────╮
            │  This a very long text to be displayed as title heading  │
            ├──────────────────────────────────────────────────────────┤
            │                  A very simple subtitle                  │
            ├────────────────────────────┬─────────────────────────────┤
            │ short                      : long                        │
            ├----------------------------┼-----------------------------┤
            │ abc                        : Very long column contents   │
            ├────────────────────────────┴─────────────────────────────┤
            │                   Do you need a footer?                  │
            ╰──────────────────────────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end

    context "PackingMode::AutoSized as default, excluding column" do
      describe %(call = table.pack(except: "long")) do
        it "correctly adapts columns size to their largest value for header" \
           " and body, except for excluded column \"long\"" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("medium") { |n| n[1] }
            t.add_group("Short and medium")
            t.add_column("long") { |n| n[2] }
            t.add_group("Long")
          end
          output = table.pack(except: "long").to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────────────╮
            │     This a very long text to be     │
            │      displayed as title heading     │
            ├─────────────────────────────────────┤
            │        A very simple subtitle       │
            ├──────────────────────┬──────────────┤
            │   Short and medium   :     Long     │
            ├−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
            │ short : medium       : long         │
            ├-------┼--------------┼--------------┤
            │ abc   : not so large : Very long    │
            │       :              : column       │
            │       :              : contents     │
            ├───────┴──────────────┴──────────────┤
            │        Do you need a footer?        │
            ╰─────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end
    context "PackingMode::AutoSized as default, selecting column" do
      describe %(call = table.pack(only: "long")) do
        it "correctly adapts columns size to their largest value for header" \
           " and body, only for column \"long\"" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: title, subtitle: subtitle,
            footer: footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("medium") { |n| n[1] }
            t.add_group("Short and medium")
            t.add_column("long") { |n| n[2] }
            t.add_group("Long")
          end
          output = table.pack(only: "long").to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────────────────────────────────╮
            │  This a very long text to be displayed as title heading │
            ├─────────────────────────────────────────────────────────┤
            │                  A very simple subtitle                 │
            ├─────────────────────────────┬───────────────────────────┤
            │       Short and medium      :            Long           │
            ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−−−−−−−−−−−−−−┤
            │ short        : medium       : long                      │
            ├--------------┼--------------┼---------------------------┤
            │ abc          : not so large : Very long column contents │
            ├──────────────┴──────────────┴───────────────────────────┤
            │                  Do you need a footer?                  │
            ╰─────────────────────────────────────────────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
    end
  end

  context "Formatting and styling" do
    context "Headings and groups" do
      context "Formatting headings" do
        it "displays the title in upper case" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("my title",
              formatter: ->(c : Tablo::CellType) { c.as(String).upcase })) do |t|
            t.add_column("itself", &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
                MY TITLE    
            ╭──────────────╮
            │       itself │
            ├--------------┤
            │          0.0 │
            │        -10.3 │
            │       43.606 │
            │    -909.0302 │
            │       1024.0 │
            ╰──────────────╯
            OUTPUT
          output.should eq expected_output
        end

        it "stretches the title with  dashes" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("my title",
              formatter: ->(c : Tablo::CellType, column_width : Int32) {
                Tablo::Functions.stretch(c.as(String),
                  target_width: column_width, fill_char: '-', max_fill: 1)
              })) do |t|
            t.add_column("itself", width: 15, &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
              m-y- -t-i-t-l-e  
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          output.should eq expected_output
        end

        it "stretches the footer with spaces" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            footer: Tablo::Heading.new("Footer", framed: true, line_breaks_before: 1,
              formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Functions.stretch(c.as(String),
                target_width: column_width, fill_char: ' ', max_fill: 2) })) do |t|
            t.add_column("itself", width: 16, &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────╮
            │           itself │
            ├------------------┤
            │              0.0 │
            │            -10.3 │
            │           43.606 │
            │        -909.0302 │
            │           1024.0 │
            ╰──────────────────╯
            ╭──────────────────╮
            │ F  o  o  t  e  r │
            ╰──────────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      describe "Styling headings" do
        it "displays the title in blue" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("my title",
              styler: ->(s : String) { s.colorize(:blue).to_s })) do |t|
            t.add_column("itself", width: 15, &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
                  \e[34mmy title\e[0m     
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          else
            expected_output = <<-OUTPUT
                  my title     
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          end
          output.should eq expected_output
        end

        it "displays the (possibly) multiline title in different colors" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("This is a very, very, very long title",
              styler: ->(content : String, line : Int32) {
                case line
                when 0
                  content.colorize(:blue).to_s
                when 1
                  content.colorize(:green).to_s
                else
                  content.colorize(:red).to_s
                end
              })) do |t|
            t.add_column("itself", width: 15, &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
                 \e[34mThis is a\e[0m     
                \e[32mvery, very,\e[0m    
              \e[31mvery long title\e[0m  
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          else
            expected_output = <<-OUTPUT
                 This is a     
                very, very,    
              very long title  
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          end
          output.should eq expected_output
        end
        it "displays the (forced) multiline title in different colors" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Title line 1\nTitle line 2\nTitle line 3",
              styler: ->(content : String, line : Int32) {
                case line
                when 0
                  content.colorize(:blue).to_s
                when 1
                  content.colorize(:green).to_s
                else
                  content.colorize(:red).to_s
                end
              })) do |t|
            t.add_column("itself", width: 15, &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
                \e[34mTitle line 1\e[0m   
                \e[32mTitle line 2\e[0m   
                \e[31mTitle line 3\e[0m   
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          else
            expected_output = <<-OUTPUT
                Title line 1   
                Title line 2   
                Title line 3   
            ╭─────────────────╮
            │          itself │
            ├-----------------┤
            │             0.0 │
            │           -10.3 │
            │          43.606 │
            │       -909.0302 │
            │          1024.0 │
            ╰─────────────────╯
            OUTPUT
          end
          output.should eq expected_output
        end
      end
      context "Formatting groups" do
        it "stretches the group content to its best width with spaces" do
          table = Tablo::Table.new([1, 2, 3],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy)) do |t|
            t.add_column("itself", &.itself)
            t.add_column("double") { |n| n * 2 }
            t.add_group("Numeric",
              formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Functions.stretch(c.as(String),
                target_width: column_width, fill_char: ' ') })
            t.add_column("stringified") { |n| n.to_s * 7 }
            t.add_group("String",
              formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Functions.stretch(c.as(String),
                target_width: column_width, fill_char: ' ') })
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────────────────┬──────────────╮
            │  N   u   m   e   r   i   c  :  S t r i n g │
            ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
            │       itself :       double : stringified  │
            ├--------------┼--------------┼--------------┤
            │            1 :            2 : 1111111      │
            │            2 :            4 : 2222222      │
            │            3 :            6 : 3333333      │
            ╰──────────────┴──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      describe "Styling groups" do
        it "colorize the group content, funny way, character by character" do
          table = Tablo::Table.new([1, 2, 3],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy)) do |t|
            t.add_column("itself", &.itself)
            t.add_column("double") { |n| n * 2 }
            t.add_group("Numeric",
              formatter: ->(c : Tablo::CellType) { Tablo::Functions.stretch(c.as(String), 25,
                fill_char: ' ') },
              styler: ->(s : String) {
                colors = [:blue, :red, :green, :yellow]
                index = 0
                s.chars.map { |c|
                  if c == ' '
                    c
                  elsif ['a', 'e', 'i', 'o', 'u'].includes?(c)
                    index += 1
                    c.colorize(colors[index % 4]).mode(:bright)
                  else
                    index += 1
                    c.colorize(colors[3 - index % 4]).mode(:bold)
                  end
                }.join
              })
            t.add_column("stringified") { |n| n.to_s * 7 }
            t.add_group("String",
              formatter: ->(c : Tablo::CellType) { Tablo::Functions.stretch(c.as(String), 11,
                fill_char: ' ') })
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭─────────────────────────────┬──────────────╮
              │  \e[32;1mN\e[0m   \e[32;1mu\e[0m   \e[34;1mm\e[0m   \e[34;1me\e[0m   \e[32;1mr\e[0m   \e[32;1mi\e[0m   \e[34;1mc\e[0m  :  S t r i n g │
              ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
              │       itself :       double : stringified  │
              ├--------------┼--------------┼--------------┤
              │            1 :            2 : 1111111      │
              │            2 :            4 : 2222222      │
              │            3 :            6 : 3333333      │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭─────────────────────────────┬──────────────╮
              │  N   u   m   e   r   i   c  :  S t r i n g │
              ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
              │       itself :       double : stringified  │
              ├--------------┼--------------┼--------------┤
              │            1 :            2 : 1111111      │
              │            2 :            4 : 2222222      │
              │            3 :            6 : 3333333      │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
      end
    end

    context "Headers and body" do
      context "Formatting headers" do
        it "by default, justifies headers depending on body cell value type" do
          table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Justifying headers", framed: true)) do |t|
            t.add_column("numbers") { |n| n[0] }
            t.add_column("Booleans") { |n| n[1] }
            t.add_column("Strings") { |n| n[2] }
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭────────────────────────────────────────────╮
            │             Justifying headers             │
            ├──────────────┬──────────────┬──────────────┤
            │      numbers :   Booleans   : Strings      │
            ├--------------┼--------------┼--------------┤
            │            1 :     false    : Abc          │
            │            2 :     true     : def          │
            │            3 :     true     : ghi          │
            ╰──────────────┴──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      context "Styling headers" do
        it "colorize headers in blue" do
          table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
            header_styler: ->(content : String) { content.colorize(:blue).to_s },
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Justifying headers", framed: true)) do |t|
            t.add_column("numbers") { |n| n[0] }
            t.add_column("Booleans") { |n| n[1] }
            t.add_column("Strings") { |n| n[2] }
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭────────────────────────────────────────────╮
              │             Justifying headers             │
              ├──────────────┬──────────────┬──────────────┤
              │      \e[34mnumbers\e[0m :   \e[34mBooleans\e[0m   : \e[34mStrings\e[0m      │
              ├--------------┼--------------┼--------------┤
              │            1 :     false    : Abc          │
              │            2 :     true     : def          │
              │            3 :     true     : ghi          │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭────────────────────────────────────────────╮
              │             Justifying headers             │
              ├──────────────┬──────────────┬──────────────┤
              │      numbers :   Booleans   : Strings      │
              ├--------------┼--------------┼--------------┤
              │            1 :     false    : Abc          │
              │            2 :     true     : def          │
              │            3 :     true     : ghi          │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
      end
      describe "Formatting body" do
        it "displays floating point numbers with 2 decimals" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Floating point formatting", framed: true)) do |t|
            t.add_column("itself", width: 15,
              body_formatter: ->(c : Tablo::CellType) { "%.2f" % c.as(Float64) },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────╮
            │  Floating point │
            │    formatting   │
            ├─────────────────┤
            │          itself │
            ├-----------------┤
            │            0.00 │
            │          -10.30 │
            │           43.61 │
            │         -909.03 │
            │         1024.00 │
            ╰─────────────────╯
            OUTPUT
          output.should eq expected_output
        end
        it "align floating point numbers on decimal point (blank)" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Floating point align (blank)", framed: true)) do |t|
            t.add_column("itself", width: 15,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :blank) },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭─────────────────╮
            │  Floating point │
            │  align (blank)  │
            ├─────────────────┤
            │          itself │
            ├-----------------┤
            │                 │
            │        -10.3    │
            │         43.606  │
            │       -909.0302 │
            │       1024      │
            ╰─────────────────╯
            OUTPUT
          output.should eq expected_output
        end

        it "align floating point numbers on decimal point (dot_zero)" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Floating point align (dot_zero)", framed: true)) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :dot_zero) },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭──────────────────╮
            │  Floating point  │
            │ align (dot_zero) │
            ├──────────────────┤
            │           itself │
            ├------------------┤
            │           0.0    │
            │         -10.3    │
            │          43.606  │
            │        -909.0302 │
            │        1024.0    │
            ╰──────────────────╯
            OUTPUT
          output.should eq expected_output
        end
        it "renders body in uppercase" do
          table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            body_formatter: ->(value : Tablo::CellType) { value.to_s.upcase },
            title: Tablo::Heading.new("Justifying headers", framed: true)) do |t|
            t.add_column("numbers") { |n| n[0] }
            t.add_column("Booleans") { |n| n[1] }
            t.add_column("Strings") { |n| n[2] }
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          expected_output = <<-OUTPUT
            ╭────────────────────────────────────────────╮
            │             Justifying headers             │
            ├──────────────┬──────────────┬──────────────┤
            │      numbers :   Booleans   : Strings      │
            ├--------------┼--------------┼--------------┤
            │            1 :     FALSE    : ABC          │
            │            2 :     TRUE     : DEF          │
            │            3 :     TRUE     : GHI          │
            ╰──────────────┴──────────────┴──────────────╯
            OUTPUT
          output.should eq expected_output
        end
      end
      describe "Styling body" do
        it "unconditionnaly colorizes body contents" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color, nodot aligned", framed: true)) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :no_dot) },
              body_styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │   nodot aligned  │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           \e[31m0     \e[0m │
              │         \e[31m-10.3   \e[0m │
              │          \e[31m43.606 \e[0m │
              │        \e[31m-909.0302\e[0m │
              │        \e[31m1024     \e[0m │
              ╰──────────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │   nodot aligned  │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           0      │
              │         -10.3    │
              │          43.606  │
              │        -909.0302 │
              │        1024      │
              ╰──────────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "conditionnaly colorizes body contents, depending on cell value" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color, nodot aligned", framed: true)) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :no_dot) },
              body_styler: ->(c : Tablo::CellType, s : String) {
                if c.as(Float64) < 0.0
                  s.colorize(:red).to_s
                else
                  s.colorize(:green).to_s
                end
              },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │   nodot aligned  │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           \e[32m0     \e[0m │
              │         \e[31m-10.3   \e[0m │
              │          \e[32m43.606 \e[0m │
              │        \e[31m-909.0302\e[0m │
              │        \e[32m1024     \e[0m │
              ╰──────────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │   nodot aligned  │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           0      │
              │         -10.3    │
              │          43.606  │
              │        -909.0302 │
              │        1024      │
              ╰──────────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "conditionnaly colorizes body contents, depending on row index" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color, dot aligned", framed: true)) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :dot_only) },
              body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
                if r.row_index % 2 == 0
                  s.colorize(:blue).to_s
                else
                  s.colorize(:magenta).to_s
                end
              },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │    dot aligned   │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           \e[34m0.    \e[0m │
              │         \e[35m-10.3   \e[0m │
              │          \e[34m43.606 \e[0m │
              │        \e[35m-909.0302\e[0m │
              │        \e[34m1024.    \e[0m │
              ╰──────────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭──────────────────╮
              │  Body in color,  │
              │    dot aligned   │
              ├──────────────────┤
              │           itself │
              ├------------------┤
              │           0.     │
              │         -10.3    │
              │          43.606  │
              │        -909.0302 │
              │        1024.     │
              ╰──────────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "conditionnaly colorizes row's body contents, depending on row index" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
            body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
              if r.row_index % 2 == 0
                s.colorize(:red).to_s
              else
                s.colorize(:blue).to_s
              end
            }) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :dot_only) },
              &.itself)
            t.add_column("Double", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64)*2, 4, :dot_only) },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭─────────────────────────────────────╮
              │      Body in color, dot aligned     │
              ├──────────────────┬──────────────────┤
              │           itself :           Double │
              ├------------------┼------------------┤
              │           \e[31m0.    \e[0m :           \e[31m0.    \e[0m │
              │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
              │          \e[31m43.606 \e[0m :          \e[31m87.212 \e[0m │
              │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
              │        \e[31m1024.    \e[0m :        \e[31m2048.    \e[0m │
              ╰──────────────────┴──────────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭─────────────────────────────────────╮
              │      Body in color, dot aligned     │
              ├──────────────────┬──────────────────┤
              │           itself :           Double │
              ├------------------┼------------------┤
              │           0.     :           0.     │
              │         -10.3    :         -20.6    │
              │          43.606  :          87.212  │
              │        -909.0302 :       -1818.0604 │
              │        1024.     :        2048.     │
              ╰──────────────────┴──────────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "conditionnaly colorizes row's body contents, depending on row AND column index" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
            body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
              if r.row_index % 2 == 0
                if r.column_index % 2 == 0
                  s.colorize(:red).to_s
                else
                  s.colorize(:yellow).to_s
                end
              else
                s.colorize(:blue).to_s
              end
            }) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :dot_only) },
              &.itself)
            t.add_column("Double", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64)*2, 4, :dot_only) },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭─────────────────────────────────────╮
              │      Body in color, dot aligned     │
              ├──────────────────┬──────────────────┤
              │           itself :           Double │
              ├------------------┼------------------┤
              │           \e[31m0.    \e[0m :           \e[33m0.    \e[0m │
              │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
              │          \e[31m43.606 \e[0m :          \e[33m87.212 \e[0m │
              │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
              │        \e[31m1024.    \e[0m :        \e[33m2048.    \e[0m │
              ╰──────────────────┴──────────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭─────────────────────────────────────╮
              │      Body in color, dot aligned     │
              ├──────────────────┬──────────────────┤
              │           itself :           Double │
              ├------------------┼------------------┤
              │           0.     :           0.     │
              │         -10.3    :         -20.6    │
              │          43.606  :          87.212  │
              │        -909.0302 :       -1818.0604 │
              │        1024.     :        2048.     │
              ╰──────────────────┴──────────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "conditionnaly colorizes row's body contents, depending on row AND column index AND cell line number" do
          table = Tablo::Table.new(FloatSamples.new,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading.new("Body in color\n2nd line of cell in bold", framed: true),
            body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String, line : Int32) {
              if line == 1
                s.colorize(:magenta).mode(:bold).to_s
              else
                if r.row_index % 2 == 0
                  if r.column_index % 2 == 0
                    s.colorize(:red).to_s
                  else
                    s.colorize(:yellow).to_s
                  end
                else
                  s.colorize(:blue).to_s
                end
              end
            }) do |t|
            t.add_column("itself", width: 16,
              body_formatter: ->(c : Tablo::CellType) { Tablo::Functions.fp_align(c.as(Float64), 4, :dot_only) },
              &.itself)
            t.add_column("Double", width: 6,
              body_formatter: ->(c : Tablo::CellType) { "%.2f" % [c.as(Float64) * 2] },
              &.itself)
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭───────────────────────────╮
              │       Body in color       │
              │  2nd line of cell in bold │
              ├──────────────────┬────────┤
              │           itself : Double │
              ├------------------┼--------┤
              │           \e[31m0.    \e[0m :   \e[33m0.00\e[0m │
              │         \e[34m-10.3   \e[0m : \e[34m-20.60\e[0m │
              │          \e[31m43.606 \e[0m :  \e[33m87.21\e[0m │
              │        \e[34m-909.0302\e[0m : \e[34m-1818.\e[0m │
              │                  :     \e[35;1m06\e[0m │
              │        \e[31m1024.    \e[0m : \e[33m2048.0\e[0m │
              │                  :      \e[35;1m0\e[0m │
              ╰──────────────────┴────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭───────────────────────────╮
              │       Body in color       │
              │  2nd line of cell in bold │
              ├──────────────────┬────────┤
              │           itself : Double │
              ├------------------┼--------┤
              │           0.     :   0.00 │
              │         -10.3    : -20.60 │
              │          43.606  :  87.21 │
              │        -909.0302 : -1818. │
              │                  :     06 │
              │        1024.     : 2048.0 │
              │                  :      0 │
              ╰──────────────────┴────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
        it "colorize body in red" do
          table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            body_styler: ->(content : String) { content.colorize(:red).to_s },
            title: Tablo::Heading.new("Justifying headers", framed: true)) do |t|
            t.add_column("numbers") { |n| n[0] }
            t.add_column("Booleans") { |n| n[1] }
            t.add_column("Strings") { |n| n[2] }
          end
          output = table.to_s
          {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
          if Tablo::Util.styler_allowed
            expected_output = <<-OUTPUT
              ╭────────────────────────────────────────────╮
              │             Justifying headers             │
              ├──────────────┬──────────────┬──────────────┤
              │      numbers :   Booleans   : Strings      │
              ├--------------┼--------------┼--------------┤
              │            \e[31m1\e[0m :     \e[31mfalse\e[0m    : \e[31mAbc\e[0m          │
              │            \e[31m2\e[0m :     \e[31mtrue\e[0m     : \e[31mdef\e[0m          │
              │            \e[31m3\e[0m :     \e[31mtrue\e[0m     : \e[31mghi\e[0m          │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          else
            expected_output = <<-OUTPUT
              ╭────────────────────────────────────────────╮
              │             Justifying headers             │
              ├──────────────┬──────────────┬──────────────┤
              │      numbers :   Booleans   : Strings      │
              ├--------------┼--------------┼--------------┤
              │            1 :     false    : Abc          │
              │            2 :     true     : def          │
              │            3 :     true     : ghi          │
              ╰──────────────┴──────────────┴──────────────╯
              OUTPUT
          end
          output.should eq expected_output
        end
      end
    end
  end

  describe "Changing data sources" do
    it "takes new sources into account" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy)) do |t|
        t.add_column(:number) { |n| n }
        t.add_column(:doubled, header: "Number X 2") { |n| n * 2 }
      end
      table.sources = [50, 60]
      output = table.to_s
      {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────╮
        │       number :   Number X 2 │
        ├--------------┼--------------┤
        │           50 :          100 │
        │           60 :          120 │
        ╰──────────────┴──────────────╯
        OUTPUT
      output.should eq expected_output
    end
    it "takes updated sources into account" do
      arr = [1, 2, 3]
      table = Tablo::Table.new(arr,
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy)) do |t|
        t.add_column(:number) { |n| n }
        t.add_column(:doubled, header: "Number X 2") { |n| n * 2 }
      end
      arr << 42
      arr.shift
      output = table.to_s
      {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────╮
        │       number :   Number X 2 │
        ├--------------┼--------------┤
        │            2 :            4 │
        │            3 :            6 │
        │           42 :           84 │
        ╰──────────────┴──────────────╯
        OUTPUT
      output.should eq expected_output
    end
  end
  describe "Selecting and sorting columns for display" do
    context "Using column ids" do
      it "selects and reorders columns, groups are lost" do
        data = [[-1.14, "Abc", "Hello", 4, 5],
                [42.3, "Xyz", "Halo", 33, 42]]

        table = Tablo::Table.new(data) do |t|
          t.add_column(:col1, &.[0])
          t.add_column(:col2, &.[1])
          t.add_group(:group1)
          t.add_column(:col3, &.[2])
          t.add_group(:group2)
          t.add_column(:col4, &.[3])
          t.add_column(:col5, &.[4])
          t.add_group(:group3)
        end
        output = table.using_columns({:col5, :col1}, reordered: true).to_s
        {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
        expected_output = <<-OUTPUT
        +--------------+--------------+--------------+--------------+--------------+
        |         col5 |         col4 | col3         | col2         |         col1 |
        +--------------+--------------+--------------+--------------+--------------+
        |            5 |            4 | Hello        | Abc          |        -1.14 |
        |           42 |           33 | Halo         | Xyz          |         42.3 |
        +--------------+--------------+--------------+--------------+--------------+
        OUTPUT
        output.should eq expected_output
      end
    end
    context "Using column indexes" do
      it "selects columns without reordering them, groups are preserved" do
        data = [[-1.14, "Abc", "Hello", 4, 5],
                [42.3, "Xyz", "Halo", 33, 42]]

        table = Tablo::Table.new(data) do |t|
          t.add_column(:col1, &.[0])
          t.add_column(:col2, &.[1])
          t.add_group(:group1)
          t.add_column(:col3, &.[2])
          t.add_group(:group2)
          t.add_column(:col4, &.[3])
          t.add_column(:col5, &.[4])
          t.add_group(:group3)
        end
        output = table.using_column_indexes({1, 2}, 0).to_s
        {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
        expected_output = <<-OUTPUT
          +-----------------------------+--------------+
          |            group1           |    group2    |
          +--------------+--------------+--------------+
          |         col1 | col2         | col3         |
          +--------------+--------------+--------------+
          |        -1.14 | Abc          | Hello        |
          |         42.3 | Xyz          | Halo         |
          +--------------+--------------+--------------+
          OUTPUT
        output.should eq expected_output
      end
      it "selects and reorders columns, groups are lost" do
        data = [[-1.14, "Abc", "Hello", 4, 5],
                [42.3, "Xyz", "Halo", 33, 42]]

        table = Tablo::Table.new(data) do |t|
          t.add_column(:col1, &.[0])
          t.add_column(:col2, &.[1])
          t.add_group(:group1)
          t.add_column(:col3, &.[2])
          t.add_group(:group2)
          t.add_column(:col4, &.[3])
          t.add_column(:col5, &.[4])
          t.add_group(:group3)
        end
        output = table.using_column_indexes({1, 2}, 0, reordered: true).to_s
        {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
        expected_output = <<-OUTPUT
          +--------------+--------------+--------------+
          | col2         | col3         |         col1 |
          +--------------+--------------+--------------+
          | Abc          | Hello        |        -1.14 |
          | Xyz          | Halo         |         42.3 |
          +--------------+--------------+--------------+
          OUTPUT
        output.should eq expected_output
      end
    end
  end
  context "#transpose method" do
    it "inverts rows and columns" do
      table = Tablo::Table.new([-1, 0, 1],
        header_alignment: Tablo::Justify::Center,
        body_alignment: Tablo::Justify::Center) do |t|
        t.add_column("Even?", &.even?)
        t.add_column("Odd?", &.odd?)
        t.add_column("Abs", &.abs)
      end.transpose(
        field_names_header_alignment: Tablo::Justify::Right,
        field_names_body_alignment: Tablo::Justify::Right,
        field_names_header: "Field names",
        body_headers: "Row #%d content"
      )

      output = table.to_s
      {% if flag?(:DEBUG) %} puts "\n#{output}" {% end %}
      expected_output = <<-OUTPUT
          +-------+--------------+--------------+--------------+
          | Field |    Row #0    |    Row #1    |    Row #2    |
          | names |    content   |    content   |    content   |
          +-------+--------------+--------------+--------------+
          | Even? |     false    |     true     |     false    |
          |  Odd? |     true     |     false    |     true     |
          |   Abs |       1      |       0      |       1      |
          +-------+--------------+--------------+--------------+
          OUTPUT
      output.should eq expected_output
    end
  end
end
