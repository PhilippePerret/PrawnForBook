#
# Class Prawn4book::PdfBook::NotesManager
# ---------------------------------------
# Pour gérer les notes au cours de la fabrication du livre
# 
# 
module Prawn4book
class PdfBook
  class NotesManager

    attr_reader :book

    def initialize(book)
      @book = book
      drain
    end

    # Pour tout vider (utilisé par les tests — et le second tour)
    def drain
      @items = {}
      @current_items = []
      @flux_opened = false
      @last_indice_note = 0
      @last_indice_mark = 0
      @last_unnumbering_note_def_index  = 0
      @last_unnumbering_note_mark_index = 0
      @unnumbering_notes = {}
      # Propriété qui permet de savoir quand on recommence de poser
      # des marques (des appels de notes). Si c’est un nouveau premier
      # appel (donc après avoir écrit les définitions des notes 
      # précédentes) alors il faut impérativement que toutes les notes
      # précédentes aient été définie. Sinon, on génère une erreur
      # fatale.
      @last_operation = nil
    end

    # Pour obtenir le prochain numéro pour un APPEL DE NOTE
    def next_unnumbering_note_mark_index
      @last_unnumbering_note_mark_index += 1
    end

    # Pour obtenir le prochain numéro pour une DÉFINITION DE NOTE
    def next_unnumbering_note_def_index
      @last_unnumbering_note_def_index += 1
    end

    # Quand on rencontre une première note de page (définition) de
    # bloc (donc il peut y avoir eu d’autres notes de page dans 
    # d’autres blocs avant).
    def init_bloc_notes(pdf)
      @flux_opened = false
      write_line(pdf) if borders?
      @last_operation = 'ecriture_definitions'
    end


    # -- Action Methods --

    # Pour ajouter une note (un indice)
    # 
    def add(index_mark_note)
      index_mark_note = 
        if index_mark_note == :auto
          # Une vérification s’impose pour voir si toutes les notes
          # déclarée par des appels ont été inscrites en tant que
          # notes.
          check_definitions_notes_or_raise
          @last_operation = 'pose_appel_notes'
          # On prend le numéro de marque suivant
          next_unnumbering_note_mark_index # valeur retournée
        else
          index_mark_note.to_i
        end
      @current_items << index_mark_note
      @items.merge!(index_mark_note => Note.new(self, index_mark_note))
      return index_mark_note
    end

    def check_definitions_notes_or_raise
      return if @last_operation == 'pose_appel_notes' # cf. l’initialisatin pour savoir ce que c’est
      return if @last_unnumbering_note_mark_index == @last_unnumbering_note_def_index
      raise PFBFatalError.new(105, {last_mark:@last_unnumbering_note_mark_index, last_def:@last_unnumbering_note_def_index})
    end

    # Pour traiter la note d'indice +indice+
    # 
    # @note
    # 
    #   Ici sont traitées aussi bien les définitions de notes auto-
    #   incrémentées que de notes numérotées explicitement.
    # 
    def treate(indice_note, note, context)
      my = self
      #
      # Index de la note
      # 
      indice_note ||= next_unnumbering_note_def_index

      pdf = context[:pdf]

      # 
      # On retire cette note des notes courante
      # 
      @current_items.shift

      # 
      # -- Écriture de la note --
      #
      @flux_opened = true
      Printer.pretty_render(
        owner:    self, 
        pdf:      pdf, 
        text:     "<sup>#{indice_note}</sup> #{note}",
        fonte:    fonte,
        options:  options_note_page
      )

      return nil
    end


    def options_note_page
      {
        inline_format: true, 
        align: :justify,
        left:   left,
        color:  color,
      }
    end

    # Méthode appelée après la dernière note écrite
    # 
    def end_bloc(pdf)
      # On n'ajoute une ligne que si l'on ne se retrouve pas en
      # bas de page et si la recette le demande
      if borders? && pdf.cursor < pdf.bounds.height - 20
         write_line(pdf)
      end
      @flux_opened = false
    end

    def write_line(pdf)
      my = self
      pdf.update do
        # - Hauteur réelle -
        v = cursor - ascender + 4
        # Conservation des valeurs actuelles
        color_init = stroke_color.freeze
        width_init = line_width.freeze
        # - Application des nouvelles valeurs -
        line_width(my.border_width)
        stroke_color(my.border_color)
        # - Dessiner la ligne -
        stroke do
          line [my.left, v], [pdf.bounds.width, v]
        end
        stroke_color(color_init)
        line_width(width_init)
        move_to_next_line
      end
    end

    def borders_raw_value
      book.recipe.notes_page_borders
    end

    def borders?
      case borders_raw_value
      when 0, FalseClass then false
      else true
      end
    end

    def border_width
      case borders_raw_value
      when Integer, Float then borders_raw_value
      when FalseClass then nil
      when TrueClass then 0.3
      else borders_raw_value
      end
    end

    def color
      fonte.color
    end

    def border_color
      book.recipe.notes_page[:border_color]
    end

    def left
      book.recipe.notes_page[:left]
    end

    def fonte
      book.recipe.note_page_fonte
    end

    # Pour le "test de limite basse" (test qui vérifie dans 
    # pretty_render si le curseur n’est pas trop bas)
    # 
    def title?; false end

    # Pour ne pas traiter la numérotation par exemple
    def paragraph?; false end

    # Pour compatibilité avec NTextParagraph
    def indentation
      nil
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
