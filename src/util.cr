module Tablo
  # :nodoc:
  module Util
    # :nodoc:
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
    def self.terminal_lines_and_columns
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
  end
end
