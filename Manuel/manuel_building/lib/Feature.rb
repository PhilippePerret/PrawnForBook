module Prawn4book
module Manual
class Feature

  attr_reader :pdf, :book

  # DSL
  def initialize(&block)
    @description    = nil
    @sample_recipe  = nil # Exemple tiré de la recette
    @recipe         = nil # Pour modifier la recette
    @sample_texte   = nil # écrit dans le fichier texte.pfb.md
    @texte          = nil # Le texte donné à PFB. En règle générale,
                          # c'est sample_texte qui doit être pris, pour être pertinennt. Mais parfois, il faut le modifier un peu pour obtenir le résultat exact voulu.
    @sample_code    = nil # code ruby donné en exemple (sera joué)
                          # (par exemple pour un module personnalisé)
    @code           = nil # code joué en coulisses
                          # (pour obtenir le résultat voulu)
    if block_given?
      instance_eval(&block)
    end
    self.class.last = self
  end

  # --- Pour définir la fonctionnalités ---

  def titre(value = nil)
    set_or_get(:titre, value)
  end
  alias :title :titre

  def description(value = nil)
    set_or_get(:description, value)
  end

  def recipe(value = nil)
    set_or_get(:recipe, value)
  end

  def sample_texte(value = nil)
    set_or_get(:sample_texte, value)
  end

  def texte(value = nil)
    set_or_get(:texte, value)
  end

  def sample_code(value = nil)
    set_or_get(:sample_code, value)
  end

  def code(value = nil)
    set_or_get(:code, value)
  end


  # --- Pour imprimer la fonctionnalité ---

  def print_with(pdf, book)
    @pdf  = pdf
    @book = book
    print_titre         if titre
    print_description   if description
  end

  # Méthode générique pour imprimer dans le manuel PDF
  #
  def print(text:, options:, fonte: Fonte.default_fonte)
    spy "-> print".rouge
    Prawn4book::Printer.pretty_render(
      owner:    self,
      text:     text,
      options:  options,
      fonte:    fonte,
      pdf:      pdf,
    )
  end

  # Méthode pour imprimer le titre
  # 
  def print_titre
    par = PdfBook::NTitre.new(book:book, level:3, titre: titre, pindex:0)  
    par.print(pdf)
  end

  # Méthode pour imprimer la description
  # 
  def print_description
    description.split("\n\n").each do |par_str|
      par = PdfBook::NTextParagraph.new(book:book, raw_text:par_str, pindex: 0)
      par.print(pdf)
    end
  end


  private

    def set_or_get(key, value = nil)
      if value.nil?
        instance_variable_get("@#{key}")
      else
        value = value.strip
        instance_variable_set("@#{key}", value)
      end
    end


    def options_description
      @options_description ||= {
        inline_format: true,
        align: :justify
      }.freeze
    end

# === CLASSE ===
class << self

  def last=(feature)
    @last = feature
  end
  def last
    @last ||= nil
  end
end #/<< self
end #/class Feature
end #/module Manual
end #/module Prawn4book
