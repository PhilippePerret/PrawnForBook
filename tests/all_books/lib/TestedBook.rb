# encoding: UTF-8
=begin

  class TestedBook
  ----------------

  Elle doit permettre de tester en profondeur les livres produits.

=end
require_relative 'TestedBook_Assertions'
class TestedBook
  
  include Minitest::Assertions
  attr_accessor :assertions

  attr_reader :folder
  def initialize(folder)
    @folder = folder
    self.assertions = 0
  end

  def pinspect(what, instance = nil)
    res =
      if instance
        instance.instance_eval(what)
      else
        eval(what)
      end
    puts "\n++++ #{what}".bleu + ' : ' + res.inspect
  end

  # = main =
  # 
  # Méthode principale pour checker le livre produit sans erreur
  # 
  def check
    # pinspect('textor.class.instance_methods')

    # pinspect('textor.word_spacing')
    # pinspect('textor.word_spacing.count')

    # pinspect('textor.font_settings')
    # pinspect('textor.font_settings.count')

    # pinspect('textor.text_rendering_mode')
    # pinspect('textor.text_rendering_mode.count')

    # pinspect('textor.character_spacing')
    # pinspect('textor.character_spacing.count')

    # pinspect('textor.horizontal_text_scaling')
    # pinspect('textor.horizontal_text_scaling.count')

    # pinspect('textor.kerned')
    # pinspect('textor.kerned.count')

    # pinspect('textor.positions')
    # pinspect('textor.positions.count')

    # pinspect('textor.strings')
    # pinspect('textor.strings.count')

    # pinspect('textor.show_text')
    # pinspect('textor.show_text.count')

    # pinspect('textor.show_text_with_positioning')
    # pinspect('textor.show_text_with_positioning.count')

    # pinspect('textor.size')
    # pinspect('textor.size.count')


    # Les méthodes de pagtor
    # pinspect('pagtor.class.instance_methods')

    # pagtor.page = pagtor.pages[0]

    # pinspect('pagtor.show_text')
    # pinspect('pagtor.show_text.count')

    # page = reador.pages.first

    # pinspect('self.class', reador.pages.first)
    # pinspect('self.attributes', reador.pages.first)


    # pinspect('reador.metadata')
    # pinspect('reador.page_count')

    # reador.pages.each do |page|
    #   pinspect('fonts', page)
    #   pinspect('text', page)
    #   # pinspect('raw_content',page)
    # end

    assert File.exist?(book_path), "Le livre n'a pas été produit…"
    assert File.exist?(expectations_file_path), "Le fichier 'expectations' n'existe pas…"
    File.readlines(expectations_file_path).each do |line|
      next if line.start_with?('#')
      line = line.strip
      next if line.empty?
      # puts "Traitement de la ligne #{line.inspect}".jaune
      dline = line.split(":::").map{|n|eval(n.strip)}
      assertion = dline.shift
      args = dline
      send(assertion, *args)
    end
  end

  # --- PDF Document Properties ---

  # @prop Table des fontes utilisées dans le document
  # 
  # Pour l'obtenir, on boucle sur toutes les pages en récupérant
  # l'information sur les fontes de la page.
  def fonts
    @fonts ||= begin
      tbl = {}
      reador.pages.each do |page|
        tbl.merge!(page.fonts)
      end
      # spy "fontes : #{tbl.pretty_inspect}"
      tbl
    end
  end 

  # --- Propriétés générales utiles ---

  # Le texte entier simple, ligne après ligne
  def whole_string
    @whole_string ||= text_inspector.strings.join("\n")#.force_encoding('utf-8')
  end

  def reador
    @reador ||= PDF::Reader.new(book_path)
  end

  # alias :textor (pour "text inspector")
  def text_inspector
    @text_inspector ||= PDF::Inspector::Text.analyze_file(book_path)
  end
  alias :textor :text_inspector

  # alis pagtor (pour "page inspector")
  def pages_inspector
    @pages_inspector ||= PDF::Inspector::Page.analyze_file(book_path)
  end
  alias :pagtor :pages_inspector

  # --- Fonctional Methods ---

  def delete_pdf
    File.delete(book_path) if File.exist?(book_path)
  end

  # --- Path Properties ---

  # @prop Fichier contenant le check du pdf à faire
  def expectations_file_path
    @expectations_file_path ||= File.join(folder,'expectations')
  end

  def name # le nom du dossier
    @name ||= File.basename(folder)
  end

  def book_path
    @book_path ||= File.join(folder,'book.pdf')
  end

  def recipe_path
    @recipe_path ||= File.join(folder,'recipe.yaml')
  end

  def collection_recipe_path
    @collection_recipe_path ||= File.join(collection_folder,'recipe_collection.yaml')
  end

  def collection_folder
    @collection_folder ||= File.dirname(folder)
  end
end
