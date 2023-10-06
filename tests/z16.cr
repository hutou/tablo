require "tablo"
require "debug"

# class Array
#   include Tablo::CellType
# end

# table = Tablo::Table.new([1, -2, nil, -4, 5, nil],
table = Tablo::Table.new([17.0, -42, nil, -74, 15, "abc", "bca"],
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column("Double") { |n| n.nil? ? nil : n * 2 }
  t.summary({
    "itself" => {
      header: "My sum\nmy avg",
      # proc:   ->(row : Int32, ary : Tablo::ColumnValues) { 42 },
      proc: [
        {1, ->(ary : Tablo::ColumnsValues) {
          # ar = ary["itself"]
          # ar = ar.select &.in?(Int32, Float64)
          # ar = ar.select { |e| Tablo::CellType.number?(e) }
          # ar = ary["itself"].select { |e| Tablo::CellType.number?(e) }.map &.as(Tablo::Num)
          ar = ary["itself"].select { |e| e.is_a?(Number) }.map &.as(Number)
          p! ar
          p! typeof(ar)
          ar.sum.as(Tablo::CellType)
          # ar = ar.select { |e| e.nil? }
          # ar = ar.select &.number?
          # p! ary["itself"]
          # p! ar
          # ar.sum.as(Tablo::CellType)
          # (ar.sum).as(Tablo::CellType)
        }},
        {2, ->(ary : Tablo::ColumnValues) {
          # ar = ary.select { |e| Tablo::CellType.number?(e) }.map &.as(Tablo::Num)
          ar = ary.select { |e| e.is_a?(String) }.map &.as(String)
          # ar = ary.select { |e| Tablo::CellType.string?(e) }.map &.as(String)
          p! ar
          p! typeof(ar)
          ar.max.as(Tablo::CellType)
        }},
      ], # proc2: {2, ->(_ary : Tablo::ColumnsValues) { 99.as(:CellType) }},

    },
    # {1, ->(ary : Tablo::ColumnsValues) { ary["itself"].sum { |e|
    #   # p! e
    #   if e.nil?
    #     0
    #   elsif e.is_a?(Tablo::Num)
    #     p! e
    #     e.as(Tablo::Num)
    #   else
    #     0
    #   end
    # }.as(Tablo::CellType) }},

    "Double" => {
      header: "My avg double",
      proc:   [{1, ->(ary : Tablo::ColumnsValues) {
        # ar = ary["itself"].select { |e| e.is_a?(Number) }.map &.as(Number)
        ar = (ary["itself"].select &.is_a?(Number)).map &.as(Number)
        p! ar
        p! typeof(ar)
        # ar = ary["itself"].select { |e| Tablo::CellType.number?(e) }.map &.as(Tablo::Num)
        if ar.size > 0
          (ar.sum / ar.size)
        else
          "ND"
        end.as(Tablo::CellType)
      }}],
    },
  },
    masked_headers: false)
end
puts table
puts table.summary
