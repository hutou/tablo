require "./table"

module Tablo
  VERSION = "0.99.0"

  module Functions
    # Used by `Tablo::Functions.fp_align` class method for floats formatting, where
    # all trailing decimal zeroes are replaced by spaces. <br />
    #
    # Special formatting is further applied depending on enum values:
    # - *Blank*: Whole field is blank if value == 0
    # - *NoDot*: Decimal part of field (including dot) is blank if all decimals are zeroes
    # - *DotOnly*: Decimal part of field is blank if all decimals are zeroes
    # - *DotZero*: Decimal part of field is blank if all decimals are zeroes, except first (.0)
    enum FPAlign
      Blank
      NoDot
      DotOnly
      DotZero
    end

    # Method to align floats on decimal point, where non significant zeroes are
    # replaced by spaces (see `FPAlign`)
    #
    # Mandatory parameters are:
    # - *value*: The number to align on decimal point
    # - *dec*: Number of decimal places (can be negative: see valid interval in
    # `Config::Controls.rounding_range`)
    # - *mode*: Defines format type for decimal point alignment
    #    (defaults to `FPAlign::DotZero`)
    #
    # Example:
    # ```
    # require "tablo"
    #
    # ar = [423.14159, 2.0000345, 0.0000234, 42.21, 7.9]
    # table = Tablo::Table.new(ar) do |t|
    #   t.add_column("Floats",
    #     body_formatter: ->(value : Tablo::CellType) {
    #       Tablo::Functions.fp_align(value.as(Float), 3, :dot_zero)
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
    def self.fp_align(value : Float, dec : Int32, mode : FPAlign = FPAlign::DotZero)
      unless dec.in?(Config::Controls.rounding_range)
        raise Error::InvalidValue.new "fp_align: number of decimals must be in range " +
                                      "(#{Config::Controls.rounding_range})"
      end
      snum = value.round(dec).to_s
      dec = 1 if dec <= 0
      ipart, fpart = snum.split(".")
      if fpart == "0"
        case mode
        in FPAlign::DotZero
          ipart + ".0" + " " * (dec - 1)
        in FPAlign::DotOnly
          ipart + "." + " " * dec
        in FPAlign::NoDot, FPAlign::Blank
          if value.zero? && mode == FPAlign::Blank
            " " * (dec + 1)
          else
            ipart + " " * (dec + 1)
          end
        end
      else
        ipart + "." + fpart + " " * (dec - fpart.size)
      end
    end

    # The `.stretch` method is designed to optimize the filling of a text zone,
    # possibly multi-line, by inserting one or more filler characters (by
    # default space) between each character of the initial string.
    #
    # _Mandatory parameters:_
    #
    # - *text*: The content of the cell (possibly multiline) to be stretched
    # - *target_width*: Width of column (or group or header cell)
    #
    # _Optional named parameters, with default values_
    #
    # - *prefix*: String inserted in front of stretched text, left-aligned <br/>
    #   The area between braces can be reduced at will, to maximize stretching.
    #   See example below.
    # - *suffix*: Same as prefix, but right-aligned
    # - *alignment*: Justification of stretched text, excluding prefix and suffix
    # - *fill_char*: Fill character for stretched text
    # - *max_fill*: Can be set to control the number of padding characters
    # (*fill_char*) between each character in the stretched string
    #
    # If constraints cannot be met (for example, prefix or suffix margins too large),
    # returns text unchanged.
    #
    # ```
    # require "tablo"
    # table = Tablo::Table.new([1, 2, 3]) do |t|
    #   t.add_column("integer", &.itself)
    #   t.add_column("Float", &.**(0.5).round(2))
    #   t.add_group("Numbers", formatter: ->(value : Tablo::CellType, width : Int32) {
    #     Tablo::Functions.stretch(value.as(String), width, fill_char: '.', max_fill: 1,
    #       prefix: "<--{------} ", suffix: " {------}-->")
    #   })
    # end
    # puts table
    # ```
    # In this example, we can see that the variable areas of the prefix and
    # suffix have been reduced to maximize the stretch, which is nevertheless
    # limited by the *max_fill* parameter to one character.
    #
    # ```
    # +-----------------------------+
    # | <----- N.u.m.b.e.r.s -----> |
    # +--------------+--------------+
    # |      integer |        Float |
    # +--------------+--------------+
    # |            1 |          1.0 |
    # |            2 |         1.41 |
    # |            3 |         1.73 |
    # +--------------+--------------+
    # ```
    # And, without specifying *max_fill*:
    # ```
    # +-----------------------------+
    # | <-- N..u..m..b..e..r..s --> |
    # +--------------+--------------+
    # |      integer |        Float |
    # +--------------+--------------+
    # |            1 |          1.0 |
    # |            2 |         1.41 |
    # |            3 |         1.73 |
    # +--------------+--------------+
    # ```
    def self.stretch(text : String, target_width : Int32,
                     prefix : String = "", suffix : String = "",
                     text_alignment : Justify = Justify::Center,
                     fill_char : Char = ' ',
                     max_fill : Int32 = Int32::MAX) : String
      stretched_text = [] of String

      if max_fill < 0
        raise Error::InvalidValue.new "stretch: filler size cannot be negative"
      end
      pre_fix, pre_var, pre_head = if (open = prefix.index('{')) &&
                                      (close = prefix.rindex('}'))
                                     {prefix[0..open - 1],
                                      prefix[open + 1..close - 1],
                                      prefix[close + 1..-1]}
                                   else
                                     {prefix, "", ""}
                                   end
      suf_head, suf_var, suf_fix = if (open = suffix.index('{')) &&
                                      (close = suffix.rindex('}'))
                                     {suffix[0..open - 1],
                                      suffix[open + 1..close - 1],
                                      suffix[close + 1..-1]}
                                   else
                                     {"", "", suffix}
                                   end
      max_line_len = text.lines.map(&.strip.size).max
      intervals = max_line_len - 1
      pre_fix_head_size = pre_fix.size + pre_head.size
      suf_fix_head_size = suf_fix.size + suf_head.size
      space_max = target_width - (pre_fix_head_size +
                                  suf_fix_head_size) - max_line_len
      return text if space_max < 0
      spaces = [space_max // intervals, max_fill].min
      var_size = pre_var.size + suf_var.size
      reduce = var_size - (target_width - pre_fix_head_size - suf_fix_head_size -
                           spaces * intervals - max_line_len)
      if reduce > 0
        reduce_left = reduce * pre_var.size // var_size
        pre_var = pre_var[0..-(1 + reduce_left)]
        suf_var = suf_var[reduce - reduce_left..-1]
      end
      margin_left = pre_fix + pre_var + pre_head
      margin_right = suf_head + suf_var + suf_fix
      margin_size = (margin_left + margin_right).size
      text.each_line do |line|
        central = line.strip.chars.join(fill_char.to_s * spaces)
        justified = case text_alignment
                    when Justify::Left
                      central.ljust(target_width - margin_size)
                    when Justify::Right
                      central.rjust(target_width - margin_size)
                    else
                      central.center(target_width - margin_size)
                    end
        stretched_text << "#{margin_left}#{justified}#{margin_right}"
      end
      stretched_text.join("\n")
    end

    extend self
  end
end
