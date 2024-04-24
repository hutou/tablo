require "./spec_helper"

Tablo::Config::Defaults.border_definition = Tablo::Border::PreSet::Fancy

test_data_numbers = FloatSamples.new

describe "#{Tablo::Table} -> Headings and groups formatting and styling" do
  describe "#Formatting headings" do
    it "displays the title in upper case" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("my title",
          formatter: ->(c : Tablo::CellType) { c.as(String).upcase })) do |t|
        t.add_column("itself", &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
            MY TITLE    
        ╭──────────────╮
        │       itself │
        ├--------------┤
        │          0.0 │
        │        -10.3 │
        │       43.606 │
        │    -909.0302 │
        │       1024.0 │
        ╰──────────────╯
        EOS
      table.to_s.should eq output
    end

    it "stretches the title with  dashes" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("my title",
          formatter: ->(c : Tablo::CellType, column_width : Int32) {
            Tablo::Util.stretch(c.as(String),
              width: column_width, insert_char: '-', gap: 1)
          })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
          m-y- -t-i-t-l-e  
        ╭─────────────────╮
        │          itself │
        ├-----------------┤
        │             0.0 │
        │           -10.3 │
        │          43.606 │
        │       -909.0302 │
        │          1024.0 │
        ╰─────────────────╯
        EOS
      table.to_s.should eq output
    end

    it "stretches the footer with spaces" do
      table = Tablo::Table.new(FloatSamples.new,
        footer: Tablo::Heading.new("Footer", framed: true, line_breaks_before: 1,
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: 2) })) do |t|
        t.add_column("itself", width: 16, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
        ╭──────────────────╮
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
        ╰──────────────────╯
        EOS
      table.to_s.should eq output
    end
  end
  describe "#Styling headings" do
    it "displays the title in blue" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("my title",
          styler: ->(s : String) { s.colorize(:blue).to_s })) do |t|
        t.add_column("itself", width: 15, &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      # \e[34mmy title\e[0m     \n
      if Tablo::Util.styler_allowed
        output = <<-EOS
                \e[34mmy title\e[0m     
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      else
        output = <<-EOS
                my title     
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      end
      table.to_s.should eq output
    end

    it "displays the (possibly) multiline title in different colors" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("This is a very, very, very long title",
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
        output = <<-EOS
               \e[34mThis is a\e[0m     
              \e[32mvery, very,\e[0m    
            \e[31mvery long title\e[0m  
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      else
        output = <<-EOS
               This is a     
              very, very,    
            very long title  
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "displays the (forced) multiline title in different colors" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Title line 1\nTitle line 2\nTitle line 3",
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
        output = <<-EOS
              \e[34mTitle line 1\e[0m   
              \e[32mTitle line 2\e[0m   
              \e[31mTitle line 3\e[0m   
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      else
        output = <<-EOS
              Title line 1   
              Title line 2   
              Title line 3   
          ╭─────────────────╮
          │          itself │
          ├-----------------┤
          │             0.0 │
          │           -10.3 │
          │          43.606 │
          │       -909.0302 │
          │          1024.0 │
          ╰─────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
  end
  describe "#Formatting groups" do
    it "stretches the group content to its best width with spaces" do
      table = Tablo::Table.new([1, 2, 3]) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double") { |n| n * 2 }
        t.add_group("Numeric",
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: nil) })
        t.add_column("stringified") { |n| n.to_s * 7 }
        t.add_group("String",
          formatter: ->(c : Tablo::CellType, column_width : Int32) { Tablo::Util.stretch(c.as(String),
            width: column_width, insert_char: ' ', gap: nil) })
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
        ╭─────────────────────────────┬──────────────╮
        │  N   u   m   e   r   i   c  :  S t r i n g │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :       double : stringified  │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : 1111111      │
        │            2 :            4 : 2222222      │
        │            3 :            6 : 3333333      │
        ╰──────────────┴──────────────┴──────────────╯
        EOS
      table.to_s.should eq output
    end
  end
  describe "#Styling groups" do
    it "colorize the group content, funny way, character by character" do
      table = Tablo::Table.new([1, 2, 3]) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double") { |n| n * 2 }
        t.add_group("Numeric",
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
        output = <<-EOS
        ╭─────────────────────────────┬──────────────╮
        │  \e[32;1mN\e[0m   \e[32;1mu\e[0m   \e[34;1mm\e[0m   \e[34;1me\e[0m   \e[32;1mr\e[0m   \e[32;1mi\e[0m   \e[34;1mc\e[0m  :  S t r i n g │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :       double : stringified  │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : 1111111      │
        │            2 :            4 : 2222222      │
        │            3 :            6 : 3333333      │
        ╰──────────────┴──────────────┴──────────────╯
        EOS
      else
        output = <<-EOS
        ╭─────────────────────────────┬──────────────╮
        │  N   u   m   e   r   i   c  :  S t r i n g │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :       double : stringified  │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : 1111111      │
        │            2 :            4 : 2222222      │
        │            3 :            6 : 3333333      │
        ╰──────────────┴──────────────┴──────────────╯
        EOS
      end
      table.to_s.should eq output
    end
  end
end

describe "#{Tablo::Table} -> Headers and body formatting and styling" do
  describe "#Formatting headers" do
    it "by default, justifies headers depending on body cell value type" do
      table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
        title: Tablo::Heading.new("Justifying headers", framed: true)) do |t|
        t.add_column("number") { |n| n[0] }
        t.add_column("Booleans") { |n| n[1] }
        t.add_column("Strings") { |n| n[0] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
          ╭────────────────────────────────────────────╮
          │             Justifying headers             │
          ├──────────────┬──────────────┬──────────────┤
          │       number :   Booleans   :      Strings │
          ├--------------┼--------------┼--------------┤
          │            1 :     false    :            1 │
          │            2 :     true     :            2 │
          │            3 :     true     :            3 │
          ╰──────────────┴──────────────┴──────────────╯
          EOS
      table.to_s.should eq output
    end
  end
  describe "#Styling headers" do
    pending "styling headers" do
    end
  end
  describe "#Formatting body" do
    it "displays floating point numbers with 2 decimals" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Floating point formatting", framed: true)) do |t|
        t.add_column("itself", width: 15,
          body_formatter: ->(c : Tablo::CellType) { "%.2f" % c.as(Float64) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
        ╭─────────────────╮
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
        ╰─────────────────╯
        EOS
      table.to_s.should eq output
    end
    it "align floating point numbers on decimal point (blank)" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Floating point align (blank)", framed: true)) do |t|
        t.add_column("itself", width: 15,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :blank) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
        ╭─────────────────╮
        │  Floating point │
        │  align (blank)  │
        ├─────────────────┤
        │          itself │
        ├-----------------┤
        │                 │
        │        -10.3    │
        │         43.606  │
        │       -909.0302 │
        │       1024      │
        ╰─────────────────╯
        EOS
      table.to_s.should eq output
    end

    it "align floating point numbers on decimal point (dot_zero)" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Floating point align (dot_zero)", framed: true)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :dot_zero) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = <<-EOS
        ╭──────────────────╮
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
        ╰──────────────────╯
        EOS
      table.to_s.should eq output
    end
    pending "formatting body" do
    end
  end
  describe "#Styling body" do
    it "unconditionnaly colorizes body contents" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color, nodot aligned", framed: true)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :no_dot) },
          body_styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = <<-EOS
          ╭──────────────────╮
          │  Body in color,  │
          │   nodot aligned  │
          ├──────────────────┤
          │           itself │
          ├------------------┤
          │           \e[31m0     \e[0m │
          │         \e[31m-10.3   \e[0m │
          │          \e[31m43.606 \e[0m │
          │        \e[31m-909.0302\e[0m │
          │        \e[31m1024     \e[0m │
          ╰──────────────────╯
          EOS
      else
        output = <<-EOS
          ╭──────────────────╮
          │  Body in color,  │
          │   nodot aligned  │
          ├──────────────────┤
          │           itself │
          ├------------------┤
          │           0      │
          │         -10.3    │
          │          43.606  │
          │        -909.0302 │
          │        1024      │
          ╰──────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes body contents, depending on cell value" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color, nodot aligned", framed: true)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :no_dot) },
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
        output = <<-EOS
          ╭──────────────────╮
          │  Body in color,  │
          │   nodot aligned  │
          ├──────────────────┤
          │           itself │
          ├------------------┤
          │           \e[32m0     \e[0m │
          │         \e[31m-10.3   \e[0m │
          │          \e[32m43.606 \e[0m │
          │        \e[31m-909.0302\e[0m │
          │        \e[32m1024     \e[0m │
          ╰──────────────────╯
          EOS
      else
        output = <<-EOS
          ╭──────────────────╮
          │  Body in color,  │
          │   nodot aligned  │
          ├──────────────────┤
          │           itself │
          ├------------------┤
          │           0      │
          │         -10.3    │
          │          43.606  │
          │        -909.0302 │
          │        1024      │
          ╰──────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes body contents, depending on row index" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color, dot aligned", framed: true)) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :dot_only) },
          body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
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
        output = <<-EOS
          ╭──────────────────╮
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
          ╰──────────────────╯
          EOS
      else
        output = <<-EOS
          ╭──────────────────╮
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
          ╰──────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row index" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
          if r.row_index % 2 == 0
            s.colorize(:red).to_s
          else
            s.colorize(:blue).to_s
          end
        }) do |t|
        t.add_column("itself", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :dot_only) },
          &.itself)
        t.add_column("Double", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64)*2, 4, :dot_only) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = <<-EOS
          ╭─────────────────────────────────────╮
          │      Body in color, dot aligned     │
          ├──────────────────┬──────────────────┤
          │           itself :           Double │
          ├------------------┼------------------┤
          │           \e[31m0.    \e[0m :           \e[31m0.    \e[0m │
          │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
          │          \e[31m43.606 \e[0m :          \e[31m87.212 \e[0m │
          │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
          │        \e[31m1024.    \e[0m :        \e[31m2048.    \e[0m │
          ╰──────────────────┴──────────────────╯
          EOS
      else
        output = <<-EOS
          ╭─────────────────────────────────────╮
          │      Body in color, dot aligned     │
          ├──────────────────┬──────────────────┤
          │           itself :           Double │
          ├------------------┼------------------┤
          │           0.     :           0.     │
          │         -10.3    :         -20.6    │
          │          43.606  :          87.212  │
          │        -909.0302 :       -1818.0604 │
          │        1024.     :        2048.     │
          ╰──────────────────┴──────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row AND column index" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String) {
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
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :dot_only) },
          &.itself)
        t.add_column("Double", width: 16,
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64)*2, 4, :dot_only) },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = <<-EOS
          ╭─────────────────────────────────────╮
          │      Body in color, dot aligned     │
          ├──────────────────┬──────────────────┤
          │           itself :           Double │
          ├------------------┼------------------┤
          │           \e[31m0.    \e[0m :           \e[33m0.    \e[0m │
          │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
          │          \e[31m43.606 \e[0m :          \e[33m87.212 \e[0m │
          │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
          │        \e[31m1024.    \e[0m :        \e[33m2048.    \e[0m │
          ╰──────────────────┴──────────────────╯
          EOS
      else
        output = <<-EOS
          ╭─────────────────────────────────────╮
          │      Body in color, dot aligned     │
          ├──────────────────┬──────────────────┤
          │           itself :           Double │
          ├------------------┼------------------┤
          │           0.     :           0.     │
          │         -10.3    :         -20.6    │
          │          43.606  :          87.212  │
          │        -909.0302 :       -1818.0604 │
          │        1024.     :        2048.     │
          ╰──────────────────┴──────────────────╯
          EOS
      end
      table.to_s.should eq output
    end
    it "conditionnaly colorizes row's body contents, depending on row AND column index AND cell line number" do
      table = Tablo::Table.new(FloatSamples.new,
        title: Tablo::Heading.new("Body in color\n2nd line of cell in bold", framed: true),
        body_styler: ->(_c : Tablo::CellType, r : Tablo::Cell::Data::Coords, s : String, line : Int32) {
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
          body_formatter: ->(c : Tablo::CellType) { Tablo.dot_align(c.as(Float64), 4, :dot_only) },
          &.itself)
        t.add_column("Double", width: 6,
          body_formatter: ->(c : Tablo::CellType) { "%.2f" % [c.as(Float64) * 2] },
          &.itself)
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      if Tablo::Util.styler_allowed
        output = <<-EOS
          ╭───────────────────────────╮
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
          ╰──────────────────┴────────╯
          EOS
      else
        output = <<-EOS
          ╭───────────────────────────╮
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
          ╰──────────────────┴────────╯
          EOS
      end
      table.to_s.should eq output
    end
    pending "styling body" do
    end
  end
end
