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

rest_data_numbers = FNumbers.new

describe "#{Tablo::Table} -> packing methods" do
  # ---------- #autosize_columns ---------------------------------------------------
  #
  #
  describe "#autosize_columns" do
    it "expands or shrinks columns appropriately" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short") { |n| n[0] }
        t.add_column("long") { |n| n[1] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table.autosize_columns}" {% end %}
      output = %q(╭───────┬───────────────────────────╮
                  │ short : long                      │
                  ├-------┼---------------------------┤
                  │ abc   : Very long column contents │
                  ╰───────┴───────────────────────────╯).gsub(/^ */m, "")

      # table.autosize_columns.to_s.should eq output
      table.pack(nil).to_s.should eq output
    end
    it "expands or shrinks columns appropriately and defines title width" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        title: Tablo::FramedHeading.new("This a very long text to be displayed as title heading"),
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short") { |n| n[0] }
        t.add_column("long") { |n| n[1] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table.autosize_columns}" {% end %}
      output = %q(╭───────────────────────────────────╮
                  │    This a very long text to be    │
                  │     displayed as title heading    │
                  ├───────┬───────────────────────────┤
                  │ short : long                      │
                  ├-------┼---------------------------┤
                  │ abc   : Very long column contents │
                  ╰───────┴───────────────────────────╯).gsub(/^ */m, "")

      # table.autosize_columns.to_s.should eq output
      table.pack(nil).to_s.should eq output
    end
    it "expands or shrinks columns appropriately and defines group width" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short") { |n| n[0] }
        t.add_column("long") { |n| n[1] }
        t.add_group("This a very long text to be displayed as group heading")
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      {% if flag?(:DEBUG) %} puts "\n#{table.autosize_columns}" {% end %}
      output = %q(╭───────────────────────────────────╮
                  │    This a very long text to be    │
                  │     displayed as group heading    │
                  ├−−−−−−−┬−−−−−−−−−−−−−−−−−−−−−−−−−−−┤
                  │ short : long                      │
                  ├-------┼---------------------------┤
                  │ abc   : Very long column contents │
                  ╰───────┴───────────────────────────╯).gsub(/^ */m, "")

      # table.autosize_columns.to_s.should eq output
      table.pack(nil).to_s.should eq output
    end
    it "expands or shrinks columns appropriately and defines group width, with column exclusion" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short") { |n| n[0] }
        t.add_column("long") { |n| n[1] }
        t.add_group("This a very long text to be displayed as group heading")
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      {% if flag?(:DEBUG) %} puts "\n#{table.autosize_columns(except: "long")}" {% end %}
      output = %q(╭──────────────────────╮
                  │   This a very long   │
                  │      text to be      │
                  │  displayed as group  │
                  │        heading       │
                  ├−−−−−−−┬−−−−−−−−−−−−−−┤
                  │ short : long         │
                  ├-------┼--------------┤
                  │ abc   : Very long    │
                  │       : column       │
                  │       : contents     │
                  ╰───────┴──────────────╯).gsub(/^ */m, "")
      # table.autosize_columns(except: "long").to_s.should eq output
      table.pack(nil, except: "long").to_s.should eq output
    end
  end

  # ---------- #shrink_to ----------------------------------------------------------
  #
  #
  describe "#shrink_to" do
    it "shrinks columns to adjust table width" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short", width: 7) { |n| n[0] }
        t.add_column("long", width: 20) { |n| n[1] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table.pack(25)}" {% end %}
      output = %q(╭───────┬───────────────╮
                  │ short : long          │
                  ├-------┼---------------┤
                  │ abc   : Very long     │
                  │       : column        │
                  │       : contents      │
                  ╰───────┴───────────────╯).gsub(/^ */m, "")
      # table.shrink_to(25).to_s.should eq output
      table.pack(25).to_s.should eq output
    end

    it "shrinks columns to adjust table width, with excepted columns" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short", width: 7) { |n| n[0] }
        t.add_column("long", width: 20) { |n| n[1] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      {% if flag?(:DEBUG) %} puts "\n#{table.pack(30, except: "long")}" {% end %}
      output = %q( ╭─────┬──────────────────────╮
                   │ sho : long                 │
                   │ rt  :                      │
                   ├-----┼----------------------┤
                   │ abc : Very long column     │
                   │     : contents             │
                   ╰─────┴──────────────────────╯).gsub(/^ */m, "")
      table.pack(30, except: "long").to_s.should eq output
    end

    it "does nothing if table width is <= required width" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short", width: 7) { |n| n[0] }
        t.add_column("long", width: 20) { |n| n[1] }
      end
      output1 = table.to_s
      {% if flag?(:DEBUG) %} puts "\n#{output1}" {% end %}
      # output2 = table.shrink_to(34).to_s
      output2 = table.pack(34, init: :reset).to_s
      {% if flag?(:DEBUG) %} puts "\n#{output2}" {% end %}
      output1.should eq output2
    end

    it "shrinks columns to adjust table width, with respect to minimum" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short", width: 7) { |n| n[0] }
        t.add_column("long", width: 20) { |n| n[1] }
      end
      {% if flag?(:DEBUG) %} puts "\n#{table.pack(3)}" {% end %}
      output = %q(╭───┬───╮
                  │ s : l │
                  │ h : o │
                  │ o : n │
                  │ r : g │
                  │ t :   │
                  ├---┼---┤
                  │ a : V │
                  │ b : e │
                  │ c : r │
                  │   : y │
                  │   : l │
                  │   : o │
                  │   : n │
                  │   : g │
                  │   : c │
                  │   : o │
                  │   : l │
                  │   : u │
                  │   : m │
                  │   : n │
                  │   : c │
                  │   : o │
                  │   : n │
                  │   : t │
                  │   : e │
                  │   : n │
                  │   : t │
                  │   : s │
                  ╰───┴───╯).gsub(/^ */m, "")
      # table.shrink_to(3).to_s.should eq output
      table.pack(3).to_s.should eq output
    end
    it "shrinks columns to adjust table width, with respect to minimum, and excepted columns" do
      table = Tablo::Table.new([["abc", "Very long column contents"]],
        border_type: Tablo::BorderName::Fancy) do |t|
        t.add_column("short", width: 7) { |n| n[0] }
        t.add_column("long", width: 20) { |n| n[1] }
      end

      # {% if flag?(:DEBUG) %} puts "\n#{table.shrink_to(3, except: "long")}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table.shrink_to(3, except: "long")}" {% end %}
      {% if flag?(:DEBUG) %} puts "\n#{table.pack(-100)}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table.pack(table_width: :screen)}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table.pack(:screen)}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table.expand_to(520, except: ["short", "long"])}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      # {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
      output = %q(╭───┬──────────────────────╮
                  │ s : long                 │
                  │ h :                      │
                  │ o :                      │
                  │ r :                      │
                  │ t :                      │
                  ├---┼----------------------┤
                  │ a : Very long column     │
                  │ b : contents             │
                  │ c :                      │
                  ╰───┴──────────────────────╯).gsub(/^ */m, "")
      # table.shrink_to(3, except: "long").to_s.should eq output
      table.pack(3, except: "long", init: :reset).to_s.should eq output
    end
  end
end

# it "stretches the title with  dashes" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("my title",
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 15, '-') }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15, &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = "  m-y---t-i-t-l-e  \n" +
#            %q( ╭─────────────────╮
#                │          itself │
#                ├-----------------┤
#                │             0.0 │
#                │           -10.3 │
#                │          43.606 │
#                │       -909.0302 │
#                │          1024.0 │
#                ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end

# it "stretches the footer with spaces" do
#   table = Tablo::Table.new(FNumbers.new,
#     footer: Tablo::Heading.new("Footer", framed: true, line_breaks_before: 1,
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 16, ' ') }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16, &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %q( ╭──────────────────╮
#                │           itself │
#                ├------------------┤
#                │              0.0 │
#                │            -10.3 │
#                │           43.606 │
#                │        -909.0302 │
#                │           1024.0 │
#                ╰──────────────────╯
#                ╭──────────────────╮
#                │ F  o  o  t  e  r │
#                ╰──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# end
# describe "#Styling headings" do
# it "displays the title in blue" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("my title",
#       styler: ->(s : String) { s.colorize(:blue).to_s }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15, &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = "      \e[34mmy title\e[0m     \n" +
#            %q( ╭─────────────────╮
#                │          itself │
#                ├-----------------┤
#                │             0.0 │
#                │           -10.3 │
#                │          43.606 │
#                │       -909.0302 │
#                │          1024.0 │
#                ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end

# it "displays the (possibly) multiline title in different colors" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("This is a very, very, very long title",
#       styler: ->(content : String, line : Int32) {
#         case line
#         when 0
#           content.colorize(:blue).to_s
#         when 1
#           content.colorize(:green).to_s
#         else
#           content.colorize(:red).to_s
#         end
#       }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15, &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = "     \e[34mThis is a\e[0m     \n" +
#            "    \e[32mvery, very,\e[0m    \n" +
#            "  \e[31mvery long title\e[0m  \n" +
#            %q( ╭─────────────────╮
#                │          itself │
#                ├-----------------┤
#                │             0.0 │
#                │           -10.3 │
#                │          43.606 │
#                │       -909.0302 │
#                │          1024.0 │
#                ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "displays the (forced) multiline title in different colors" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Title line 1\nTitle line 2\nTitle line 3",
#       styler: ->(content : String, line : Int32) {
#         case line
#         when 0
#           content.colorize(:blue).to_s
#         when 1
#           content.colorize(:green).to_s
#         else
#           content.colorize(:red).to_s
#         end
#       }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15, &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = "    \e[34mTitle line 1\e[0m   \n" +
#            "    \e[32mTitle line 2\e[0m   \n" +
#            "    \e[31mTitle line 3\e[0m   \n" +
#            %q( ╭─────────────────╮
#                │          itself │
#                ├-----------------┤
#                │             0.0 │
#                │           -10.3 │
#                │          43.606 │
#                │       -909.0302 │
#                │          1024.0 │
#                ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# end
# describe "#Formatting groups" do
# it "stretches the group content to its best width with spaces" do
#   table = Tablo::Table.new([1, 2, 3],
#     # footer: Tablo::Heading.new("Footer", framed: true, line_breaks_before: 1,
#     #   formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 16, ' ') }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", &.itself)
#     t.add_column("double") { |n| n * 2 }
#     t.add_group("Numbers",
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 25, ' ') })
#     t.add_column("stringified") { |n| n.to_s * 7 }
#     t.add_group("String",
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 11, ' ') })
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %q(╭─────────────────────────────┬──────────────╮
#               │  N   u   m   b   e   r   s  :  S t r i n g │
#               ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
#               │       itself :       double : stringified  │
#               ├--------------┼--------------┼--------------┤
#               │            1 :            2 : 1111111      │
#               │            2 :            4 : 2222222      │
#               │            3 :            6 : 3333333      │
#               ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# end
# describe "#Styling groups" do
# it "colorize the group content, funny way, character by character" do
#   table = Tablo::Table.new([1, 2, 3],
#     # footer: Tablo::Heading.new("Footer", framed: true, line_breaks_before: 1,
#     #   formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 16, ' ') }),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", &.itself)
#     t.add_column("double") { |n| n * 2 }
#     t.add_group("Numbers",
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 25, ' ') },
#       styler: ->(s : String) {
#         colors = [:blue, :red, :green, :yellow]
#         index = 0
#         s.chars.map { |c|
#           if c == ' '
#             c
#           elsif ['a', 'e', 'i', 'o', 'u'].includes?(c)
#             index += 1
#             c.colorize(colors[index % 4]).mode(:bright)
#           else
#             index += 1
#             c.colorize(colors[3 - index % 4]).mode(:bold)
#           end
#         }.join
#       })
#     t.add_column("stringified") { |n| n.to_s * 7 }
#     t.add_group("String",
#       formatter: ->(c : Tablo::CellType) { Tablo::Util.stretch(c.as(String), 11, ' ') })
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q( ╭─────────────────────────────┬──────────────╮
#                │  \e[32;1mN\e[0m   \e[32;1mu\e[0m   \e[34;1mm\e[0m   \e[33;1mb\e[0m   \e[31;1me\e[0m   \e[31;1mr\e[0m   \e[34;1ms\e[0m  :  S t r i n g │
#                ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
#                │       itself :       double : stringified  │
#                ├--------------┼--------------┼--------------┤
#                │            1 :            2 : 1111111      │
#                │            2 :            4 : 2222222      │
#                │            3 :            6 : 3333333      │
#                ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# end
# end

# describe "#{Tablo::Table} -> Headers and body formatting and styling" do
# describe "#Formatting headers" do
# it "by default, justifies headers depending on body cell value type" do
#   table = Tablo::Table.new([[1, false, "Abc"], [2, true, "def"], [3, true, "ghi"]],
#     title: Tablo::Heading.new("Justifying headers", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("number") { |n| n[0] }
#     t.add_column("Booleans") { |n| n[1] }
#     t.add_column("Strings") { |n| n[0] }
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭────────────────────────────────────────────╮
#               │             Justifying headers             │
#               ├──────────────┬──────────────┬──────────────┤
#               │       number :   Booleans   :      Strings │
#               ├--------------┼--------------┼--------------┤
#               │            1 :     false    :            1 │
#               │            2 :     true     :            2 │
#               │            3 :     true     :            3 │
#               ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# end
# describe "#Styling headers" do
# pending "styling headers" do
# end
# end
# describe "#Formatting body" do
# it "displays floating point numbers with 2 decimals" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Floating point formatting", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15,
#       body_formatter: ->(c : Tablo::CellType) { "%.2f" % c.as(Float64) },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭─────────────────╮
#               │  Floating point │
#               │    formatting   │
#               ├─────────────────┤
#               │          itself │
#               ├-----------------┤
#               │            0.00 │
#               │          -10.30 │
#               │           43.61 │
#               │         -909.03 │
#               │         1024.00 │
#               ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "align floating point numbers on decimal point (empty)" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Floating point align (empty)", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 15,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :empty) },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %q( ╭─────────────────╮
#                │  Floating point │
#                │  align (empty)  │
#                ├─────────────────┤
#                │          itself │
#                ├-----------------┤
#                │                 │
#                │        -10.3    │
#                │         43.606  │
#                │       -909.0302 │
#                │       1024      │
#                ╰─────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "align floating point numbers on decimal point (dot_zero)" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Floating point align (dot_zero)", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot_zero) },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %q( ╭──────────────────╮
#                │  Floating point  │
#                │ align (dot_zero) │
#                ├──────────────────┤
#                │           itself │
#                ├------------------┤
#                │           0.0    │
#                │         -10.3    │
#                │          43.606  │
#                │        -909.0302 │
#                │        1024.0    │
#                ╰──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# pending "formatting body" do
# end
# end
# describe "#Styling body" do
# it "unconditionnaly colorizes body contents" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color, blank aligned", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :blank) },
#       body_styler: ->(_c : Tablo::CellType, s : String) { s.colorize(:red).to_s },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭──────────────────╮
#               │  Body in color,  │
#               │   blank aligned  │
#               ├──────────────────┤
#               │           itself │
#               ├------------------┤
#               │           \e[31m0     \e[0m │
#               │         \e[31m-10.3   \e[0m │
#               │          \e[31m43.606 \e[0m │
#               │        \e[31m-909.0302\e[0m │
#               │        \e[31m1024     \e[0m │
#               ╰──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "conditionnaly colorizes body contents, depending on cell value" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color, blank aligned", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :blank) },
#       body_styler: ->(c : Tablo::CellType, s : String) {
#         if c.as(Float64) < 0.0
#           s.colorize(:red).to_s
#         else
#           s.colorize(:green).to_s
#         end
#       },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭──────────────────╮
#               │  Body in color,  │
#               │   blank aligned  │
#               ├──────────────────┤
#               │           itself │
#               ├------------------┤
#               │           \e[32m0     \e[0m │
#               │         \e[31m-10.3   \e[0m │
#               │          \e[32m43.606 \e[0m │
#               │        \e[31m-909.0302\e[0m │
#               │        \e[32m1024     \e[0m │
#               ╰──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "conditionnaly colorizes body contents, depending on row index" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
#       body_styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData) {
#         if r.row_index % 2 == 0
#           s.colorize(:blue).to_s
#         else
#           s.colorize(:magenta).to_s
#         end
#       },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭──────────────────╮
#               │  Body in color,  │
#               │    dot aligned   │
#               ├──────────────────┤
#               │           itself │
#               ├------------------┤
#               │           \e[34m0.    \e[0m │
#               │         \e[35m-10.3   \e[0m │
#               │          \e[34m43.606 \e[0m │
#               │        \e[35m-909.0302\e[0m │
#               │        \e[34m1024.    \e[0m │
#               ╰──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "conditionnaly colorizes row's body contents, depending on row index" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
#     body_styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData) {
#       if r.row_index % 2 == 0
#         s.colorize(:red).to_s
#       else
#         s.colorize(:blue).to_s
#       end
#     },
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
#       &.itself)
#     t.add_column("Double", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64)*2, 4, :dot) },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q( ╭─────────────────────────────────────╮
#                │      Body in color, dot aligned     │
#                ├──────────────────┬──────────────────┤
#                │           itself :           Double │
#                ├------------------┼------------------┤
#                │           \e[31m0.    \e[0m :           \e[31m0.    \e[0m │
#                │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
#                │          \e[31m43.606 \e[0m :          \e[31m87.212 \e[0m │
#                │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
#                │        \e[31m1024.    \e[0m :        \e[31m2048.    \e[0m │
#                ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "conditionnaly colorizes row's body contents, depending on row AND column index" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color, dot aligned", framed: true),
#     body_styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData) {
#       if r.row_index % 2 == 0
#         if r.column_index % 2 == 0
#           s.colorize(:red).to_s
#         else
#           s.colorize(:yellow).to_s
#         end
#       else
#         s.colorize(:blue).to_s
#       end
#     },
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
#       &.itself)
#     t.add_column("Double", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64)*2, 4, :dot) },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q( ╭─────────────────────────────────────╮
#                │      Body in color, dot aligned     │
#                ├──────────────────┬──────────────────┤
#                │           itself :           Double │
#                ├------------------┼------------------┤
#                │           \e[31m0.    \e[0m :           \e[33m0.    \e[0m │
#                │         \e[34m-10.3   \e[0m :         \e[34m-20.6   \e[0m │
#                │          \e[31m43.606 \e[0m :          \e[33m87.212 \e[0m │
#                │        \e[34m-909.0302\e[0m :       \e[34m-1818.0604\e[0m │
#                │        \e[31m1024.    \e[0m :        \e[33m2048.    \e[0m │
#                ╰──────────────────┴──────────────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# it "conditionnaly colorizes row's body contents, depending on row AND column index AND cell line number" do
#   table = Tablo::Table.new(FNumbers.new,
#     title: Tablo::Heading.new("Body in color\n2nd line of cell in bold", framed: true),
#     body_styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData, line : Int32) {
#       if line == 1
#         s.colorize(:magenta).mode(:bold).to_s
#       else
#         if r.row_index % 2 == 0
#           if r.column_index % 2 == 0
#             s.colorize(:red).to_s
#           else
#             s.colorize(:yellow).to_s
#           end
#         else
#           s.colorize(:blue).to_s
#         end
#       end
#     },
#     border_type: Tablo::BorderName::Fancy) do |t|
#     t.add_column("itself", width: 16,
#       body_formatter: ->(c : Tablo::CellType) { Tablo::Util.dot_align(c.as(Float64), 4, :dot) },
#       &.itself)
#     t.add_column("Double", width: 6,
#       body_formatter: ->(c : Tablo::CellType) { "%.2f" % [c.as(Float64) * 2] },
#       &.itself)
#   end
#   {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
#   output = %Q(╭───────────────────────────╮
#               │       Body in color       │
#               │  2nd line of cell in bold │
#               ├──────────────────┬────────┤
#               │           itself : Double │
#               ├------------------┼--------┤
#               │           \e[31m0.    \e[0m :   \e[33m0.00\e[0m │
#               │         \e[34m-10.3   \e[0m : \e[34m-20.60\e[0m │
#               │          \e[31m43.606 \e[0m :  \e[33m87.21\e[0m │
#               │        \e[34m-909.0302\e[0m : \e[34m-1818.\e[0m │
#               │                  :     \e[35;1m06\e[0m │
#               │        \e[31m1024.    \e[0m : \e[33m2048.0\e[0m │
#               │                  :      \e[35;1m0\e[0m │
#               ╰──────────────────┴────────╯).gsub(/^ */m, "")
#   table.to_s.should eq output
# end
# pending "styling body" do
# end
# end
# end
