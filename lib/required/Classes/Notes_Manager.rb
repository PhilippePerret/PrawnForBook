#
# Class Prawn4book::PdfBook::NotesManager
# ---------------------------------------
# Pour gérer les notes au cours de la fabrication du livre
# 
# 
module Prawn4book
class PdfBook
  class NotesManager

    LINE_COLOR = 'CCCCCC'

    attr_reader :pdfbook
    alias :book :pdfbook

    def initialize(pdfbook)
      @pdfbook = pdfbook
      drain
    end

    # Pour tout vider (utilisé par les tests)
    def drain
      @items = {}
      @current_items = []
      @flux_opened = false
    end

    # -- Action Methods --

    # Pour ajouter une note (un indice)
    # 
    def add(index_note)
      @current_items << index_note
      @items.merge!(index_note => Note.new(self, index_note))
    end

    # Pour traiter la note d'indice +indice+
    # 
    def treate(indice_note, note, context)
      pdf = context[:pdf]
      #
      # Si la note est la première des notes non encore marquées,
      # alors il faut amorcer le bloc avec une ligne.
      # 
      if not(@flux_opened)
        pdf.update do
          # - Hauteur ajustée -
          v = cursor - ascender
          stroke do
            stroke_color(LINE_COLOR)
            line [0, v], [pdf.bounds.width, v]
          end
        end
      end
      @flux_opened = true

      # 
      # On retire cette note des notes courante
      # 
      @current_items.shift

      # 
      # -- Écriture de la note --
      #
      str   = "<sup>#{indice_note}</sup> #{note}"
      pdf.move_to_next_line
      Printer.pretty_render(
        owner:    self, 
        pdf:      pdf, 
        text:     str, 
        fonte:    book.recipe.fonte_note_page, 
        options:  options_note_page)

      return nil
    end

    def options_note_page
      @options_note_page ||= {
        inline_format: true, 
        align: :justify
      }
    end

    # Méthode appelée après la dernière note écrite
    # 
    def end_bloc(pdf)
      pdf.update do
        # On n'ajoute une ligne que si l'on ne se retrouve pas en
        # bas de page.
        if cursor < pdf.bounds.height - 20
          # - Hauteur réelle -
          v = cursor - ascender
          stroke do
            stroke_color(LINE_COLOR)
            line [0, v], [pdf.bounds.width, v]
          end
          move_to_next_line
        end
      end
      @flux_opened = false
    end

    # 
    # === Class Prawn4book::PdfBook::NotesManager::Note
    # 

    class Note
      def initialize(manager, indice)
        @manager = manager
        @indice  = indice
      end
    end

  end #/class NotesManager
end #/class PdfBook
end #/module Prawn4book
