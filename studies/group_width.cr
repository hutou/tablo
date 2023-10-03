require "tablo"
require "debug"

borders = ["╭┬╮├┼┤╰┴╯│:│─−-⋅",
           "EEEEEEEEEEEE----",
           "ESEESEESEESE----",
           "EDEEDEEDEEDE----",
           "ETEETEETEETE----"]
hdr_freqs = [0, 2]
titles = [false, true]
titles_repeated = [false, true]

borders.each do |border|
  hdr_freqs.each do |hdr_freq|
    titles.each do |title|
      titles_repeated.each do |title_repeated|
        if title
          my_title = Tablo::Title.new("My Title", frame: Tablo::Frame.new, repeated: title_repeated)
        else
          my_title = Tablo::Title.new
        end
        puts "border=\"#{border}\", hdr_freq=\"#{hdr_freq}\", title=\"#{title}\", title_repeated=\"#{title_repeated}\""
        table = Tablo::Table.new([1, 2, 3],
          left_padding: 0, right_padding: 0,
          header_frequency: hdr_freq,
          # header_frequency: 2,
          title: my_title,
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
        puts
        puts
      end
    end
  end
end
