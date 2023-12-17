#
# Pour gérer l'export du texte en fichier simple texte
# 
# Cet export du livre permet de le corriger dans Antidote. Avec le
# texte complet, sans balise et avec tous les textes.
# 
# Il suffit d'ajouter l'option -t pour obtenir cet export
# 
# 
module Prawn4book
  def self.exported_book=(book)
    @@book = book
  end
  def self.exported_book
    return @@book
  end
  class PdfBook

    attr_reader :last_str

    # @api
    # 
    # Méthode principale appelée pour sauver le texte dans le fichier
    # 
    # @usage
    # 
    #   pdf.export_text(str)
    # 
    # @notes
    # 
    #   [1] Cela arrive souvent avec les Prawn::tables.
    # 
    def export_text(str)
      return if str == last_str # [1]
      return if str == ' '
      return if str.numeric? # un numéro de page
      exportator << epure(str)
      #
      # Pour ne pas écrire deux fois le même texte (par exemple une
      # ligne de saut de page)
      # 
      @last_str = str.dup
    end

    def epure(str)
      # -- Retirer toutes les balises HTML --
      str = str.gsub(/<(.+?)>/,'')
      return str
    end

    def exportator
      @exportator ||= Exportator.new(self)
    end

  end #/class PdfBook


  class Exportator
    def initialize(pdfbook)
      @pdfbook = pdfbook
    end

    def add(str)
      # Méthode à utiliser en fonction du début (début de phrase ou
      # cours de phrase)
      begin
        car = str.match?(/^[A-ZÉÀ]/) ? "\n" : " "
      rescue Encoding::CompatibilityError => e
        # TODO Régler le problème d'encodate
        car = "\n"
      end
      str = "#{car}#{str}"
      ref.write str.force_encoding('utf-8')
    end
    alias :<< :add

    def ref
      @ref ||= begin
        delete_if_exists
        File.open(path, File::CREAT|File::APPEND|File::WRONLY)
      end
    end

    def delete_if_exists
      File.delete(path) if File.exist?(path)
    end

    def path
      @path ||= File.join(@pdfbook.folder, 'only_text.txt')
    end
  end #/class Exportator
end #/module Prawn4book


module Prawn
  class Table
    class Cell
      class Text < Cell
        alias :real_draw_content :draw_content
        # def text_box(extra_options={})
        def draw_content
          # Si le texte n'est pas vide, on l'écrit dans le fichier
          # de texte exporté
          # @rappel : ce module n'est chargé qu'en cas d'export du
          # texte.
          # if @content.length > 0
          #   Prawn4book.exported_book.export_text(@content)
          # end
          # -- Dans tous les cas, on utilise la méthode originale
          #    pour écrire le texte ---
          # real_text_box(extra_options)
          real_draw_content
        end
      end #/class Text
    end #/class Cell
  end #/class Table

  module Text

    alias :read_draw_text! :draw_text!
    def draw_text!(text, options)
      # puts "Je dois écrire depuis draw_text!: #{text.inspect}".jaune
      # exit 100
      Prawn4book.exported_book.export_text(text)
      read_draw_text!(text, options)
    end
  end #/module Text
end #/module Prawn
