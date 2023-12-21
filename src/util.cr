module Tablo
  module Util
    # Update namedtuple (dst) fields from another namedtuple (src) fields
    # Fields existing in src and missing in dst are ignored
    # Returns the updated dst as a new NamedTuple
    def self.update(dst : NamedTuple, from src : NamedTuple)
      update_impl(dst, src)
    end

    # :nodoc:
    # auxiliary method for update
    private def self.update_impl(dst : T, from src : U) forall T, U
      {% begin %}
      {% u_keys = U.keys %}
        NamedTuple(
          {% for k in T.keys %}
            {{ k.stringify }}: typeof(
              dst[{{ k.stringify }}],
              {% if u_keys.includes?(k) %}
                src[{{ k.stringify }}],
              {% end %}
            ),
          {% end %}
        ).new(
          {% for k in T.keys %}
            {% receiver = u_keys.includes?(k) ? "src" : "dst" %}
            {{ k.stringify }}: {{ receiver.id }}[{{ k.stringify }}],
          {% end %}
        )
      {% end %}
    end

    # Merge all namedtuple (nt1) fields and namedtuple (nt2) fields
    # For fields existing in both nt1 and nt2, merge use nt2 field value
    # This is equivalent to stdlib NameTuple.merge method
    # (Shown here as an example of macro)
    # Returns a new NamedTuple
    # def self.merge(nt1 : NamedTuple, nt2 : NamedTuple)
    #   merge_impl(nt1, nt2)
    # end

    # # auxiliary method for merge
    # private def self.merge_impl(nt1 : T, nt2 : U) forall T, U
    #   {% begin %}
    #   {% u_keys = U.keys %}
    #     NamedTuple.new(
    #       {% for k in T.keys %}
    #         {% unless u_keys.includes?(k) %}
    #         {{ k.stringify }}: nt1[{{ k.symbolize }}],
    #         {% end %}
    #       {% end %}
    #       {% for k in U.keys %}
    #         {{ k.stringify }}: nt2[{{ k.symbolize }}],
    #       {% end %}
    #       )
    #   {% debug %}
    #   {% end %}
    # end

    # :nodoc:
    # Checks if a command can be executed (found in Path)
    def self.command_exists?(command)
      ENV["PATH"].split(Process::PATH_DELIMITER).any? { |d| File.exists? File.join(d, command) }
    end

    # :nodoc:
    # returns terminal size, as tuple {lines, columns}
    def self.get_terminal_lines_and_columns
      # def self.terminal_size
      if (ENV["COLUMNS"]? =~ /^\d+$/) && (ENV["LINES"]? =~ /^\d+$/)
        lines = ENV["LINES"].to_i
        columns = ENV["COLUMNS"].to_i
      elsif self.command_exists?("tput")
        lines = %x(tput lines).to_i
        columns = %x(tput cols).to_i
      elsif self.command_exists?("stty")
        lines, columns = %x(stty size).split(" ").map &.to_i
      else
        columns = lines = nil
      end
      {lines, columns}
    end

    # :nodoc:
    # Returns true if styler proc may be applied
    def self.styler_allowed
      STDOUT.tty? || !Config.styler_tty_only?
    end

    # -------------- stretch --------------------------------------------------------
    #
    #
    def self.stretch(s : String, width : Int32, insert_char : Char, gap : Int32 = 0,
                     left_margin : String = "", right_margin : String = "")
      # first, we need to compute the optimized working_gap, the gap
      # which "harmonize" all lines
      working_gap = 999
      working_width = width - (left_margin.size + right_margin.size)
      s.each_line do |line|
        if line.size > 1
          intervals = line.size - 1
          max_gap = (working_width - line.size) // intervals
          max_gap = 0 if max_gap < 0
          working_gap = [working_gap, max_gap].min
        end
      end
      # now, compute final_gap, min between gap and working_gap if gap > 0
      final_gap = if gap == 0
                    working_gap
                  else
                    [working_gap, gap].min
                  end
      # and finally, compute stretched lines
      arrout = [] of String
      s.each_line do |line|
        if line =~ /^\s*$/
          arrout << ""
        elsif line.size == 1
          arrout << line
        else
          intervals = line.size - 1
          if final_gap == 0
            arrout << line
          else
            ary_src = line.chars
            final_length = line.size + (intervals * final_gap)
            ary_dest = Array(Char).new(final_length, insert_char)
            pos = 0
            ary_src.each.with_index do |c, i|
              ary_dest[pos] = c
              pos += (1 + final_gap)
            end
            arrout << left_margin + ary_dest.join + right_margin
          end
        end
      end
      arrout.join("\n")
    end

    enum DotAlign # All trailing decimal zeroes are replaced by spaces
      Empty       # Field is blank if value == 0
      Blank       # decimal part of field (including dot) is blank if zeroes
      Dot         # decimal part of field is blank if zeroes
      DotZero     # decimal part of field is blank if zeroes, except first (.0)
    end

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
            in DotAlign::Dot
              bytes[pos] = 32_u8
              break
            in DotAlign::Blank, DotAlign::Empty
              bytes[pos] = 32_u8
              bytes[pos - 1] = 32_u8
              if mode == DotAlign::Empty
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
end
