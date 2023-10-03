require "tablo"
require "debug"

borders = ["╭┬╮├┼┤╰┴╯│:│─−-⋅",
           "EEEEEEEEEEEE----",
           "ESEESEESEESE----",
           "EDEEDEEDEEDE----",
           "ETEETEETEETE----"]

border = "ETEETEETEETE----"
if true
  debug! puts
  debug! puts "header_frequency=0"
  debug! puts
  border = "╭┬╮├┼┤╰┴╯│:│─−-⋅"
  # border = "╭S╮├S┤╰S╯│S│─−-⋅"
  table = Tablo::Table.new([1, 2, 3],
    left_padding: 0, right_padding: 0,
    header_frequency: 0,
    # header_frequency: 2,
    # title: my_title,
    # title: Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: true),
    # footer: Tablo::Footer.new("My Footer", frame: Tablo::Frame.new),
    # border_type: :fancy
    # border_type: "EDEEDEEDEEDE----"
    # border_type: "ESEESEESEESE----"
    border_type: border
  ) do |t|
    t.add_column("itself", &.itself)
    t.add_column(2, header: "Double") { |n| n * 2 }
    t.add_group("Numbers", alignment: Tablo::Justify::Right)
    t.add_column(:column_3, header: "Boolean") { |n| n.even?.to_s }
    t.add_column(:column_4, header: "String") { |n| n.to_s * n }
    t.add_group("Text", alignment: Tablo::Justify::Left)
  end
  puts table
end
if false
  debug! puts
  debug! puts "header_frequency=0"
  debug! puts

  table = Tablo::Table.new([1, 2, 3],
    left_padding: 0, right_padding: 0,
    header_frequency: 0,
    # header_frequency: 2,
    # title: Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: true),
    # footer: Tablo::Footer.new("My Footer", frame: Tablo::Frame.new),
    # border_type: :fancy
    # border_type: "EDEEDEEDEEDE----"
    border_type: border
    # border_type: "EDEEDEEDEEDE----"
  ) do |t|
    t.add_column("itself", &.itself)
    t.add_column(2, header: "Double") { |n| n * 2 }
    t.add_group("Numbers", alignment: Tablo::Justify::Right)
    t.add_column(:column_3, header: "Boolean") { |n| n.even?.to_s }
    t.add_column(:column_4, header: "String") { |n| n.to_s * n }
    t.add_group("Text", alignment: Tablo::Justify::Left)
  end
  puts table
end

if true
  debug! puts
  debug! puts "header_frequency=0, title"
  debug! puts
  table = Tablo::Table.new([1, 2, 3],
    left_padding: 0, right_padding: 0,
    header_frequency: 0,
    # header_frequency: 2,
    title: Tablo::Title.new("My Title", frame: Tablo::Frame.new),
    # title: Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: true),
    # footer: Tablo::Footer.new("My Footer", frame: Tablo::Frame.new),
    # border_type: :fancy
    # border_type: "EDEEDEEDEEDE----"
    # border_type: "ESEESEESEESE----"
    # border_type: "EDEEDEEDEEDE----"
    border_type: border
  ) do |t|
    t.add_column("itself", &.itself)
    t.add_column(2, header: "Double") { |n| n * 2 }
    t.add_group("Numbers", alignment: Tablo::Justify::Right)
    t.add_column(:column_3, header: "Boolean") { |n| n.even?.to_s }
    t.add_column(:column_4, header: "String") { |n| n.to_s * n }
    t.add_group("Text", alignment: Tablo::Justify::Left)
  end
  puts table
end

if false
  debug! puts
  debug! puts "header_frequency=2"
  debug! puts
  table = Tablo::Table.new([1, 2, 3],
    left_padding: 0, right_padding: 0,
    header_frequency: 2,
    # header_frequency: 2,
    # title: Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: true),
    # footer: Tablo::Footer.new("My Footer", frame: Tablo::Frame.new),
    # border_type: :fancy
    # border_type: "EDEEDEEDEEDE----"
    # border_type: "ESEESEESEESE----"
    # border_type: "EDEEDEEDEEDE----"
    border_type: border
  ) do |t|
    t.add_column("itself", &.itself)
    t.add_column(2, header: "Double") { |n| n * 2 }
    t.add_group("Numbers", alignment: Tablo::Justify::Right)
    t.add_column(:column_3, header: "Boolean") { |n| n.even?.to_s }
    t.add_column(:column_4, header: "String") { |n| n.to_s * n }
    t.add_group("Text", alignment: Tablo::Justify::Left)
  end
  puts table
end

if false
  debug! puts
  debug! puts "header_frequency=2, title repeated"
  debug! puts
  table = Tablo::Table.new([1, 2, 3],
    left_padding: 0, right_padding: 0,
    header_frequency: 2,
    # header_frequency: 2,
    # title: Tablo::Title.new("My Title", frame: Tablo::Frame.new),
    title: Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: true),
    # footer: Tablo::Footer.new("My Footer", frame: Tablo::Frame.new),
    # border_type: :fancy
    # border_type: "EDEEDEEDEEDE----"
    # border_type: "ESEESEESEESE----"
    border_type: "EDEEDEEDEEDE----"
  ) do |t|
    t.add_column("itself", &.itself)
    t.add_column(2, header: "Double") { |n| n * 2 }
    t.add_group("Numbers", alignment: Tablo::Justify::Right)
    t.add_column(:column_3, header: "Boolean") { |n| n.even?.to_s }
    t.add_column(:column_4, header: "String") { |n| n.to_s * n }
    t.add_group("Text", alignment: Tablo::Justify::Left)
  end
  puts table
  puts
  puts
end
