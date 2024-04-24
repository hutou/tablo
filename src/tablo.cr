require "./table"

module Tablo
  VERSION = "0.90.0"

  # Used by `Tablo.dot_align` class method for floats formatting, where
  # all trailing decimal zeroes are replaced by spaces. <br />
  #
  # special formatting is further applied depending on enum values:
  # - `Blank`   = whole field is blank if value == 0
  # - `NoDot`   = decimal part of field (including dot) is blank if all decimals are zeroes
  # - `DotOnly` = decimal part of field is blank if all decimals are zeroes
  # - `DotZero` = decimal part of field is blank if all decimals are zeroes, except first (.0)
  enum DotAlign
    Blank
    NoDot
    DotOnly
    DotZero
  end

  # Method to align floats on decimal point, where non significant zeroes are
  # replaced by spaces (see `DotAlign`)
  #
  # Mandatory parameters are:
  # - `value` : type is a Float`
  # - `dec` : type is Int32 : the number of decimals
  # - `mode` : a formatting enum DotAlign value (defaults to DotZero)
  #
  # Example with default `DotAlign::DotZero`
  # ```
  # require "tablo"
  #
  # ar = [423.14159, 2.0000345, 0.0000234, 42.21, 7.9]
  # table = Tablo::Table.new(ar) do |t|
  #   t.add_column("Floats",
  #     body_formatter: ->(value : Tablo::CellType) {
  #       Tablo.dot_align(value, 3, :dot_zero)
  #     }, &.itself)
  # end
  # puts table
  # ```
  #     +--------------+
  #     |       Floats |
  #     +--------------+
  #     |      423.142 |
  #     |        2.0   |
  #     |        0.0   |
  #     |       42.21  |
  #     |        7.9   |
  #     +--------------+
  def self.dot_align(value : Float, dec : Int32, mode : DotAlign = DotAlign::DotZero)
    unless dec.in?(Config::Controls.rounding_range)
      raise Error::InvalidValue.new "Number of decimals must be in range " +
                                    "(#{Config::Controls.rounding_range})"
    end
    snum = value.round(dec).to_s
    dec = 1 if dec <= 0
    ipart, fpart = snum.split(".")
    if fpart == "0"
      case mode
      in DotAlign::DotZero
        ipart + ".0" + " " * (dec - 1)
      in DotAlign::DotOnly
        ipart + "." + " " * dec
      in DotAlign::NoDot, DotAlign::Blank
        if value.zero? && mode == DotAlign::Blank
          " " * (dec + 1)
        else
          ipart + " " * (dec + 1)
        end
      end
    else
      ipart + "." + fpart + " " * (dec - fpart.size)
    end
  end
end
