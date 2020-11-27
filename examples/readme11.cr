require "tablo"

data = [
  # Name         Initial   Initial    Initial    Initial   Initial
  #                 cost      cost       cost       cost      cost
  ["Charlie", 420.50, 420.50, 420.50, 420.50, 420.50],
  ["Max", 575.32, 575.32, 575.32, 575.32, 575.32],
  ["Simba", 498.00, 498.00, 498.00, 498.00, 498.00],
  ["Coco", 276.36, 276.36, 276.36, 276.36, 276.36],
  ["Ruby", 320.95, 320.95, 320.95, 320.95, 320.95],
  ["Freecat", 0.0, 0.0, 0.0, 0.0, 0.0],
]

Tablo.fpjust(data, 1, 5, nil) # Params: data array, column, decimals, mode
Tablo.fpjust(data, 2, 4, 0)
Tablo.fpjust(data, 3, 3, 1)
Tablo.fpjust(data, 4, 2, 2)
Tablo.fpjust(data, 5, 1, 3)
table = Tablo::Table.new(data) do |t|
  t.add_column("Name") { |n| n[0] }
  t.add_column("Initial\ncost\nmode=nil\ndec=5") { |n| n[1] }
  t.add_column("Initial\ncost\nmode=0\ndec=4") { |n| n[2] }
  t.add_column("Initial\ncost\nmode=1\ndec=3") { |n| n[3] }
  t.add_column("Initial\ncost\nmode=2\ndec=2") { |n| n[4] }
  t.add_column("Initial\ncost\nmode=3\ndec=1") { |n| n[5] }
end
table.shrinkwrap!
puts table
