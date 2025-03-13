# In each Tablo cell, the *value* attribute contains a raw value, either read from
# the data source or defined in the program source code.
#
# This attribute is of type `CellType` and can therefore only store
# values of this type.  To make this possible, each type intended for use in
# Tablo must include the `CellType` module, an empty module defined as follows:
#
# ```
# module CellType
# end
# ```
#
# In Tablo, most scalar types already benefit from this addition, i.e.
# :
# - Signed integers: `Int8`, `Int16`, `Int32`, `Int64`, `Int128`
# - Unsigned integers: `UInt8`, `UInt16`, `UInt32`, `UInt64`, `UInt128`
# - Floats: `Float32`, `Float64`
# - Misc : `Char`, `String`, `Bool`, `Nil`, `Symbol`, `Time`
#
# If another data type is to be used in Tablo, we need to reopen the type and
# include the `CellType` module, as in the case of the `BigDecimal` type below:
# ```
# struct BigDecimal
#   include Tablo::CellType
# end
# ```
# <span style="color:red">__Important__:</span><br />
# After initialization of a Tablo table, when data is read for processing
# before being displayed, its type is therefore restricted to `Tablo::CellType`.
# So, in most cases, a reverse casting is required when operations are performed
# on it, such as:
# ```
# - value.as(String)
# - value.as(Float64)
# - value.as(Int32)
# - ...
# ```
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

  # A mere "to_s" formatter
  DEFAULT_FORMATTER = ->(c : CellType) { c.to_s }
  # A "do nothing" styler
  DEFAULT_STYLER = ->(s : String) { s }

  DEFAULT_HEADING_ALIGNMENT = Justify::Center

  # `Tablo::LabelType` is an union of allowed types for a column identifier (*label*).
  alias LabelType = String | Symbol | Int32

  # Line break settings :
  # - Rune: allowed between characters
  # - Word: allowed between words
  enum WrapMode
    Rune
    Word
  end

  # :nodoc:
  # The RowType type identifies the different types of row in a Table layout
  # *internal use only*
  enum RowType
    Title
    SubTitle
    Group
    Header
    Body
    Footer
  end

  # :nodoc:
  # The RuleType type identifies the different cases of transition between row
  # types, and hence the type of separating rule to be applied.
  # *internal use only*
  enum RuleType
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

  # Cell contents can be justified in 3 ways: to the left, to the right or centered.
  #
  # Justification can be explicit, defined by a dedicated attribute, or
  # implicit, depending on the cell data type or heading.
  #
  # In the latter case, in Tablo, the justification is as follows:
  # - Right for cells containing numeric data
  # - Centered for colomn cells containing Boolean data and for headings
  #   (Title, Subtitle, Group and Footer)
  # - Left for all other cases
  enum Justify
    Left
    Center
    Right
  end

  # The class Error contains all the error cases specific to the Tablo library
  #
  # Its subclasses return the precise type of error
  class Error < Exception
    # This exception is raised when the column (or group) identifier (`LabelType`)
    # is used more than once in a given situation
    class DuplicateLabel < Error
    end

    # This exception is raised when the column (or group) identifier (`LabelType`)
    # does not exist
    class LabelNotFound < Error
    end

    # This exception is raised when the column index is out of bounds
    class InvalidColumnIndex < Error
    end

    # This exception is raised when there is no column to group
    class GroupEmpty < Error
    end

    # This exception is raised when the border definition string is invalid,
    # ie when its size is not exactly 16.
    class InvalidBorderDefinition < Error
    end

    # This exception is raised when the given value is not expected
    # (This is a generic error, covering various cases)
    class InvalidValue < Error
    end
  end
end
