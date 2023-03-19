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
        dline = rawline.strip[1...-1].split('|')
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

end #/class NTable
end #/class PdfBook
end #/module Prawn4book
