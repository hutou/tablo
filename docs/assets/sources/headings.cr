require "tablo"
data = [
  {name: "Enrique", age: 33},
  {name: "Edward", age: 44},
]
# Create the table
table = Tablo::Table.new(data,
  #  border_type: Tablo::BorderName::Fancy,
  title: Tablo::HeadingFramed.new("my title", spacing_after: 5),
  subtitle: Tablo::HeadingFree.new("my subtitle"),
  # subtitle: Tablo::HeadingFramed.new("my subtitle", spacing_before: 3),
  footer: Tablo::HeadingFramed.new("My footer", spacing_before: 2)
)
# add columns
table.add_column("Name") { |n| n[:name] }
table.add_column("Age") { |n| n[:age] }

puts table
