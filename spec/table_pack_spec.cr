require "./spec_helper"

describe "\n\n#{Tablo::Table} -> packing method\n\n", tags: "pack" do
  context "StartingWidths::AutoSized as default" do
    context do
      describe "call = table.pack" do
        it "correctly adapts columns size to their largest value for header" \
           " and body and adapts headings contents inside" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::AutoSized
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("medium") { |n| n[1] }
            t.add_group("Short and medium")
            t.add_column("long") { |n| n[2] }
            t.add_group("Long")
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack}" {% end %}
          output = %q(╭──────────────────────────────────────────────────╮
                      │  This a very long text to be displayed as title  │
                      │                      heading                     │
                      ├──────────────────────────────────────────────────┤
                      │              A very simple subtitle              │
                      ├──────────────────────┬───────────────────────────┤
                      │   Short and medium   :            Long           │
                      ├−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−−−−−−−−−−−−−−┤
                      │ short : medium       : long                      │
                      ├-------┼--------------┼---------------------------┤
                      │ abc   : not so large : Very long column contents │
                      ├───────┴──────────────┴───────────────────────────┤
                      │               Do you need a footer?              │
                      ╰──────────────────────────────────────────────────╯).gsub(/^ */m, "")
          table.pack.to_s.should eq output
        end
      end
    end

    context do
      requested_size = 30
      describe "call = table.pack(#{requested_size}})" do
        it "After autosizing columns, shrinks columns to meet total width requirement" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::AutoSized
          table = Tablo::Table.new([["abc", "Very long column contents"]],

            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),

            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}
          output = %q(╭────────────────────────────╮
                      │  This a very long text to  │
                      │    be displayed as title   │
                      │           heading          │
                      ├────────────────────────────┤
                      │   A very simple subtitle   │
                      ├───────┬────────────────────┤
                      │ short : long               │
                      ├-------┼--------------------┤
                      │ abc   : Very long column   │
                      │       : contents           │
                      ├───────┴────────────────────┤
                      │    Do you need a footer?   │
                      ╰────────────────────────────╯).gsub(/^ */m, "")
          table.pack(requested_size).to_s.should eq output
        end
      end
    end

    context do
      requested_size = 60
      describe "call = table.pack(#{requested_size})" do
        it "After autosizing columns, expands columns to meet total width requirement" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::AutoSized
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}
          output = %q(╭──────────────────────────────────────────────────────────╮
                      │  This a very long text to be displayed as title heading  │
                      ├──────────────────────────────────────────────────────────┤
                      │                  A very simple subtitle                  │
                      ├────────────────────────────┬─────────────────────────────┤
                      │ short                      : long                        │
                      ├----------------------------┼-----------------------------┤
                      │ abc                        : Very long column contents   │
                      ├────────────────────────────┴─────────────────────────────┤
                      │                   Do you need a footer?                  │
                      ╰──────────────────────────────────────────────────────────╯).gsub(/^ */m, "")
          table.pack(requested_size).to_s.should eq output
        end
      end
    end
  end

  context "\n  StartingWidths::Initial as default" do
    context do
      describe "call = table.pack" do
        it "should not do any packing, just reset current column widths " \
           "to their initial value" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::Initial
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack}" {% end %}
          output = %q(╭─────────────────────────────╮
                      │   This a very long text to  │
                      │    be displayed as title    │
                      │           heading           │
                      ├─────────────────────────────┤
                      │    A very simple subtitle   │
                      ├──────────────┬──────────────┤
                      │ short        : long         │
                      ├--------------┼--------------┤
                      │ abc          : Very long    │
                      │              : column       │
                      │              : contents     │
                      ├──────────────┴──────────────┤
                      │    Do you need a footer?    │
                      ╰─────────────────────────────╯).gsub(/^ */m, "")
          table.pack.to_s.should eq output
        end
      end
    end

    context do
      requested_size = 30
      describe "call = table.pack(#{requested_size})" do
        it "resets current column widths to their initial values " \
           "and shrinks columns to meet total width requirement" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::Initial
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}
          output = %q(╭────────────────────────────╮
                      │  This a very long text to  │
                      │    be displayed as title   │
                      │           heading          │
                      ├────────────────────────────┤
                      │   A very simple subtitle   │
                      ├──────────────┬─────────────┤
                      │ short        : long        │
                      ├--------------┼-------------┤
                      │ abc          : Very long   │
                      │              : column      │
                      │              : contents    │
                      ├──────────────┴─────────────┤
                      │    Do you need a footer?   │
                      ╰────────────────────────────╯).gsub(/^ */m, "")
          table.pack(requested_size).to_s.should eq output
        end
      end
    end

    context do
      requested_size = 60
      describe "call = table.pack(#{requested_size})" do
        it "resets current column widths to their initial values " \
           "and expands columns to meet total width requirement" do
          Tablo::Config.starting_widths = Tablo::StartingWidths::Initial
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
            subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
            footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
            border_type: Tablo::BorderName::Fancy) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("long") { |n| n[1] }
          end
          {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}
          output = %q(╭──────────────────────────────────────────────────────────╮
                      │  This a very long text to be displayed as title heading  │
                      ├──────────────────────────────────────────────────────────┤
                      │                  A very simple subtitle                  │
                      ├────────────────────────────┬─────────────────────────────┤
                      │ short                      : long                        │
                      ├----------------------------┼-----------------------------┤
                      │ abc                        : Very long column contents   │
                      ├────────────────────────────┴─────────────────────────────┤
                      │                   Do you need a footer?                  │
                      ╰──────────────────────────────────────────────────────────╯).gsub(/^ */m, "")
          table.pack(requested_size).to_s.should eq output
        end
      end
    end

    context "\n  StartingWidths::Current as default" do
      context do
        describe "call = table.pack" do
          it "should not do anything !" do
            Tablo::Config.starting_widths = Tablo::StartingWidths::Current
            table = Tablo::Table.new([["abc", "Very long column contents"]],
              title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
              subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
              footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
              border_type: Tablo::BorderName::Fancy) do |t|
              t.add_column("short") { |n| n[0] }
              t.add_column("long") { |n| n[1] }
            end
            {% if flag?(:DEBUG) %} puts "\n#{table.pack}" {% end %}
            output = %q(╭─────────────────────────────╮
                        │   This a very long text to  │
                        │    be displayed as title    │
                        │           heading           │
                        ├─────────────────────────────┤
                        │    A very simple subtitle   │
                        ├──────────────┬──────────────┤
                        │ short        : long         │
                        ├--------------┼--------------┤
                        │ abc          : Very long    │
                        │              : column       │
                        │              : contents     │
                        ├──────────────┴──────────────┤
                        │    Do you need a footer?    │
                        ╰─────────────────────────────╯).gsub(/^ */m, "")
            table.pack.to_s.should eq output
          end
        end
      end

      context do
        requested_size = 30
        describe "call = table.pack(#{requested_size})" do
          it "shrinks columns to meet total width requirement" do
            Tablo::Config.starting_widths = Tablo::StartingWidths::Current
            table = Tablo::Table.new([["abc", "Very long column contents"]],
              title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
              subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
              footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
              border_type: Tablo::BorderName::Fancy) do |t|
              t.add_column("short") { |n| n[0] }
              t.add_column("long") { |n| n[1] }
            end
            {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}
            output = %q(╭────────────────────────────╮
                        │  This a very long text to  │
                        │    be displayed as title   │
                        │           heading          │
                        ├────────────────────────────┤
                        │   A very simple subtitle   │
                        ├──────────────┬─────────────┤
                        │ short        : long        │
                        ├--------------┼-------------┤
                        │ abc          : Very long   │
                        │              : column      │
                        │              : contents    │
                        ├──────────────┴─────────────┤
                        │    Do you need a footer?   │
                        ╰────────────────────────────╯).gsub(/^ */m, "")
            table.pack(requested_size).to_s.should eq output
          end
        end
      end

      context do
        requested_size = 60
        describe "call = table.pack(#{requested_size})" do
          it "expands columns to meet total width requirement" do
            Tablo::Config.starting_widths = Tablo::StartingWidths::Current
            table = Tablo::Table.new([["abc", "Very long column contents"]],
              title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
              subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
              footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
              border_type: Tablo::BorderName::Fancy) do |t|
              t.add_column("short") { |n| n[0] }
              t.add_column("long") { |n| n[1] }
            end
            {% if flag?(:DEBUG) %} puts "\n#{table.pack(requested_size)}" {% end %}

            output = %q(╭──────────────────────────────────────────────────────────╮
                        │  This a very long text to be displayed as title heading  │
                        ├──────────────────────────────────────────────────────────┤
                        │                  A very simple subtitle                  │
                        ├────────────────────────────┬─────────────────────────────┤
                        │ short                      : long                        │
                        ├----------------------------┼-----------------------------┤
                        │ abc                        : Very long column contents   │
                        ├────────────────────────────┴─────────────────────────────┤
                        │                   Do you need a footer?                  │
                        ╰──────────────────────────────────────────────────────────╯).gsub(/^ */m, "")
            table.pack(requested_size).to_s.should eq output
          end
        end
      end
    end

    context "\n  StartingWidths::AutoSized as default, excluding column" do
      context do
        describe %(call = table.pack(except: "long")) do
          it "correctly adapts columns size to their largest value for header" \
             " and body, except for excluded column \"long\"" do
            Tablo::Config.starting_widths = Tablo::StartingWidths::AutoSized
            table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
              title: Tablo::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new),
              subtitle: Tablo::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new),
              footer: Tablo::Footer.new("Do you need a footer?", frame: Tablo::Frame.new),
              border_type: Tablo::BorderName::Fancy) do |t|
              t.add_column("short") { |n| n[0] }
              t.add_column("medium") { |n| n[1] }
              t.add_group("Short and medium")
              t.add_column("long") { |n| n[2] }
              t.add_group("Long")
            end
            {% if flag?(:DEBUG) %} puts %(\n#{table.pack(except: "long")}) {% end %}
            output = %q(╭─────────────────────────────────────╮
                        │     This a very long text to be     │
                        │      displayed as title heading     │
                        ├─────────────────────────────────────┤
                        │        A very simple subtitle       │
                        ├──────────────────────┬──────────────┤
                        │   Short and medium   :     Long     │
                        ├−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−┤
                        │ short : medium       : long         │
                        ├-------┼--------------┼--------------┤
                        │ abc   : not so large : Very long    │
                        │       :              : column       │
                        │       :              : contents     │
                        ├───────┴──────────────┴──────────────┤
                        │        Do you need a footer?        │
                        ╰─────────────────────────────────────╯).gsub(/^ */m, "")
            table.pack(except: "long").to_s.should eq output
          end
        end
      end
    end
  end
end
