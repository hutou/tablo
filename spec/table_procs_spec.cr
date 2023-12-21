require "./spec_helper"

class FNumbers
  include Enumerable(Float64)

  def each(&)
    yield 0.0
    yield -10.3
    yield 43.606
    yield -909.0302
    yield 1024.0
  end
end

# define border type for all tests
Tablo::Config.border_type = Tablo::BorderName::Fancy

test_data_numbers = FNumbers.new

describe "#{Tablo::Table} -> Headings and groups formatting and styling" do
  describe "#Formatting headings" do
    it "displays the title in upper case" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("my title",
          formatter: ->(c : Tablo::CellType) { c.as(String).upcase })) do |t|
        t.add_column("itself", &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = "    MY TITLE    \n" +
               %q( ╭──────────────╮
                   │       itself │
                   ├--------------┤
                   │          0.0 │
                   │        -10.3 │
                   │       43.606 │
                   │    -909.0302 │
                   │       1024.0 │
                   ╰──────────────╯).gsub(/^ */m, "")

      table.to_s.should eq output
    end

    it "stretches the title with  dashes" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("my title",
          formatter: ->(c : Tablo::CellType, column_width : Int32) {
            Tablo::Util.stretch(c.as(String),
              width: column_width, insert_char: '-', gap: 1)
          })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end

      # ../tablo_doc/scripts/create_overview.cr:13:      Tablo::Util.stretch(c.to_s.titleize, width: column_width,
      # ../tablo_doc/scripts/create_overview.cr-14-        insert_char: ' ', gap: 2, margin: 4)

      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = "  m-y- -t-i-t-l-e  \n" +
               %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end

    it "stretches the footer with spaces" do
      table = Tablo::Table.new(FNumbers.new,
        footer: Tablo::Footer.new("Footer", frame: Tablo::Frame.new(1, 0),
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: 2) })) do |t|
        t.add_column("itself", width: 16, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %q( ╭──────────────────╮
                   │           itself │
                   ├------------------┤
                   │              0.0 │
                   │            -10.3 │
                   │           43.606 │
                   │        -909.0302 │
                   │           1024.0 │
                   ╰──────────────────╯
                   ╭──────────────────╮
                   │ F  o  o  t  e  r │
                   ╰──────────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
  end
  describe "#Styling headings" do
    it "displays the title in blue" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("my title",
          styler: ->(s : String) { s.colorize(:blue).to_s })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = "      \e[34mmy title\e[0m     \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      else
        output = "      my title     \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end

    it "displays the (possibly) multiline title in different colors" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("This is a very, very, very long title",
          styler: ->(content : String, line : Int32) {
            case line
            when 0
              content.colorize(:blue).to_s
            when 1
              content.colorize(:green).to_s
            else
              content.colorize(:red).to_s
            end
          })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = "     \e[34mThis is a\e[0m     \n" +
                 "    \e[32mvery, very,\e[0m    \n" +
                 "  \e[31mvery long title\e[0m  \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      else
        output = "     This is a     \n" +
                 "    very, very,    \n" +
                 "  very long title  \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "displays the (forced) multiline title in different colors" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Title line 1\nTitle line 2\nTitle line 3",
          styler: ->(content : String, line : Int32) {
            case line
            when 0
              content.colorize(:blue).to_s
            when 1
              content.colorize(:green).to_s
            else
              content.colorize(:red).to_s
            end
          })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = "    \e[34mTitle line 1\e[0m   \n" +
                 "    \e[32mTitle line 2\e[0m   \n" +
                 "    \e[31mTitle line 3\e[0m   \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      else
        output = "    Title line 1   \n" +
                 "    Title line 2   \n" +
                 "    Title line 3   \n" +
                 %q( ╭─────────────────╮
                   │          itself │
                   ├-----------------┤
                   │             0.0 │
                   │           -10.3 │
                   │          43.606 │
                   │       -909.0302 │
                   │          1024.0 │
                   ╰─────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
  end
  describe "#Formatting groups" do
    it "stretches the group content to its best width with spaces" do
      table = Tablo::Table.new([1, 2, 3]) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double") { |n| n * 2 }
        t.add_group("Numbers",
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: 0) })
        t.add_column("stringified") { |n| n.to_s * 7 }
        t.add_group("String",
          # formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 11, ' ') })
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: 0) })
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %q(╭─────────────────────────────┬──────────────╮
                  │  N   u   m   b   e   r   s  :  S t r i n g │
                  ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                  │       itself :       double : stringified  │
                  ├--------------┼--------------┼--------------┤
                  │            1 :            2 : 1111111      │
                  │            2 :            4 : 2222222      │
                  │            3 :            6 : 3333333      │
                  ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
  end
  describe "#Styling groups" do
    it "colorize the group content, funny way, character by character" do
      table = Tablo::Table.new([1, 2, 3]) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double") { |n| n * 2 }
        t.add_group("Numbers",
          formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 25, ' ') },
          styler: ->(s : String) {
            colors = [:blue, :red, :green, :yellow]
            index = 0
            s.chars.map { |c|
              if c == ' '
                c
              elsif ['a', 'e', 'i', 'o', 'u'].includes?(c)
                index += 1
                c.colorize(colors[index % 4]).mode(:bright)
              else
                index += 1
                c.colorize(colors[3 - index % 4]).mode(:bold)
              end
            }.join
          })
        t.add_column("stringified") { |n| n.to_s * 7 }
        t.add_group("String",
          formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 11, ' ') })
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q( ╭─────────────────────────────┬──────────────╮
                   │  \e[32;1mN\e[0m   \e[32;1mu\e[0m   \e[34;1mm\e[0m   \e[33;1mb\e[0m   \e[31;1me\e[0m   \e[31;1mr\e[0m   \e[34;1ms\e[0m  :  S t r i n g │
                   ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                   │       itself :       double : stringified  │
                   ├--------------┼--------------┼--------------┤
                   │            1 :            2 : 1111111      │
                   │            2 :            4 : 2222222      │
                   │            3 :            6 : 3333333      │
                   ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
      else
        output = %Q( ╭─────────────────────────────┬──────────────╮
                   │  N   u   m   b   e   r   s  :  S t r i n g │
                   ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                   │       itself :       double : stringified  │
                   ├--------------┼--------------┼--------------┤
                   │            1 :            2 : 1111111      │
                   │            2 :            4 : 2222222      │
                   │            3 :            6 : 3333333      │
                   ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
  end
end

describe "#{Tablo::Table} -> Headers and body formatting and styling" do
  describe "#Formatting headers" do
    it "by default, justifies headers depending on body cell value type" do
      table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
        title: Tablo::Title.new("Justifying headers", frame: Tablo::Frame.new)) do |t|
        t.add_column("number") { |n| n[0] }
        t.add_column("Booleans") { |n| n[1] }
        t.add_column("Strings") { |n| n[0] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %Q(╭────────────────────────────────────────────╮
                  │             Justifying headers             │
                  ├──────────────┬──────────────┬──────────────┤
                  │       number :   Booleans   :      Strings │
                  ├--------------┼--------------┼--------------┤
                  │            1 :     false    :            1 │
                  │            2 :     true     :            2 │
                  │            3 :     true     :            3 │
                  ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
  end
  describe "#Styling headers" do
    pending "styling headers" do
    end
  end
  describe "#Formatting body" do
    it "displays floating point numbers with 2 decimals" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Floating point formatting", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 15,
          body_formatter: ->(c : Tablo::CellType) { "%.2f" % c.as(Float64) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %Q(╭─────────────────╮
                  │  Floating point │
                  │    formatting   │
                  ├─────────────────┤
                  │          itself │
                  ├-----------------┤
                  │            0.00 │
                  │          -10.30 │
                  │           43.61 │
                  │         -909.03 │
                  │         1024.00 │
                  ╰─────────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
    it "align floating point numbers on decimal point (empty)" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Floating point align (empty)", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 15,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :empty) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %q( ╭─────────────────╮
                   │  Floating point │
                   │  align (empty)  │
                   ├─────────────────┤
                   │          itself │
                   ├-----------------┤
                   │                 │
                   │        -10.3    │
                   │         43.606  │
                   │       -909.0302 │
                   │       1024      │
                   ╰─────────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
    it "align floating point numbers on decimal point (dot_zero)" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Floating point align (dot_zero)", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot_zero) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %q( ╭──────────────────╮
                   │  Floating point  │
                   │ align (dot_zero) │
                   ├──────────────────┤
                   │           itself │
                   ├------------------┤
                   │           0.0    │
                   │         -10.3    │
                   │          43.606  │
                   │        -909.0302 │
                   │        1024.0    │
                   ╰──────────────────╯).gsub(/^ */m, "")
      table.to_s.should eq output
    end
    pending "formatting body" do
    end
  end
  describe "#Styling body" do
    it "unconditionnaly colorizes body contents" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color, blank aligned", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :blank) },
          body_styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │   blank aligned  │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           \e[31m0     \e[0m │
                  │         \e[31m-10.3   \e[0m │
                  │          \e[31m43.606 \e[0m │
                  │        \e[31m-909.0302\e[0m │
                  │        \e[31m1024     \e[0m │
                  ╰──────────────────╯).gsub(/^ */m, "")
      else
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │   blank aligned  │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           0      │
                  │         -10.3    │
                  │          43.606  │
                  │        -909.0302 │
                  │        1024      │
                  ╰──────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes body contents, depending on cell value" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color, blank aligned", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :blank) },
          body_styler: ->(c : Tablo::CellType, s : String) {
            if c.as(Float64) < 0.0
              s.colorize(:red).to_s
            else
              s.colorize(:green).to_s
            end
          },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │   blank aligned  │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           \e[32m0     \e[0m │
                  │         \e[31m-10.3   \e[0m │
                  │          \e[32m43.606 \e[0m │
                  │        \e[31m-909.0302\e[0m │
                  │        \e[32m1024     \e[0m │
                  ╰──────────────────╯).gsub(/^ */m, "")
      else
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │   blank aligned  │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           0      │
                  │         -10.3    │
                  │          43.606  │
                  │        -909.0302 │
                  │        1024      │
                  ╰──────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes body contents, depending on row index" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color, dot aligned", frame: Tablo::Frame.new)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
          body_styler: ->(_c : Tablo::CellType, r : Tablo::CellData, s : String) {
            if r.row_index % 2 == 0
              s.colorize(:blue).to_s
            else
              s.colorize(:magenta).to_s
            end
          },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │    dot aligned   │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           \e[34m0.    \e[0m │
                  │         \e[35m-10.3   \e[0m │
                  │          \e[34m43.606 \e[0m │
                  │        \e[35m-909.0302\e[0m │
                  │        \e[34m1024.    \e[0m │
                  ╰──────────────────╯).gsub(/^ */m, "")
      else
        output = %Q(╭──────────────────╮
                  │  Body in color,  │
                  │    dot aligned   │
                  ├──────────────────┤
                  │           itself │
                  ├------------------┤
                  │           0.     │
                  │         -10.3    │
                  │          43.606  │
                  │        -909.0302 │
                  │        1024.     │
                  ╰──────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row index" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color, dot aligned", frame: Tablo::Frame.new),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::CellData, s : String) {
          if r.row_index % 2 == 0
            s.colorize(:red).to_s
          else
            s.colorize(:blue).to_s
          end
        }) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
          &.itself)
        t.add_column("Double", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64)*2, 4, :dot) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q( ╭─────────────────────────────────────╮
                   │      Body in color, dot aligned     │
                   ├──────────────────┬──────────────────┤
                   │           itself :           Double │
                   ├------------------┼------------------┤
                   │           \e[31m0.    \e[0m :           \e[31m0.    \e[0m │
                   │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
                   │          \e[31m43.606 \e[0m :          \e[31m87.212 \e[0m │
                   │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
                   │        \e[31m1024.    \e[0m :        \e[31m2048.    \e[0m │
                   ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
      else
        output = %Q( ╭─────────────────────────────────────╮
                   │      Body in color, dot aligned     │
                   ├──────────────────┬──────────────────┤
                   │           itself :           Double │
                   ├------------------┼------------------┤
                   │           0.     :           0.     │
                   │         -10.3    :         -20.6    │
                   │          43.606  :          87.212  │
                   │        -909.0302 :       -1818.0604 │
                   │        1024.     :        2048.     │
                   ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row AND column index" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color, dot aligned", frame: Tablo::Frame.new),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::CellData, s : String) {
          if r.row_index % 2 == 0
            if r.column_index % 2 == 0
              s.colorize(:red).to_s
            else
              s.colorize(:yellow).to_s
            end
          else
            s.colorize(:blue).to_s
          end
        }) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
          &.itself)
        t.add_column("Double", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64)*2, 4, :dot) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q( ╭─────────────────────────────────────╮
                   │      Body in color, dot aligned     │
                   ├──────────────────┬──────────────────┤
                   │           itself :           Double │
                   ├------------------┼------------------┤
                   │           \e[31m0.    \e[0m :           \e[33m0.    \e[0m │
                   │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
                   │          \e[31m43.606 \e[0m :          \e[33m87.212 \e[0m │
                   │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
                   │        \e[31m1024.    \e[0m :        \e[33m2048.    \e[0m │
                   ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
      else
        output = %Q( ╭─────────────────────────────────────╮
                   │      Body in color, dot aligned     │
                   ├──────────────────┬──────────────────┤
                   │           itself :           Double │
                   ├------------------┼------------------┤
                   │           0.     :           0.     │
                   │         -10.3    :         -20.6    │
                   │          43.606  :          87.212  │
                   │        -909.0302 :       -1818.0604 │
                   │        1024.     :        2048.     │
                   ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row AND column index AND cell line number" do
      table = Tablo::Table.new(FNumbers.new,
        title: Tablo::Title.new("Body in color\n2nd line of cell in bold", frame: Tablo::Frame.new),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::CellData, s : String, line : Int32) {
          if line == 1
            s.colorize(:magenta).mode(:bold).to_s
          else
            if r.row_index % 2 == 0
              if r.column_index % 2 == 0
                s.colorize(:red).to_s
              else
                s.colorize(:yellow).to_s
              end
            else
              s.colorize(:blue).to_s
            end
          end
        }) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
          &.itself)
        t.add_column("Double", width: 6,
          body_formatter: ->(c : Tablo::CellType) { "%.2f" % [c.as(Float64) * 2] },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = %Q(╭───────────────────────────╮
                  │       Body in color       │
                  │  2nd line of cell in bold │
                  ├──────────────────┬────────┤
                  │           itself : Double │
                  ├------------------┼--------┤
                  │           \e[31m0.    \e[0m :   \e[33m0.00\e[0m │
                  │         \e[34m-10.3   \e[0m : \e[34m-20.60\e[0m │
                  │          \e[31m43.606 \e[0m :  \e[33m87.21\e[0m │
                  │        \e[34m-909.0302\e[0m : \e[34m-1818.\e[0m │
                  │                  :     \e[35;1m06\e[0m │
                  │        \e[31m1024.    \e[0m : \e[33m2048.0\e[0m │
                  │                  :      \e[35;1m0\e[0m │
                  ╰──────────────────┴────────╯).gsub(/^ */m, "")
      else
        output = %Q(╭───────────────────────────╮
                  │       Body in color       │
                  │  2nd line of cell in bold │
                  ├──────────────────┬────────┤
                  │           itself : Double │
                  ├------------------┼--------┤
                  │           0.     :   0.00 │
                  │         -10.3    : -20.60 │
                  │          43.606  :  87.21 │
                  │        -909.0302 : -1818. │
                  │                  :     06 │
                  │        1024.     : 2048.0 │
                  │                  :      0 │
                  ╰──────────────────┴────────╯).gsub(/^ */m, "")
      end
      table.to_s.should eq output
    end
    pending "styling body" do
    end
  end
end
