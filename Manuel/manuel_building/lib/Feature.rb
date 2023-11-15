module Prawn4book
module Manual
class Feature

  # DESCRIPTION
  # ===========
  # 
  # La classe Prawn4book::Manual::Feature permet de décrire une 
  # fonctionnalité à ajouter au manuel, tout en la testant. Le 
  # principe est le suivant : tous les codes donnés en exemple sont
  # exécutés pour produire ce qu’on voit dans le document. Donc s’il
  # y a un problème dans le programme, ce problème se voit dans le
  # mode d’emploi.
  # Cela est valable pour le texte du livre (texte.pfb.md) aussi bien
  # que pour le code de la recette.
  # 
  # 
  # TRAITEMENT D’UNE FONCTIONNALITÉ
  # ===============================
  # 
  # Quand on veut donner un exemple de texte (dans texte.pfb.md), on
  # utilise (**) :
  # 
  #   sample_texte <<~EOT
  #     ... Ici le texte ...
  #     EOT
  # 
  # (**) Mais il vaut mieux, toujours, utiliser le même code que 
  # celui donné par #texte (ci-dessous) pour être sûr d’obtenir un
  # résultat réel.
  # 
  # Si le texte doit être le même que sample_texte, juste avec les 
  # "\" supprimés, c’est-à-dire que tous les codes seront exécutés, 
  # il suffit de faire :
  # 
  #   texte(:as_sample)
  # 
  # Dans le cas contraire, on définit explicitement le texte (en 
  # sachant que c’est moins bon, puisqu’on n’est pas sûr que ce soit
  # exactement le code donné en exemple)
  # 
  # 
  # Modification de la recette
  # ---------------------------
  # 
  # On modifie ponctuellement (*) la recette avec la méthode #recipe.
  # 
  # (*) La recette est mise à son état précédent après l’écriture de
  # la fonctionnalité.
  # 
  #   recipe <<~EOT[, "<entete>"]
  #     ---
  #     ensemble:
  #       groupe:
  #         element1: <valeur>
  #         element2: <valeur>
  #     EOT
  # 
  # Quand cette recette est défini, les variables "@ensemble", 
  # "@ensemble_groupe", "@groupe", "@ensemble_groupe_element1",
  # "@groupe_element1", "@element1", "@ensemble_groupe_element2",
  # "@groupe_element2" et "@element2", *s’ils existent dans la 
  # recette* sont automatiquement remis à nil.
  # 
  # Mais si des variables en cache portent d’autres noms que ces noms
  # naturels, alors il faut les définir dans une liste envoyée à 
  # #init_recipe :
  # 
  #   init_recipe([:premier_nom_var_cache, :second_nom_var_cache])
  # 
  # Ces variables cache seront initialisées au début et à la fin de
  # l’inscription de la recette.
  # 
  # Si c’est juste un exemple de recette, qui ne doit pas être
  # "interprété", on utilise la méthode #sample_recipe
  # 
  #   sample_recipe <<~EOT[, "<entete>"]
  #     ...
  #     EOT
  # 
  # 
  # Insertion d’une page avant un élément
  # -------------------------------------
  # 
  # Pour insérer une page avant un élément(*) quelconque :
  # 
  #   new_page_before(:what)
  # 
  # (*) Les éléments (:what) peuvent être :
  # 
  #   :feature      Avant toute la fonctionnalité
  #   :texte        Avant le texte (évalué)
  #   :description  Avant la description

  # Les variables utilisables dans les textes (description, texte, 
  # sample_texte, etc.)
  # 
  VARIABLES = {
    '_PFB_' => '***Prawn-For-Book***'
  }

  attr_reader :pdf, :book
  attr_accessor :filename # chemin relatif (souvent le nom)

  # == IMPRESSION DE LA FONCTIONNALITÉ ==

  def print_with(pdf, book)

    spy(:on)

    @pdf  = pdf
    @book = book

    saut_page if new_page?

    # Mémoriser la première page de cette fonctionnalité
    first_page_texte = pdf.page_number

    # = NOUVELLE RECETTE =
    # 
    # Si une recette est définie, il faut appliquer ses nouvelles
    # valeurs (et garder les valeurs actuelles pour pouvoir les 
    # remettre)
    # 
    apply_new_state if recipe

    # = GRAND TITRE =
    if grand_titre
      saut_page
      print_grand_titre
    end

    # = TITRE =
    if titre
      saut_page if new_page_before[:title]
      print_titre
    elsif subtitle.nil?
      pdf.move_to_next_line
    end

    # = SOUS-TITRE =
    print_subtitle if subtitle

    # = DESCRIPTION =
    if description
      saut_page if new_page_before[:description]
      print_description
    end

    if margins
      # - Marges propres à la fonctionnalités -
      # - Mémorisation des marges actuelles -
      odd_margins_default   = pdf.odd_margins.freeze
      even_margins_default  = pdf.even_margins.freeze
      # - Application des nouvelles marges -
      pdf.odd_margins   = margins[:odd]
      pdf.even_margins  = margins[:even]
    end

    # = CODE =
    if code
      saut_page if new_page_before[:code]
      if code.is_a?(Proc)
        code.call(pdf)
      else
        eval(code, bind)
      end
    end

    if line_height
      cur_line_height = pdf.line_height.freeze
      pdf.line_height = line_height 
    end

    # = RECETTE EN EXEMPLE =
    if recipe || sample_recipe
      saut_page if new_page_before[:recipe]
      print_sample_recipe
    end

    # = CODE EXEMPLE =
    if sample_code
      saut_page if new_page_before[:sample_code]
      print_sample_code
    end

    # = TEXTE EXEMPLE =
    if sample_texte || texte
      if sample_texte
        saut_page if new_page_before[:sample_texte]
        print_sample_texte
      end
      saut_page if new_page_before[:texte]
      print_texte(texte || sample_texte)
    end

    # = DERNIÈRE LIGNE DE FONCTIONNALITÉ =
    draw_last_feature_line if recipe || sample_texte || texte || sample_recipe

    # Mémoriser la dernière page de cette fonctionnalité
    last_page_texte  = pdf.page_number

    if margins
      # On remet les marges initiales
      pdf.odd_margins   = odd_margins_default
      pdf.even_margins  = even_margins_default
    end

    # Un saut de page à la fin si nécessaire
    saut_page if new_page_before[:next]

    # Si on doit montrer la grille de référence, on 
    # ajoute les pages de cette fonctionnalité
    add_gridded_pages(first_page_texte, last_page_texte) if show_grid?

    # Si on doit montrer les marges, on ajoute les pages
    # de cette fonctionnalités aux pages de marges à afficher
    if show_margins?
      add_marged_pages(first_page_texte, last_page_texte) 
    end

    # = REMETTRE LA RECETTE INITIALE =
    #
    retrieve_previous_state if recipe

    # Si on a modifié la hauteur de ligne, il faut la remettre
    if line_height
      pdf.line_height = cur_line_height 
    end

    spy(:off)

  end #/ #print_with

  def deslash(str)
    str.gsub('\\','')
  end

  # DSL
  def initialize(&block)
    # Description de la fonctionnalité
    # Note : contrairement au @texte, la description découpe ses 
    # paragraphe par double retour-chariot. Donc, si la description
    # contient une liste, il faut séparer chaque item d'un double 
    # retour chariot
    @description    = nil
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
    # Quand c’est seulement un exemple de recette, qui ne doit pas
    # être interprété
    @sample_recipe = nil
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

    # Pour consigner où mettre des nouvelles pages. Il suffit d'appe-
    # ler la méthode #new_page_before avec :feature, :texte, :recipe,
    # :sample_texte, :code, :next (à la fin de la fonctionnalité)
    # 
    @new_page_before = {}

    # Pour conserver l’état actuel de la recette (les valeurs 
    # modifiées s’il y en a)
    @current_state = nil

    if block_given?
      instance_eval(&block)
    end
    self.class.last = self
  end


  # === BUILDING METHODS ===

  # Une dernière ligne pour clore (sauf si on est sur la page
  # suivante)
  def draw_last_feature_line
    pdf.update do
      move_to_next_line
      stroke_horizontal_rule if current_line > 3
    end
  end


  # === DEFINE METHODS (DSL) ===

  def grand_titre(value = nil)
    set_or_get(:grand_titre, value)
  end

  def titre(value = nil, level = 3)
    return @titre if value.nil?
    @titre = {titre: correct_string_value(value), level: level}
  end
  alias :title :titre

  def subtitle(value = nil)
    set_or_get(:subtitle, value)
  end

  def description(value = nil)
    set_or_get(:description, value)
  end

  def recipe(value = nil, entete = nil)
    set_or_get(:recipe, value, entete)
  end

  def sample_recipe(value = nil, entete = nil)
    set_or_get(:sample_recipe, value, entete)
  end

  def sample_texte(value = nil, entete = nil)
    set_or_get(:sample_texte, value, entete)
  end

  def texte(value = nil, entete = nil)
    if value == :as_sample
      value = sample_texte
        .gsub('\\\\','_DOBLEANTISLASHES_')
        .gsub('\\','')
        .gsub('_DOBLEANTISLASHES_','\\')
    end
    set_or_get(:texte, value, entete)
  end

  def sample_code(value = nil, entete = nil)
    set_or_get(:sample_code, value, entete)
  end

  def code(value = nil, entete = nil)
    set_or_get(:code, value, entete)
  end

  def margins(value = nil)
    set_or_get(:margins, value)
  end

  def show_grid(value = nil)
    case value
    when NilClass then return @show_grid
    when TrueClass then value = (0..-1)
    end
    @show_grid = value
  end
  def show_grid? ; @show_grid.is_a?(Range) end

  # @param value [Nil|True|Range]
  # 
  #   Soit rien (toutes les pages afficheront les marges)
  #   Soit true (idem)
  #   Soit le rang de pages à afficher (par exemple '(1..-2)' signi-
  #   fiera qu'il faut afficher de la deuxième à l'avant-dernière)
  #   (0-start)
  # 
  def show_margins(value = nil)
    case value
    when NilClass
      return @show_margins
    when TrueClass
      value = (0..-1)
    when Range
      # garder value
    end
    @show_margins = value
  end
  def show_margins?
    @show_margins.is_a?(Range)
  end

  def new_page(value = true)
    @new_page = value
  end
  def new_page?
    @new_page === true || not(line_height.nil?) || new_page_before[:feature]
  end

  # Pour passer à la nouvelle page avant la chose spécifiée
  # 
  # @param what [Symbol]
  # 
  # 
  #   :feature        Avant la fonctionnalité elle-même (= new_page)
  #   :title          Avant le titre
  #   :description    Avant la description
  #   :texte          Avant le texte (interprété)
  #   :recipe         Avant l'exemple de recette
  #   :sample_texte   Avant le code du texte
  #   :code     Avant de jouer le code
  def new_page_before(what = nil)
    if what
      @new_page_before.merge!(what => true)
    else
      @new_page_before
    end
  end

  # Définition ou retrait de la hauteur de ligne
  def line_height(value = nil)
    set_or_get(:line_height, value)
  end

  # --- Pour imprimer la fonctionnalité ---

  def bind(); self.binding() end

  def saut_page
    pdf.start_new_page
  end

  attr_reader :recipe_cache_variables
  def init_recipe(liste)
    @recipe_cache_variables = liste
  end

  def apply_new_state
    # - Appliquer le nouvelle état de la recette -
    @init_recipe_state ||= Marshal.dump(Prawn4book::Recipe::DATA)
    apply_recipe_state(YAML.safe_load(recipe, **YAML_OPTIONS))
  end

  # Revenir à l'état de recette précédent
  def retrieve_previous_state
    # - Remettre la recette dans son ancien état -
    ::Prawn4book::Recipe.send(:remove_const, 'DATA')
    ::Prawn4book::Recipe.const_set('DATA', Marshal.load(@init_recipe_state))
    init_recipe_cache_variables
  end

  def apply_recipe_state(patch)
    Prawn4book::Recipe::DATA.deep_merge!(patch)
    # spy "Prawn4book::Recipe::DATA : #{Prawn4book::Recipe::DATA}".gris
    # - Initialiser des variables caches -
    init_recipe_cache_variables
  end

  def init_recipe_cache_variables
    # book.instance_variable_set('@recipe', nil)
    # - Réinitialisation des variables caches existantes -
    recipe_patch = YAML.safe_load(recipe, **YAML_OPTIONS)
    # - Initialisation des variables caches possibles -
    init_cache_variables_in(recipe_patch)
    # - Les variables cache définies explicitement -
    if recipe_cache_variables
      recipe_cache_variables.each do |cvar|
        init_cache_variable("@#{cvar}")
      end
    end
  end

  def init_cache_variable(cvar_name)
    if book.recipe.instance_variable_get(cvar_name)
      book.recipe.instance_variable_set(cvar_name, nil)
      spy "Variable-cache initialisée dans recette: #{cvar_name}".bleu
    # else 
    #   spy "Variable-cache inconnue: #{cvar_name}".rouge
    end
  end

  # Méthode récursive qui permet d’initialiser toutes les variables
  # cache qui peuvent avoir des noms correspondant aux clés de la
  # +table+. Par exemple, si :
  #   +table+ = {
  #     key1: {
  #       subkey1: <valeur string>,
  #       subkey2: <valeur number>,
  #     }
  #   }
  # alors les variables cache @key1, @key1_subkey1, @subkey1, 
  # @key1_subkey2, @subkey2, si elles existent dans la recette du 
  # livre, seront remise à nil.
  def init_cache_variables_in(table, racine = [])
    table.each do |k, v|
      case v
      when Hash 
        init_cache_variables_in(v, racine.dup << k)
      else
        # - Liste des noms de variables-cache possibles -
        cached_names = ["@#{k}"]
        cur_racine  = []
        racine.reverse.each do |kr|
          cur_racine << kr
          cached_names << "@#{kr}"
          cached_names << "@#{cur_racine.reverse.join('_')}_#{k}"
        end
        cached_names.each { |vckey| init_cache_variable(vckey) }
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

  def anchored(str)
    str = "#{str}<-(#{filename_cible})"
    return str if @anchor_already_printed
    @anchor_already_printed = true
    # Pour les liens de type [[path/feature]], on mémorise la page
    # courante avec le fichier
    Prawn4book.consigne_page_feature(filename, feature_title, pdf.page_number)

    # On retourne le titre avec ancre, mais pour le moment ça ne
    # fait rien.
    # "<link anchor=\"#{filename}\">#{str}<-(#{filename_cible})</link>"
    return str
  end

  def filename_cible
    @filename_cible ||= filename.gsub('/','_')#.tap{|n|puts "Cible #{n.inspect}".bleu;sleep 0.3}
  end

  ## Méthode qui retourne un titre unique pour la
  # feature, quel que soit son niveau de titre (grand titre, titre de
  # différent niveau ou sous titre)
  # 
  def feature_title
    @feature_title ||= begin
      grand_titre || (titre && titre[:titre]) || subtitle
    end
  end

  # Méthode pour imprimer un grand titre
  # 
  def print_grand_titre
    par = PdfBook::NTitre.new(book:book, level:1, titre:anchored(grand_titre), pindex:0)
    book.paragraphes << par  
    par.print(pdf)
  end

  # Méthode pour imprimer le titre
  # 
  def print_titre
    par = PdfBook::NTitre.new(book:book, level:titre[:level], titre: anchored(titre[:titre]), pindex:0)
    book.paragraphes << par  
    par.print(pdf)
  end

  def print_subtitle
    par = PdfBook::NTitre.new(book:book, level:4, titre: anchored(subtitle), pindex:0)  
    par.print(pdf)
  end

  # Méthode pour imprimer la description
  # 
  def print_description
    description.split("\n").each_with_index do |par_str, idx|
      next if par_str.empty?
      book.inject(pdf, par_str, idx + 1)
    end
  end

  # Pour afficher l'exemple de recette
  # 
  def print_sample_recipe
    if sample_recipe
      entete = @sample_recipe_entete || "Si recipe.yaml ou recipe_collection.yaml contient…"
      print_as_code(sample_recipe.dup, entete)
    elsif recipe
      entete = @recipe_entete || "Si recipe.yaml ou recipe_collection.yaml contient…"
      print_as_code(recipe.dup, entete)
    end
  end

  # Pour afficher l’exemple de code
  # 
  def print_sample_code
    print_as_code(sample_code.dup, @sample_code_entete || "")
  end

  ##
  # Méthode générique pour afficher du code (un bloc de code en
  # Courrier, comme la recette ou de l’exemple de code)
  # 
  def print_as_code(str, entete)
    str = str.gsub(/\n( +)/){
      fois = $1.length
      "\n" + (' ' * fois)
    }.gsub('<','&lt;').gsub(/"/,'\\"').gsub('# ', '# ')
    fontline1 = "(( font(name:'Courier', size:12, style: :normal, hname:'recipe') ))\n"
    fontline  = "(( font('recipe') ))\n"
    str = fontline1 + str.split("\n").join("\n#{fontline}")
    __print_texte(str, entete, 2)
  end

  # Méthode pour afficher le texte donné en exemple
  # Attention, il peut contenir (il contient même certainement) des
  # code à évaluer (format markdown, code ruby, etc.) donc il faut
  # tout échapper pour que ça s'affiche correctement
  # 
  def print_sample_texte
    entete = @sample_texte_entete || "Si texte.pfb.md contient…"
    str = sample_texte.dup
    str = str.gsub(/\*/, '\\*').gsub('_', '\_').gsub('<','&lt;').gsub(/"/,'\\"')
    __print_texte(str, entete, 3)
  end

  def print_texte(str)
    entete = @texte_entete || "Le livre final (document PDF) contiendra :"
    __print_texte(str, entete, 3)
  end

  # Méthode générique pour imprimer tous les textes
  # 
  def __print_texte(str, entete = nil, lines_after = 1)
    my = self
    # str = correct_string_value(str) # si ça ne fonctionne pas avec les cibles
    pdf.update do
      self.line_width = 0.3
      unless entete.nil?
        move_to_next_line if my.last_is_not_title?
        entete = "<color rgb=\"999999\">*#{entete}*</color>"
        book.inject(self, entete, 0)
      end
      stroke_horizontal_rule
      move_to_next_line
      str.split("\n").each_with_index do |par_str, idx|

        # puts "Injection de #{par_str.inspect} (page #{self.page_number})".bleu

        book.inject(self, par_str, idx + 1)
      end
    end #/pdf.update
  end


  # TRUE si le dernier paragraphe (ou autre) écrit n'est pas un
  # titre.
  def last_is_not_title?
    not(last_is_title?)
  end

  private

    # Pour ajouter des pages à marger, c'est-à-dire où il faut
    # afficher les marges
    def add_marged_pages(from_page, to_page)
      mp = pdf.marged_pages == :all ? [] : pdf.marged_pages.to_a
      mp += (from_page..to_page).to_a[show_margins]
      pdf.instance_variable_set('@marged_pages', mp)
    end

    def add_gridded_pages(from_page, to_page)
      # si gridded_pages est :all, c'est qu'aucune page n'a été 
      # sélectionnée. On part donc de la liste vide et non pas de
      # toutes les pages
      gp = pdf.gridded_pages == :all ? [] : pdf.gridded_pages.to_a
      gp += (from_page..to_page).to_a[show_grid]
      pdf.instance_variable_set("@gridded_pages", gp)
    end

    def set_or_get(key, value = nil, entete = nil)
      if value.nil?
        instance_variable_get("@#{key}")
      else
        value   = correct_string_value(value) if value.is_a?(String)
        if entete
          entete  = correct_string_value(entete) 
          instance_variable_set("@#{key}_entete", entete)
        end
        instance_variable_set("@#{key}", value)
      end
    end


    # TRUE si le dernier paragraphe (ou autre) écrit est un titre
    def last_is_title?
      :TRUE == @lastistitle ||= true_or_false(define_if_last_is_title)
    end


    def options_description
      @options_description ||= {
        inline_format: true,
        align: :justify
      }.freeze
    end

# === CLASSE ===
class << self
  def add(feature)
    @features ||= []
    @features << feature
  end
  def last=(feature)
    @last = feature
    add(feature)
  end
  def last
    @last ||= nil
  end

  def each(&block)
    (@features||[]).each do |feature|
      yield feature
    end
  end
end #/<< self


private

    def correct_string_value(v)
      v = v.strip
      VARIABLES.each do |key, val|
        v = v.gsub(key, val)
      end
      if v.match?(/\[\[/)
        v = v.gsub(REG_LIEN_FEATURE){
          path = $1.freeze
          "->(#{path.gsub('/','_')})"
          # if dfeature = Prawn4book::FEATURES_TO_PAGE[path]
          #   "*#{dfeature[:title]}* (page #{dfeature[:page]})"
          # elsif Prawn4book.first_turn?
          #   "#{path} (page XXX)"
          # else
          #   add_erreur("Dans #{filename}, la feature de path #{path.inspect} est inconnue…")
          #   "{{INCONNU : #{path}}}"
          # end
        }
      end
      return v    
    end
    REG_LIEN_FEATURE = /\[\[(.+?)\]\]/.freeze

    # @private
    def define_if_last_is_title
      if par = book.paragraphes.last
        par.title?
      end
    end


end #/class Feature
end #/module Manual
end #/module Prawn4book
