require "./spec_helper"

# test_data definitions
#
record Person, name : String, age : Int32

class OddNumbers
  include Enumerable(Int32)

  def each(&)
    yield 1
    yield 7
    yield 13
    yield 43
    yield 59
  end
end

test_data_array_int32 = [1, 2, 3]

test_data_hash_string_int32 = {"A" => 1, "B" => 2, "C" => 3}

test_data_range_int32 = 1..3

test_data_oddnumbers = OddNumbers.new

test_data_struct_person = [] of Person
test_data_struct_person << Person.new("Albert", 76)
test_data_struct_person << Person.new("Karl", 61)
test_data_struct_person << Person.new("Joseph", 56)

describe "#{Tablo::Table} -> Initialization with different types of Enumerable" do
  describe "#initialize with block given" do
    context "from an Array(Int32)" do
      it "correctly create a new table from Array(Int32)" do
        table = Tablo::Table.new(test_data_array_int32) do |t|
          t.add_column("itself", &.itself)
        end
        table.should be_a(Tablo::Table(Int32))
      end
    end
    context "from a hash(String, Int32)" do
      it "correctly create a new table from Hash(String, Int32)" do
        table = Tablo::Table.new(test_data_hash_string_int32) do |t|
          t.add_column("Key") { |(k, v)| k }
          t.add_column("Value") { |(k, v)| v }
        end
        table.should be_a(Tablo::Table(Tuple(String, Int32)))
      end
    end
    pending "from a Range(Int32). Ranges are not supported yet (issue #10518)" do
      # it "correctly create a new table from Range(Int32..Int32)" do
      #   table = Tablo::Table.new(test_data_range_int32) do |t|
      #     t.add_column("itself") { |n| n }
      #   end
      #   table.should be_a(Tablo::Table(Int32))
      # end
    end
    context "from an array of Struct" do
      it "correctly create a new table from Array(Person)" do
        table = Tablo::Table.new(test_data_struct_person) do |t|
          t.add_column("Row") { |_, row_index| row_index }
          t.add_column("Name", &.name)
          t.add_column("Age", &.age)
        end
        table.should be_a(Tablo::Table(Person))
      end
    end
    context "from a user defined enumerable class" do
      it "correctly create a new table from OddNumbers enumerable class" do
        table = Tablo::Table.new(test_data_oddnumbers) do |t|
          t.add_column("Row") { |_, row_index| row_index }
          t.add_column("Number", &.itself)
        end
        table.should be_a(Tablo::Table(Int32))
      end
    end
  end
  describe "#initialize *without* block given" do
    context "from an Array(Int32)" do
      it "correctly create a new table from Array(Int32)" do
        table = Tablo::Table.new(test_data_array_int32)
        table.add_column("itself", &.itself)
        table.should be_a(Tablo::Table(Int32))
      end
    end
    context "from a hash(String, Int32)" do
      it "correctly create a new table from Hash(String, Int32)" do
        table = Tablo::Table.new(test_data_hash_string_int32)
        table.add_column("Key") { |(k, v)| k }
        table.add_column("Value") { |(k, v)| v }
        table.should be_a(Tablo::Table(Tuple(String, Int32)))
      end
    end
    pending "from a Range(Int32). Ranges are not supported yet (issue #10518)" do
      # context "from a Range(Int32)" do
      #   it "correctly create a new table from Range(Int32..Int32)" do
      #     table = Tablo::Table.new(test_data_range_int32)
      #     table.add_column("itself") { |n| n }
      #     table.should be_a(Tablo::Table(Int32))
      #   end
    end
    context "from an array of Struct" do
      it "correctly create a new table from Array(Person)" do
        table = Tablo::Table.new(test_data_struct_person)
        table.add_column("Row") { |_, row_index| row_index }
        table.add_column("Name", &.name)
        table.add_column("Age", &.age)
        table.should be_a(Tablo::Table(Person))
      end
    end
    context "from a user defined enumerable class" do
      it "correctly create a new table from OddNumbers enumerable class" do
        table = Tablo::Table.new(test_data_oddnumbers)
        table.add_column("Row") { |_, row_index| row_index }
        table.add_column("Number", &.itself)
        table.should be_a(Tablo::Table(Int32))
      end
    end
  end
end
