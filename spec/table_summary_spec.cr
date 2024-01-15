require "./spec_helper"

def context_data
  sources = [
    [2, 3.14, false, "abcd"],
    [12, 2.78, false, "xyz"],
    [42, 4.21, true, "ijkl"],
    [33, 1.41, false, "rst"],
    [17, 1.33, true, "uvw"],
  ]
end

def context_table
  sources = context_data
  table = Tablo::Table.new(sources,
    omit_last_rule: true,
    row_divider_frequency: 1) do |t|
    t.add_column("Integer") { |n| n[0] }
    t.add_column("Float") { |n| n[1] }
    t.add_group("Number")
    t.add_column("Bool") { |n| n[2] }
    t.add_column("String") { |n| n[3] }
    t.add_group("Other")
  end
end

def get_summary_definition
  summary_definition = {
    :header_column => {
      "Integer" => {:alignment => Tablo::Justify::Right},
      "Float"   => {:alignment => Tablo::Justify::Left,
                  :formatter => ->(value : Tablo::CellType) { value.to_s.upcase },
                  :styler => ->(s : String) { s.colorize(:yellow).to_s }},
      "Bool" => {:formatter => ->(value : Tablo::CellType) { value.to_s.upcase }},
    },
    :header_row => {
      "Integer" => "Entier".as(Tablo::CellType),
      "Float"   => "Réel".as(Tablo::CellType),
      "Bool"    => "Booléen".as(Tablo::CellType),
    },
    :body_column => {
      "Integer" => {:alignment => Tablo::Justify::Right},
      "Float"   => {:alignment => Tablo::Justify::Left,
                  :formatter => ->(value : Tablo::CellType) { value.to_s.upcase },
                  :styler => ->(s : String) { s.colorize(:red).to_s }},
      "Bool" => {:formatter => ->(value : Tablo::CellType) { value.to_s.upcase }},
    },
    :body_row => {
      "Integer" => {
        1 => "Literal value 1".as(Tablo::CellType),
        2 => "Literal value 2".as(Tablo::CellType),
        3 => ->{ Tablo::Summary.use("Float",
          Tablo::Aggregate::Sum).as(Tablo::CellType) },
      },
      "Float" => {
        1 => ->{ Tablo::Summary.use("Float",
          Tablo::Aggregate::Sum).as(Tablo::CellType) },
      },
      "Bool" => {
        1 => "Bool literal value".as(Tablo::CellType),
      },
    },
    :aggregation => {
      "Integer" => [Tablo::Aggregate::Count],
      "Float"   => [Tablo::Aggregate::Sum],
    }, #
    :user_aggregation => {
      :user_source => ->(sources : Enumerable(Array(Int32 | Float64 | Bool | String))) {
        42.as(Tablo::CellType)
      },
      :user_table => ->(tbl : Tablo::Table(Array(Int32 | Float64 | Bool | String))) {
        (tbl.source_column("Integer").select(&.is_a?(Int32))
          .map &.as(Int32)).sum.as(Tablo::CellType)
      },
    },
  }
end

describe "#{Tablo::Table} -> summary definition", tags: "summary" do
  tbl = context_table
  tbl.summary(get_summary_definition,
    {body_styler:   ->(s : String) { s.colorize(:green).to_s },
     header_styler: ->(s : String) { s.colorize(:blue).mode(:italic).to_s },
     border:        Tablo::Border.new(Tablo::BorderName::Ascii,
       styler: ->(s : String) { s.colorize(:yellow).to_s })})
  it "returns valid data", focus: true do
    sources_array = tbl.summary.as(Tablo::SummaryTable).sources.to_a
    # debug! sources_array
    sources_array[0][0].should eq("Literal value 1")
    sources_array[1][0].should eq("Literal value 2")
    sources_array[2][0].should eq(12.87)
    sources_array[0][1].should eq(12.87)
    sources_array[0][2].should eq("Bool literal value")
    puts "\n#{tbl}"
    puts tbl.summary
    # puts "\n#{tbl.summary}"
  end
end
