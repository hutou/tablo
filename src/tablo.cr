require "./table"

module Tablo
  VERSION = "0.90.0"

  # Used by `Tablo.dot_align` class method for floats formatting, where
  # all trailing decimal zeroes are replaced by spaces. <br />
  #
  # Special formatting is further applied depending on enum values:
  # - *Blank*: Whole field is blank if value == 0
  # - *NoDot*: Decimal part of field (including dot) is blank if all decimals are zeroes
  # - *DotOnly*: Decimal part of field is blank if all decimals are zeroes
  # - *DotZero*: Decimal part of field is blank if all decimals are zeroes, except first (.0)
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
  # - *value*: The number to align on decimal point
  # - *dec*: Number of decimal places (can be negative: see valid interval in
  # `Config::Controls.rounding_range`)
  # - *mode*: Defines format type for decimal point alignment
  #    (defaults to `DotAlign::DotZero`)
  #
  # Example:
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
      raise Error::InvalidValue.new "dot_align: number of decimals must be in range " +
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
  #     Tablo.stretch(value.as(`String`), width, fill_char: '.', max_fill: 1,
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
  def self.stretch(text : String, target_width : Int32,
                   prefix : String = "", suffix : String = "",
                   text_alignment : Justify = Justify::Center,
                   fill_char : Char = ' ',
                   max_fill : Int32 = Int32::MAX) : String
    stretched_text = [] of String

    if max_fill < 0
      raise Error::InvalidValue.new "stretch: filler size cannot be negative"
    end
    if (fb = prefix.index('{')) && (lb = prefix.rindex('}'))
      prefix_fixed, prefix_variable, prefix_head =
        prefix[0..fb - 1], prefix[fb + 1..lb - 1], prefix[lb + 1..-1]
    else
      prefix_fixed, prefix_variable, prefix_head = prefix, "", ""
    end
    if (fb = suffix.index('{')) && (lb = suffix.rindex('}'))
      suffix_head, suffix_variable, suffix_fixed =
        suffix[0..fb - 1], suffix[fb + 1..lb - 1], suffix[lb + 1..-1]
    else
      suffix_fixed, suffix_variable, suffix_head = suffix, "", ""
    end

    max_line_size = text.lines.map(&.strip.size).max
    intervals = max_line_size - 1

    margins_max = (prefix_fixed + prefix_variable + prefix_head +
                   suffix_fixed + suffix_variable + suffix_head).size
    margins_min = margins_max - (prefix_variable + suffix_variable).size
    space_chars_avail_min = target_width - margins_max - max_line_size
    space_chars_avail_max = target_width - margins_min - max_line_size

    # Check if any stretching can be done. If not, return the
    # text value unchanged
    return text if space_chars_avail_max < 0

    spaces_between_chars_max = space_chars_avail_max // intervals
    spaces_between_chars_min = space_chars_avail_min // intervals

    prefix_variable_size = prefix_variable.size
    suffix_variable_size = suffix_variable.size
    variable_size = prefix_variable_size + suffix_variable_size

    spaces_between_chars_min = 0 if spaces_between_chars_min < 0
    spaces_between_chars = spaces_between_chars_min
    spaces_between_chars_max.downto [spaces_between_chars_min, max_fill].min do |spaces_between|
      next if spaces_between > max_fill
      reduce = prefix_variable_size + suffix_variable_size -
               (target_width - (prefix_fixed + prefix_head).size -
                (suffix_fixed + suffix_head).size - spaces_between *
                                                    intervals - max_line_size)
      if reduce > 0
        reduce_left = reduce * prefix_variable_size // variable_size
        reduce_right = reduce - reduce_left
        prefix_variable = prefix_variable[0..-(1 + reduce_left)]
        suffix_variable = suffix_variable[reduce_right..-1]
      end
      spaces_between_chars = spaces_between
      break
    end

    margin_left = prefix_fixed + prefix_variable + prefix_head
    margin_right = suffix_head + suffix_variable + suffix_fixed
    margins_size = (margin_left + margin_right).size
    text.each_line do |line|
      line = line.strip
      central_part = line.chars.join(fill_char.to_s * spaces_between_chars)
      central_part_justified = case text_alignment
                               when Justify::Left
                                 central_part.ljust(target_width - margins_size)
                               when Justify::Right
                                 central_part.rjust(target_width - margins_size)
                               else
                                 central_part.center(target_width - margins_size)
                               end
      final_line = margin_left + central_part_justified + margin_right
      stretched_text << final_line
    end
    stretched_text.join("\n")
  end
end
