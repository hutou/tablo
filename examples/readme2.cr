require "tablo"

# Name, Animal, Sex, Age(Yrs), Weight(Kg), Initial_cost, average_annual_expenses
data = [
  ["Charlie", "Dog", 'M', 7, 37.0, 420.50, 695],
  ["Max", "Cat", 'M', 12, 4.2, 575.32, 790],
  ["Simba", "Cat", 'M', 5, 3.8, 498.70, 720],
  ["Coco", "Dog", 'F', 8, 13.9, 276.36, 632],
  ["Ruby", "Dog", 'F', 6, 15.7, 320.95, 543],
]

table = Tablo::Table.new(data, connectors: Tablo::CONNECTORS_SINGLE_ROUNDED) do |t|
  t.add_column("Name", width: 8) { |n| n[0].as(String).upcase }
  t.add_column("Kind", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[1] }
  t.add_column("Sex", align_header: Tablo::Justify::Center, align_body: Tablo::Justify::Center, width: 4) { |n| n[2] }
  t.add_column("Age") { |n| n[3] }
  t.add_column("Weight") { |n| n[4] }
  t.add_column("Initial\ncost", formatter: ->(x : Tablo::CellType) { "%.2f" % x }) { |n| n[5] }
  t.add_column("Average\nannual\nexpenses") { |n| n[6] }
end
puts table
