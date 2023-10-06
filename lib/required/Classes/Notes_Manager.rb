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
      @flux_opened = true
    end

    # Pour traiter la note d'indice +indice+
    # 
    def treate(indice_note, note, context)
      pdf = context[:pdf]
      #
      # Si la note est la première des notes non encore marquées,
      # alors il faut amorcer le bloc avec une ligne.
      # 
      if @current_items[0] == indice_note
        pdf.update do
          move_down(5)
          stroke do
            stroke_color(LINE_COLOR)
            line [0, cursor], [pdf.bounds.width, cursor]
          end
          move_down(5)
        end
        pdf.move_cursor_to_next_reference_line
      end

      # 
      # On retire cette note des notes courante
      # 
      @current_items.shift

      fs = book.recipe.default_font_size - 2
      "<sup>#{indice_note}</sup> <font size=\"#{fs}\">#{note}</font>"

    end

    # Méthode appelée après chaque écriture de texte pour voir
    # si c'est une fin de notes
    def check_if_end_of_notes(pdf)
      return unless @flux_opened
      #
      # Si la note est la dernière des notes non encore marquées,
      # alors il faut clore le bloc de notes (sauf si on est assez
      # bas)
      # 
      if empty?
        pdf.update do
          move_down(5)
          # puts "cursor : #{cursor.inspect}"
          if cursor < pdf.bounds.height - 20
            stroke do
              stroke_color(LINE_COLOR)
              line [0, cursor], [pdf.bounds.width, cursor]
            end
            move_down(10)
            # move_cursor_to_next_reference_line
          end
        end
        @flux_opened = false
      end
    end

    # -- Predicate Methods --

    # @return true s'il y a des notes courantes (donc non encore
    # traitées)
    def has_current_notes?
      not(@current_items.empty?)
    end

    # @return true s'il n'y a plus de notes courantes
    def empty?
      not(has_current_notes?)
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
