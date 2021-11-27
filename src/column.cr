module Tablo
  class Column
    property width, formatter
    getter header

    def initialize(@header : String,
                   @width : Int32,
                   @align_header : Justify,
                   @align_body : Justify,
                   @formatter : CellType -> String,
                   @styler : CellType -> String,
                   @extractor : Array(CellType) -> CellType)
    end

    # Returns an array of string, representing the (possibly multilines) header
    # formatted and aligned contents
    def header_subcells
      infilled_subcells(@header, @align_header)
    end

    # Returns an array of string, representing the (possibly multilines) body
    # cell formatted and aligned contents
    def body_subcells(source)
      cell_datum = body_cell_value(source)
      formatted_content = @formatter.call(cell_datum)
      type_alignment = infer_alignment(cell_datum) # Compute alignment from cell type
      @align_header = type_alignment if @align_header.none?
      @align_body = type_alignment if @align_body.none?
      infilled_subcells(formatted_content, @align_body, true)
    end

    # Format the cell using the formatter proc
    def formatted_cell_content(source)
      @formatter.call(body_cell_value(source))
    end

    # Get a cell value from source, which is Array(CellType).
    def body_cell_value(source)
      @extractor.call(source)
    end

    # Calculates the number of lines necessary to deal with cell contents and
    # column width, and fills each resulting subcell with aligned data
    private def infilled_subcells(str, alignment, apply_styler = false)
      str.split("\n").flat_map do |substr|
        num_subsubcells = [1, (substr.size.to_f / width).ceil].max
        (0...num_subsubcells).map do |i|
          align_cell_content(substr[i * width, width], alignment, apply_styler)
        end
      end
    end

    # Calculate alignment and padding of a (sub)cell
    private def align_cell_content(content, alignment, apply_styler)
      styled_content =
        if apply_styler
          @styler.call(content)
        else
          content
        end
      padding = [width - content.size, 0].max
      left_padding, right_padding =
        case alignment
        when .left?
          [0, padding]
        when .right?
          [padding, 0]
        else
          half_padding = padding // 2
          [padding - half_padding, half_padding]
        end
      "#{" " * left_padding}#{styled_content}#{" " * right_padding}"
    end

    # Calculate alignment of a (sub)cell
    private def infer_alignment(cell_datum)
      align = case cell_datum
              when Number
                Justify::Right
              when Bool
                Justify::Center
              else
                Justify::Left
              end
    end
  end
end
