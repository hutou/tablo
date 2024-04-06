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
  NEWLINE = {% if flag?(:windows) %}
              "\r\n"
            {% else %}
              "\n"
            {% end %}
  DEFAULT_STYLER                = ->(s : String) { s }
  DEFAULT_DATA_DEPENDENT_STYLER = ->(_c : CellType, s : String) { s }
  DEFAULT_HEADING_ALIGNMENT     = Justify::Center
  DEFAULT_FORMATTER             = ->(c : CellType) { c.to_s }

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

  class Exception < Exception
    # This exception is raised when the column identifier (LabelType) is used more than once
    class DuplicateKey < Exception
    end

    class LabelNotFound < Exception
    end
  end

  class TabloException < Exception
  end

  # class DuplicateKey < TabloException
  # end

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
