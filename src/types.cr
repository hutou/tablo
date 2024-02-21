# CellType is an empty module, included in every standard scalar type,
# so that type checking can be done transparently.
module Tablo::CellType
  # def render_cell(io : IO)
  #   to_s(io)
  # end
  # def int?(klass)
  #   p! klass
  #   if klass.class.in?(Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128)
  #     x = true
  #   else
  #     x = false
  #   end
  #   p! "klass:#{klass} : (#{klass.class}) -> x:#{x}"
  #   x
  # end

  # def float?(klass)
  #   p! klass
  #   if klass.class.in?(Float32, Float64)
  #     x = true
  #   else
  #     x = false
  #   end
  #   p! "klass:#{klass} : (#{klass.class}) -> x:#{x}"
  #   x
  # end

  # def number?(klass)
  #   if int?(klass) || float?(klass)
  #     x = true
  #   else
  #     x = false
  #   end
  #   p! "klass:#{klass} : (#{klass.class}) -> x:#{x}"
  #   x
  # end

  # def string?(klass)
  #   klass.class == String
  # end

  # def symbol?(klass)
  #   klass.class == Symbol
  # end

  # def nil_?(klass)
  #   klass.class == Nil
  # end

  # extend self
end

# :nodoc:
macro include_celltype
  {% for name in [Int8, Int16, Int32, Int64, Int128,
                  UInt8, UInt16, UInt32, UInt64, UInt128,
                  Float32, Float64, Char, Bool, Nil, Symbol,
                  Time] %}
    struct {{name.id}}
      include Tablo::CellType
    end
  {% end %}
  {% for name in [String] %}
    class {{name.id}}
      include Tablo::CellType
    end
  {% end %}
end

# :nodoc:
# macro for CellType inclusion in scalar standard types
include_celltype

module Tablo
  # extend Tablo::CellType
  NEWLINE                       = /\r\n|\n|\r/
  DEFAULT_STYLER                = ->(s : String) { s }
  DEFAULT_DATA_DEPENDENT_STYLER = ->(_c : CellType, s : String) { s }
  DEFAULT_HEADING_ALIGNMENT     = Justify::Center
  DEFAULT_FORMATTER             = ->(c : CellType) { c.to_s }

  struct CellData
    getter body_value, row_index, column_index

    def initialize(@body_value : CellType, @row_index : Int32, @column_index : Int32)
    end
  end

  # BorderName define allowed keys to access predefined connectors string.
  enum BorderName
    Ascii
    ReducedAscii
    ReducedModern
    Markdown
    Modern
    Fancy
    Empty
    Blank
  end

  # A border, of type BorderType, may be created either by a border predefined
  # name (`Tablo::BorderName`) or by a litteral string of 16 characters (see `Tablo::Border`).
  alias BorderType = String | BorderName

  # Styler Proc for borders<br />
  # Default : `Config.border_styler`
  #
  # Example, to colorize borders in blue :
  # ```
  # border_styler: ->(b : String) { b.colorize(:blue).to_s }
  # ```
  alias BorderStyler = Proc(String, String)

  # ---------- TextCellStyler -----------------------------------------------------
  #
  #

  # Styler procs for text cell types.
  #
  # Using the first form (`Proc(String, String)`), the whole content of the cell may be styled.
  #
  # Example :
  # ```
  # styler: ->(content : String) { content.colorize(:blue).to_s }
  # ```
  #
  # If (`Proc(String, Int32, String)`) is used,
  # the `Int32` is the line number (0..n) inside the (possibly multiline) cell,
  # thus allowing to differently style each line.
  #
  # Example:
  # ```
  # styler: ->(content : String, line : Int32) {
  #   case line
  #   when 0
  #     content.colorize(:blue).to_s
  #   when 1
  #     content.colorize(:green).to_s
  #   else
  #     content.colorize(:red).to_s
  #   end
  # }
  # ```
  alias TextCellStyler = Proc(String, Int32, String) |
                         Proc(String, String)
  # Corresponding parameters:
  # formatter.call(@content, @width)
  # formatter.call(@content)

  # ---------- DataCellStyler -----------------------------------------------------
  #
  #

  # 1st form : Proc(CellType, String, CellData, Int32, String)
  # ```
  # styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData, line : Int32) {
  #   if line == 1
  #     s.colorize(:magenta).mode(:bold).to_s
  #   else
  #     if r.row_index % 2 == 0
  #       if r.column_index % 2 == 0
  #         s.colorize(:red).to_s
  #       else
  #         s.colorize(:yellow).to_s
  #       end
  #     else
  #       s.colorize(:blue).to_s
  #     end
  #   end
  # }
  # ```
  #
  # 2nd form : Proc(CellType, String, CellData, String)
  # ```
  # styler: ->(_c : Tablo::CellType, s : String, r : Tablo::CellData) {
  #   if r.row_index % 2 == 0
  #     if r.column_index % 2 == 0
  #       s.colorize(:red).to_s
  #     else
  #       s.colorize(:yellow).to_s
  #     end
  #   else
  #     s.colorize(:blue).to_s
  #   end
  #    }
  # ```
  # 3rd form : Proc(CellType, String, String)
  # ```
  # styler: ->(c : Tablo::CellType, s : String) {
  #   if c.as(Float64) < 0.0
  #     s.colorize(:red).to_s
  #   else
  #     s.colorize(:green).to_s
  #   end
  # }
  # ```
  alias DataCellStyler = Proc(CellType, CellData, String, Int32, String) |
                         Proc(CellType, CellData, String, String) |
                         Proc(CellType, String, String) |
                         Proc(String, String)
  # Corresponding parameters:
  # value, cell_data, content, line_index
  # value, cell_data, content
  # value, content
  # content

  # alias CellStyler = Proc(CellType, CellData, String, Int32, String) |
  #                    Proc(CellType, CellData, String, String) |
  #                    Proc(CellType, String, String) |
  #                    Proc(String, Int32, String) |
  #                    Proc(String, String)

  # Formatter proc for text cell types (Heading and Group).
  #
  # Any processing can be done on cell value. For example, if the runtime cell value type
  # is Time, we could format as :
  #
  # ```
  # formatter: ->(c : Tablo::CellType) { "Date: " + c.as(Time).to_s("%Y-%m-%d") }
  # ```
  alias TextCellFormatter = Proc(CellType, Int32, String) |
                            Proc(CellType, String)
  # Corresponding parameters:
  # value, width
  # value

  # ---------- DataCellFormatter --------------------------------------------------
  #
  #

  # Formatter Proc for data cell types (Header and Body).
  #
  # Any processing can be done on cell value.
  #
  # The first form allows for conditional formatting, depending on attribute values
  # of `Tablo::CellData` (row_index or column_index).
  #
  # For example, to alternate case after each row, the Proc would be:
  # ```
  # formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
  #   cell_data.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase }
  # ```
  #
  # The second form is the same as `Tablo::TextCellFormatter`
  #
  # Commonly used parameter names for the different forms:<br />
  # - value : `CellType`, cell_data : `CellData`, width : `Int32`
  # - value : `CellType`, cell_data : `CellData`
  # - value : `CellType`, width : `Int32`
  # - value : `CellType`
  alias DataCellFormatter = Proc(CellType, CellData, Int32, String) |
                            Proc(CellType, CellData, String) |
                            Proc(CellType, Int32, String) |
                            Proc(CellType, String)

  # ---------- LabelType ----------------------------------------------------------
  #
  #

  # LabelType is an union of allowed types for a column label.
  alias LabelType = String | Symbol | Int32

  # ---------- LabelType ----------------------------------------------------------
  #
  #

  # Excepted columns
  # alias Except = LabelType | Array(LabelType)

  # -------------------------------------------------------------------------------
  #
  #

  # :nodoc:
  # Table width, packing
  # enum GetWidthFrom
  #   Screen
  # end
  # alias TableWidth = GetWidthFrom | Int32

  enum StartingWidths
    Initial
    Current
    AutoSized
  end

  # an Enum to define cutting modes
  # - Rune : cutting allowed between graphemes
  # - Word : cutting between words only
  enum WrapMode
    Rune
    Word
  end

  # Types of rows in Table layout
  enum RowType
    Title
    SubTitle
    Group
    Header
    Body
    Footer
  end

  # :nodoc:
  # Rows position
  enum Position
    BodyBody
    BodyBottom
    BodyFiller
    BodyGroup
    BodyHeader
    BodyTitle
    BodyTop
    GroupHeader
    GroupTop
    HeaderBody
    HeaderTop
    SummaryBody
    SummaryHeader
    TitleBody
    TitleBottom
    TitleGroup
    TitleHeader
    TitleTitle
    TitleTop
  end

  # Cell justification
  enum Justify
    Left
    Center
    Right
  end

  # The `SummaryProc` struct lets you define specific functions to be applied
  # to source data, accessible either by column or directly from the source,
  # in order to provide aggregated results.
  struct SummaryProc(T)
    protected getter proc

    # The constructor's only parameter is a Proc, which in turn expects
    # a Table(T) as its only parameter.
    #
    # The Proc must return a hash of results (of type CellType), which are
    # automatically saved for future use (See `Summary.use` method
    # in `SummaryBodyRow`).
    #
    # Example of accessing data directly from source:
    # ```
    # struct InvoiceItem
    #   getter product, quantity, price
    #
    #   def initialize(@product : String, @quantity : Int32?, @price : Int32?)
    #   end
    # end
    #
    # Tablo::SummaryProc.new(
    #   proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    #     total_sum = 0
    #     tbl.sources.each do |row|
    #       next unless row.quantity.is_a?(Int32) && row.price.is_a?(Int32)
    #       total_sum += row.quantity.as(Int32) * row.price.as(Int32)
    #     end
    #     {:total_sum => total_sum.as(Tablo::CellType)}
    #   })
    # ```
    # Another example, this time using column access, with iterators, and
    # returning several results.
    # ```
    # Tablo::SummaryProc.new(
    #   proc: ->(tbl : Tablo::Table(InvoiceItem)) {
    #     total_sum = total_count = max_price = 0
    #     iter_quantity = tbl.source_column("Quantity").each
    #     iter_price = tbl.source_column("Price").each
    #     iter = iter_quantity.zip(iter_price)
    #     iter.each do |q, p|
    #       next unless q.is_a?(Int32) && p.is_a?(Int32)
    #       total_sum += q * p
    #       total_count += 1
    #       max_price = [max_price, p].max
    #     end
    #     {
    #       :total_count => total_count.as(Tablo::CellType),
    #       :total_sum   => total_sum.as(Tablo::CellType),
    #       :max_price   => max_price.as(Tablo::CellType),
    #     }
    #   })
    # ```
    def initialize(@proc : Proc(Table(T), Hash(Symbol, CellType)))
    end
  end

  # The `SummaryHeaderColumn` struct lets you define header content and specific
  # alignment, formatting and styling
  struct SummaryHeaderColumn
    protected getter column, content, alignment, formatter, styler

    # The constructor expects up to 5 parameters, the first 2 being mandatory
    #
    # - `column` : type if `LabelType` <br />
    #    It is the column identifier.
    #
    # - `content` : type is String <br />
    #    (may be empty)
    #
    # - The last three are optional (`alignment`, `formatter` and `styler`)
    #
    # Examples:
    # ```
    # Tablo::SummaryHeaderColumn.new("Price",
    #   content: "Total Invoice",
    #   alignment: Tablo::Justify::Right),
    # Tablo::SummaryHeaderColumn.new(:total,
    #   content: "Amounts",
    #   styler: ->(s : String) {s.colorize(:red).to_s}),
    # ```
    def initialize(@column : LabelType,
                   @content : String,
                   @alignment : Justify? = nil,
                   @formatter : DataCellFormatter? = nil,
                   @styler : DataCellStyler? = nil)
    end
  end

  # The `SummaryBodyColumn` struct lets you define specific
  # alignment, formatting and styling on body columns.
  struct SummaryBodyColumn
    protected getter column, alignment, formatter, styler

    # The constructor expects up to 4 parameters, of which the first, the
    # column identifier, is the only mandatory one (but it goes without saying
    # that at least one of the 3 optional parameters must be defined!)
    #
    # - `column` : type if `LabelType`
    #
    # - The last three optional parameters are (`alignment`,
    #   `formatter` and `styler`)
    #
    # Example:
    # ```
    # Tablo::SummaryBodyColumn.new(:total, alignment: Tablo::Justify::Right,
    #   formatter: ->(value : Tablo::CellType) {
    #     value.is_a?(String) ? value : (
    #       value.nil? ? "" : "%.2f" % value.as(BigDecimal)
    #     )
    #   },
    #   styler: ->(_value : Tablo::CellType, cd : Tablo::CellData, fc : String) {
    #     case cd.row_index
    #     when 0, 2, 5 then fc.colorize.mode(:bold).to_s
    #     when 1       then fc.colorize.mode(:italic).to_s
    #     else              fc
    #     end
    #   }),
    # ```
    def initialize(@column : LabelType,
                   @alignment : Justify? = nil,
                   @formatter : DataCellFormatter? = nil,
                   @styler : DataCellStyler? = nil)
    end
  end

  struct SummaryBodyRow
    protected getter column, row, content

    def initialize(@column : LabelType,
                   @row : Int32,
                   @content : CellType | Proc(CellType))
    end
  end

  class TabloException < Exception
  end

  class InvalidConnectorString < TabloException
  end

  class DuplicateLabel < TabloException
  end

  class DuplicateRow < TabloException
  end

  class LabelNotFound < TabloException
  end

  class GroupError < TabloException
  end

  class InvalidValue < TabloException
  end

  class IncompatibleValue < TabloException
  end

  class InvalidSummaryDefinition < TabloException
  end

  class DuplicateInSummaryDefinition < TabloException
  end
end
