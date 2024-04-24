require "./table"

module Tablo
  VERSION = "0.90.0"

  # Used by `Tablo.dot_align` class method for floats formatting, where
  # all trailing decimal zeroes are replaced by spaces. <br />
  #
  # special formatting is further applied depending on enum values:
  # - Blank   = whole field is blank if value == 0
  # - NoDot   = decimal part of field (including dot) is blank if all decimals are zeroes
  # - DotOnly = decimal part of field is blank if all decimals are zeroes
  # - DotZero = decimal part of field is blank if all decimals are zeroes, except first (.0)
  enum DotAlign
    Blank
    NoDot
    DotOnly
    DotZero
  end

  # Method to align floats on decimal point, where non significant zeroes are
  # replaced by spaces (see `DotAlign`)
  #
  # Parameters are:
  # - value
  # - decimals
  # - Formatting enum value
  #
  # Example with default DotAlign::DotZero
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
  def self.dot_align(value, dec, mode : DotAlign = DotAlign::DotZero)
    dec = 1 if dec <= 0 # default to 1 if invalid
    bytes = ("%.#{dec}f" % value).to_slice.dup
    pos = bytes.size - 1
    chr = bytes[pos]
    loop do
      chr_prev = bytes[pos - 1]
      if chr == 48_u8
        if chr_prev == 48_u8
          bytes[pos] = 32_u8
        elsif chr_prev == 46_u8
          case mode
          in DotAlign::DotZero
            break
          in DotAlign::DotOnly
            bytes[pos] = 32_u8
            break
          in DotAlign::Blank, DotAlign::NoDot
            bytes[pos] = 32_u8
            bytes[pos - 1] = 32_u8
            if mode == DotAlign::Blank
              bytes[pos - 2] = 32_u8 if bytes[pos - 2] == 48_u8 &&
                                        pos - 2 == 0
            end
            break
          end
        else
          bytes[pos] = 32_u8
          break
        end
      else
        break
      end
      pos -= 1
      chr = chr_prev
    end
    String.new(bytes)
  end
end
