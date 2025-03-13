require "./spec_helper"

describe Tablo::Heading do
  context "Heading : common features for title, subtitle and footer" do
    it "displays the table headings, centered, unframed, over 2 lines, wrap mode=default(Word)" do
      table = Tablo::Table.new(["a", "b", "c"],
        title: Tablo::Heading.new("This is a title"),
        subtitle: Tablo::Heading.new("This is a subtitle"),
        footer: Tablo::Heading.new("This is a footer")) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
            This is a   
              title     
            This is a   
            subtitle    
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
            This is a   
             footer     
        OUTPUT
      output.should eq(expected_output)
    end
    it "displays the table headings, centered, unframed, over 2 lines, wrap mode=Rune" do
      table = Tablo::Table.new(["a", "b", "c"],
        wrap_mode: Tablo::WrapMode::Rune,
        title: Tablo::Heading.new("This is a title"),
        subtitle: Tablo::Heading.new("This is a subtitle"),
        footer: Tablo::Heading.new("This is a footer")) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
          This is a ti  
               tle      
          This is a su  
             btitle     
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
          This is a fo  
              oter      
        OUTPUT
      output.should eq(expected_output)
    end
    it "displays the table headings, centered over 2 lines, unframed (line breaks have no effect)" do
      table = Tablo::Table.new(["a", "b", "c"],
        title: Tablo::Heading.new("This is a title",
          line_breaks_before: 3, line_breaks_after: 3),
        subtitle: Tablo::Heading.new("This is a subtitle",
          line_breaks_before: 3, line_breaks_after: 3),
        footer: Tablo::Heading.new("This is a footer",
          line_breaks_before: 3, line_breaks_after: 3)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
            This is a   
              title     
            This is a   
            subtitle    
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
            This is a   
             footer     
        OUTPUT
      output.should eq(expected_output)
    end
    it "displays the table headings, centered over 2 lines, framed (line breaks do have effect)" do
      table = Tablo::Table.new(["a", "b", "c"],
        title: Tablo::Heading.new("This is a title", framed: true,
          line_breaks_before: 3, line_breaks_after: 3),
        subtitle: Tablo::Heading.new("This is a subtitle", framed: true,
          line_breaks_before: 3, line_breaks_after: 3),
        footer: Tablo::Heading.new("This is a footer", framed: true,
          line_breaks_before: 3, line_breaks_after: 3)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT


        +--------------+
        |   This is a  |
        |     title    |
        +--------------+


        +--------------+
        |   This is a  |
        |   subtitle   |
        +--------------+


        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+


        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        OUTPUT
      # XXX # Missing 3 newlines after footer : is this normal ? XXX
      output.should eq(expected_output)
    end
  end

  context "Title specific : 'repeated' flag" do
    it "repeats footer, but not title and subtitle (all unframed), repeated=false" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        title: Tablo::Heading.new("This is a title", repeated: false),
        subtitle: Tablo::Heading.new("This is a subtitle"),
        footer: Tablo::Heading.new("This is a footer")) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
            This is a   
              title     
            This is a   
            subtitle    
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
            This is a   
             footer     
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
            This is a   
             footer     
        OUTPUT
      output.should eq(expected_output)
    end
    it "repeats footer, title and subtitle (all unframed), repeated=true" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        title: Tablo::Heading.new("This is a title", repeated: true),
        subtitle: Tablo::Heading.new("This is a subtitle"),
        footer: Tablo::Heading.new("This is a footer")) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
            This is a   
              title     
            This is a   
            subtitle    
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
            This is a   
             footer     
            This is a   
              title     
            This is a   
            subtitle    
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
            This is a   
             footer     
        OUTPUT
      output.should eq(expected_output)
    end
    it "repeats footer, but not title and subtitle (all framed), repeated=false" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        title: Tablo::Heading.new("This is a title", framed: true),
        subtitle: Tablo::Heading.new("This is a subtitle", framed: true),
        footer: Tablo::Heading.new("This is a footer", framed: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        |   This is a  |
        |     title    |
        +--------------+
        |   This is a  |
        |   subtitle   |
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        OUTPUT
      output.should eq(expected_output)
    end
    it "repeats footer, title and subtitle (all framed), repeated=true" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        title: Tablo::Heading.new("This is a title", framed: true, repeated: true),
        subtitle: Tablo::Heading.new("This is a subtitle", framed: true),
        footer: Tablo::Heading.new("This is a footer", framed: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        |   This is a  |
        |     title    |
        +--------------+
        |   This is a  |
        |   subtitle   |
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        |   This is a  |
        |     title    |
        +--------------+
        |   This is a  |
        |   subtitle   |
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        OUTPUT
      output.should eq(expected_output)
    end
  end

  context "SubTitle specific : Title missing" do
    it "omits subtitle if title is missing" do
      table = Tablo::Table.new(["a", "b", "c"],
        subtitle: Tablo::Heading.new("This is a subtitle", framed: true),
        footer: Tablo::Heading.new("This is a footer", framed: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+
        OUTPUT
      output.should eq(expected_output)
    end
  end

  context "Footer specific : 'page_break' flag" do
    it "adds a page break after footer's frame (not repeated)" do
      table = Tablo::Table.new(["a", "b", "c"],
        footer: Tablo::Heading.new("This is a footer", framed: true,
          page_break: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+\f
        OUTPUT
      output.should eq(expected_output)
    end
    it "adds a page break at the end of footer's last line if unframed (not repeated)" do
      table = Tablo::Table.new(["a", "b", "c"],
        footer: Tablo::Heading.new("This is a footer", framed: false,
          page_break: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        | c            |
        +--------------+
            This is a   
             footer     \f
        OUTPUT
      output.should eq(expected_output)
    end
    it "adds a page break at the end of each footer's last line if unframed (repeated)" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        footer: Tablo::Heading.new("This is a footer", framed: false,
          page_break: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
            This is a   
             footer     \f
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
            This is a   
             footer     \f
        OUTPUT
      output.should eq(expected_output)
    end
    it "adds a page break at the end of each footer's frame (line break forced in inner repeated footers)" do
      table = Tablo::Table.new(["a", "b", "c"],
        header_frequency: 2,
        footer: Tablo::Heading.new("This is a footer", framed: true,
          page_break: true)) do |t|
        t.add_column("Char", &.itself)
      end
      output = table.to_s
      expected_output = <<-OUTPUT
        +--------------+
        | Char         |
        +--------------+
        | a            |
        | b            |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+\f
        +--------------+
        | Char         |
        +--------------+
        | c            |
        |              |
        +--------------+
        |   This is a  |
        |    footer    |
        +--------------+\f
        OUTPUT
      output.should eq(expected_output)
    end
  end

  context "'repeated' flag : only for title" do
    it "raises an error if 'repeated' flag used for subtitle" do
      expect_raises Tablo::Error::InvalidValue do
        table = Tablo::Table.new(["a", "b", "c"],
          title: Tablo::Heading.new("This is a title"),
          subtitle: Tablo::Heading.new("This is a subtitle", repeated: true)) do |t|
          t.add_column("Char", &.itself)
        end
      end
    end
    it "raises an error if 'repeated' flag used for footer" do
      expect_raises Tablo::Error::InvalidValue do
        table = Tablo::Table.new(["a", "b", "c"],
          footer: Tablo::Heading.new("This is a footer", repeated: true)) do |t|
          t.add_column("Char", &.itself)
        end
      end
    end
  end
  context "'page_break' flag : only for footer" do
    it "raises an error if 'page_break' flag used for title" do
      expect_raises Tablo::Error::InvalidValue do
        table = Tablo::Table.new(["a", "b", "c"],
          title: Tablo::Heading.new("This is a title", page_break: true)) do |t|
          t.add_column("Char", &.itself)
        end
      end
    end
    it "raises an error if 'page_break' flag used for subtitle" do
      expect_raises Tablo::Error::InvalidValue do
        table = Tablo::Table.new(["a", "b", "c"],
          title: Tablo::Heading.new("This is a title"),
          subtitle: Tablo::Heading.new("This is a subtitle", page_break: true)) do |t|
          t.add_column("Char", &.itself)
        end
      end
    end
  end
end
