require "tablo"
require "debug"

table = Tablo::Table.new([17.0, -42, nil, -74, 15, "abc", false, "bca"],
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column("triple") { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 3) }
  t.add_column("Double") { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 2) }
  t.summary({
    "itself" => {
      header: "My sum",
      proc:   [
        {1, ->(ary : Hash(Tablo::LabelType, Array(Tablo::CellType))) {
          # ar = ary["itself"].select(&.is_a?(Number)).map &.as(Number)
          # ar.sum.as(Tablo::CellType)
          (ary["itself"].select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
        }},
        {2, ->(ary : Array(Tablo::CellType)) {
          ar = ary.select(String).map &.as(String)
          ar.max.as(Tablo::CellType)
        }},
      ],

    },
    "Double" => {
      header: "My avg double",
      proc:   [
        {1, ->(ary : Hash(Tablo::LabelType, Array(Tablo::CellType))) {
          ar = ary["Double"].select(&.is_a?(Number)).map &.as(Number)
          if ar.size > 0
            (ar.sum / ar.size)
          else
            "ND"
          end.as(Tablo::CellType)
        }},
      ],
    },
  },
    masked_headers: false)
end
puts table
puts table.summary
