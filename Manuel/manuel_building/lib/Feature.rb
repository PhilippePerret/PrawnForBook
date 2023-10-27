module Prawn4book
module Manual
class Feature

  attr_reader :pdf, :book

  # DSL
  def initialize(&block)
    # Description de la fonctionnalité
    # Note : contrairement au @texte, la description découpe ses 
    # paragraphe par double retour-chariot. Donc, si la description
    # contient une liste, il faut séparer chaque item d'un double 
    # retour chariot
    @description    = nil
    # Exemple de recette
    @sample_recipe  = nil 
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
    # Le texte donné en exemple
    # Si @texte n'est pas fourni, c'est lui qui sera injecté dans le
    # document (et donc interprété).
    @sample_texte   = nil
    # Lorsque @sample_texte ne peut pas produire exactement le rendu
    # attendu, on utilise @texte pour définir exactement le texte qui
    # devra être injecté (interprété et imprimé) dans le document.
    @texte          = nil
    # code ruby donné en exemple. Par exemple du code de module
    # personnalisé
    # (il est susceptible d'être joué)
    @sample_code    = nil
    # code joué en coulisses pour obtenir le résultat voulu.
    # N'a rien à voir avec @sample_code
    @code           = nil 

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

  # --- DSL Pour définir la fonctionnalités ---

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
    set_or_get(:sample_recipe, value)
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

  def new_page_before_texte(value = nil)
    set_or_get(:new_page_before_texte, value)
  end

  def new_page_before_texte?; new_page_before_texte === true end

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

    if titre
      print_titre
    else
      pdf.move_to_next_line
    end

    print_description   if description
    eval(code, bind)    if code


    if line_height
      cur_line_height = pdf.line_height.freeze
      pdf.line_height = line_height 
    end

    pdf.start_new_page if new_page_before_texte?

    # Mémoriser la première page de cette fonctionnalité
    first_page_texte = pdf.page_number
    
    if sample_recipe
      print_sample_recipe
    end

    if sample_texte || texte
      print_sample_texte if sample_texte
      print_texte(texte || sample_texte)
    end

    # Une dernière ligne pour clore
    pdf.move_to_next_line
    pdf.stroke_horizontal_rule

    # # Mémoriser la dernière page de cette fonctionnalité
    last_page_texte  = pdf.page_number

    add_gridded_pages(first_page_texte, last_page_texte) if show_grid?

    # S'il y avait une recette, on remet l'état précédent
    retriev_previous_state if recipe

    pdf.start_new_page if new_page?

    # Si on a modifié la hauteur de ligne, il faut la remettre
    if line_height
      pdf.line_height = cur_line_height 
    end


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

  # Pour afficher l'exemple de recette
  # 
  def print_sample_recipe
    entete = "Dans le fichier recipe.yaml ou recipe_collection.yaml"
    str = sample_recipe.dup
    str = str.gsub(' ', '  ').gsub('<','&lt;')
    fontline1 = "(( font(name:'Courier', size:12, style: :normal, hname:'recipe') ))\n"
    fontline  = "(( font('recipe') ))\n"
    str = fontline1 + str.split("\n").join("\n#{fontline}")
    __print_texte(str, entete)
  end

  # Méthode pour afficher le texte donné en exemple
  # Attention, il peut contenir (il contient même certainement) des
  # code à évaluer (format markdown, code ruby, etc.) donc il faut
  # tout échapper pour que ça s'affiche correctement
  # 
  def print_sample_texte
    entete = "Dans le fichier texte.pfb.md"
    str = sample_texte.dup
    str = str.gsub(/\*/, '\\*').gsub(/_/, '\_')
    __print_texte(str, entete)
  end

  def print_texte(str)
    entete = "Produira dans le livre :"
    __print_texte(str, entete)
  end

  # Méthode pour imprimer le texte
  # 
  # @note
  def __print_texte(str, entete = nil)
    pdf.line_width = 0.3
    pdf.move_to_next_line
    unless entete.nil?
      entete = "<color rgb=\"CCCCCC\">*#{entete}*</color>"
      book.inject(pdf, entete, 0)
    end
    pdf.stroke_horizontal_rule
    pdf.move_to_next_line
    str.split("\n").each_with_index do |par_str, idx|
      book.inject(pdf, par_str, idx + 1)
    end
  end

  private

    def add_gridded_pages(from_page, to_page)
      if pdf.gridded_pages == :all
        gp = []
      else
        gp = pdf.gridded_pages.to_a
      end
      (from_page..to_page).each do |numpage|
        gp << numpage
      end
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
