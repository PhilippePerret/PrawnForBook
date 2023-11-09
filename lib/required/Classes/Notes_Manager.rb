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

    # Pour tout vider (utilisé par les tests — et le second tour)
    def drain
      @items = {}
      @current_items = []
      @flux_opened = false
      @last_indice_note = 0
      @last_indice_mark = 0
      @last_unnumbering_note_def_index = 0
      @last_unnumbering_note_mark_index = 0
      @unnumbering_notes = {}
    end

    def next_unnumbering_note_mark_index
      @last_unnumbering_note_mark_index += 1
    end

    def next_unnumbering_note_def_index
      @last_unnumbering_note_def_index += 1
    end


    # -- Action Methods --

    # Pour ajouter une note (un indice)
    # 
    def add(index_mark_note)
      index_mark_note = 
        if index_mark_note == :auto
          next_unnumbering_note_mark_index
        else
          index_mark_note.to_i
        end
      @current_items << index_mark_note
      @items.merge!(index_mark_note => Note.new(self, index_mark_note))
      return index_mark_note
    end

    # Pour traiter la note d'indice +indice+
    # 
    def treate(indice_note, note, context)
      indice_note = 
        if indice_note == :auto
          next_unnumbering_note_def_index
        else
          indice_note = indice_note.to_i
        end
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
          pdf.move_to_next_line
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
