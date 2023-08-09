module Tablo
  module Util
    # :nodoc:
    # Update namedtuple (dst) existing fields from another namedtuple (src) fields
    # Fields existing in src and missing in dest are ignored
    def self.update(dst : NamedTuple, from src : NamedTuple)
      update_impl(dst, src)
    end

    # :nodoc:
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

    def self.merge(nt1 : NamedTuple, nt2 : NamedTuple)
      merge_impl(nt1, nt2)
    end

    private def self.merge_impl(nt1 : T, nt2 : U) forall T, U
      {% begin %}
      {% u_keys = U.keys %}
        NamedTuple.new(
          {% for k in T.keys %}
            {% unless u_keys.includes?(k) %}
            {{ k.stringify }}: nt1[{{ k.symbolize }}],
            {% end %}
          {% end %}
          {% for k in U.keys %}
            {{ k.stringify }}: nt2[{{ k.symbolize }}],
          {% end %}
          )
      {% debug %}
      {% end %}
    end

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

    def self.stretch(s : String, width : Int32, insert_char : Char,
                     gap : Int32 = 0, margin : Int32 = 0)
      arrout = [] of String
      width -= (margin * 2)
      s.each_line do |line|
        if line =~ /^\s*$/
          arrout << ""
        else
          # compute allowable gap value
          # allowed_gap = line.size == 1 ? width : width // (line.size - 1)
          allowed_gap = if line.size == 1
                          width
                        elsif width % line.size == 0
                          width // (line.size + 1)
                        else
                          width // line.size
                        end
          unless gap == 0
            allowed_gap = [gap, allowed_gap].min
          end
          # compute new line
          ary_src = line.chars
          ary_dest = Array(Char).new(width, insert_char)
          last_pos = 0
          if allowed_gap > 0
            ary_src.each.with_index do |c, i|
              pos = [((allowed_gap + 1) * i).to_i, width - 1].min
              # pos = [i, width - 1].min if pos > width
              # pos = i if pos > width
              ary_dest[pos] = c unless c.whitespace?
              last_pos = pos
            end
            ary_dest.delete_at((last_pos + 1), ary_dest.size - last_pos)
          else
            ary_dest = ary_src
          end
          arrout << ary_dest.join
          # arrout << " " * margin + ary_dest.join + " " * margin:w
        end
      end
      arrout.join("\n")
    end

    def self.debug_stretch(s : String, width : Int32, insert_char : Char, gap : Int32 = 0, margin = 0)
      arrout = [] of String
      width -= (margin * 2)
      debug!(width)
      debug!(gap)
      s.each_line do |line|
        debug!(line)
        debug!(line.size)
        if line =~ /^\s*$/
          arrout << ""
        else
          # compute allowable gap value
          # allowed_gap = line.size == 1 ? width : width // (line.size - 1)
          allowed_gap = if line.size == 1
                          width
                        elsif width % line.size == 0
                          width // (line.size + 1)
                        else
                          width // line.size
                        end
          debug!(allowed_gap)
          unless gap == 0
            allowed_gap = [gap, allowed_gap].min
          end
          debug!(allowed_gap)
          # compute new line
          ary_src = line.chars
          ary_dest = Array(Char).new(width, insert_char)
          debug!(allowed_gap)
          last_pos = 0
          if allowed_gap > 0
            ary_src.each.with_index do |c, i|
              debug!(((allowed_gap + 1) * i).to_i)
              pos = [((allowed_gap + 1) * i).to_i, width - 1].min
              # pos = [i, width - 1].min if pos > width
              # pos = i if pos > width
              debug!(pos)
              ary_dest[pos] = c unless c.whitespace?
              last_pos = pos
              debug!(last_pos)
            end
            debug!(last_pos)
            debug!(ary_dest.join)
            ary_dest.delete_at((last_pos + 1), ary_dest.size - last_pos)
            debug!(ary_dest.join)
          else
            ary_dest = ary_src
          end
          debug!(ary_dest.join)
          arrout << ary_dest.join
          # arrout << " " * margin + ary_dest.join + " " * margin:w
        end
        debug!("")
      end
      debug!(arrout)
      arrout.join("\n")
    end

    def self.new3_stretch(s : String, width : Int32, insert_char : Char, gap = 0, margins = 0)
      # To obtain best result, width must be equal to : s.width + (s.width -1) * n
      arrout = [] of String
      s.each_line do |line|
        if line =~ /^\s*$/
          arrout << ""
        else
          # w = width - (margins * 2)
          insert_gap = gap
          debug!(line)
          debug!(width)
          debug!(line.size)
          # return s if width < line.size
          if gap == 0
            if line.size == 1
              insert_gap = width
            else
              insert_gap = width // (line.size - 1)
            end
          else
            insert_gap = gap + 1
          end
          ary_src = line.chars
          ary_dest = Array(Char).new(width, insert_char)
          loop do
            if line.size + insert_gap * (line.size - 1) > width
              insert_gap -= 1
            else
              break
            end
          end
          debug!(insert_gap)
          if insert_gap > 0
            ary_src.each.with_index do |c, i|
              debug!((insert_gap * i).to_i)
              pos = [(insert_gap * i).to_i, width - 1].min
              # pos = [i, width - 1].min if pos > width
              pos = i if pos > width
              debug!(pos)
              ary_dest[pos] = c unless c.whitespace?
            end
          else
            ary_dest = ary_src
          end
          debug!(ary_dest.join)
          arrout << ary_dest.join
        end
        debug!("")
      end
      debug!(arrout)
      arrout.join("\n")
    end

    def self.new2_stretch(s : String, width : Int32, insert_char : Char, gap = 0, margins = 0)
      # To obtain best result, width must be equal to : s.width + (s.width -1) * n
      arrout = [] of String
      s.each_line do |line|
        w = width - (margins * 2)
        return s if w < line.size
        if gap == 0
          if line.size == 1
            insert_gap = w
          else
            insert_gap = w // (line.size - 1)
          end
        else
          insert_gap = gap + 1
        end
        ary_src = line.chars
        ary_dest = Array(Char).new(w, insert_char)
        ary_src.each.with_index do |c, i|
          pos = [(insert_gap * i).to_i, w - 1].min
          ary_dest[pos] = c unless c.whitespace?
        end
        arrout << " " * margins + ary_dest.join + " " * margins
      end
      arrout.join("\n")
    end

    def self.new_stretch(s : String, width : Int32, insert_char : Char, before = "", after = "")
      # To obtain best result, width must be equal to : s.width + (s.width -1) * n
      arrout = [] of String
      s.each_line do |line|
        w = width - (before.size + after.size)
        return s if w < line.size
        insert_gap = w // (line.size - 1)
        ary_src = line.chars
        ary_dest = Array(Char).new(w, insert_char)
        ary_src.each.with_index do |c, i|
          pos = [(insert_gap * i).to_i, w - 1].min
          ary_dest[pos] = c unless c.whitespace?
        end
        arrout << before + ary_dest.join + after
      end
      arrout.join("\n")
    end

    def self.old_stretch(s : String, width : Int32, insert_char : Char, before = "", after = "")
      # To obtain best result, width must be equal to : s.width + (s.width -1) * n
      strout = String.build do |str|
        s.each_line do |line|
          if line =~ /^\s*$/
            str << "\n"
          else
            width -= (before.size + after.size)
            return s if width < line.size
            insert_gap = width // (line.size - 1)
            ary_src = line.chars
            ary_dest = Array(Char).new(width, insert_char)
            ary_src.each.with_index do |c, i|
              pos = [(insert_gap * i).to_i, width - 1].min
              ary_dest[pos] = c unless c.whitespace?
            end
            str << before << ary_dest.join << after
          end
        end
      end
      strout
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
