=begin

  Gestion de la table des matières

=end
module Prawn4book
class Tdm
  attr_reader :document, :pdf

  # @prop [Integer] Numéro de page sur laquelle écrire la table
  # des matières
  attr_accessor :page_number

  # @prop [Array<Titre>] Liste des instances de titre
  attr_reader :titres


  def initialize(document, pdf)
    @document = document
    @pdf      = pdf
    @titres   = []
  end

  ##
  # Ajout d'un titre à la table des matières
  # 
  # @param [Prawn4book::PdfBook::NTitre] ntitre Instance du paragraphe de titre
  # @param [Integer] page Numéro de page
  # @param [Integer] paragraph Numéro de paragraphe
  # 
  def add_title(ntitre, page, paragraph)
    titre = Titre.new(document, {content:ntitre.text, level: ntitre.level, instance: ntitre, page: page, paragraph: paragraph})
    @titres << titre
  end

  def each_titre(&block)
    titres.each do |titre|
      yield titre
    end
  end

class Titre
  attr_reader :book
  attr_reader :params
  def initialize(book, params)
    @book   = book
    @params = params
  end
  # @return [Integer] Le numéro en fonction du fait qu'il faut
  # numéroter avec le numéro de page ou de paragraphe.
  def numero
    @numero ||= numero_page? ? page : paragraph
  end

  # - Prédicate method -

  def numero_page?
    book.recipe.page_number?
  end

  # - Volatile Data -

  # @return [Integer] L'indentation du titre en fonction de son
  # level
  def indent
    @indent ||= level * recipe[:"level#{level}"][:indent]
  end

  # - Data -

  def content   ; @content    ||= params[:content]    end
  def page      ; @page       ||= params[:page]       end
  def paragraph ; @paragraph  ||= params[:paragraph]  end
  def level     ; @level      ||= params[:level]      end

  def recipe
    @recipe ||= book.recipe.table_of_content
  end

end #/class Titre
end #/class Tdm

end #/module Prawn4book
