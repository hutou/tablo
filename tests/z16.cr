require "tablo"
require "debug"

table = Tablo::Table.new([17.0, -42, nil, -74, 15, "abc", false, "bca"],
  # border_type: :fancy,
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column("triple") { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 3) }
  t.add_column("Double",
    body_formatter: ->(c : Tablo::CellType) { c.is_a?(String) ? c.as(String).upcase : c.to_s }) { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 2) }
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
    border_type: "+++++++++SSS----",
    omit_last_rule: true,
    masked_headers: true)
end
puts table
puts table.summary
# puts
# ts = table.summary.as(Tablo::Table(Array(Tablo::CellType)))
# ts.each_with_index do |row, i|
#   if i == 0
#     lines = row.to_s.split("\n")
#     # puts lines[-2]
#     puts lines[-1]
#     # puts lines[-2]
#   end
# end
puts
table.each do |row|
  puts
  row.each { |cell| puts cell.value }             # 1, false, true...2, true, false...3, false, true
  row.each { |cell| puts cell.formatted_content } # 1, false, true...2, true, false...3, false, true
  # puts row.to_h["triple"].value       # false...true...false
  p! row.to_h
  p! row.to_h["triple"] # false...true...false
  puts
end
