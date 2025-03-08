# require "./types"
# require "./heading"

module Tablo
  # The main purpose of the RowGroup class is to manage the alternation of different
  # types of rows and the types of rules that separate them.
  #
  # Each time the data source is read and ready to print, an instance of the
  # RowGroup class is created to display the body and all other possible previous
  # row types and rule types.
  #
  # To do this, the previous and current row types are used to determine the rule type
  # and border position to be used.
  #
  # The RowGroup class also manages the transition between the main table and its
  # child, the summary table, where applicable.
  #
  # The RowGroup class is of crucial importance for managing table layout, but it is
  # only used internally and therefore has no public interface.
  #
  #
  class RowGroup(T)
    # From one instance to the next, the RowGroup class has no memory: the
    # RowGroup.rowtype_memory class variable is therefore used to ensure the link:
    # when a new instance of RowGroup is created, the previous_rowtype instance
    # variable is initialized by RowGroup.rowtype_memory, and on exit from
    # RowGroup's run method, the current_rowtype instance variable is assigned to
    # RowGroup.rowtype_memory.
    protected class_property rowtype_memory : RowType? = nil

    # Linking conditions between table :main and table :summary is governed by
    # the class variable RowGroup.transition_footer, where we store the footer of
    # :main or nil, depending of the last rowtype of :main. This info is then
    # use on first row of :summary to properly link or not the two tables.
    protected class_property transition_footer : Heading? = nil

    # Whenever we enter rowgroup, we retrieve the previous rowtype from
    # the recorded value in class variable RowGroup.rowtype_memory
    private property previous_rowtype : RowType? = RowGroup.rowtype_memory
    private property current_rowtype : RowType? = nil

    private getter rows = [] of String
    private getter table, source, row_index, row_divider

    # :nodoc:
    def initialize(@table : Table(T),
                   @source : T,
                   @row_divider : Bool?,
                   @row_index : Int32)
    end

    # If compilation is done with the flag DEBUG_ROWs, debugging infos are
    # displayed before each output line
    private def add_row(rows, linenum = 0)
      {% if flag?(:DEBUG_ROWS) %}
        rows.each_line.with_index do |r, i|
          if i == 0
            self.rows << "[in %-8s from %-8s%18s (%3d)] => %s" % [
              current_rowtype.to_s, previous_rowtype.to_s, "", linenum, r,
            ]
          else
            self.rows << "%-15s%-16s%24s%s" % ["", "...", "", r]
          end
        end
      {% else %}
        self.rows << rows
      {% end %}
    end

    # private def add_rule(position, groups = nil, linenum = 0)
    private def add_rule(position, groups = [] of Array(Int32), linenum = 0)
      {% if flag?(:DEBUG_ROWS) %}
        row = table.horizontal_rule(position, groups)
        unless row.empty?
          self.rows << "[in %-8s from %-8s  pos:%-12.12s (%3d)] => %s" % [
            current_rowtype.to_s, previous_rowtype.to_s, position.to_s, linenum, row,
          ]
        end
      {% else %}
        row = table.horizontal_rule(position, groups)
        unless row.empty?
          self.rows << row
        end
      {% end %}
    end

    private def apply_rules
      # Determine columns to be used for grouped rules if either previous or current row is a group.
      groups = (previous_rowtype == RowType::Group || current_rowtype == RowType::Group) ? table.column_groups : [] of Array(Int32)
      # Compute maximum spacing required between the previous and current rows.
      spacing = [line_breaks_after(previous_rowtype), line_breaks_before(current_rowtype)].max

      if framed?(previous_rowtype) && framed?(current_rowtype)
        handle_both_framed(groups, spacing)
      elsif framed?(previous_rowtype) && !framed?(current_rowtype)
        handle_prev_framed_only(groups)
      elsif !framed?(previous_rowtype) && framed?(current_rowtype)
        handle_curr_framed_only(groups)
      end

      add_rowtype
      self.previous_rowtype = current_rowtype
    end

    private def handle_both_framed(groups : Array(Array(Int32)), spacing : Int32)
      if spacing.zero?
        fill_page
        summary_first? ? handle_summary_first(groups) : handle_regular_framed(groups)
      else
        fill_page
        add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}], groups: groups, linenum: {{__LINE__}})
        manage_page_break if previous_rowtype == RowType::Footer
        apply_line_spacing(spacing - 1)
        add_rule(ROWTYPE_POSITION[{current_rowtype, :top}], groups: groups, linenum: {{__LINE__}})
      end
    end

    private def handle_summary_first(groups : Array(Array(Int32)))
      # Handle the specific rules for chaining a summary table when there is no spacing.
      case {previous_rowtype, current_rowtype}
      when {RowType::Body, RowType::Header}
        add_rule(RuleType::SummaryHeader, groups: groups, linenum: {{__LINE__}})
      when {RowType::Footer, RowType::Body}
        add_rule(RuleType::TitleBody, groups: groups, linenum: {{__LINE__}})
      when {RowType::Body, RowType::Body}
        add_rule(RuleType::SummaryBody, groups: groups, linenum: {{__LINE__}})
      else
        add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}], groups: groups, linenum: {{__LINE__}})
      end
    end

    private def handle_regular_framed(groups : Array(Array(Int32)))
      # Handle consecutive framed rows within the same table.
      case {previous_rowtype, current_rowtype}
      when {RowType::Body, RowType::Body}
        add_rule(RuleType::BodyBody, groups: groups, linenum: {{__LINE__}}) if row_divider
      when {RowType::Group, RowType::Header}
        add_rule(RuleType::GroupHeader, groups: groups, linenum: {{__LINE__}}) unless table.omit_group_header_rule?
      else
        add_rule(ROWTYPE_POSITION[{previous_rowtype, current_rowtype}], groups: groups, linenum: {{__LINE__}})
      end
    end

    private def handle_prev_framed_only(groups : Array(Array(Int32)))
      # Handle the case where the previous row is framed and the current row is not.
      fill_page
      add_rule(ROWTYPE_POSITION[{previous_rowtype, :bottom}], groups: groups, linenum: {{__LINE__}})
      apply_line_spacing(line_breaks_after(previous_rowtype) - 1)
    end

    private def handle_curr_framed_only(groups : Array(Array(Int32)))
      # Handle the case where the current row is framed and the previous is not.
      apply_line_spacing(line_breaks_before(current_rowtype) - 1)
      add_rule(ROWTYPE_POSITION[{current_rowtype, :top}], groups: groups, linenum: {{__LINE__}})
    end

    private def process_last_row
      if table.name == :main
        process_main_table_last_row
      elsif table.name == :summary
        close_table unless table.omit_last_rule?
        RowGroup.rowtype_memory = nil
        RowGroup.transition_footer = nil
      end
    end

    private def process_main_table_last_row
      # Process the end of the main table.
      if !table.child.nil?
        # When a summary table exists, decide whether to link based on omit_last_rule? and current row type.
        if !(table.omit_last_rule? && (current_rowtype == RowType::Body ||
           (current_rowtype == RowType::Footer && table.footer.framed? && !table.footer.page_break?)))
          close_table unless table.omit_last_rule?
          RowGroup.rowtype_memory = nil
          manage_page_break if table.omit_last_rule?
        end
        # Prepare transition: if the last row is a framed Footer, store it for the summary table.
        RowGroup.transition_footer = (current_rowtype == RowType::Footer) ? table.footer : nil
      else
        # No summary table attached.
        close_table unless table.omit_last_rule?
        RowGroup.rowtype_memory = nil
        manage_page_break if table.omit_last_rule?
      end
    end

    # private def process_title
    #   print_title if has_title?
    # end

    # private def process_subtitle
    #   print_subtitle if has_subtitle?
    # end

    # private def process_group_header
    #   print_group if has_group?
    # end

    # private def process_rows
    #   rows.each do |row|
    #     process_row(row)
    #   end
    # end

    private def fill_page
      # Add "filler" rows to reach page size (header_frequency)
      if previous_rowtype == RowType::Body && current_rowtype == RowType::Footer
        missing_rows.times do
          add_rule(ROWTYPE_POSITION[{RowType::Body, :filler}],
            groups: [] of Array(Int32), linenum: {{__LINE__}})
        end
      end
    end

    private def add_rowtype
      case current_rowtype
      when RowType::Title
        add_row(table.rendered_title_row, linenum: {{__LINE__}})
      when RowType::SubTitle
        add_row(table.rendered_subtitle_row, linenum: {{__LINE__}})
      when RowType::Group
        add_row(table.rendered_group_row, linenum: {{__LINE__}})
      when RowType::Header
        add_row(table.rendered_header_row(source, row_index), linenum: {{__LINE__}})
      when RowType::Body
        add_row(table.rendered_body_row(source, row_index), linenum: {{__LINE__}})
      when RowType::Footer
        add_row(table.rendered_footer_row(page), linenum: {{__LINE__}})
        manage_page_break unless table.footer.framed?
      end
    end

    private def close_table
      # Only Body and Footer row types are possible
      case previous_rowtype
      when RowType::Body
        add_rule(RuleType::BodyBottom, linenum: {{__LINE__}})
      when RowType::Footer
        add_rule(RuleType::TitleBottom, linenum: {{__LINE__}}) if table.footer.framed?
        manage_page_break
      end
    end

    private def framed?(rowtype)
      case rowtype
      when Nil
        false
      when RowType::Title
        table.title.framed?
      when RowType::SubTitle
        table.subtitle.framed?
      when RowType::Footer
        if summary_first?
          RowGroup.transition_footer.as(Heading).framed?
        else
          table.footer.framed?
        end
      else
        true
      end
    end

    private def line_breaks_after(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.line_breaks_after : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.line_breaks_after : 0
      when RowType::Footer
        # table.footer.framed? ? table.footer.line_breaks_after : 0
        if table.footer.framed?
          if table.footer.page_break? && table.footer.line_breaks_after == 0
            1 # we cannot accept a "join" here, so we force a line break !
          else
            table.footer.line_breaks_after
          end
        else
          0
        end
      else
        0
      end
    end

    private def line_breaks_before(rowtype)
      case rowtype
      when RowType::Title
        table.title.framed? ? table.title.line_breaks_before : 0
      when RowType::SubTitle
        table.subtitle.framed? ? table.subtitle.line_breaks_before : 0
      when RowType::Footer
        table.footer.framed? ? table.footer.line_breaks_before : 0
      else
        0
      end
    end

    private ROWTYPE_POSITION = {
      # previous, current
      {RowType::Body, RowType::Body}       => RuleType::BodyBody,
      {RowType::Body, :bottom}             => RuleType::BodyBottom,
      {RowType::Body, :filler}             => RuleType::BodyFiller,
      {RowType::Body, RowType::Group}      => RuleType::BodyGroup,
      {RowType::Body, RowType::Header}     => RuleType::BodyHeader,
      {RowType::Body, RowType::Footer}     => RuleType::BodyTitle,
      {RowType::Body, RowType::Title}      => RuleType::BodyTitle,
      {RowType::Body, :top}                => RuleType::BodyTop,
      {RowType::Group, RowType::Header}    => RuleType::GroupHeader,
      {RowType::Group, :top}               => RuleType::GroupTop,
      {RowType::Header, RowType::Body}     => RuleType::HeaderBody,
      {RowType::Header, :top}              => RuleType::HeaderTop,
      {:summary, RowType::Body}            => RuleType::SummaryBody,
      {:summary, RowType::Header}          => RuleType::SummaryHeader,
      {RowType::Footer, RowType::Body}     => RuleType::TitleBody,
      {RowType::Title, RowType::Body}      => RuleType::TitleBody,
      {RowType::Footer, :bottom}           => RuleType::TitleBottom,
      {RowType::SubTitle, :bottom}         => RuleType::TitleBottom,
      {RowType::Title, :bottom}            => RuleType::TitleBottom,
      {RowType::Footer, RowType::Group}    => RuleType::TitleGroup,
      {RowType::SubTitle, RowType::Group}  => RuleType::TitleGroup,
      {RowType::Title, RowType::Group}     => RuleType::TitleGroup,
      {RowType::Footer, RowType::Header}   => RuleType::TitleHeader,
      {RowType::SubTitle, RowType::Header} => RuleType::TitleHeader,
      {RowType::Title, RowType::Header}    => RuleType::TitleHeader,
      {RowType::Footer, RowType::Title}    => RuleType::TitleTitle,
      {RowType::Title, RowType::SubTitle}  => RuleType::TitleTitle,
      {RowType::Title, RowType::Title}     => RuleType::TitleTitle,
      {RowType::Footer, :top}              => RuleType::TitleTop,
      {RowType::SubTitle, :top}            => RuleType::TitleTop,
      {RowType::Title, :top}               => RuleType::TitleTop,
    }

    private def process_table_transition
      if summary_first?
        if RowGroup.rowtype_memory.nil?
          # :main has been closed, so no previous rowtype !
          self.previous_rowtype = nil
        else
          # Linking allowed
          self.previous_rowtype = RowGroup.transition_footer.nil? ? RowType::Body : RowType::Footer
        end
      elsif main_first?
        # We forget previous rowtype, if any
        # (fix problem with `table.each {|row| ...` when last row not reached)
        self.previous_rowtype = nil
      end
    end

    private def process_title
      if has_title?
        self.current_rowtype = RowType::Title
        apply_rules
      end
    end

    private def process_subtitle
      if has_subtitle?
        self.current_rowtype = RowType::SubTitle
        apply_rules
      end
    end

    private def process_group
      if has_group?
        self.current_rowtype = RowType::Group
        apply_rules
      end
    end

    private def process_header
      if has_header?
        self.current_rowtype = RowType::Header
        apply_rules
      end
    end

    private def process_footer
      if has_footer?
        self.current_rowtype = RowType::Footer
        apply_rules
      end
    end

    protected def run
      process_table_transition
      process_title
      process_subtitle
      process_group
      process_header

      # For Body, always !
      self.current_rowtype = RowType::Body
      apply_rules
      process_footer

      # After each fired rule, previous_rowtype and current_rowtype are equal
      if last_row?
        process_last_row
      else
        # save current rowtype for next run in current table²
        RowGroup.rowtype_memory = previous_rowtype
      end
      rows
    end

    private def apply_line_spacing(count)
      count.times do
        # self.rows << " " # min one space char, otherwise row if rejected !
        self.rows << "" # empty string seems Ok now !
      end
    end

    private def first_row?
      row_index == 0
    end

    private def last_row?
      row_index == table.row_count - 1
    end

    private def summary_first?
      first_row? && table.name == :summary
    end

    private def main_first?
      first_row? && table.name == :main
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

    private def manage_page_break
      # No need to !
      return unless table.footer.page_break?
      # We already have one !
      return if rows[-1][-1] == '\f'
      # Ok, add a form feed !
      self.rows[-1] += "\f"
    end
  end
end
