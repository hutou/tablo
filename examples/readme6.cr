require "tablo"

# Name, Animal, Sex, Age(Yrs), Weight(Kg), Initial_cost, average_annual_expenses
data = [
  ["Charlie", "Dog", 'M', 7, 37.0, 420.50, 695],
  ["Max", "Cat", 'M', 12, 4.2, 575.32, 790],
  ["Simba", "Cat", 'M', 5, 3.8, 498.70, 720],
  ["Coco", "Dog", 'F', 8, 13.9, 276.36, 632],
  ["Ruby", "Dog", 'F', 6, 15.7, 320.95, 543],
]

table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_SINGLE_DOUBLE,
  style: "lc,mc,rc,ml", wrap_header_cells_to: 1) do |t|
  t.add_column("Name", width: 8) { |n| n[0].as(String).upcase }
  t.add_column("Kind", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[1] }
  t.add_column("Sex", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[2] }
  t.add_column("Age : weight") { |n| "%3d : %6.1f" % [n[3], n[4]] }
  t.add_column("Initial\ncost", formatter: ->(x : Tablo::CellType) { "%.2f" % x }) { |n| n[5] }
  t.add_column("Total\nCost", formatter: ->(x : Tablo::CellType) { "%.2f" % x }) { |n| n[3].as(Int32) * n[6].as(Int32) + n[5].as(Float64) }
end
puts table
