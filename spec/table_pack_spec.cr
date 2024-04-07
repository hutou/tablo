require "./spec_helper"

def set_border
  Tablo::Border.new(Tablo::Border::Name::Fancy)
end

def set_title
  Tablo::Heading::Title.new("This a very long text to be displayed as title heading", frame: Tablo::Frame.new)
end

def set_subtitle
  Tablo::Heading::SubTitle.new("A very simple subtitle", frame: Tablo::Frame.new)
end

def set_footer
  Tablo::Heading::Footer.new("Do you need a footer?", frame: Tablo::Frame.new)
end

describe "#{Tablo::Table} -> packing method", tags: "pack" do
  context "StartingWidths::AutoSized as default" do
    context do
      describe "call = table.pack" do
        it "correctly adapts columns size to their largest value for header" \
           " and body and adapts headings contents inside" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(starting_widths: Tablo::Table::StartingWidths::AutoSized).to_s.should eq output
        end
      end
    end

    context "" do
      describe "call = table.pack(#{requested_size = 30})" do
        it "After autosizing columns, shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::AutoSized)
            .to_s.should eq output
        end
      end
    end

    context do
      describe "call = table.pack(#{requested_size = 60})" do
        it "After autosizing columns, expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::AutoSized)
            .to_s.should eq output
        end
      end
    end
  end
  context "StartingWidths::Initial as default" do
    context do
      describe "call = table.pack" do
        it "should not do any packing, just reset current column widths " \
           "to their initial value" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(starting_widths: Tablo::Table::StartingWidths::Initial)
            .to_s.should eq output
        end
      end
    end

    context do
      describe "call = table.pack(#{requested_size = 30})" do
        it "resets current column widths to their initial values " \
           "and shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::Initial)
            .to_s.should eq output
        end
      end
    end

    context do
      describe "call = table.pack(#{requested_size = 60})" do
        it "resets current column widths to their initial values " \
           "and expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::Initial)
            .to_s.should eq output
        end
      end
    end
  end

  context "StartingWidths::Current as default" do
    context do
      describe "call = table.pack" do
        it "should not do anything !" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(starting_widths: Tablo::Table::StartingWidths::Current)
            .to_s.should eq output
        end
      end
    end

    context do
      describe "call = table.pack(#{requested_size = 30})" do
        it "shrinks columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::Current)
            .to_s.should eq output
        end
      end
    end

    context do
      describe "call = table.pack(#{requested_size = 60})" do
        it "expands columns to meet total width requirement" do
          table = Tablo::Table.new([["abc", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(requested_size, starting_widths: Tablo::Table::StartingWidths::Current)
            .to_s.should eq output
        end
      end
    end
  end

  context "StartingWidths::AutoSized as default, excluding column" do
    context do
      describe %(call = table.pack(except: "long")) do
        it "correctly adapts columns size to their largest value for header" \
           " and body, except for excluded column \"long\"" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
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
          table.pack(starting_widths: Tablo::Table::StartingWidths::AutoSized,
            except: "long").to_s.should eq output
        end
      end
    end
  end
  context "StartingWidths::AutoSized as default, selecting column" do
    context do
      describe %(call = table.pack(only: "long")) do
        it "correctly adapts columns size to their largest value for header" \
           " and body, only for column \"long\"" do
          table = Tablo::Table.new([["abc", "not so large", "Very long column contents"]],
            border: set_border, title: set_title, subtitle: set_subtitle,
            footer: set_footer) do |t|
            t.add_column("short") { |n| n[0] }
            t.add_column("medium") { |n| n[1] }
            t.add_group("Short and medium")
            t.add_column("long") { |n| n[2] }
            t.add_group("Long")
          end
          {% if flag?(:DEBUG) %}
            puts %(\n#{table.pack(only: "long")})
          {% end %}
          output = %q(╭─────────────────────────────────────────────────────────╮
                      │  This a very long text to be displayed as title heading │
                      ├─────────────────────────────────────────────────────────┤
                      │                  A very simple subtitle                 │
                      ├─────────────────────────────┬───────────────────────────┤
                      │       Short and medium      :            Long           │
                      ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┼−−−−−−−−−−−−−−−−−−−−−−−−−−−┤
                      │ short        : medium       : long                      │
                      ├--------------┼--------------┼---------------------------┤
                      │ abc          : not so large : Very long column contents │
                      ├──────────────┴──────────────┴───────────────────────────┤
                      │                  Do you need a footer?                  │
                      ╰─────────────────────────────────────────────────────────╯).gsub(/^ */m, "")
          table.pack(starting_widths: Tablo::Table::StartingWidths::AutoSized,
            only: "long").to_s.should eq output
        end
      end
    end
  end
end
