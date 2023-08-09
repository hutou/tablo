require "./types"
require "./heading"

module Tablo
  class RowGroup(T)
    @rows = [] of String
    property previous_rowtype : RowType? = Table.previous_rowtype
    property current_rowtype : RowType? = nil
    private getter table, source, row_index, row_divider
    property rows

    def initialize(@table : Table(T),
                   @source : T,
                   @row_divider : Bool?,
                   @row_index : Int32)
    end

    def add_row(rows)
      {% if flag?(:DEBUG_ROWS) %}
        rows.each_line.with_index do |r, i|
          if i == 0
            self.rows << "[in %-8s from %-8s%24s] => %s" % [
              current_rowtype.to_s, previous_rowtype.to_s, "", r,
            ]
          else
            self.rows << "%-15s%-16s%24s%s" % ["", "...", "", r]
          end
        end
      {% else %}
        self.rows << rows
      {% end %}
    end

    def add_rule(position, linenum = 0, groups = nil)
      row = table.horizontal_rule(position, groups)
      unless row.empty?
        {% if flag?(:DEBUG_ROWS) %}
          self.rows << "[in %-8s from %-8s  pos:%-12.12s (%3d)] => %s" % [
            current_rowtype.to_s, previous_rowtype.to_s, position.to_s, linenum, row,
          ]
        {% else %}
          self.rows << row
        {% end %}
      end
    end

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

    private def spacing_after(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.as(HeadingFramed).spacing_after : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.as(HeadingFramed).spacing_after : 0
      when RowType::Footer
        table.footer.framed? ? table.footer.as(HeadingFramed).spacing_after : 0
      else
        0
      end
    end

    private def spacing_before(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.as(HeadingFramed).spacing_before : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.as(HeadingFramed).spacing_before : 0
      when RowType::Footer
        table.footer.framed? ? table.footer.as(HeadingFramed).spacing_before : 0
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
            __LINE__, groups: nil)
        end
      end
    end

    private def apply_rules
      # Deal with table transition from Detail to Summary
      if row_index == 0 && !Table.omitted_rowtype.nil?
        self.previous_rowtype = Table.omitted_rowtype # if previous_rowtype.nil?
        previous_rowtype_framed = Table.omitted_rowtype_framed?
        previous_rowtype_spacing_after = Table.omitted_rowtype_spacing_after
        Table.omitted_rowtype = nil
        summary_first = true
      else
        previous_rowtype_framed = framed?(previous_rowtype)
        previous_rowtype_spacing_after = spacing_after(previous_rowtype)
        summary_first = false
      end

      groups = previous_rowtype == RowType::Group ||
               current_rowtype == RowType::Group ? table.groups : nil
      spacing = [previous_rowtype_spacing_after, spacing_before(current_rowtype)].max
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
                __LINE__, groups: groups)
            when {RowType::Body, RowType::Body}
              add_rule(Position::SummaryBody,
                __LINE__, groups: groups)
            else
              add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}],
                __LINE__, groups: groups)
            end
          else
            case {previous_rowtype, current_rowtype}
            when {RowType::Body, RowType::Body}
              add_rule(Position::BodyBody,
                __LINE__, groups: groups) if row_divider
            else
              add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}],
                __LINE__, groups: groups)
            end
          end
        else
          fill_page
          add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}],
            __LINE__, groups: groups)
          # add page break after framed footer
          if previous_rowtype == RowType::Footer && table.footer_page_break?
            self.rows[-1] += "\f"
          end
          apply_line_spacing(spacing - 1)
          add_rule(ROWTYPE_POSITION[{current_rowtype, :top}],
            __LINE__, groups: groups)
        end
      when {true, false}
        fill_page
        add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}],
          __LINE__, groups: groups)
        apply_line_spacing(spacing_after(previous_rowtype) - 1)
      when {false, true}
        apply_line_spacing(spacing_before(current_rowtype) - 1)
        add_rule(ROWTYPE_POSITION[{current_rowtype, :top}],
          __LINE__, groups: groups)
      when {false, false}
      end
      case current_rowtype
      when RowType::Title
        add_row(table.rendered_title_row)
      when RowType::SubTitle
        add_row(table.rendered_subtitle_row)
      when RowType::Group
        add_row(table.rendered_group_row)
      when RowType::Header
        add_row(table.rendered_header_row(source, row_index))
      when RowType::Body
        add_row(table.rendered_body_row(source, row_index))
      when RowType::Footer
        add_row(table.rendered_footer_row(page))
        self.rows[-1] += "\f" if table.footer_page_break? && !table.footer.framed?
      end
      self.previous_rowtype = current_rowtype
    end

    def run
      # if we are on first row of the table
      if row_index.zero?
        # restore previous_rowtype from previous table (Detail)
        self.previous_rowtype = Table.omitted_rowtype unless Table.omitted_rowtype.nil?
      end

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
        self.current_rowtype = RowType::Footer
        apply_rules
      end

      if last_row?
        # we must terminate with last horizontal_rule, if appropriate
        if previous_rowtype == RowType::Body
          add_rule(Position::BodyBottom, __LINE__) unless table.omit_last_rule?
        elsif previous_rowtype == RowType::Footer
          if table.footer.framed?
            unless table.omit_last_rule?
              add_rule(Position::TitleBottom, __LINE__)
              if table.footer_page_break?
                self.rows[-1] += "\f"
              end
            end
          end
        end
        # saved omitted_rowtype allows for linking between detail and summary table
        if table.omit_last_rule?
          Table.omitted_rowtype = previous_rowtype
          Table.omitted_rowtype_framed = true
          Table.omitted_rowtype_spacing_after = 0
          if previous_rowtype == RowType::Footer
            Table.omitted_rowtype_framed = table.footer.framed?
            # Table.omitted_rowtype_spacing_after = table.footer.spacing_after
            Table.omitted_rowtype_spacing_after = table.footer.framed? ? table.footer.as(HeadingFramed).spacing_after : 0
          end
        end
        # Table is now printed, reset attribute previous_rowtype to nil to allow
        # 'fresh' printing of next table
        Table.previous_rowtype = nil
      else
        # save current rowtype for next run in current table²
        Table.previous_rowtype = previous_rowtype
      end
      rows
    end

    private def apply_line_spacing(count)
      count.times do
        self.rows << " " # min one space char, otherwise row if rejected !
      end
    end

    private def last_row?
      row_index == table.row_count - 1
    end

    def old_spacing(prev, curr)
      if prev.spacing_after.nil? || curr.spacing_before.nil?
        nil
      else
        [prev.spacing_after.as(Int32), curr.spacing_before.as(Int32)].max
      end
    end

    private def is_first?
      row_index == 0
    end

    private def has_title?
      return false if table.title.value.nil? ||
                      table.header_frequency.nil?
      is_first? || (is_repeated? && table.title_repeated?)
    end

    private def has_subtitle?
      return false unless has_title?
      !table.subtitle.value.nil?
    end

    private def has_group?
      return false if table.group_registry.size.zero? ||
                      table.header_frequency.nil? ||
                      table.masked_headers?
      is_first? || is_repeated?
    end

    private def has_header?
      return false if table.header_frequency.nil? ||
                      table.masked_headers?
      is_first? || is_repeated?
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

    private def zzz_has_footer?
      return false if table.header_frequency.nil? || table.footer.value.nil?
      hf = table.header_frequency.as(Int32).abs
      disp = if row_index > 0 && hf > 0
               (row_index + 1) % hf == 0
             else
               row_index == (hf - 1)
             end
      disp || last_row?
    end

    private def is_repeated?
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
