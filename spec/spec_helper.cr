require "spec"
require "../src/tablo"

# Defined table with empty array
def mktable_empty(default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
                  column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
                  header_frequency : Int32? = 0,
                  wrap_header_cells_to : Int32? = nil,
                  wrap_body_cells_to : Int32 | Nil = nil,
                  default_header_alignment : Tablo::Justify = Tablo::Justify::None,
                  truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
                  connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
                  style : String = Tablo::STYLE_ALL_BORDERS)
  Tablo::Table.new([] of Array(Int32),
    default_column_width,
    column_padding,
    header_frequency,
    wrap_header_cells_to,
    wrap_body_cells_to,
    default_header_alignment,
    truncation_indicator,
    connectors,
    style)
end

# Defined table with array of 5 integers
def mktable_5i32(default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
                 column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
                 header_frequency : Int32? = 0,
                 wrap_header_cells_to : Int32? = nil,
                 wrap_body_cells_to : Int32 | Nil = nil,
                 default_header_alignment : Tablo::Justify = Tablo::Justify::None,
                 truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
                 connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
                 style : String = Tablo::STYLE_ALL_BORDERS)
  Tablo::Table.new([[1], [2], [3], [4], [5]],
    default_column_width,
    column_padding,
    header_frequency,
    wrap_header_cells_to,
    wrap_body_cells_to,
    default_header_alignment,
    truncation_indicator,
    connectors,
    style)
end

# Defined table with array of 3 integers (i64)
def mktable_3i64(default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
                 column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
                 header_frequency : Int32? = 0,
                 wrap_header_cells_to : Int32? = nil,
                 wrap_body_cells_to : Int32 | Nil = nil,
                 default_header_alignment : Tablo::Justify = Tablo::Justify::None,
                 truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
                 connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
                 style : String = Tablo::STYLE_ALL_BORDERS)
  Tablo::Table.new([[1_i64], [2_i64], [500_000_000_000_i64]],
    default_column_width,
    column_padding,
    header_frequency,
    wrap_header_cells_to,
    wrap_body_cells_to,
    default_header_alignment,
    truncation_indicator,
    connectors,
    style)
end

# Defined table with array of 4 strings
def mktable_4string(default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
                    column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
                    header_frequency : Int32? = 0,
                    wrap_header_cells_to : Int32? = nil,
                    wrap_body_cells_to : Int32 | Nil = nil,
                    default_header_alignment : Tablo::Justify = Tablo::Justify::None,
                    truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
                    connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
                    style : String = Tablo::STYLE_ALL_BORDERS)
  Tablo::Table.new([["Two\nlines"], ["\nInitial"], ["Final\n"], ["Multiple\nnew\nlines"]],
    default_column_width,
    column_padding,
    header_frequency,
    wrap_header_cells_to,
    wrap_body_cells_to,
    default_header_alignment,
    truncation_indicator,
    connectors,
    style)
end

# Defined table with array of 2 integers (i64)
def mktable_2i64(default_column_width : Int32 = Tablo::Table::DEFAULT_COLUMN_WIDTH,
                 column_padding : Int32 = Tablo::Table::DEFAULT_COLUMN_PADDING,
                 header_frequency : Int32? = 0,
                 wrap_header_cells_to : Int32? = nil,
                 wrap_body_cells_to : Int32 | Nil = nil,
                 default_header_alignment : Tablo::Justify = Tablo::Justify::None,
                 truncation_indicator : Char = Tablo::Table::DEFAULT_TRUNCATION_INDICATOR,
                 connectors : String = Tablo::CONNECTORS_TEXT_CLASSIC,
                 style : String = Tablo::STYLE_ALL_BORDERS)
  Tablo::Table.new([[400000000000000000], [400000000000000000]],
    default_column_width,
    column_padding,
    header_frequency,
    wrap_header_cells_to,
    wrap_body_cells_to,
    default_header_alignment,
    truncation_indicator,
    connectors,
    style)
end

def add_columns_nd(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t
end

def add_columns_ndt(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("Triple", width: 16) { |n| n[0].as(Number) * 3 }
  t
end

def add_columns_ndf(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("Triple", formatter: ->(val : Tablo::CellType) { "%.2f" % val }) { |n| n[0].as(Number) * 3 }
  t
end

def add_columns_ndfs(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("Triple", formatter: ->(val : Tablo::CellType) { "%.2f" % val }, styler: ->(val : Tablo::CellType) { "\e[31m#{val}\e[0m" }) { |n| n[0].as(Number) * 3 }
  t
end

def add_columns_ndn(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("N" * 26) { |n| n[0] }
  t
end

def add_columns_5n(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("x 2") { |n| n[0].as(Number) * 2 }
  t.add_column("x 3") { |n| n[0].as(Number) * 3 }
  t.add_column("x 4") { |n| n[0].as(Number) * 4 }
  t.add_column("x 5") { |n| n[0].as(Number) * 5 }
  t
end

def add_columns_7m(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("to_s") { |n| n[0].to_s }
  t.add_column("Is it\neven?") { |n| n[0].as(Int).even? }
  t.add_column("dec", formatter: ->(n : Tablo::CellType) { "%.#{n}f" % n }) { |n| n[0] }
  t.add_column("word\nyep", width: 5) { |n| "w" * n[0].as(Int) * 2 }
  t.add_column("cool") { |n| n[0].as(Number) == 3 ? "two\nlines" : "" }
  t
end

def add_columns_sss(t : Tablo::Table)
  t.add_column("Firstpart\nsecondpart", width: 7) { |n| n[0] }
  t.add_column("length") { |n| (n[0].as(String)).size }
  t.add_column("Lines\nin\nheader", align_body: Tablo::Justify::Right) { |n| n[0] }
  t
end

def add_columns_nd2(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("AAAAAAAAAAAAAAAAAAAA") { |n| n[0].as(Number) * 2 }
  t
end

def add_columns_nse(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("N_to_s") { |n| n[0].to_s }
  t.add_column("even?") { |n| n[0].as(Int).even? }
  t
end

def add_columns_ndsef(t : Tablo::Table)
  t.add_column("N") { |n| n[0] }
  t.add_column("Double") { |n| n[0].as(Number) * 2 }
  t.add_column("to_s", align_header: Tablo::Justify::Left, align_body: Tablo::Justify::Center) { |n| n[0].to_s }
  t.add_column("even?", align_header: Tablo::Justify::Left, align_body: Tablo::Justify::Right) { |n| n[0].as(Int).even? }
  t.add_column("to_f", align_header: Tablo::Justify::Right, align_body: Tablo::Justify::Left) { |n| n[0].as(Number).to_f }
  t
end
