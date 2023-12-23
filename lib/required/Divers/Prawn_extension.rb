#
# Module contenant les extensions produites pour :
# Prawn
# Prawn::Table
# 
# 
#
#  Prawn "warppers"
#  ----------------
#
# Ces "warppers" permettent de connaitre précisément le contenu qui
# est ajoué aux pages.
# 
# De façon simple :
# 
#   Lorsque l'on appelle la méthode Prawn::Document#text pour ajouter
#   du texte, on appelle en vérité le wrapper de même nom défini ici
#   (avec les mêmes paramètres) qui enregistre la longueur de texte
#   dans la page courante puis appelle la méthode originale pour 
#   vraiment écrire dans le document PDF.
# 
# Ces wrappers existent pour les méthodes :
# 
#   Prawn::Document           #text
#   Prawn::Document           #draw_text
#   Prawn::Document           #image    (une image ajoute du contenu)
#   Prawn::Document           #formatted_text
#   Prawn::Document           #text_box
#   Prawn::Document           #formatted_text_box
#   Prawn::Table::Cell::Text  #draw_content
# 
# @notes
# 
#   - les titres (NTitre) ajoutent une propriété :is_title à true 
#     pour indiquer que ce sont des titres (ils ne sont pas comptabi-
#     lisés dans le contenu de la page)
# 

require 'prawn/table'

module Prawn
module Text

  # Narrow no-break-space
  # (ne semble pas exploitable)
  NNBSP = "\u202F"
  
  module Formatted
    class Box
      def at=(coor)
        @at = coor
      end
    end #/class Box
  end #/module Formatted

  def at=(coor)
    @at = coor
  end

  # Surclassement de la méthode originale pour traiter l'option
  # :dry_run
  def text_box(string, options = {})
    options = options.dup
    options[:document] = self

    # --AJOUT--
    dry_run = options.delete(:dry_run)
    # --/AJOUT--

    box =
      if options[:inline_format]
        p = options.delete(:inline_format)
        p = [] unless p.is_a?(Array)
        array = text_formatter.format(string, *p)
        Text::Formatted::Box.new(array, options)
      else
        Text::Box.new(string, options)
      end

    # --REMPLACEMENT--
    if dry_run
      exceed = box.render(dry_run: dry_run)
      [exceed, box]
    else
      box.render
    end
    # --/REMPLACEMENT--
    # --REMPLACÉ--
    # box.render
    # --/REMPLACÉ--
  end

end #/module Text
end #/module Prawn


module Prawn
  class Table

    alias :original_start_new_page? :start_new_page?
    
    def start_new_page?(cell, offset, ref_bounds)
      # Ici, on pourrait ajouter les contraintes sur les rangées
      # Mais comment le faire ?
      if cell.respond_to?(:keep_with_next?) # donc pas une dummy
        if cell.keep_with_next?
          # puts "cell.keep_with_next = #{cell.keep_with_next.inspect}"
          # puts "cell.row = #{cell.row}"
          # puts "next row height = #{cells.rows(cell.row + 1).height}"
          # 
          # On répète pour autant de rangées qu'on cherche
          # 
          # extra_h = 0
          # extra_h = 0
          (cell.keep_with_next + 1).times do |i|
            offset -= cells.rows(cell.row + i).height
          end
          # puts "Il faudrait pouvoir avoir #{extra_h} (offset = #{offset})"
          # puts "ref_bounds.absolute_bottom = #{ref_bounds.absolute_bottom.inspect}"
          # puts "pdf.cursor = #{@pdf.cursor}"
          # exit 1
          # offset -= extra_h #+ 5 # Je ne sais pas pourquoi le "+5"
        end
      end
      # exit 1
      original_start_new_page?(cell, offset, ref_bounds)
    end
  
    class Cell
      class Text

        alias_method :__real_draw_content, :draw_content
        def draw_content #(lines, **params, &block)
          # puts "On ajoute #{content.length} caractères dans la table : #{content.inspect}".bleu
          @pdf.add_content_length_to_current_page(content.length)
          __real_draw_content
          # super
        end

        def keep_with_next=(value)
          value = nil if value === false
          @_keep_with_next = value
        end
        
        def keep_with_next?
          not(@_keep_with_next.nil?)
        end

        def keep_with_next
          if @_keep_with_next === true
            1
          else 
            @_keep_with_next
          end
        end

      end #/class Text
    end #/class Cell
  end #/class Table
end #/module Prawn


module Prawn::Measurements
  # Conversion manquante
  def pt2in
    self.to_f / 72
  end
  def pt2cm
    self.pt2mm / 10
  end
  # def pt2in(pt)
  #   pt.to_f / 72
  # end
end

class Prawn::Document
  
  def add_content_length_to_current_page(len)
    @book ||= Prawn4book::PdfBook.ensure_current
    page = @book.pages[page_number] || begin
      @book.add_page(page_number)
    end
    page.add_content_length(len)
    page[:first_par] = 1 # sinon n'imprime pas le numéro
  end

  # #text utilise forcément formatted_text, donc c'est seulement
  # dans la seconde méthode qu'on regarde s'il faut ajouter du
  # contenu. Mais on garde quand même ce wrapper, au cas où, pour
  # l'avenir.
  alias_method :__real_text, :text
  def text(str, **params)
    __real_text(str, **params)
  end

  alias_method :__real_draw_text, :draw_text
  def draw_text(str, **params)
    # puts "-> draw_text".bleu
    add_content_length_to_current_page(str.to_s.length)
    __real_draw_text(str, **params)
  end
  alias_method :__real_formatted_text, :formatted_text
  def formatted_text(str, **params)
    # puts "-> formatted_text".bleu
    is_titre = params.delete(:is_title)
    add_content_length_to_current_page(str.to_s.length) unless is_titre
    __real_formatted_text(str, **params)
  end
  alias_method :__real_formatted_text_box, :formatted_text_box
  def formatted_text_box(str, **params)
    # puts "-> formatted_text_box".bleu
    add_content_length_to_current_page(str.to_s.length)
    __real_formatted_text_box(str, **params)
  end
  alias_method :__real_text_box, :text_box
  def text_box(str, **params)
    # puts "-> text_box".bleu
    add_content_length_to_current_page(str.to_s.length)
    __real_text_box(str, **params)
  end
  alias_method :__real_image, :image
  def image(ipath, **params)
    add_content_length_to_current_page(100)
    __real_image(ipath, **params)
  end
  # TODO IDEM AVEC : text_box, formatted_text,
  # formatted_text_box,
end

