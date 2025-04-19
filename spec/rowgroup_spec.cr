require "./spec_helper"

class IntSamples
  include Enumerable(Int32)

  def each(&)
    # yield 0
    yield 1
    yield 7
    yield 10
    yield 13
    yield 42
    yield 43
    yield 59
    yield 66
  end
end

describe "#{Tablo::RowGroup} -> Sequences of row types (Title, subtitle, " +
         "group, header, body and footer", tags: "rowgroup" do
  context "header_frequency=nil" do
    context "title framed, subtitle framed, footer framed" do
      it "does not display any title, subtitle, header or footer" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          subtitle: Tablo::Heading.new("Subtitle", framed: true),
          footer: Tablo::Heading.new("Footer", framed: true),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭──────────────┬──────────────┬──────────────╮
          │            7 :           14 : 2.6457513110 │
          │              :              :       645907 │
          │           10 :           20 : 3.1622776601 │
          │              :              :       683795 │
          │           13 :           26 : 3.6055512754 │
          │              :              :        63989 │
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end
  end

  context "header_frequency=0" do
    context "title framed, no subtitle" do
      it "displays framed title, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_after: 1),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, no subtitle" do
      it "displays framed & joined title, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title, no subtitle" do
      it "displays unframed title, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
                              Numeric                   
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
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, subtitle framed & joinable" do
      it "displays framed joined title and subtitle, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          subtitle: Tablo::Heading.new("Integers and float", framed: true),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed, subtitle framed" do
      it "displays framed title and subtitle, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_after: 1),
          subtitle: Tablo::Heading.new("Integers and float", framed: true, line_breaks_after: 1),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, subtitle framed" do
      it "displays framed title and subtitle, both joined, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          subtitle: Tablo::Heading.new("Integers and float", framed: true, line_breaks_after: 1),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, subtitle" do
      it "displays framed title, unframed subtitle, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          subtitle: Tablo::Heading.new("Integers and float"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
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
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, subtitle, footer framed" do
      it "displays framed title, unframed subtitle, and framed footer, with headers" do
        table = Tablo::Table.new(IntSamples.new.select(7..13),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true),
          subtitle: Tablo::Heading.new("Integers and float"),
          footer: Tablo::Heading.new("end of data", framed: true, line_breaks_before: 1),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
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
          OUTPUT
        table.to_s.should eq expected_output
      end
    end
  end

  context "header_frequency=3" do
    context "title framed, subtitle" do
      it "displays framed title, unframed subtitle after body" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_before: 1, repeated: true),
          subtitle: Tablo::Heading.new("Integers and float"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
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
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
          ╭──────────────┬──────────────┬──────────────╮
          │       itself :       Double :         Sqrt │
          ├--------------┼--------------┼--------------┤
          │           42 :           84 : 6.4807406984 │
          │              :              :         0786 │
          │           43 :           86 : 6.5574385243 │
          │              :              :           02 │
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title framed & joinable, subtitle" do
      it "displays framed & joined title, unframed subtitle after body" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, repeated: true),
          subtitle: Tablo::Heading.new("Integers and float"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
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
          │                   Numeric                  │
          ╰────────────────────────────────────────────╯
                        Integers and float              
          ╭──────────────┬──────────────┬──────────────╮
          │       itself :       Double :         Sqrt │
          ├--------------┼--------------┼--------------┤
          │           42 :           84 : 6.4807406984 │
          │              :              :         0786 │
          │           43 :           86 : 6.5574385243 │
          │              :              :           02 │
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "title and subtitle" do
      it "displays unframed title, unframed subtitle after body" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", repeated: true),
          subtitle: Tablo::Heading.new("Integers and float"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
                              Numeric                   
                        Integers and float              
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
                              Numeric                   
                        Integers and float              
          ╭──────────────┬──────────────┬──────────────╮
          │       itself :       Double :         Sqrt │
          ├--------------┼--------------┼--------------┤
          │           42 :           84 : 6.4807406984 │
          │              :              :         0786 │
          │           43 :           86 : 6.5574385243 │
          │              :              :           02 │
          ╰──────────────┴──────────────┴──────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "footer --> title" do
      it "displays framed & body-joined footer, page break and framed title" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_before: 1,
            line_breaks_after: 1, repeated: true),
          footer: Tablo::Heading.new("end of data", framed: true, page_break: true),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰────────────────────────────────────────────╯\f
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "framed title and framed & joinable footer" do
      it "displays framed & body-joined footer and framed title" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_after: 1, repeated: true),
          footer: Tablo::Heading.new("end of data", framed: true, line_breaks_after: 1),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end

        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰────────────────────────────────────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "framed title and framed footer" do
      it "displays framed and framed title" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_before: 1, line_breaks_after: 1, repeated: true),
          footer: Tablo::Heading.new("end of data", framed: true, line_breaks_before: 1),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end

        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰────────────────────────────────────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "framed title and framed footer, both joined" do
      it "displays joined framed footer and title" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true, line_breaks_after: 1, repeated: true),
          footer: Tablo::Heading.new("end of data", framed: true, line_breaks_before: 1),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end

        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰────────────────────────────────────────────╯
          OUTPUT
        table.to_s.should eq expected_output
      end
    end

    context "framed title and framed footer, both joined" do
      it "displays joined framed footer and title" do
        table = Tablo::Table.new(IntSamples.new.select(7..43),
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Numeric", framed: true,
            line_breaks_after: 1, repeated: true),
          footer: Tablo::Heading.new("end of data", framed: true,
            line_breaks_before: 1, line_breaks_after: 1, page_break: true),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("Double", &.*(2))
          t.add_column("Sqrt", &.**(0.5))
        end

        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        expected_output = <<-OUTPUT
          ╭────────────────────────────────────────────╮
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
          ╰────────────────────────────────────────────╯\f
          OUTPUT
        table.to_s.should eq expected_output
      end
    end
  end

  describe "Table with summary" do
    it "prints a detached summary" do
      table = Tablo::Table.new((1..5).to_a,
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        title: Tablo::Heading.new("Numeric", framed: true),
        masked_headers: false,
        row_divider_frequency: 1,
        omit_last_rule: true,
        header_frequency: 0) do |t|
        t.add_column("itself", &.itself)
        t.add_column("Double", &.*(2))
        t.add_group("Integers")
        t.add_column("Sqrt", &.**(0.5))
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = 0
              sum_flt = 0
              sum_int = (table.column_data("itself").map &.as(Int32)).sum
              sum_flt = (table.column_data("Sqrt").map &.as(Float64)).sum
              {:sum_int => sum_int.as(Tablo::CellType),
               :sum_flt => sum_flt.as(Tablo::CellType)}
            }),
            Tablo::Summary::HeaderColumn.new("itself", "Somme"),
            Tablo::Summary::HeaderColumn.new("Double", ""),
            Tablo::Summary::HeaderColumn.new("Sqrt", "Sum"),
            Tablo::Summary::BodyRow.new("itself", 1, -> { Tablo::Summary.use(:sum_int) }),
            Tablo::Summary::BodyRow.new("Sqrt", 1, -> { Tablo::Summary.use(:sum_flt) }),
          ],
          title: Tablo::Heading.new("Summary", framed: true, line_breaks_before: 1),
        )
      end
      expected_output = <<-OUTPUT
        ╭────────────────────────────────────────────╮
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
        │              :              :         9979 │
        ╰──────────────┴──────────────┴──────────────╯
        ╭────────────────────────────────────────────╮
        │                   Summary                  │
        ├──────────────┬──────────────┬──────────────┤
        │        Somme :              :          Sum │
        ├--------------┼--------------┼--------------┤
        │           15 :              : 8.3823323474 │
        │              :              :        41762 │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, with spacing" do
      table = Tablo::Table.new((1..5).to_a,
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        title: Tablo::Heading.new("Numeric", framed: true),
        masked_headers: false,
        row_divider_frequency: 1,
        omit_last_rule: true,
        header_frequency: 0) do |t|
        t.add_column("itself", &.itself)
        t.add_column("Double", &.*(2))
        t.add_group("Integers")
        t.add_column("Sqrt", &.**(0.5))
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data("itself").map &.as(Int32)).sum
              sum_flt = (table.column_data("Sqrt").map &.as(Float64)).sum
              {:sum_int => sum_int.as(Tablo::CellType),
               :sum_flt => sum_flt.as(Tablo::CellType)}
            }),
            Tablo::Summary::HeaderColumn.new("itself", "Somme"),
            Tablo::Summary::HeaderColumn.new("Double", ""),
            Tablo::Summary::HeaderColumn.new("Sqrt", "Sum"),
            Tablo::Summary::BodyRow.new("itself", 1, -> { Tablo::Summary.use(:sum_int) }),
            Tablo::Summary::BodyRow.new("Sqrt", 1, -> { Tablo::Summary.use(:sum_flt) }),
          ],
          title: Tablo::Heading.new("Summary", framed: true, line_breaks_before: 3),
        )
      end
      expected_output = <<-OUTPUT
        ╭────────────────────────────────────────────╮
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
        │              :              :         9979 │
        ╰──────────────┴──────────────┴──────────────╯\n\n
        ╭────────────────────────────────────────────╮
        │                   Summary                  │
        ├──────────────┬──────────────┬──────────────┤
        │        Somme :              :          Sum │
        ├--------------┼--------------┼--------------┤
        │           15 :              : 8.3823323474 │
        │              :              :        41762 │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary" do
      table = Tablo::Table.new((1..5).to_a,
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        title: Tablo::Heading.new("Numeric", framed: true),
        masked_headers: false,
        row_divider_frequency: 1,
        omit_last_rule: true,
        header_frequency: 0) do |t|
        t.add_column("itself", &.itself)
        t.add_column("Double", &.*(2))
        t.add_group("Integers")
        t.add_column("Sqrt", &.**(0.5))
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data("itself").map &.as(Int32)).sum
              sum_flt = (table.column_data("Sqrt").map &.as(Float64)).sum
              {:sum_int => sum_int.as(Tablo::CellType),
               :sum_flt => sum_flt.as(Tablo::CellType)}
            }),
            Tablo::Summary::HeaderColumn.new("itself", "Somme"),
            Tablo::Summary::HeaderColumn.new("Double", ""),
            Tablo::Summary::HeaderColumn.new("Sqrt", "Sum"),
            Tablo::Summary::BodyRow.new("itself", 1, -> { Tablo::Summary.use(:sum_int) }),
            Tablo::Summary::BodyRow.new("Sqrt", 1, -> { Tablo::Summary.use(:sum_flt) }),
          ],
          title: Tablo::Heading.new("Summary", framed: true),
        )
      end
      expected_output = <<-OUTPUT
        ╭────────────────────────────────────────────╮
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
        │              :              :         9979 │
        ├──────────────┴──────────────┴──────────────┤
        │                   Summary                  │
        ├──────────────┬──────────────┬──────────────┤
        │        Somme :              :          Sum │
        ├--------------┼--------------┼--------------┤
        │           15 :              : 8.3823323474 │
        │              :              :        41762 │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=0, oml: false, from Body" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ╰──────────────┴──────────────┴──────────────╯
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary, hf=0, oml: true, from Body" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┼──────────────┼──────────────┤
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf: nil, oml: false, from Body" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        subtitle: Tablo::Heading.new("No booleans"),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ╰──────────────┴──────────────┴──────────────╯
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary, hf: nil, oml: true, from Body" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        subtitle: Tablo::Heading.new("No booleans"),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┼──────────────┼──────────────┤
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=0, oml: false, from footer, pgbrk: false" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┴──────────────┴──────────────┤
        │                 End of page                │
        ╰────────────────────────────────────────────╯
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=0, oml: false, from footer, pgbrk: true" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true, page_break: true),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┴──────────────┴──────────────┤
        │                 End of page                │
        ╰────────────────────────────────────────────╯\f
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary, hf=0, oml: true, from footer, pgbrk: false" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┴──────────────┴──────────────┤
        │                 End of page                │
        ├──────────────┬──────────────┬──────────────┤
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=0, oml: true, from footer, pgbrk: true" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: 0,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true, page_break: true),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭─────────────────────────────┬──────────────╮
        │                             : Text         │
        ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
        │       itself :              :              │
        ├--------------┼--------------┼--------------┤
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┴──────────────┴──────────────┤
        │                 End of page                │\f
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=nil, oml: false, from footer, pgbrk: false" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        title: Tablo::Heading.new("Numeric and text", framed: true,
          line_breaks_after: 2),
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ╰──────────────┴──────────────┴──────────────╯
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a detached summary, hf=nil, oml: false, from footer, pgbrk: true" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true, page_break: true),
        omit_last_rule: false) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ╰──────────────┴──────────────┴──────────────╯
        ╭──────────────┬──────────────┬──────────────╮
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary, hf=nil, oml: true, from footer, pgbrk: false" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┼──────────────┼──────────────┤
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end

    it "prints a joined summary, hf=nil, oml: true, from footer, pgbrk: true" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
        header_frequency: nil,
        subtitle: Tablo::Heading.new("No booleans"),
        footer: Tablo::Heading.new("End of page", framed: true, page_break: true),
        omit_last_rule: true) do |t|
        t.add_column("itself", &.itself)
        t.add_column(2, header: "") { |n| n * 2 }
        t.add_group("")
        t.add_column(:column_3, header: "") { |n| n.even?.to_s }
        t.add_group("Text", alignment: Tablo::Justify::Left)
        t.add_summary(
          [
            Tablo::Summary::UserProc.new(proc: ->(table : Tablo::Table(Int32)) {
              sum_int = (table.column_data(2).map &.as(Int32)).sum
              {:sum_int => sum_int.as(Tablo::CellType)}
            }),
            Tablo::Summary::BodyRow.new(2, 1, -> { Tablo::Summary.use(:sum_int) }),
          ],
          header_frequency: nil)
      end
      expected_output = <<-OUTPUT
        ╭──────────────┬──────────────┬──────────────╮
        │            1 :            2 : false        │
        │            2 :            4 : true         │
        │            3 :            6 : false        │
        ├──────────────┼──────────────┼──────────────┤
        │              :           12 :              │
        ╰──────────────┴──────────────┴──────────────╯
        OUTPUT
      {% if flag?(:DEBUG) %}
        puts ""
        puts table
        puts table.summary
      {% end %}
      (table.to_s + "\n" + table.summary.to_s).should eq expected_output
    end
  end
end
