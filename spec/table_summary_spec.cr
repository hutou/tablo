require "./spec_helper"

def set_context
  # Tablo::Config.border_type = Tablo::BorderName::Fancy
  # Tablo::Config.title = Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new)
  # Tablo::Config.subtitle = Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new)
  # Tablo::Config.footer = Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new)
end

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
    row_divider_frequency: 1) do |t|
    t.add_column("Integer") { |n| n[0] }
    t.add_column("Float") { |n| n[1] }
    t.add_group("Number")
    t.add_column("Bool") { |n| n[2] }
    t.add_column("String") { |n| n[3] }
    t.add_group("Other")
  end
end

# def summary_def_minimal
#   summary_def = {
#     body_row: {
#       "Integer" => {
#         # {1, ->{ Tablo::Summary.use("Integer", Tablo::Aggregate::Sum).as(Tablo::CellType)}}
#         {1, "Literal value 1".as(Tablo::CellType)},
#         {2, "Literal value 2".as(Tablo::CellType)},
#       },
#     },
#     aggregation: NamedTuple.new,
#   }
# end

def get_summary_definition_namedtuple
  summary_definition = {
    aggregation: [
      {"Integer", [Tablo::Aggregate::Count]},
      {"Float", [Tablo::Aggregate::Sum]},
    ], #
    # user_aggregation: [ ],
    # header_column: [ ],
    header_row: [
      {"Integer", "Entier".as(Tablo::CellType)},
      {"Float", "Réel".as(Tablo::CellType)},
      {"Bool", "Booléen".as(Tablo::CellType)},
    ],
    body_column: [
      {"Integer", [{alignment: Tablo::Justify::Left}]},
      {"Float", [{alignment: Tablo::Justify::Left},
                 {formatter: ->(value : Tablo::CellType) { value.to_s.upcase }}]},
      {"Bool", [{formatter: ->(value : Tablo::CellType) { value.to_s.upcase }}]},
    ],
    body_row: [
      {"Integer", [
        {1, "Literal value 1".as(Tablo::CellType)},
        {2, "Literal value 2".as(Tablo::CellType)},
        {3, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
      ]},
      {"Float", [
        {1, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
      ]},
      {"Bool", [
        {1, "Bool literal value".as(Tablo::CellType)},
        # {2, ->{ 42.as(Int32) }},
      ]},
    ],
  }
end

def get_summary_definition
  summary_definition = {
    # :aggregation => [
    #   {"Integer", [Tablo::Aggregate::Count]},
    #   {"Float", [Tablo::Aggregate::Sum]},
    # ], #
    :aggregation => {
      "Integer" => [Tablo::Aggregate::Count],
      "Float"   => [Tablo::Aggregate::Sum],
    }, #
    # user_aggregation: [ ],
    # header_column: [ ],
    :header_column => {
      "Integer" => {:alignment => Tablo::Justify::Right},
      "Float"   => {:alignment => Tablo::Justify::Left,
                  :formatter => ->(value : Tablo::CellType) { value.to_s.upcase },
                  :styler => ->(s : String) { s.colorize(:yellow).to_s }},
      "Bool" => {:formatter => ->(value : Tablo::CellType) { value.to_s.upcase }},
    },
    # :header_row => [
    #   {"Integer", "Entier".as(Tablo::CellType)},
    #   {"Float", "Réel".as(Tablo::CellType)},
    #   {"Bool", "Booléen".as(Tablo::CellType)},
    # ],
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
      "Integer" => [
        {1, "Literal value 1".as(Tablo::CellType)},
        {2, "Literal value 2".as(Tablo::CellType)},
        {3, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
      ],
      # "Integer" => {
      #   1 => "Literal value 1".as(Tablo::CellType),
      #   2 => "Literal value 2".as(Tablo::CellType),
      #   3 => ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) },
      # },
      "Float" => [
        {1, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
      ],
      "Bool" => [
        {1, "Bool literal value".as(Tablo::CellType)},
        # {2, ->{ 42.as(Int32) }},
      ],
    },
    # :body_row => [
    #   {"Integer", [
    #     {1, "Literal value 1".as(Tablo::CellType)},
    #     {2, "Literal value 2".as(Tablo::CellType)},
    #     {3, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
    #   ]},
    #   {"Float", [
    #     {1, ->{ Tablo::Summary.use("Float", Tablo::Aggregate::Sum).as(Tablo::CellType) }},
    #   ]},
    #   {"Bool", [
    #     {1, "Bool literal value".as(Tablo::CellType)},
    #     # {2, ->{ 42.as(Int32) }},
    #   ]},
    # ],
  }
end

describe "#{Tablo::Table} -> summary method", tags: "summary" do
  context "summary_definition" do
    #   context do
    tbl = context_table
    tbl.summary(get_summary_definition)
    describe "call = table.summary(summary_def, options)" do
      it "returns valid data", focus: true do
        sources_array = tbl.summary.as(Tablo::SummaryTable).sources.to_a
        # debug! sources_array
        sources_array[0][0].should eq("Literal value 1")
        sources_array[1][0].should eq("Literal value 2")
        sources_array[2][0].should eq(12.87)
        sources_array[0][1].should eq(12.87)
        sources_array[0][2].should eq("Bool literal value")
        # puts "\n#{tbl}"
        # puts tbl.summary
        puts "\n#{tbl.summary}"
      end
    end
  end
end
