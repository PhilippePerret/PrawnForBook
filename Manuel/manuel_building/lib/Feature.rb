module Prawn4book
module Manual
class Feature

  attr_reader :pdf, :book

  # DSL
  def initialize(&block)
    @description    = nil
    @sample_recipe  = nil # Exemple tiré de la recette
    # Pour modifier la recette
    # 
    # Avec cette donnée, on va vraiment modifier la recette.
    # Mais pour ce faire, on ne vas pas pouvoir donner une table YAML
    # comme celle de la recette, car beaucoup de données sont mises
    # en cache. On va plutôt utiliser le nom des variables cache, ce
    # qui va en fait simplifier l'écriture (il faut juste rechercher
    # dans recipe_data.rb le nom des variables cache).
    # 
    # Par exemple, pour la hauteur de ligne, il suffit de définir
    # :line_height :
    # 
    #   recipe {
    #     line_height: 30
    #   }
    # 
    # Certaines valeurs se servent d'une table et d'une clé dans 
    # cette table. Par exemple, pour l'affichage ou non de la grille
    # de référence, la recette va chercher la clé :show_grid dans la
    # donnée @format_page mise en page. Il suffit alors de dire :
    # 
    #   recipe {
    #     format_page: {numerotation: 'hybrid'}
    #   }
    # 
    # Ces redéfinitions ne s'appliquent que pour la feature courante.
    # Les anciennes valeurs sont aussitôt réappliquées.
    # 
    @recipe         = nil
    @sample_texte   = nil # écrit dans le fichier texte.pfb.md
    @texte          = nil # Le texte donné à PFB. En règle générale,
                          # c'est sample_texte qui doit être pris, pour être pertinennt. Mais parfois, il faut le modifier un peu pour obtenir le résultat exact voulu.
    @sample_code    = nil # code ruby donné en exemple (sera joué)
                          # (par exemple pour un module personnalisé)
    @code           = nil # code joué en coulisses
                          # (pour obtenir le résultat voulu)

    # Pour modifier la hauteur de ligne (la grille de référence)
    # Si cette valeur est modifiée (par 'line_height(new value)'),
    # la fonctionnalité est automatiquement "isolée", c'est-à-dire
    # mise sur une nouvelle page avec un saut de page à la fin.
    @line_height = nil

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

  def sample_recipe(value = nil)
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

  def show_grid(value)
    @show_grid = value
  end
  def show_grid? ; @show_grid === true end

  def new_page(value)
    @new_page = value
  end
  def new_page?; @new_page === true || not(line_height.nil?) end

  def line_height(value = nil)
    set_or_get(:line_height, value)
  end

  # --- Pour imprimer la fonctionnalité ---

  def print_with(pdf, book)
    @pdf  = pdf
    @book = book

    pdf.start_new_page if new_page?

    # 
    # Si une recette est définie, il faut l'enrouler autour du 
    # code pour pouvoir en tenir compte
    # 
    apply_new_state if recipe

    print_titre         if titre
    print_description   if description
    eval(code, bind)    if code


    if line_height
      cur_line_height = pdf.line_height.freeze
      pdf.line_height = line_height 
    end
    print_texte         if texte

    add_gridded_page_current if show_grid?

    # S'il y avait une recette, on remet l'état précédent
    retriev_previous_state if recipe

    # Si on a modifié la hauteur de ligne, il faut la remettre
    if line_height
      pdf.line_height = cur_line_height 
    end

    pdf.start_new_page if new_page?

  end

  def bind(); self.binding() end

  def apply_new_state
    recipe.each do |k, v|
      if v.is_a?(Hash)
        table = book.recipe.send(k)
        v.each do |sk, sv|
          # Conserver la valeur actuelle
          cur_value = table[sk]
          # Appliquer la nouvelle valeur
          table.merge!(sk => sv)
          # Mémoriser la valeur actuelle
          recipe[k].merge!( sk => cur_value )
        end
      else
        # Conserver la valeur actuelle
        cur_value = book.recipe.send(k)
        # Appliquer la nouvelle valeur
        book.recipe.instance_variable_set("@#{k}", v)
        # Mémoriser la valeur actuelle
        recipe.merge!(k => cur_value)
      end
    end
  end

  # Revenir à l'état de recette précédent
  def retriev_previous_state
    recipe.each do |k, v|
      if v.is_a?(Hash)
        table = book.recipe.send(k)
        v.each do |sk, sv|
          table.merge!(sk => sv)
        end
      else
        book.recipe.instance_variable_set("@#{k}", v)
      end
    end
  end

  # Méthode générique pour imprimer dans le manuel PDF
  #
  def print(text:, options:, fonte: Fonte.default_fonte)
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

  # Méthode pour imprimer le texte
  # 
  # @note
  def print_texte
    pdf.line_width = 0.3
    pdf.move_to_next_line
    pdf.stroke_horizontal_rule
    texte.split("\n").each_with_index do |par_str, idx|

      book.inject(pdf, par_str, idx)
 
      # par = Prawn4book::PdfBook::AnyParagraph.instantiate(self, par_str, 0, self)
      # book.print_paragraph(pdf, par) # gestion des blocs courants
      # # par.print(pdf) # pas de gestion des blocs courants

    end
    pdf.move_to_next_line
    pdf.stroke_horizontal_rule
  end

  private

    def add_gridded_page_current
      if pdf.gridded_pages == :all
        gp = []
      else
        gp = pdf.gridded_pages.to_a
      end
      gp << pdf.page_number
      pdf.instance_variable_set("@gridded_pages", gp)
    end

    def set_or_get(key, value = nil)
      if value.nil?
        instance_variable_get("@#{key}")
      else
        value = value.strip if value.is_a?(String)
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
