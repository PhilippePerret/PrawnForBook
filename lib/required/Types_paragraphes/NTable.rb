require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTable < AnyParagraph

  attr_accessor :page_numero

  attr_reader :data

  def initialize(pdfbook, data)
    super(pdfbook)
    @data = data.merge!(type: 'table')
  end

  # --- Printing Methods ---

  def print(pdf)
    pdf.move_down(pdf.line_height)
    pdf.move_cursor_to_next_reference_line

    # table = pdf.make_table(lines)
    # table.draw(**table_style)

    pdf.table(lines, **table_style)

    pdf.move_down(2 * pdf.line_height)
  end

  # --- Predicate Methods ---

  def paragraph?; false end
  def sometext? ; true  end
  def titre?    ; false  end

  # --- Volatile Data Methods ---

  ##
  # Les lignes préparées pour Prawn::Table
  def lines
    @lines ||= begin
      # 
      # Si la deuxième ligne ne contient que '-', ':' et '|', c'est
      # une ligne qui définit l'alignement dans les colonnes
      # 
      puts "\nDeuxième ligne : #{raw_lines[1].inspect}"
      if raw_lines[1].match?(/^[ \-\:\|]+$/)
        puts "Deuxième ligne d'alignement"
        entete = raw_lines.shift()
        aligns = raw_lines.shift()
      end
      raw_lines.map do |rawline|
        dline = rawline.strip[1...-1].split('|').map do |cell|
          # 
          # Évaluation, si la cellule contient une table
          # 
          cstrip = cell.strip
          if cstrip.start_with?('{') && cstrip.end_with?('}')
            eval(cstrip)
          elsif cstrip.match?(REG_IMAGE_IN_CELL)
            found = cstrip.match(REG_IMAGE_IN_CELL)
            image_path  = found[1]
            image_style = found[2]
            image_style = "{#{image_style}}" unless image_style.start_with?('{')
            image_style = eval(image_style)
          else
            cell
          end
        end
      end
    end
  end

  def table_style
    @table_style ||= begin
      if pfbcode
        pfbcode.parag_style
      else
        nil
      end
    end
  end

  def text
    @text ||= begin
      raw_lines.join("\n")
    end
  end

  # --- Data Methods ---

  def raw_lines  ; @raw_lines   ||= data[:lines]   end


REG_IMAGE_IN_CELL = /^IMAGE\[(.+?)(?:\|(.+?))\]$/

end #/class NTable
end #/class PdfBook
end #/module Prawn4book
