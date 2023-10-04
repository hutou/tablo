require "tablo"
require "debug"

class Array
  include Tablo::CellType
end

# table = Tablo::Table.new([1, -2, nil, -4, 5, nil],
table = Tablo::Table.new([17, -42, nil, -74, 15],
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column("Double") { |n| n.nil? ? nil : n * 2 }
  t.summary({
    "itself" => {
      header: "My sum\nmy avg",
      proca:  ->(ary : Tablo::ColumnValues) {
        # ar.reduce(0) { |acc, i| i < 0 ? acc + i : acc } },
        # ary.sum { |e| e.is_a?(Tablo::Num) ? e.as(Tablo::Num) : 0.as(Tablo::Num) }.as(Tablo::CellType)
        33.as(Tablo::CellType)
      },
      # procb:  ->(ary : Tablo::NumCol) { ary.compact.reduce(0) { |acc, i| i >= 0 ? acc + i : acc } },
      # procc:  ->(ary : Tablo::NumCol) { ary.compact.reduce([] of Int32) { |memo, i|
      #   if i < 0
      #     memo.unshift(i)
      #   else
      #     memo
      #   end
      # } },
      # proc1: ->(ary : Tablo::NumCol) { ary.sum { |e| e.nil? ? 0 : e } },
      # proc2: ->(ary : Tablo::NumCol) { ar = ary.compact; ar.size > 0 ? (ar.sum / ar.size) : nil },
      # proc3: ->(ary : Tablo::NumCols) { ar = ary["itself"].map_with_index { |e, i|
      #   if e.nil? || ary["Double"][i].nil?
      #     0.0
      #   else
      #     e.as(Tablo::Num) * ary["Double"][i].as(Tablo::Num)
      #   end
      # }
      # ar.sum },
      # proc4: ->(ary : Tablo::NumCol) { ar = Hash(Symbol, Tablo::Num).new
      # ar[:nega] = ar[:posi] = 0.0
      # ary.each do |e|
      #   next if e.nil?
      #   debug! e
      #   if e < 0
      #     ar[:nega] += e
      #   else
      #     ar[:posi] += e
      #   end
      # end
      # debug! ar
      # ar[:nega] * ar[:posi] },

      # proc5: ->(ary : Tablo::NumCol) { "Hello" },
    },
    "Double" => {
      header: "My sum double",
      # proc:   ->(ary : Tablo::NumCol) { ary.compact.sum },
      # proc: ->(ary : Tablo::ColumnValues) { 42.as(Tablo::CellType) },
      # proc3:  ->(ary : Tablo::NumCol) { ary.count { |e| e.is_a?(Tablo::Num) } },
      procy: ->(ary : Tablo::ColumnValues) {
        ary.sum { |e| e.is_a?(Tablo::Num) && !e.nil? ? e.as(Tablo::Num) : 0 }.as(Tablo::CellType)
      },
      procz: ->(ary : Tablo::ColumnValues) {
        ary.map { |e| e.is_a?(Tablo::Num) && !e.nil? ? e.as(Tablo::Num) : -9999999999999 }.max.as(Tablo::CellType)
      },
    },
  },
    masked_headers: false)
end
puts table
puts table.summary
