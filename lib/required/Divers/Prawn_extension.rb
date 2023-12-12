#
# Module contenant les extensions produites pour :
# Prawn
# Prawn::Table
# 
# Elles ont été inaugurées pour l'option :keep_with_next qui permet
# de souder des rangées.
# 

module PrawnTableCellTextExtension
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
end


module Prawn
module Text

  # Narrow no-break-space
  NNBSP = "\u202F"
  
  module Formatted
    class Box
      def at=(coor)
        @at = coor
      end
    end #/class Box
  end #/module Formatted

  # # Méthode #text surclassée pour que le leading soit toujours
  # # appliqué en fonction de la hauteur de ligne courante (grille de
  # # référence).
  # # 
  # alias :real_text :text
  # def text(str, **options)
  #   options.merge!(leading: current_leading)
  #   real_text(str, **options)
  # end

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
        # include PrawnTableCellTextExtension

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
