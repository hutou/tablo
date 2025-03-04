require "./spec_helper"

# border specs uses a basic table and checks rendering for all presets
# and somme string definitions

describe Tablo::Border do
  describe "Border presets (using enum or symbol)" do
    it "creates a border from :ascii" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(:ascii),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      +-----------------------------+
      |            Title            |
      +-----------------------------+
      |           SubTitle          |
      +--------------+--------------+
      |       itself |       double |
      +--------------+--------------+
      |            1 |            2 |
      +--------------+--------------+
      |            2 |            4 |
      +--------------+--------------+
      |            3 |            6 |
      +--------------+--------------+
      |            Footer           |
      +-----------------------------+
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from PreSet::ReducedAscii" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::ReducedAscii),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      -----------------------------
                  Title            
      -----------------------------
                 SubTitle          
      -------------- --------------
             itself         double 
      -------------- --------------
                  1              2 
      -------------- --------------
                  2              4 
      -------------- --------------
                  3              6 
      -------------- --------------
                  Footer           
      -----------------------------
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from PreSet::Modern" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Modern),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      ┌─────────────────────────────┐
      │            Title            │
      ├─────────────────────────────┤
      │           SubTitle          │
      ├──────────────┬──────────────┤
      │       itself │       double │
      ├──────────────┼──────────────┤
      │            1 │            2 │
      ├──────────────┼──────────────┤
      │            2 │            4 │
      ├──────────────┼──────────────┤
      │            3 │            6 │
      ├──────────────┴──────────────┤
      │            Footer           │
      └─────────────────────────────┘
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from PreSet::ReducedModern" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::ReducedModern),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      ─────────────────────────────
                  Title            
      ─────────────────────────────
                 SubTitle          
      ────────────── ──────────────
             itself         double 
      ────────────── ──────────────
                  1              2 
      ────────────── ──────────────
                  2              4 
      ────────────── ──────────────
                  3              6 
      ────────────── ──────────────
                  Footer           
      ─────────────────────────────
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from PreSet::Markdown" do
      table = Tablo::Table.new([1, 2, 3],
        # Do not use title, nor subtitle, nor footer for markdown table
        border: Tablo::Border.new(Tablo::Border::PreSet::Markdown)) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      |       itself |       double |
      |--------------|--------------|
      |            1 |            2 |
      |            2 |            4 |
      |            3 |            6 |
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from :fancy" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(:fancy),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      ╭─────────────────────────────╮
      │            Title            │
      ├─────────────────────────────┤
      │           SubTitle          │
      ├──────────────┬──────────────┤
      │       itself :       double │
      ├--------------┼--------------┤
      │            1 :            2 │
      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
      │            2 :            4 │
      ├⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┼⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅┤
      │            3 :            6 │
      ├──────────────┴──────────────┤
      │            Footer           │
      ╰─────────────────────────────╯
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from PreSet::Blank" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(Tablo::Border::PreSet::Blank),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
                                     
                   Title             
                                     
                  SubTitle           
                                     
              itself         double  
                                     
                   1              2  
                                     
                   2              4  
                                     
                   3              6  
                                     
                   Footer            
                                     
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from :empty" do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new(:empty),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
                  Title           
                SubTitle          
             itself        double 
                  1             2 
                  2             4 
                  3             6 
                 Footer           
      OUTPUT
      table.to_s.should eq(expected_output)
    end
  end

  describe "Border strings" do
    it "raises an exception on incorrect string length definition" do
      expect_raises Tablo::Error::InvalidBorderDefinition do
        border = Tablo::Border.new("abcdefghijklmnopz")
      end
    end

    it "creates a border from 'abcdefghijklmnop' " do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new("abcdefghijklmnop"),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      ammmmmmmmmmmmmmmmmmmmmmmmmmmmmc
      j            Title            l
      dmmmmmmmmmmmmmmmmmmmmmmmmmmmmmf
      j           SubTitle          l
      dmmmmmmmmmmmmmmbmmmmmmmmmmmmmmf
      j       itself k       double l
      dooooooooooooooeoooooooooooooof
      j            1 k            2 l
      dppppppppppppppeppppppppppppppf
      j            2 k            4 l
      dppppppppppppppeppppppppppppppf
      j            3 k            6 l
      dmmmmmmmmmmmmmmhmmmmmmmmmmmmmmf
      j            Footer           l
      gmmmmmmmmmmmmmmmmmmmmmmmmmmmmmi
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from 'ABCDEFGHIJKLMNOP' " do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new("ABCDEFGHIJKLMNOP"),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      AMMMMMMMMMMMMMMMMMMMMMMMMMMMMMC
      J            Title            L
      DMMMMMMMMMMMMMMMMMMMMMMMMMMMMMF
      J           SubTitle          L
      DMMMMMMMMMMMMMMBMMMMMMMMMMMMMMF
      J       itself K       double L
      DOOOOOOOOOOOOOOOOOOOOOOOOOOOOF
      J            1 K            2 L
      DPPPPPPPPPPPPPPPPPPPPPPPPPPPPF
      J            2 K            4 L
      DPPPPPPPPPPPPPPPPPPPPPPPPPPPPF
      J            3 K            6 L
      DMMMMMMMMMMMMMMHMMMMMMMMMMMMMMF
      J            Footer           L
      GMMMMMMMMMMMMMMMMMMMMMMMMMMMMMI
      OUTPUT
      table.to_s.should eq(expected_output)
    end

    it "creates a border from 'ABCDSFGHIJKLMNOP' " do
      table = Tablo::Table.new([1, 2, 3],
        border: Tablo::Border.new("ABCDSFGHIJKLMNOP"),
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      AMMMMMMMMMMMMMMMMMMMMMMMMMMMMMC
      J            Title            L
      DMMMMMMMMMMMMMMMMMMMMMMMMMMMMMF
      J           SubTitle          L
      DMMMMMMMMMMMMMMBMMMMMMMMMMMMMMF
      J       itself K       double L
      DOOOOOOOOOOOOOO OOOOOOOOOOOOOOF
      J            1 K            2 L
      DPPPPPPPPPPPPPP PPPPPPPPPPPPPPF
      J            2 K            4 L
      DPPPPPPPPPPPPPP PPPPPPPPPPPPPPF
      J            3 K            6 L
      DMMMMMMMMMMMMMMHMMMMMMMMMMMMMMF
      J            Footer           L
      GMMMMMMMMMMMMMMMMMMMMMMMMMMMMMI
      OUTPUT
      table.to_s.should eq(expected_output)
    end
  end
  describe "Border styler" do
    it "colorizes border characters" do
      table = Tablo::Table.new([1, 2, 3],
        # TODO
        border: Tablo::Border.new("ABCDSFGHIJKLMNOP", styler: ->(x : String) { x.colorize.fore(:green).mode(:bold).to_s }),
        # TODO
        title: Tablo::Heading.new("Title", framed: true),
        subtitle: Tablo::Heading.new("SubTitle", framed: true),
        footer: Tablo::Heading.new("Footer", framed: true),
        row_divider_frequency: 1) do |t|
        t.add_column("itself", &.itself)
        t.add_column("double", &.itself.*(2))
      end
      expected_output = <<-OUTPUT
      \e[32;1mAMMMMMMMMMMMMMMMMMMMMMMMMMMMMMC\e[0m
      \e[32;1mJ\e[0m            Title            \e[32;1mL\e[0m
      \e[32;1mDMMMMMMMMMMMMMMMMMMMMMMMMMMMMMF\e[0m
      \e[32;1mJ\e[0m           SubTitle          \e[32;1mL\e[0m
      \e[32;1mDMMMMMMMMMMMMMMBMMMMMMMMMMMMMMF\e[0m
      \e[32;1mJ\e[0m       itself \e[32;1mK\e[0m       double \e[32;1mL\e[0m
      \e[32;1mDOOOOOOOOOOOOOO OOOOOOOOOOOOOOF\e[0m
      \e[32;1mJ\e[0m            1 \e[32;1mK\e[0m            2 \e[32;1mL\e[0m
      \e[32;1mDPPPPPPPPPPPPPP PPPPPPPPPPPPPPF\e[0m
      \e[32;1mJ\e[0m            2 \e[32;1mK\e[0m            4 \e[32;1mL\e[0m
      \e[32;1mDPPPPPPPPPPPPPP PPPPPPPPPPPPPPF\e[0m
      \e[32;1mJ\e[0m            3 \e[32;1mK\e[0m            6 \e[32;1mL\e[0m
      \e[32;1mDMMMMMMMMMMMMMMHMMMMMMMMMMMMMMF\e[0m
      \e[32;1mJ\e[0m            Footer           \e[32;1mL\e[0m
      \e[32;1mGMMMMMMMMMMMMMMMMMMMMMMMMMMMMMI\e[0m
      OUTPUT
      table.to_s.should eq(expected_output)
    end
  end
end
