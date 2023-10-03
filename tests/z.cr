require "tablo"

table = Tablo::Table.new([1, 2, 3]) do |t|
  t.add_column("itself", &.itself)
end

puts table
