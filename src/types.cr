# CellType is an empty module, included in every standard scalar type,
# so that type checking can be done transparently.
module Tablo::CellType
  # def render_cell(io : IO)
  #   to_s(io)
  # end
end

# :nodoc:
macro include_celltype
  {% for name in [Int8, Int16, Int32, Int64, Int128,
                  UInt8, UInt16, UInt32, UInt64, UInt128,
                  Float32, Float64, Char, Bool, Nil, Symbol, Time] %}
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
    Blank
  end

  # A border, of type BorderType, may be created either by a border predefined
  # name (`Tablo::BorderName`) or by a litteral string of 16 characters (see `Tablo::Border`).
  alias BorderType = String | BorderName

  # Styler procs for borders
  # default : do nothing
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

  # ---------- TextCellFormatter --------------------------------------------------
  #
  #

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
  # formatter: ->(c : Tablo::CellType, d : Tablo::CellData) {
  #   d.row_index % 2 == 0 ? c.as(String).upcase : c.as(String).downcase }
  # ```
  #
  # The second form is the same as `Tablo::TextCellFormatter`
  alias DataCellFormatter = Proc(CellType, CellData, Int32, String) |
                            Proc(CellType, CellData, String) |
                            Proc(CellType, Int32, String) |
                            Proc(CellType, String)
  # Corresponding parameters:
  # value, cell_data, width
  # value, cell_data
  # value, width
  # value

  # ---------- LabelType ----------------------------------------------------------
  #
  #

  # LabelType is an union of allowed types for a column label.
  alias LabelType = String | Symbol | Int32

  # ---------- LabelType ----------------------------------------------------------
  #
  #

  # Excepted columns
  alias Except = LabelType | Array(LabelType)

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

  # TODO Define all proper aliases here
  alias Num = Float64 | Int32
  alias StrNum = Num | String

  # alias Num = Float64 | Int32
  alias NumCol = Array(Num?)
  alias NumCols = Hash(LabelType, NumCol)

  alias SummaryNumCols = Proc(NumCols, Float64) |
                         Proc(NumCols, Int32) |
                         Proc(NumCols, String) |
                         Proc(NumCols, Nil)
  alias SummaryNumCol = Proc(NumCol, Float64) |
                        Proc(NumCol, Int32) |
                        Proc(NumCol, String) |
                        Proc(NumCol, Nil)

  # Tablo Exceptions hierarchy
  #
  # Parent class

  class TabloException < Exception
  end

  class InvalidConnectorString < TabloException
  end

  class DuplicateLabel < TabloException
  end

  class LabelNotFound < TabloException
  end

  class GroupError < TabloException
  end

  class InvalidValue < TabloException
  end

  class IncompatibleValue < TabloException
  end
end
