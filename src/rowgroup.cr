require "./types"
require "./heading"

module Tablo
  # Each time the source is read, an instance of the RowGroup class is created
  # to display Body and all other preceeding possible row types and rule
  # types.
  #
  # The main purpose of the RowGroup class is to manage the alternation of
  # different row types  and their separating rule types.
  #
  # To do this, the previous and current row types are used to determine the
  # rule type and deduce border position to be used (see ROWTYPE_POSITION below).

  # From one instance to the next, the RowGroup class has no memory: the
  # Table.rowtype_memory class variable is therefore used to ensure the link:
  # when a new instance of RowGroup is created, the previous_rowtype instance
  # variable is initialized by Table.rowtype_memory, and on exit from
  # RowGroup's run method, the current_rowtype instance variable is assigned to
  # Table.rowtype_memory.
  class RowGroup(T)
    @rows = [] of String
    # Whenever we enter rowgroup, we retrieve the previous rowtype from
    # the recorded value in class variable Table.rowtype_memory
    property previous_rowtype : RowType? = Table.rowtype_memory
    # property previous_rowtype : RowType? = Table.previous_rowtype
    property current_rowtype : RowType? = nil
    private getter table, source, row_index, row_divider
    property rows

    def initialize(@table : Table(T),
                   @source : T,
                   @row_divider : Bool?,
                   @row_index : Int32)
    end

    {% if flag?(:DEBUG_ROWS) %}
      def add_row(rows, linenum = 0)
        rows.each_line.with_index do |r, i|
          if i == 0
            # self.rows << "[in %-8s from %-8s%24s] => %s" % [
            # current_rowtype.to_s, previous_rowtype.to_s, "", r,
            self.rows << "[in %-8s from %-8s%18s (%3d)] => %s" % [
              current_rowtype.to_s, previous_rowtype.to_s, "", linenum, r,
            ]
          else
            self.rows << "%-15s%-16s%24s%s" % ["", "...", "", r]
          end
        end
      end

      def add_rule(position, groups = nil, linenum = 0)
        row = table.horizontal_rule(position, groups)
        unless row.empty?
          self.rows << "[in %-8s from %-8s  pos:%-12.12s (%3d)] => %s" % [
            current_rowtype.to_s, previous_rowtype.to_s, position.to_s, linenum, row,
          ]
        end
      end
    {% else %}
      def add_row(rows, linenum = 0)
        self.rows << rows
      end

      def add_rule(position, groups = nil, linenum = 0)
        row = table.horizontal_rule(position, groups)
        unless row.empty?
          self.rows << row
        end
      end
    {% end %}

    def framed?(rowtype)
      case rowtype
      when Nil
        false
      when RowType::Title
        table.title.framed?
      when RowType::SubTitle
        table.subtitle.framed?
      when RowType::Footer
        table.footer.framed?
      else
        true
      end
    end

    private def line_breaks_after(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.frame.as(Frame).line_breaks_after : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.frame.as(Frame).line_breaks_after : 0
      when RowType::Footer
        table.footer.framed? ? table.footer.frame.as(Frame).line_breaks_after : 0
      else
        0
      end
    end

    private def line_breaks_before(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.frame.as(Frame).line_breaks_before : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.frame.as(Frame).line_breaks_before : 0
      when RowType::Footer
        table.footer.framed? ? table.footer.frame.as(Frame).line_breaks_before : 0
      else
        0
      end
    end

    ROWTYPE_POSITION = {
      # previous, current
      {RowType::Body, RowType::Body}       => Position::BodyBody,
      {RowType::Body, :bottom}             => Position::BodyBottom,
      {RowType::Body, :filler}             => Position::BodyFiller,
      {RowType::Body, RowType::Group}      => Position::BodyGroup,
      {RowType::Body, RowType::Header}     => Position::BodyHeader,
      {RowType::Body, RowType::Footer}     => Position::BodyTitle,
      {RowType::Body, RowType::Title}      => Position::BodyTitle,
      {RowType::Body, :top}                => Position::BodyTop,
      {RowType::Group, RowType::Header}    => Position::GroupHeader,
      {RowType::Group, :top}               => Position::GroupTop,
      {RowType::Header, RowType::Body}     => Position::HeaderBody,
      {RowType::Header, :top}              => Position::HeaderTop,
      {:summary, RowType::Body}            => Position::SummaryBody,
      {:summary, RowType::Header}          => Position::SummaryHeader,
      {RowType::Footer, RowType::Body}     => Position::TitleBody,
      {RowType::Title, RowType::Body}      => Position::TitleBody,
      {RowType::Footer, :bottom}           => Position::TitleBottom,
      {RowType::SubTitle, :bottom}         => Position::TitleBottom,
      {RowType::Title, :bottom}            => Position::TitleBottom,
      {RowType::Footer, RowType::Group}    => Position::TitleGroup,
      {RowType::SubTitle, RowType::Group}  => Position::TitleGroup,
      {RowType::Title, RowType::Group}     => Position::TitleGroup,
      {RowType::Footer, RowType::Header}   => Position::TitleHeader,
      {RowType::SubTitle, RowType::Header} => Position::TitleHeader,
      {RowType::Title, RowType::Header}    => Position::TitleHeader,
      {RowType::Footer, RowType::Title}    => Position::TitleTitle,
      {RowType::Title, RowType::SubTitle}  => Position::TitleTitle,
      {RowType::Title, RowType::Title}     => Position::TitleTitle,
      {RowType::Footer, :top}              => Position::TitleTop,
      {RowType::SubTitle, :top}            => Position::TitleTop,
      {RowType::Title, :top}               => Position::TitleTop,
    }

    private def fill_page
      # Add "filler" rows to reach page size (header_frequency)
      if previous_rowtype == RowType::Body && current_rowtype == RowType::Footer
        missing_rows.times do
          add_rule(ROWTYPE_POSITION[{RowType::Body, :filler}],
            groups: nil, linenum: __LINE__)
        end
      end
    end

    private def summary_first_row?
    end

    private def apply_rules
      # Deal with table transition from Detail to Summary
      if row_index == 0 && !Table.omitted_rowtype.nil?
        self.previous_rowtype = Table.omitted_rowtype # if previous_rowtype.nil?
        previous_rowtype_framed = Table.omitted_rowtype_framed?
        previous_rowtype_line_breaks_after = Table.omitted_rowtype_line_breaks_after
        Table.omitted_rowtype = nil
        summary_first = true
      else
        previous_rowtype_framed = framed?(previous_rowtype)
        previous_rowtype_line_breaks_after = line_breaks_after(previous_rowtype)
        summary_first = false
      end

      groups = previous_rowtype == RowType::Group ||
               current_rowtype == RowType::Group ? table.groups : nil
      spacing = [line_breaks_after(previous_rowtype), line_breaks_before(current_rowtype)].max
      # case {framed?(previous_rowtype), framed?(current_rowtype)}
      case {previous_rowtype_framed, framed?(current_rowtype)}
      when {true, true}
        if spacing.zero?
          fill_page
          if summary_first
            # Table linking is done if adjacent row types are framed, with no spacing
            # we must use a specific horizontal rule do separate detail and summary
            case {previous_rowtype, current_rowtype}
            when {RowType::Body, RowType::Header}
              add_rule(Position::SummaryHeader,
                groups: groups, linenum: __LINE__)
            when {RowType::Body, RowType::Body}
              add_rule(Position::SummaryBody,
                groups: groups, linenum: __LINE__)
            else
              add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}],
                groups: groups, linenum: __LINE__)
            end
          else
            case {previous_rowtype, current_rowtype}
            when {RowType::Body, RowType::Body}
              add_rule(Position::BodyBody,
                groups: groups, linenum: __LINE__) if row_divider
            else
              # puts "zzz #{ROWTYPE_POSITION[{previous_rowtype, current_rowtype}]}"
              add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}],
                groups: groups, linenum: __LINE__)
            end
          end
        else
          fill_page
          add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}],
            groups: groups, linenum: __LINE__)
          # add page break after framed footer
          if previous_rowtype == RowType::Footer && table.footer.page_break?
            self.rows[-1] += "\f"
          end
          apply_line_spacing(spacing - 1)
          add_rule(ROWTYPE_POSITION[{current_rowtype, :top}],
            groups: groups, linenum: __LINE__)
        end
      when {true, false}
        fill_page
        add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}],
          groups: groups, linenum: __LINE__)
        apply_line_spacing(line_breaks_after(previous_rowtype) - 1)
      when {false, true}
        apply_line_spacing(line_breaks_before(current_rowtype) - 1)
        add_rule(ROWTYPE_POSITION[{current_rowtype, :top}],
          groups: groups, linenum: __LINE__)
      when {false, false}
      end
      add_rowtype
      self.previous_rowtype = current_rowtype
    end

    def add_rowtype
      case current_rowtype
      when RowType::Title
        add_row(table.rendered_title_row, linenum: __LINE__)
      when RowType::SubTitle
        add_row(table.rendered_subtitle_row, linenum: __LINE__)
      when RowType::Group
        add_row(table.rendered_group_row, linenum: __LINE__)
      when RowType::Header
        add_row(table.rendered_header_row(source, row_index), linenum: __LINE__)
      when RowType::Body
        add_row(table.rendered_body_row(source, row_index), linenum: __LINE__)
      when RowType::Footer
        add_row(table.rendered_footer_row(page), linenum: __LINE__)
        self.rows[-1] += "\f" if table.footer.page_break? && !table.footer.framed?
      end
    end

    def close_table
      # Only Body and Footer row types are possible
      case previous_rowtype
      when RowType::Body
        add_rule(Position::BodyBottom, linenum: __LINE__)
      when RowType::Footer
        add_rule(Position::TitleBottom, linenum: __LINE__) if table.footer.framed?
        self.rows[-1] += "\f" if table.footer.page_break?
      end
      # Clear Table memory for next table display
      Table.rowtype_memory = nil
    end

    def run
      if has_title?
        self.current_rowtype = RowType::Title
        apply_rules
      end

      if has_subtitle?
        self.current_rowtype = RowType::SubTitle
        apply_rules
      end

      if has_group?
        self.current_rowtype = RowType::Group
        apply_rules
      end

      if has_header?
        self.current_rowtype = RowType::Header
        apply_rules
      end

      # For Body, always !
      self.current_rowtype = RowType::Body
      apply_rules

      if has_footer?
        # debugger
        self.current_rowtype = RowType::Footer
        apply_rules
      end

      if last_row?
        # Do we have a summary table ?
        if table.summary_table.nil?
          # No summary, so we can close table
          close_table unless table.omit_last_rule?
        else
          # yes, we have a summary table
          # Do we have a request for linking tables ?
          if table.omit_last_rule?
            # Ok, linked tables wanted, but conditions are :
            #  - previous_rowtype == Body
            #  - previous_rowtype == Footer *AND* # FramedHeading *AND* no footer_page_break
            if previous_rowtype == RowType::Body ||
               (previous_rowtype == RowType::Footer && table.footer.framed? &&
               !table.footer.page_break?)
              # Okay, linking is allowed, so we save data for next run
              Table.omitted_rowtype = previous_rowtype
              Table.omitted_rowtype_framed = true
              Table.omitted_rowtype_line_breaks_after = 0
              if previous_rowtype == RowType::Footer
                Table.omitted_rowtype_framed = table.footer.framed?
                # Table.omitted_rowtype_line_breaks_after = table.footer.line_breaks_after
                # Table.omitted_rowtype_line_breaks_after = table.footer.framed? ? table.footer.as(FramedHeading).line_breaks_after : 0
                Table.omitted_rowtype_line_breaks_after = table.footer.framed? ? table.footer.frame.as(Frame).line_breaks_after : 0
              end
            else
              # no linking allowed, we must close
              # and not obey omitting last rule in that case !
              close_table
            end
          else
            # No linking requested
            close_table unless table.omit_last_rule?
          end
        end
      else
        # save current rowtype for next run in current table²
        Table.rowtype_memory = previous_rowtype
      end

      rows
    end

    private def apply_line_spacing(count)
      count.times do
        self.rows << " " # min one space char, otherwise row if rejected !
      end
    end

    private def first_row?
      row_index == 0
    end

    private def last_row?
      row_index == table.row_count - 1
    end

    private def has_title?
      return false if table.title.value.nil? ||
                      table.header_frequency.nil?
      first_row? || (repeated? && table.title.repeated?)
      # masked_headers involved ???? TODO
    end

    private def has_subtitle?
      return false unless has_title?
      !table.subtitle.value.nil?
    end

    private def has_group?
      return false if table.group_registry.size.zero? ||
                      table.header_frequency.nil? ||
                      table.masked_headers?
      first_row? || repeated?
    end

    private def has_header?
      return false if table.header_frequency.nil? ||
                      table.masked_headers?
      first_row? || repeated?
    end

    private def has_footer?
      hf = table.header_frequency
      return false if hf.nil?
      return false if table.footer.value.nil?
      disp = if row_index > 0 && hf > 0
               (row_index + 1) % hf == 0
             else
               row_index + 1 == hf
             end
      disp || last_row?
    end

    private def repeated?
      if (hf = table.header_frequency).nil?
        false
      else
        if hf == 0
          false
        else
          (row_index % hf == 0) && (row_index > 0)
        end
      end
    end

    private def missing_rows
      hf = table.header_frequency
      return 0 if hf.nil?
      return 0 unless last_row?
      return 0 if hf.zero?
      mod = (row_index + 1) % hf
      return 0 if mod.zero?
      hf - mod
    end

    private def page
      hf = table.header_frequency
      return nil if hf.nil?
      hf == 0 ? 1 : row_index // hf + 1
    end
  end
end
