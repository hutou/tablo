module Tablo
  # The CellType type is the union of commonly used scalar types in
  # source code.

  # alias temporary disabled : waiting for full Int128 support
  #  alias CellType = Bool | Char | Int::Signed | Int::Unsigned | Float32 |
  #                   Float64 | String | Symbol

  alias CellType = Bool | Char | Int16 | Int32 | Int64 | Int8 |
                   UInt16 | UInt32 | UInt64 | UInt8 |
                   Float32 | Float64 | String | Symbol

  # `Tablo::DataType` is a 2D array of `Tablo::CellType` (ie a rectangular matrix).
  # This is the data structure on which the Tablo module operates. It is fed by
  # the data passed as parameter during the creation of an instance of the
  # `Tablo::Table` class, after conversion by the `Tablo.cast_to_datatype` method
  alias DataType = Array(Array(CellType))

  # Tablo::DataException is raised when data passed as parameter cannot be
  # converted to `Tablo::DataType`, for some reason : not enumerable, unsupported data
  # type, mixed (runtime) types in colums, etc.
  class DataException < Exception
  end

  # Tablo::ParamException is raised when invalid parameter values are used for Tablo
  # methods, such as `Tablo.connector`
  class ParamException < Exception
  end

  # Tabl::InvalidColumnLabelError is raised when trying to insert a label
  # already used in the table
  class InvalidColumnLabelError < Exception
  end

  # Casts a 2D array of some types to a `Tablo::DataType`, recursively calling itself
  # with each array element as argument until conversion is complete
  def cast(x : Array(Array))
    x.map { |s| cast(s).as(Array(CellType)) }.as(DataType)
  end

  # Casts a subarray of some types into an Array(`Tablo::CellType`)
  def cast(x : Array)
    x.map do |s|
      case s
      when CellType
        s.as(CellType)
      else
        raise DataException.new("Unsupported scalar Type in #{typeof(x)}")
      end
    end.as(Array(CellType))
  end

  # 3D arrays and above not allowed !
  def validate(x : Array(Array(Array)))
    raise DataException.new("Not a 2D array")
  end

  # Validates that the 2d Array argument can be converted to a DataType
  def validate(x : Array(Array))
    if x.all? { |e| e.size == x.first.size }
      if x.transpose.all? { |e| e.all? { |s| s.class == e.first.class } }
        cast(x)
      else
        raise DataException.new("Mixed types in columns")
      end
    else
      raise DataException.new("Rows of different sizes")
    end
  end

  def validate(x)
    raise DataException.new("Not a 2D array")
  end

  # Returns a corner or cross connector
  def connector(connectors, line : TLine, column : TColumn)
    connectors[line.value * 3 + column.value]
  end

  # Returns a horizontal line connector, line type specific
  def connector(connectors, line : TLine)
    connectors[12 + line.value]
  end

  # Returns a vertical line connector, column type specific
  def connector(connectors, column : TColumn)
    connectors[9 + column.value]
  end

  # Check the connectors string size : must be 15 characters long.
  def validate_connectors(connectors)
    raise ParamException.new("Connectors string length invalid : must be 15 chars") if connectors.size != 15
    connectors
  end

  # Cell justification (Header or body)
  enum Justify
    None
    Left
    Center
    Right
  end

  # 'Type' of output line, used for choosing the proper connectors
  enum TLine
    Top
    Mid
    Bot
  end

  # 'Type' of output column, used for choosing the proper connectors
  enum TColumn
    Left
    Mid
    Right
  end

  # Predefined connectors strings, whose size is 15 characters (raise
  # `Tablo::ParamException` otherwise), but the user is free to use
  # its own string of connectors when instanciating a new `Tablo::Table`
  # object.
  #
  # The first 9 characters are corner or cross connectors, the first
  # 3 correspond to the top line, the next 3 to a middle line and the last 3 to
  # the bottom line.
  #
  # The next 3 are vertical line connectors, one for each column type
  #
  # The last 3 are horizontal line connectors, one for each line type
  CONNECTORS_SINGLE_ROUNDED      = "╭┬╮├┼┤╰┴╯│││───"
  CONNECTORS_SINGLE              = "┌┬┐├┼┤└┴┘│││───"
  CONNECTORS_DOUBLE              = "╔╦╗╠╬╣╚╩╝║║║═══"
  CONNECTORS_SINGLE_DOUBLE       = "╒╤╕╞╪╡╘╧╛│││═══"
  CONNECTORS_SINGLE_DOUBLE_MIXED = "╔╤╗╟┼╢╚╧╝║│║═─═"
  CONNECTORS_DOUBLE_SINGLE       = "╓╥╖╟╫╢╙╨╜║║║───"
  CONNECTORS_HEAVY               = "┏┳┓┣╋┫┗┻┛┃┃┃━━━"
  CONNECTORS_LIGHT_HEAVY         = "┍┯┑┝┿┥┕┷┙│││━━━"
  CONNECTORS_HEAVY_LIGHT         = "┎┰┒┠╂┨┖┸┚┃┃┃───"
  CONNECTORS_TEXT_CLASSIC        = "+++++++++|||---"
  CONNECTORS_TEXT_EXTENDED       = "+++++++++!:!=-="
  #
  # Style string contains the initial of line or column types (case
  # insensitive, may be separated for better readability, but not mandatory) :
  # - lc : Left column
  # - mc : middle columns
  # - rc : right column
  # - tl : Top line
  # - ml : Middle lines
  # - bl : bottom lines
  STYLE_ALL_BORDERS = "LC,MC,RC,TL,ML,BL"
  STYLE_NO_BORDERS  = "mcml"
  STYLE_NO_MID_COL  = "LCRCTLMLBL"
end
