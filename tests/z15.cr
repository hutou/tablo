require "tablo"
require "debug"

table = Tablo::Table.new([17, -42, nil, -74, 15],
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column("Double") { |n| n.nil? ? nil : n * 2 }
  t.summary({
    "itself" => {
      header: "My sum\nmy avg",
      proc:   [
        {1, ->(_ary : Array(Tablo::CellType)) {
          33.as(Tablo::CellType)
        }},
      ],
    },
    "Double" => {
      header: "My sum double",
      proc:   [
        {1, ->(ary : Hash(Tablo::LabelType, Array(Tablo::CellType))) {
          # ary.sum { |e| e.is_a?(Number) && !e.nil? ? e.as(Number) : 0 }.as(Tablo::CellType)
          ar = ary["Double"].select(&.is_a?(Number)).map &.as(Number)
          ar.sum.as(Tablo::CellType)
        }},
        {2, ->(ary : Hash(Tablo::LabelType, Array(Tablo::CellType))) {
          # ary.map { |e| e.is_a?(Number) && !e.nil? ? e.as(Number) : -9999999999999 }
          #   .max.as(Tablo::CellType)
          ar = ary["Double"].select(&.is_a?(Number)).map &.as(Number)
          ar.max.as(Tablo::CellType)
        }},
      ],
    },
  },
    masked_headers: false)
end
puts table
puts table.summary
