require "./spec_helper"

# For these specs, border_type if BorderName::Fancy, to better see
# border transitions between rows

describe "#{Tablo::RowGroup} -> Sequences of row types (Title, subtitle, " +
         "group, header, body and footer" do
  describe "# Title, subtitle and footer variations, *NO* summary" do
    context "header_frequency=nil" do
      context "title framed, subtitle framed, footer framed" do
        it "does not display any title, subtitle, header or footer" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers"),
            subtitle: Tablo::HeadingFramed.new("Subtitle"),
            footer: Tablo::HeadingFramed.new("Footer"),
            border_type: Tablo::BorderName::Fancy,
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
          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end
    end

    context "header_frequency=0" do
      context "title framed, no subtitle" do
        it "correctly displays framed title, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers", spacing_after: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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

      context "title framed & linkable, no subtitle" do
        it "correctly displays framed & linked title, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers", spacing_after: 0),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title, no subtitle" do
        it "correctly displays unframed title, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFree.new("Numbers"),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = "                    Numbers                   " + "\n" +
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

      context "title framed & linkable, subtitle framed & linkable" do
        it "correctly displays framed linked title and subtitle, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_after: 0),
            subtitle: Tablo::HeadingFramed.new("Integers and float",
              spacing_after: 0),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title framed, subtitle framed" do
        it "correctly displays framed title and subtitle, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_after: 1),
            subtitle: Tablo::HeadingFramed.new("Integers and float",
              spacing_after: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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

          # Test 2 times to check if table is correctly reset after display
          table.to_s.should eq output
          table.to_s.should eq output
        end
      end

      context "title framed & linkable, subtitle framed" do
        it "correctly displays framed title and subtitle, both linked, with headers" do
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_after: 0),
            subtitle: Tablo::HeadingFramed.new("Integers and float",
              spacing_after: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers"),
            subtitle: Tablo::HeadingFree.new("Integers and float"),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..13),
            title: Tablo::HeadingFramed.new("Numbers"),
            subtitle: Tablo::HeadingFree.new("Integers and float"),
            footer: Tablo::HeadingFramed.new("end of data",
              spacing_before: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 0) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_before: 1),
            title_repeated: true,
            subtitle: Tablo::HeadingFree.new("Integers and float"),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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

      context "title framed & linkable, subtitle" do
        it "correctly displays framed & linked title, unframed subtitle after body" do
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers", spacing_before: 0),
            title_repeated: true,
            subtitle: Tablo::HeadingFree.new("Integers and float"),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFree.new("Numbers"),
            title_repeated: true,
            subtitle: Tablo::HeadingFree.new("Integers and float"),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = "                    Numbers                   " + "\n" +
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
                   "                    Numbers                   " + "\n" +
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_before: 1, spacing_after: 1),
            title_repeated: true,
            footer: Tablo::HeadingFramed.new("end of data", spacing_before: 0),
            footer_page_break: true,
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end
          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers", spacing_after: 1),
            title_repeated: true,
            footer: Tablo::HeadingFramed.new("end of data",
              spacing_before: 0, spacing_after: 1),
            footer_page_break: false,
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_after: 1, spacing_before: 1),
            title_repeated: true,
            footer: Tablo::HeadingFramed.new("end of data",
              spacing_before: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_before: 0, spacing_after: 1),
            title_repeated: true,
            footer: Tablo::HeadingFramed.new("end of data",
              spacing_before: 1),
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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
          table = Tablo::Table.new(Numbers.new.select(7..43),
            title: Tablo::HeadingFramed.new("Numbers",
              spacing_before: 0, spacing_after: 1),
            title_repeated: true,
            footer: Tablo::HeadingFramed.new("end of data",
              spacing_before: 1, spacing_after: 1),
            footer_page_break: true,
            border_type: Tablo::BorderName::Fancy,
            header_frequency: 3) do |t|
            t.add_column("itself", &.itself)
            t.add_column("Double", &.*(2))
            t.add_column("Sqrt", &.**(0.5))
          end

          {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
          output = %Q(╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
                      │                   Numbers                  │
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

    context "Table with summary" do
      it "prints a detached summary" do
        table = Tablo::Table.new((1..5).to_a,
          title: Tablo::HeadingFramed.new("Numbers"),
          masked_headers: false,
          border_type: Tablo::BorderName::Fancy,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: ->(ary : Tablo::Numbers) { ary.sum.to_i },
            },
            "Sqrt" => {header: "Sum",
                       proc: ->(ary : Tablo::Numbers) { ary.sum },
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::HeadingFramed.new("Summary", spacing_before: 1),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
        table.to_s.should eq output1
        table.summary.to_s.should eq output2
        {% if flag?(:DEBUG) %}
          puts ""
          puts table
          puts table.summary
        {% end %}
      end
      it "prints a detached summary, with spacing" do
        table = Tablo::Table.new((1..5).to_a,
          title: Tablo::HeadingFramed.new("Numbers"),
          masked_headers: false,
          border_type: Tablo::BorderName::Fancy,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: ->(ary : Tablo::Numbers) { ary.sum.to_i },
            },
            "Sqrt" => {header: "Sum",
                       proc: ->(ary : Tablo::Numbers) { ary.sum },
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::HeadingFramed.new("Summary", spacing_before: 3),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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
          title: Tablo::HeadingFramed.new("Numbers"),
          masked_headers: false,
          border_type: Tablo::BorderName::Fancy,
          row_divider_frequency: 1,
          omit_last_rule: true,
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_group("Integers")
          t.add_column("Sqrt", &.**(0.5))
          t.summary({
            "itself" => {header: "Somme",
                         proc: ->(ary : Tablo::Numbers) { ary.sum.to_i },
            },
            "Sqrt" => {header: "Sum",
                       proc: ->(ary : Tablo::Numbers) { ary.sum },
            },
          },
            omit_last_rule: false,
            masked_headers: false,
            title: Tablo::HeadingFramed.new("Summary", spacing_before: 0),
          )
        end
        output1 = %Q( ╭────────────────────────────────────────────╮
                      │                   Numbers                  │
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

      pending "TEST TEST TEST" do
        it "prints results !", focus: true do
          # table = Tablo::Table.new(Numbers.new.select(7..43),
          table = Tablo::Table.new((1..5).to_a,
            title: Tablo::HeadingFramed.new("Numbers"),
            masked_headers: false,
            border_type: Tablo::BorderName::Fancy,
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
                           proc: ->(ary : Tablo::Numbers) { ary.sum.to_i },
              },
              "Sqrt" => {header: "Sum",
                         proc: ->(ary : Tablo::Numbers) { ary.sum },
              },
            },
              omit_last_rule: false,
              masked_headers: false,
              title: Tablo::HeadingFramed.new("Summary", spacing_before: 0),
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
