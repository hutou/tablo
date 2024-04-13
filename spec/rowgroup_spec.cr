require "./spec_helper"

# class IntSamples
#   include Enumerable(Int32)

#   def each(&)
#     # yield 0
#     yield 1
#     yield 7
#     yield 10
#     yield 13
#     yield 42
#     yield 43
#     yield 59
#     yield 66
#   end
# end

# For these specs, border_definition if Border::PreSet::Fancy, to better see
# border transitions between rows
##
# define border type for all tests
# Tablo::Config::Defaults.border_definition = Tablo::Border::PreSet::Fancy

describe "#{Tablo::RowGroup} -> Sequences of row types (Title, subtitle, " +
         "group, header, body and footer", tags: "rowgroup" do
  describe "# Title, subtitle and footer variations, *NO* summary" do
    pending "header_frequency=nil" do
      context "title framed, subtitle framed, footer framed" do
        it "does not display any title, subtitle, header or footer" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            subtitle: Tablo::Heading::SubTitle.new("Subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Heading::Footer.new("Footer", frame: Tablo::Frame.new),
            header_frequency: nil) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭──────────────┬──────────────┬──────────────╮
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
          table.to_s.should eq output
        end
      end
    end

    context "header_frequency=0" do
      context "title framed, no subtitle" do
        it "correctly displays framed title, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(0, 1)),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          # table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title framed & linkable, no subtitle" do
        it "correctly displays framed & linked title, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├──────────────┬──────────────┬──────────────┤
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
          table.to_s.should eq output
        end
      end

      context "title, no subtitle" do
        it "correctly displays unframed title, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric"),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = "                    Numeric                   " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle framed & linkable" do
        it "correctly displays framed linked title and subtitle, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float", frame: Tablo::Frame.new),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├────────────────────────────────────────────┤
                      │             Integers and float             │
                      ├──────────────┬──────────────┬──────────────┤
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          table.to_s.should eq output
        end
      end

      context "title framed, subtitle framed" do
        it "correctly displays framed title and subtitle, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(0, 1)),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float", frame: Tablo::Frame.new(0, 1)),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭────────────────────────────────────────────╮
                      │             Integers and float             │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle framed" do
        it "correctly displays framed title and subtitle, both linked, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float", frame: Tablo::Frame.new(0, 1)),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├────────────────────────────────────────────┤
                      │             Integers and float             │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle" do
        it "correctly displays framed title, unframed subtitle, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float"),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle, footer framed" do
        it "correctly displays framed title, unframed subtitle, and framed footer, with headers" do
          table = Tablo::Table.new(IntSamples.new.select(7..13),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float"),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new(1, 0)),
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end
    end

    context "header_frequency=3" do
      context "title framed, subtitle" do
        it "correctly displays framed title, unframed subtitle after body" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(1, 0), repeated: true),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle" do
        it "correctly displays framed & linked title, unframed subtitle after body" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new, repeated: true),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ├──────────────┴──────────────┴──────────────┤
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "") + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title and subtitle" do
        it "correctly displays unframed title, unframed subtitle after body" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", repeated: true),
            subtitle: Tablo::Heading::SubTitle.new("Integers and float"),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = "                    Numeric                   " + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "") + "\n" +
                   "                    Numeric                   " + "\n" +
                   "              Integers and float              " + "\n" +
                   %q(╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "footer --> title" do
        it "correctly displays framed & body-linked footer, page break and framed title" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(1, 1), repeated: true),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new, page_break: true),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ├──────────────┴──────────────┴──────────────┤
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯\f
                      ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      │              :              :              │
                      ├──────────────┴──────────────┴──────────────┤
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯\f).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "framed title and framed & linkable footer" do
        it "correctly displays framed & body-linked footer and framed title" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(0, 1), repeated: true),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new(0, 1)),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ├──────────────┴──────────────┴──────────────┤
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯
                      ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      │              :              :              │
                      ├──────────────┴──────────────┴──────────────┤
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "framed title and framed footer" do
        it "correctly displays framed and framed title" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(1, 1), repeated: true),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new(1, 0)),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯
                      ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      │              :              :              │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "framed title and framed footer, both linked" do
        it "correctly displays linked framed footer and title" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(0, 1), repeated: true),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new(1, 0)),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ├────────────────────────────────────────────┤
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      │              :              :              │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "framed title and framed footer, both linked" do
        it "correctly displays linked framed footer and title" do
          table = Tablo::Table.new(IntSamples.new.select(7..43),
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new(0, 1), repeated: true),
            footer: Tablo::Heading::Footer.new("end of data", frame: Tablo::Frame.new(1, 1), page_break: true),
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            7 :           14 : 2.6457513110 │
                      │              :              :       645907 │
                      │           10 :           20 : 3.1622776601 │
                      │              :              :       683795 │
                      │           13 :           26 : 3.6055512754 │
                      │              :              :        63989 │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯\f
                      ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ╰────────────────────────────────────────────╯
                      ╭──────────────┬──────────────┬──────────────╮
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │           42 :           84 : 6.4807406984 │
                      │              :              :         0786 │
                      │           43 :           86 : 6.5574385243 │
                      │              :              :           02 │
                      │              :              :              │
                      ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                 end of data                │
                      ╰────────────────────────────────────────────╯\f).gsub(/^ */m, "")

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end
    end

    pending "Table with summary" do
      it "prints a detached summary" do
        table = Tablo::Table.new((1..5).to_a,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
          masked_headers: false,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: {1, ->(ary : Array(Tablo::CellType)) {
                           (ary.select(&.is_a?(Number)).map &.as(Number)).sum.to_i.as(Tablo::CellType)
                         }},
            },
            "Sqrt" => {header: "Sum",
                       proc: {1, ->(ary : Array(Tablo::CellType)) {
                         ar = ary.select(&.is_a?(Number)).map &.as(Float64)
                         (ary.select(&.is_a?(Number)).map &.as(Float64)).sum.as(Tablo::CellType)
                       }},
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new(1, 0)),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├─────────────────────────────┬──────────────┤
                      │           Integers          :              │
                      ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            1 :            2 :          1.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            2 :            4 : 1.4142135623 │
                      │              :              :       730951 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            3 :            6 : 1.7320508075 │
                      │              :              :       688772 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            4 :            8 :          2.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            5 :           10 : 2.2360679774 │
                      │              :              :         9979 │).gsub(/^ */m, "")

        output2 = %Q( ╰──────────────┴──────────────┴──────────────╯
                      ╭────────────────────────────────────────────╮
                      │                   Summary                  │
                      ├──────────────┬──────────────┬──────────────┤
                      │        Somme :              :          Sum │
                      ├--------------┼--------------┼--------------┤
                      │           15 :              : 8.3823323474 │
                      │              :              :        41762 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
      end
      it "prints a detached summary, with spacing" do
        table = Tablo::Table.new((1..5).to_a,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
          masked_headers: false,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: {1, ->(ary : Tablo::SourcesCurrentColumn) {
                           (ary.select(&.is_a?(Number)).map &.as(Number)).sum.to_i.as(Tablo::CellType)
                         }},
            },
            "Sqrt" => {header: "Sum",
                       proc: {1, ->(ary : Tablo::SourcesCurrentColumn) {
                         (ary.select(&.is_a?(Number)).map &.as(Float64)).sum.as(Tablo::CellType)
                       }},
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new(3, 0)),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├─────────────────────────────┬──────────────┤
                      │           Integers          :              │
                      ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            1 :            2 :          1.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            2 :            4 : 1.4142135623 │
                      │              :              :       730951 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            3 :            6 : 1.7320508075 │
                      │              :              :       688772 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            4 :            8 :          2.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            5 :           10 : 2.2360679774 │
                      │              :              :         9979 │).gsub(/^ */m, "")

        output2 = "╰──────────────┴──────────────┴──────────────╯\n \n \n" +
                  %Q( ╭────────────────────────────────────────────╮
                      │                   Summary                  │
                      ├──────────────┬──────────────┬──────────────┤
                      │        Somme :              :          Sum │
                      ├--------------┼--------------┼--------------┤
                      │           15 :              : 8.3823323474 │
                      │              :              :        41762 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
      end

      it "prints a linked summary" do
        table = Tablo::Table.new((1..5).to_a,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
          masked_headers: false,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: {1, ->(ary : Array(Tablo::CellType)) {
                           # (ary.select(&.is_a?(Number)).map &.as(Number)).sum(0.0).to_i.as(Tablo::CellType)
                           (ary.map &.as(Number)).sum(0.0).to_i.as(Tablo::CellType)
                           # ary.sum(0.0).to_i.as(Tablo::CellType)
                         }},
            },
            "Sqrt" => {header: "Sum",
                       proc: {1, ->(ary : Array(Tablo::CellType)) {
                         (ary.select(&.is_a?(Number)).map &.as(Number)).sum(0.0).as(Tablo::CellType)
                       }},
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numeric                  │
                      ├─────────────────────────────┬──────────────┤
                      │           Integers          :              │
                      ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                      │       itself :       Double :         Sqrt │
                      ├--------------┼--------------┼--------------┤
                      │            1 :            2 :          1.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            2 :            4 : 1.4142135623 │
                      │              :              :       730951 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            3 :            6 : 1.7320508075 │
                      │              :              :       688772 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            4 :            8 :          2.0 │
                      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
                      │            5 :           10 : 2.2360679774 │
                      │              :              :         9979 │).gsub(/^ */m, "")

        output2 = %Q( ├──────────────┴──────────────┴──────────────┤
                      │                   Summary                  │
                      ├──────────────┬──────────────┬──────────────┤
                      │        Somme :              :          Sum │
                      ├--------------┼--------------┼--------------┤
                      │           15 :              : 8.3823323474 │
                      │              :              :        41762 │
                      ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a detached summary, hf=0, oml: false, from Body" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0,2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          # footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end

        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a linked summary, hf=0, oml: true, from Body" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          # footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end

        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │).gsub(/^ */m, "")
        output2 = %Q(├──────────────┼──────────────┼──────────────┤
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a detached summary, hf: nil, oml: false, from Body" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          # footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end

        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a linked summary, hf: nil, oml: true, from Body" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0,2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          # footer: Tablo::Heading::Footer.new("End of page"; frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end

        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │).gsub(/^ */m, "")
        output2 = %Q(├──────────────┼──────────────┼──────────────┤
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a detached summary, hf=0, oml: false, from footer, pgbrk: false" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ├──────────────┴──────────────┴──────────────┤
                     │                 End of page                │
                     ╰────────────────────────────────────────────╯).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      it "prints a detached summary, hf=0, oml: false, from footer, pgbrk: true" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame(0,2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ├──────────────┴──────────────┴──────────────┤
                     │                 End of page                │
                     ╰────────────────────────────────────────────╯\f).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
      end
      it "prints a linked summary, hf=0, oml: true, from footer, pgbrk: false" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ├──────────────┴──────────────┴──────────────┤
                     │                 End of page                │).gsub(/^ */m, "")
        output2 = %Q(├──────────────┬──────────────┬──────────────┤
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
      end
      it "prints a detached summary, hf=0, oml: true, from footer, pgbrk: true" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0,
          # title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭─────────────────────────────┬──────────────╮
                     │                             : Text         │
                     ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                     │       itself :              :              │
                     ├--------------┼--------------┼--------------┤
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ├──────────────┴──────────────┴──────────────┤
                     │                 End of page                │\f).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end

      it "prints a detached summary, hf=nil, oml: false, from footer, pgbrk: false" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          title: Tablo::Heading::Title.new("Numeric and text", frame: Tablo::Frame.new(0, 2)),
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      it "prints a detached summary, hf=nil, oml: false, from footer, pgbrk: true" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: false) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        output2 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      it "prints a linked summary, hf=nil, oml: true, from footer, pgbrk: false" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │).gsub(/^ */m, "")
        output2 = %Q(├──────────────┼──────────────┼──────────────┤
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")

        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      it "prints a linked summary, hf=nil, oml: true, from footer, pgbrk: true" do
        table = Tablo::Table.new([1, 2, 3],
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil,
          subtitle: Tablo::Heading::SubTitle.new("No booleans"),
          footer: Tablo::Heading::Footer.new("End of page", frame: Tablo::Frame.new, page_break: true),
          omit_last_rule: true) do |t|
          t.add_column("itself", &.itself)
          t.add_column(2, header: "") { |n| n * 2 }
          t.add_group("")
          t.add_column(:column_3, header: "") { |n| n.even?.to_s }
          t.add_group("Text", alignment: Tablo::Justify::Left)
          t.summary({
            2 => {header: "somme",
                  proc: [
                    {1, ->(ary : Array(Tablo::CellType)) {
                      (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                    }},
                  ],
            },
          }, # masked_headers: true,
            title: Tablo::Heading::Title.new("Summary"),
            header_frequency: nil,
            omit_last_rule: false)
        end
        output1 = %Q(╭──────────────┬──────────────┬──────────────╮
                     │            1 :            2 : false        │
                     │            2 :            4 : true         │
                     │            3 :            6 : false        │).gsub(/^ */m, "")
        output2 = %Q(├──────────────┼──────────────┼──────────────┤
                     │              :         12.0 :              │
                     ╰──────────────┴──────────────┴──────────────╯).gsub(/^ */m, "")
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      pending "TEST TEST TEST" do
        it "prints results !" do
          table = Tablo::Table.new((1..5).to_a,
            border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
            title: Tablo::Heading::Title.new("Numeric", frame: Tablo::Frame.new),
            masked_headers: false,
            border_definition: Tablo::Border::PreSet::Fancy,
            row_divider_frequency: 1,
            omit_last_rule: true,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_group("Integers")
            t.add_column("Sqrt", &.**(0.5))
            # t.add_group("Float")
            t.add_summary({
              "itself" => {header: "Somme",
                           proc: [
                             {1, ->(ary : Array(Tablo::CellType)) {
                               (ary.select(&.is_a?(Number)).map &.as(Number)).sum.to_i.as(Tablo::CellType)
                             }},
                           ],
              },
              "Sqrt" => {header: "Sum",
                         proc: [
                           {1, ->(ary : Array(Tablo::CellType)) {
                             (ary.select(&.is_a?(Number)).map &.as(Number)).sum.as(Tablo::CellType)
                           }},
                         ],
              },
            },
              omit_last_rule: false,
              masked_headers: false,
              title: Tablo::Heading::Title.new("Summary", frame: Tablo::Frame.new),
            )
          end

          {% if flag?(:DEBUG) %}
            puts ""
            puts table
            puts table.summary
          {% end %}
        end
      end
    end
  end
end
