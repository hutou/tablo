require "tablo"
require "debug"

table = Tablo::Table.new([17.0, -42, nil, -74, 15, "abc", false, "bca"],
  border: Tablo::Border.new(border_type: :fancy),
  # border: Tablo::Border.new(border_type: :fancy, alter: [{12, "SSSS"}]),
  # border: Tablo::Border.new("abcdefghijklmnop", alter: [{12, "SSSS"}]),
  omit_group_header_rule: true,
  row_divider_frequency: 1,
  omit_last_rule: false) do |t|
  t.add_column("itself", &.itself)
  t.add_column("triple") { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 3) }
  t.add_group("My Group header")
  t.add_column("Double",
    body_formatter: ->(c : Tablo::CellType) { c.is_a?(String) ? c.as(String).upcase : c.to_s }) { |n| n.nil? ? nil : (n.is_a?(Bool) ? n : n * 2) }
end
puts table.border
table.border = Tablo::Border.alter([{13, "E"}])
puts table

table.border = Tablo::Border.alter(styler: ->(s : String) { s.colorize(:yellow).to_s })
puts table.border
puts table.border.border_string
puts typeof(table.border)
puts table

puts "coucou"
puts table.border.border_string

table.summary({
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
  omit_last_rule: true,
  # border: Tablo::Border.new([{9, "SSS"}, {12, "E"}], styler: ->(s : String) { s.colorize(:blue).to_s }),
  border: Tablo::Border.alter([{9, "SSS"}, {12, "E"}]),
  masked_headers: true)
# table.summary.as(Tablo::Table(Array(Tablo::CellType))).border.vdiv_left = "S"
# table.summary.as(Tablo::Table(Array(Tablo::CellType))).border.vdiv_mid = "S"
# table.summary.as(Tablo::Table(Array(Tablo::CellType))).border.vdiv_right = "S"
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
# table.each do |row|
#   puts
#   row.each { |cell| puts cell.value }             # 1, false, true...2, true, false...3, false, true
#   row.each { |cell| puts cell.formatted_content } # 1, false, true...2, true, false...3, false, true
#   # puts row.to_h["triple"].value       # false...true...false
#   p! row.to_h
#   p! row.to_h["triple"] # false...true...false
#   puts
# end
