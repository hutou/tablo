require "./spec_helper"

test_data_numbers = IntSamples.new

describe "#{Tablo::Table} -> Title and headers variations on initialization, " +
         "based on IntSamples class" do
  describe "#initialize with 'header_frequency' = nil" do
    context "with only column header, no group, no title" do
      it "displays the table without any header" do
        table = Tablo::Table.new(IntSamples.new,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column header and table title" do
      it "displays the table without any header or title" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column header and table title and subtitle" do
      it "displays the table without any header, title or subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          subtitle: Tablo::Heading.new("table subtitle"),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column header, title, subtitle and footer" do
      it "displays the table without any header, title, subtitle or footer" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          subtitle: Tablo::Heading.new("table subtitle", framed: true),
          footer: Tablo::Heading.new("Table footer", framed: true),
          header_frequency: nil) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
  end
  describe "#initialize with 'header_frequency' = 0" do
    context "with only column headers, no group, no title" do
      it "displays the table with column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and title" do
      it "displays the table with column headers and title attached" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭─────────────────────────────╮
          │         Table title         │
          ├──────────────┬──────────────┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column header, title and subtitle" do
      it "displays the table with headers, and un_framed title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          subtitle: Tablo::Heading.new("table subtitle"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
                    Table title          
                   table subtitle        
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title *framed* and subtitle" do
      it "displays the table with headers, title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          subtitle: Tablo::Heading.new("table subtitle"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭─────────────────────────────╮
          │         Table title         │
          ╰─────────────────────────────╯
                   table subtitle        
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title *framed* and subtitle and footer" do
      it "displays the table with headers, title, subtitle and footer" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          subtitle: Tablo::Heading.new("table subtitle"),
          footer: Tablo::Heading.new("Table footer"),
          header_frequency: 0) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭─────────────────────────────╮
          │         Table title         │
          ╰─────────────────────────────╯
                   table subtitle        
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
                    Table footer         
          EOS
      end
    end
  end
  describe "#initialize with 'header_frequency' > 0 (=3)" do
    context "with only column headers, no group, no title" do
      it "displays the table with column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ├--------------┼--------------┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ├--------------┼--------------┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title" do
      it "displays the table with title and repeated column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
                    Table title          
          ╭──────────────┬──────────────╮
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ├--------------┼--------------┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ├--------------┼--------------┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with group, column headers and table title" do
      it "displays the table with title and repeated group and column headers" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
                    Table title          
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title and subtitle" do
      it "displays the table with headers, title but no subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title"),
          subtitle: Tablo::Heading.new("table subtitle"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
                    Table title          
                   table subtitle        
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title *framed* and subtitle" do
      it "displays the table with headers, title and subtitle" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          subtitle: Tablo::Heading.new("table subtitle"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭─────────────────────────────╮
          │         Table title         │
          ╰─────────────────────────────╯
                   table subtitle        
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ├−−−−−−−−−−−−−−┴−−−−−−−−−−−−−−┤
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          ╰──────────────┴──────────────╯
          EOS
      end
    end
    context "with column headers and table title *framed* and subtitle and footer" do
      it "displays the table with headers, title, subtitle and footer" do
        table = Tablo::Table.new(test_data_numbers,
          border: Tablo::Border.new(Tablo::Border::PreSet::Fancy),
          title: Tablo::Heading.new("Table title", framed: true),
          subtitle: Tablo::Heading.new("table subtitle"),
          footer: Tablo::Heading.new("Table footer"),
          header_frequency: 3) do |t|
          t.add_column("itself", &.itself)
          t.add_column("even?", &.even?)
          t.add_group("Group")
        end
        {% if flag?(:DEBUG) %} puts "\n#{table}" {% end %}
        table.to_s.should eq <<-EOS
          ╭─────────────────────────────╮
          │         Table title         │
          ╰─────────────────────────────╯
                   table subtitle        
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │            1 :     false    │
          │            7 :     false    │
          │           10 :     true     │
          ╰──────────────┴──────────────╯
                    Table footer         
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           13 :     false    │
          │           42 :     true     │
          │           43 :     false    │
          ╰──────────────┴──────────────╯
                    Table footer         
          ╭─────────────────────────────╮
          │            Group            │
          ├−−−−−−−−−−−−−−┬−−−−−−−−−−−−−−┤
          │       itself :     even?    │
          ├--------------┼--------------┤
          │           59 :     false    │
          │           66 :     true     │
          │              :              │
          ╰──────────────┴──────────────╯
                    Table footer         
          EOS
      end
    end
  end
end
