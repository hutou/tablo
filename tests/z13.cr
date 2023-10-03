require "tablo"
require "debug"

table = Tablo::Table.new((1..10).to_a,
  # table = Tablo::Table.new([1, 2, 3],
  header_frequency: 0,
  border_type: Tablo::BorderName::Fancy,
  # title: Tablo::Title.new("Numbers and text", frame: Tablo::Frame.new(0, 2)),
  # title: Tablo::Title.new("Numbers and text", frame: Tablo::Frame.new),
  # footer: Tablo::Footer.new("End of page", frame: Tablo::Frame.new),
  omit_last_rule: true) do |t|
  t.add_column("itself", &.itself)
  t.add_column(2, header: "") { |n| n * 2 }
  t.add_group("")
  t.add_column(:column_3, header: "") { |n| n.even?.to_s }
  t.add_group("Text", alignment: Tablo::Justify::Left)
  t.summary({
    "itself" => {proc1: ->(ary : Tablo::NumCol) { ary.compact.sum },
    },
    2 => {header: "somme",
          proc2: ->(ary : Tablo::NumCols) { ary[2].compact.sum },
          proc3: ->(ary : Tablo::NumCols) { ary[2].compact.sum - ary["itself"].compact.sum },
    },
  }, # masked_headers: true,
    border_type: "---------|||----",
    # title: Tablo::Title.new("Summary", frame: Tablo::Frame.new),
    # header_frequency: nil,
    omit_last_rule: false)
end

puts table
puts table.summary
