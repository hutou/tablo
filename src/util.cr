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

    # The stretch method is designed to optimize the filling of a text area,
    # possibly multi-line, by inserting one or more separators (by default
    # a space) between each character of the initial string.
    def self.stretch(str : String, width : Int32, insert_char : Char = ' ',
                     gap : Int32? = nil, left_margin : String = "",
                     right_margin : String = "")
      #
      # Compute the ideal gap depending on width and line(s) size
      # returns ideal_gap and largest line

      # Stretch the line for a given gap
      stretched = ->(line : String, idgap : Int32) do
        final_length = line.size + (line.size - 1) * idgap
        ary_dest = Array(Char).new(final_length, insert_char)
        pos = 0
        line.chars.each.with_index do |c, i|
          ary_dest[pos] = c
          pos += (1 + idgap)
        end
        ary_dest.join
      end

      # Compute left and right margin areas
      rx = /^([^,;]+)*[,;]*(.+)*$/
      lm_first, lm_last = (left_margin.match(rx)
        .as(Regex::MatchData).to_a.map &.to_s)[1, 2]
      rm_last, rm_first = (right_margin.match(rx)
        .as(Regex::MatchData).to_a.map &.to_s)[1, 2]
      rm_last, rm_first = rm_first, rm_last if rm_first.empty?

      # get margins
      get_margins = ->do
        lm_first.size + rm_first.size + lm_last.size + rm_last.size
      end

      # Increase stretch zone by reducing margins to fit width
      increase_stretching_width = ->do
        # now, reduce margin begin
        first = false
        if lm_first.size > 0
          lm_first = lm_first[0..-2]
          first = true
        end
        if rm_first.size > 0
          rm_first = rm_first[1..-1]
          first = true
        end
        # now, reduce margin begin
        last = false
        unless first
          if lm_last.size > 0
            lm_last = lm_last[1..-1]
            last = true
          end
          if rm_last.size > 0
            rm_last = rm_last[0..-2]
            last = true
          end
        end
        # returns true if a modification has been done
        first | last
      end

      # Starting position : we consider all margins are kept
      stretching_width = width - get_margins.call
      ideal_gap = str.empty? ? 0 : Int32::MAX
      largest_line = ""
      str.each_line do |line|
        largest_line = line if line.size > largest_line.size
        max_gap = line.size == 1 ? 0 : (stretching_width - line.size) // (line.size - 1)
        max_gap = 0 if max_gap < 0
        ideal_gap = [ideal_gap, max_gap].min
      end
      unless gap.nil?
        ideal_gap = ideal_gap > gap ? gap : ideal_gap
      end

      # Now, check if the largest stretched fits ?
      while (stretched.call(largest_line, ideal_gap).size + get_margins.call) > width
        # obviously, we need to reduce margins !
        break unless increase_stretching_width.call
        stretching_width = width - get_margins.call
      end

      # and finally, we render stretched lines
      arrout = [] of String
      str.each_line do |line|
        if line =~ /^\s*$/
          xline = ""
        elsif line.size == 1
          xline = line
        else
          xline = stretched.call(line, ideal_gap)
        end
        lm = lm_first + lm_last
        rm = rm_last + rm_first

        arrout << lm + xline.center(width - lm.size - rm.size) + rm
      end
      arrout.join(NEWLINE)
    end

    # enum DotAlign # All trailing decimal zeroes are replaced by spaces
    #   Empty       # Field is blank if value == 0
    #   Blank       # decimal part of field (including dot) is blank if zeroes
    #   Dot         # decimal part of field is blank if zeroes
    #   DotZero     # decimal part of field is blank if zeroes, except first (.0)
    # end

    # def self.dot_align(value, dec, mode : DotAlign = DotAlign::DotZero)
    #   dec = 1 if dec <= 0 # default to 1 if invalid
    #   bytes = ("%.#{dec}f" % value).to_slice.dup
    #   pos = bytes.size - 1
    #   chr = bytes[pos]
    #   loop do
    #     chr_prev = bytes[pos - 1]
    #     if chr == 48_u8
    #       if chr_prev == 48_u8
    #         bytes[pos] = 32_u8
    #       elsif chr_prev == 46_u8
    #         case mode
    #         in DotAlign::DotZero
    #           break
    #         in DotAlign::Dot
    #           bytes[pos] = 32_u8
    #           break
    #         in DotAlign::Blank, DotAlign::Empty
    #           bytes[pos] = 32_u8
    #           bytes[pos - 1] = 32_u8
    #           if mode == DotAlign::Empty
    #             bytes[pos - 2] = 32_u8 if bytes[pos - 2] == 48_u8 &&
    #                                       pos - 2 == 0
    #           end
    #           break
    #         end
    #       else
    #         bytes[pos] = 32_u8
    #         break
    #       end
    #     else
    #       break
    #     end
    #     pos -= 1
    #     chr = chr_prev
    #   end
    #   String.new(bytes)
    # end
  end
end
