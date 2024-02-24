# `CellType` is an empty module, included in every standard scalar type.
# ```
# module CellType
# end
# ```
#
# These standard types are:
# - Signed integers : `Int8`, `Int16`, `Int32`, `Int64`, `Int128`
# - Unsigned integers : `UInt8`, `UInt16`, `UInt32`, `UInt64`, `UInt128`
# - Floats : `Float32`, `Float64`
# - Misc : `Char`, `String`, `Bool`, `Nil`, `Symbol`, `Time`
#
#  If other data types are to be used in Tablo, then reopen the type and
#  include the `CellType` module, as in the case of the `BigDecimal` type:
# ```
# struct BigDecimal
#   include Tablo::CellType
# end
# ```
# After initialization of a Tablo table, when source data are read for
# processing before display, their type is restricted to CellType, which in
# most cases requires reverse casting when operations involving them are
# performed.
module Tablo::CellType
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
  # Constant initializers
  NEWLINE                       = /\r\n|\n|\r/
  DEFAULT_STYLER                = ->(s : String) { s }
  DEFAULT_DATA_DEPENDENT_STYLER = ->(_c : CellType, s : String) { s }
  DEFAULT_HEADING_ALIGNMENT     = Justify::Center
  DEFAULT_FORMATTER             = ->(c : CellType) { c.to_s }

  #  This data structure is attached to DataCell cells and therefore only
  #  concerns Header and Body row types: it is used in particular for
  #  conditional formatting and styling.
  struct CellData
    # Returns the raw value of the Body Cell (useful when dealing with a
    # Header cell)
    getter body_value

    # Returns the index of the row (0..n)
    getter row_index

    # Returns the index of the column (0..n)
    getter column_index

    # Constructor with 3 mandatory parameters.
    def initialize(@body_value : CellType, @row_index : Int32, @column_index : Int32)
    end
  end

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

  # Formatter Proc for data cell types (Header and Body).
  #
  # There are 4 of them, as shown below by their commonly used parameter names
  # and types: <br />
  # - 1st form : (value : `CellType`, cell_data : `CellData`, column_width : `Int32`)
  # - 2nd form : (value : `CellType`, cell_data : `CellData`)
  # - 3rd form : (value : `CellType`, column_width : `Int32`)
  # - 4th form : (value : `CellType`)
  #
  # Return type is String for all of them.
  #
  # These different forms can be used for conditional formatting.
  #
  # For example, to alternate case after each row, the 2nd form
  # can be used :
  # ```
  # formatter: ->(value : Tablo::CellType, cell_data : Tablo::CellData) {
  #   cell_data.row_index % 2 == 0 ? value.as(String).upcase : value.as(String).downcase }
  # ```
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

  class TabloException < Exception
  end

  class DuplicateKey < TabloException
  end

  # --- to be validated ---
  class InvalidConnectorString < TabloException
  end

  # class DuplicateLabel < TabloException
  # end

  # class DuplicateRow < TabloException
  # end

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
end
