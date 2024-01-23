module Prawn4book
module Manual
class Feature

  # Variables utilisables dans les textes (description, texte, 
  # sample_texte, etc.)
  # 
  VARIABLES = {
    '_PFB_'       => '***Prawn-For-Book***',
    '_expert_'    => '[[expert (cf. page __page__)|expert/mode_expert]]',
    '_index_'     => '[[index (cf. page __page__)|expert/bibliographies]]',
    '_stylisation_inline_' => '[[stylisation en ligne (cf. page __page__)|texte_detail/stylisation_in_line]]'

  }

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
  # NOUVELLE FONCTIONNALITÉ
  # =======================
  # Pour créer une nouvelle fonctionnalité :
  # - déterminer la place où la mettre dans le dossier "Features"
  #     Pe: le dossier "generalites"
  # - déterminer son nom
  #     Pe: "belle_fonction"
  # - ajouter la fonctionnalité à la constante FEATURE_LIST dans le
  #   fichier _FEATURE_LIST_.rb, à l’endroit voulu
  #     Pe: Ajouter "generalites/belle_fonction"
  # - créer le fichier ruby de la fonctionnalité en dupliquant le
  #   fichier _MODELE_A_DUPLIQUER_.rb en lui appliquant le son nom
  # - dans ce fichier, déterminer le titre et les autres éléments qui
  #   seront utilisés. Cf. ci-dessous.
  # - relancer la fabrication du manuel en ouvrant une console au 
  #   dossier "MANUEL_BUILDING"
  # 
  # 
  # MODE REAL BOOK
  # ==============
  # Le "mode real book" est un mode particulier d’utilisation de
  # cette instance Feature qui permet de produire un "vrai" livre
  # PFB à titre d’exemple et d’en insérer les pages voulues dans le
  # manuel autoproduit.
  # Dans le fichier de la fonctionnalité créé ci-dessus, déterminer :
  # - real_texte    Le "vrai" texte du real book (c’est une fonction)
  # - real_recipe   La "vraie" recette du real book (voir dans le
  #                 fichier recette de la collection les éléments qui
  #                 sont déjà définis, comme la taille du livre)
  #                 (c’est une fonction aussi)
  # - texte         Le texte qui va être traduit et affiché dans le
  #                 manuel autoproduit. Les "![page-<x>]" qu’il 
  #                 contient seront les pages à tirer du real book.
  # 
  # Pour le reste, voir dans :
  #   - lib/RealBook.rb le détail de l’utilisation
  #   - RealBooksCollection/recipe_collection.yaml les définitions de
  #     recette généraux propres aux real books.
  # 
  # MODE NORMAL DU TRAITEMENT D’UNE FONCTIONNALITÉ
  # ==============================================
  # 
  # Si on n’utilise pas le mode real-book (cf. ci-dessus), on utilise
  # le mode normal où les exemples sont évalués à l’intérieur du 
  # manuel, au fur et à mesure de sa construction.
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
  # TITRE de la fonctionnalité
  # --------------------------
  # 
  # On peut utiliser les méthode `titre’ ou `grand_titre’ pour défi-
  # nir le titre de la fonctionnalité.
  # ATTENTION : utiliser seulement l’un ou l’autre, sinon, il y aura
  # une erreur de double définition de référence. Si vraiment l’un et
  # l’autre sont nécessaire, faire un fichier ’grand_titre’ à part.
  # 
  # Si l’on veut un "très grand titre", c’est-à-dire un titre qui se
  # placera sur une belle page et seul, il faut utiliser :
  # 
  #   titre "le grand grand titre", 1
  # 
  # DESCRIPTION de la fonctionnalité
  # --------------------------------
  # Elle se définit par :
  # 
  #     description <<~EOT
  #       <la description>
  #       EOT
  # 
  # Si on veut écrire cette description dans un fichier .md séparé, 
  # il suffira ensuite de le charger par :
  # 
  #     description(File.read(__dir__+'<nom_fichier>.md'))
  # 
  # TEXTE et TEXTE EXEMPLE
  # -----------------------
  # 
  # Si on définit :
  # 
  #     sample_texte("<str>"[, "<entete>"])
  # 
  # On définit en même temps un texte exemple et l’illustration de 
  # ce texte. Par exemple, si on met des *...* dans sample_texte, ils
  # seront conservés tels quels tandis qu’ils seront interprétés dans
  # le texte.
  # 
  # Si le texte doit être différent (mais c’est à éviter), on 
  # utilise :
  # 
  #     texte("<string>"[, "<entete>"])
  # 
  # Si on doit échapper des caractères spéciaux dans @sample_texte et
  # qu’ils ne doivent par l’être dans @texte. On utilise :
  # 
  #     texte(:as_sample)
  # 
  # Si aucun texte illustration ne doit être ajoué, alors on met :
  # 
  #     texte(:none)
  # 
  # Exemple de RECETTE
  # ------------------
  # 
  # Pour donner un exemple de recette on utilise la méthode :
  # 
  #   sample_recipe("<yaml string>"[, "<entête personnalisé>"])
  # 
  # où "<yaml string>" sera un extrait YAML du code de la recette.
  # 
  # 
  # Exemple de la VRAIE RECETTE actuelle
  # ------------------------------------
  # 
  # On peut aussi extraire le code de la recette courante elle-même
  # avec :
  # 
  #     sample_real_recipe([Symbol|Array<Symbol>], "<custom header>")
  # 
  # où :
  #   [Symbol] correspnd à la section de recette à afficher (par 
  #   exemple «:book_data»)
  #   Array<Symbol>] est une liste de symboles lorsque plusieurs
  #   section sont à afficher.
  # 
  # 
  # Modification de la RECETTE
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
  # "interprété", comme nous l’avons vu, on utilise la méthode 
  # #sample_recipe
  # 
  #   sample_recipe <<~EOT[, "<entete>"]
  #     ---
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
  #   :recipe       Avant la recette
  #   :real_recipe  Avant la vraie recette (extrait)
  # 
  # 
  # Faire référence à une autre fonctionnalités
  # -------------------------------------------
  # 
  # On peut faire très facilement référence à une autre fonction-
  # nalités, c’est-à-dire afficher son titre et sa page, en mettant
  # le chemin relatif au fichier entre doubles-crochets :
  # 
  #     [[puces/black_losange]]
  # 
  # Cette marque sera remplacée par : 
  # 
  #     "Les  puces losange noir (page 56)"
  # 
  # Pour ne pas avoir de majuscule au début, il suffit d’ajouter un
  # '-' (un moins) au début (noter que seule la première lettre sera
  # mise en minuscules) :
  # 
  #     [[-puces/black_losange]]
  # 
  # =>
  # 
  #     "les  puces losange noir (page 56)"
  # 
  # Si tout le titre doit être mis en minuscules, ajouter deux 
  # moins :
  # 
  #     [[--forces_de_prawn]]  # titre : #Les forces de Prawn-For-Book
  # 
  # =>
  # 
  #     "les forces de prawn-for-book"
  # 
  # Si on veut un titre tout à fait différent du titre de la fonctionnalité :
  # 
  #     [[titre particulier|dossier/feature]]
  # 
  # =>
  # 
  #     "titre particulier (page xxx)"
  # 
  # Et enfin, si l’on veut un autre format que "(page xxx)" pour 
  # indiquer la page, on utile la marque '__page__' pour dire où
  # doit être inscrit le numéro de la page :
  # 
  #     [["Le beau titre", page __page__|path/recette]]
  # 
  # =>
  # 
  #     "« Le beau titre », page 23"
  # 
  # (noter les apostrophes remplacés).
  # 
  ################################################################



  attr_reader :pdf, :book
  attr_accessor :filename # chemin relatif (souvent le nom)
  attr_accessor :filepath
  attr_reader :first_page

  # FONCTIONNALITÉ EN REAL BOOK 

  def real_book?
    @is_real_book === true
  end

  def is_real_book
    @is_real_book = true
  end

  def real_book
    @real_book ||= RealBook.new(name: filename.gsub(/\//,'_'))
  end

  def produce_real_book
    # 
    # Ici on doit tester pour voir s’il est nécessaire de recréer le
    # livre. Pour ça, il suffit de comparer la date du fichier 
    # feature avec la date du fichier PDF.
    # 
    return if real_book.up_to_date?(last_modified_time)

    logif "Le real book #{real_book.name} doit être actualisé"

    STDOUT.write "\rPréparation du livre #{real_book.name}…#{' '*10}".jaune
    #
    # === Mise en place du real-book ===
    # 
    real_book.prepare(real_texte, real_recipe)
    STDOUT.write "\rProduction du livre #{real_book.name}…#{' '*10}".jaune
    #
    # === Fabrication du PDF du real-book ===
    # 
    real_book.produce || return
    STDOUT.write "\r" # on reprend
  end

  # @return la date de dernière modification du fichier ruby 
  # définissant la fonctionnalité
  def last_modified_time
    File.stat(filepath).mtime
  end

  # == IMPRESSION DE LA FONCTIONNALITÉ ==

  def print_with(pdf, book)

    # spy(:on)

    @pdf  = pdf
    @book = book

    eval(code_before) if code_before

    saut_page if new_page?

    # Mémoriser la première page de cette fonctionnalité et l’indiquer
    # dans la liste
    Prawn4book::FEATURES_TO_PAGE[filename][:page_number] = first_page_texte = pdf.page_number

    # L’exposer pour pouvoir l’utiliser dans les codes
    @first_page = first_page_texte

    # = NOUVELLE RECETTE =
    # 
    # Si une recette est définie, il faut appliquer ses nouvelles
    # valeurs (et garder les valeurs actuelles pour pouvoir les 
    # remettre)
    # 
    apply_new_state if recipe

    # Si un code doit être effectué après l’application de la
    # recette
    if code_after_recipe
      eval(code_after_recipe)
    end

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
      puts "Ne plus changer line_height, faire un real book"
      exit 13
      cur_line_height = pdf.line_height.freeze
      pdf.line_height = line_height 
    end

    # = RECETTE EN EXEMPLE =
    if recipe || sample_recipe
      saut_page if new_page_before[:recipe]
      print_sample_recipe
    end
    if sample_real_recipe
      saut_page if new_page_before[:real_recipe]
      print_sample_real_recipe
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
    # (inutile de mémoriser et d’exposer ce numéro de page car
    #  il sera défini après que la fonctionnalité a été imprimée 
    #  dans le livre)
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
    # NON, maintenant, on empêche la modification de la hauteur
    # de ligne
    if line_height
      pdf.line_height = cur_line_height 
    end

    eval(code_after) if code_after

    # spy(:off)

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
    # La recette réelle d’un real-book
    @real_recipe = nil
    # Le texte donné en exemple
    # Si @texte n'est pas fourni, c'est lui qui sera injecté dans le
    # document (et donc interprété).
    @sample_texte   = nil
    # Le texte réel d’un real book
    @real_texte = nil
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
    # Code avant de commencer
    @code_before
    # Code après avoir appliqué la recette
    @code_after_recipe
    # Code à la fin de la fonctionnalité
    @code_after
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
  
  end #/initialize


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

  ERREUR_DOUBLE_REF_TITRE = <<~EOT
    On ne peut pas utiliser grand_titre et titre dans la même fonctionnalité !"
    (faire un fichier séparé pour le grand titre, si indispensable)
    EOT

  def grand_titre(value = nil)
    if not(value.nil?) && not(@titre.nil?)
      raise ERREUR_DOUBLE_REF_TITRE
    end
    set_or_get(:grand_titre, value)
  end

  def titre(value = nil, level = 3)
    if not(value.nil?) && not(@grand_titre.nil?)
      raise ERREUR_DOUBLE_REF_TITRE
    end
    return @titre if value.nil?
    @titre = {titre: correct_string_value(value), level: level}
  end
  alias :title :titre

  def subtitle(value = nil)
    set_or_get(:subtitle, value)
  end
  alias :sous_titre :subtitle

  def description(value = nil)
    set_or_get(:description, value)
  end

  def recipe(value = nil, entete = nil)
    set_or_get(:recipe, value, entete)
  end

  def real_recipe(value = nil, entete = nil)
    set_or_get(:real_recipe, value, entete)
  end

  def sample_real_recipe(value = nil, entete = "Extrait de la recette actuelle")
    value = extract_from_recipe(value) unless value.nil?
    set_or_get(:sample_real_recipe, value, entete)
  end

  def sample_recipe(value = nil, entete = nil)
    if value.is_a?(Symbol) || value.is_a?(Array)
      return sample_real_recipe(value, entete) 
    elsif real_book? && @sample_recipe.nil? && value.nil?
      value  = get_sample_recipe_from_real_recipe
      entete = "SI la recette du livre contient…"
    end
    set_or_get(:sample_recipe, value, entete)
  end

  def sample_texte(value = nil, entete = nil)
    if real_book? && value.nil? && @sample_texte.nil?
      value   = get_sample_texte_from_real_texte
      entete  = "ET que le texte du livre contient…"
    end
    set_or_get(:sample_texte, value, entete)
  end

  def real_texte(value = nil, entete = nil)
    is_real_book unless value.nil?
    set_or_get(:real_texte, value, entete)
  end
  alias :real_text :real_texte

  def texte(value = nil, entete = nil)
    unless value.nil?
      if value == :as_sample
        value = sample_texte
          .gsub('\\\\','_DOBLEANTISLASHES_')
          .gsub('\\','')
          .gsub('_DOBLEANTISLASHES_','\\')
      end
    end
    # Si c’est une définition du texte et que c’est un real-book,
    # on passe toujours à la page suivante avant de marquer que c’est
    # le texte final.
    if value && real_book?
      # new_page_before(:texte) # NON, le fait explicitement
      entete ||= "ALORS le livre contiendra…"
      if value.match?(/\[\[/)
        value = value.gsub(/\[\[.+?\]\]/,"{{Pas de référence par [[...]] dans un “real book”}}")
      end
    end
    set_or_get(:texte, value, entete)
  end

  def get_sample_recipe_from_real_recipe
    return nil if @real_recipe.nil?
    str = @real_recipe.dup
    # str = "```yaml\n---\n#{str}\n```"
    return str
  end

  # Méthode utilisée pour mettre le code réel en exemple de code
  # Elle prendre le code réel (@real_code) et échappe tous les
  # caractère qui pourraient être interprétés
  def get_sample_texte_from_real_texte
    return nil if @real_texte.nil?
    str = @real_texte.dup
    str = str.gsub(REG_ESCAPED_CHARS, '\\\\'+'\1')
    return str
  end
  REG_ESCAPED_CHARS = /#{EXCHAR}([\*\#\{\[\!\(])/

  # Traitement du texte d’une fonctionnalité de type real-book
  # 
  def traite_texte_for_real_book
    return if texte.nil?
    pages_to_export = []
    str = self.texte.dup
    str = str.gsub(REG_IMAGES_REAL_BOOK) do
      page_numero = $1.freeze
      pages_to_export << page_numero.to_i
      "![RealBooksCollection/#{real_book.name}/page-#{page_numero}.jpg]"
    end
    pages_to_export = pages_to_export.uniq
    unless pages_to_export.empty?
      # - Extraction des pages voulues -
      real_book.extract_pages(pages_to_export)
    end
    @texte = str
  end
  REG_IMAGES_REAL_BOOK = /\!\[page\-([0-9]+)\]/.freeze

  def sample_code(value = nil, entete = nil)
    set_or_get(:sample_code, value, entete)
  end

  def code(value = nil, entete = nil)
    set_or_get(:code, value, entete)
  end

  def code_before(value = nil, entete = nil)
    set_or_get(:code_before, value, entete)
  end

  def code_after_recipe(value = nil, entete = nil)
    set_or_get(:code_after_recipe, value, entete)
  end

  def code_after(value = nil, entete = nil)
    set_or_get(:code_after, value, entete)
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
  #   :real_recipe    Avant l’exemple de la vrai recette
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
    if book.recipe.instance_variable_get(cvar_name) || book.recipe.respond_to?(cvar_name.to_sym)
      book.recipe.instance_variable_set(cvar_name, nil)
      # spy "Variable-cache initialisée dans recette: #{cvar_name}".bleu
    # else 
      # spy "Variable-cache inconnue: #{cvar_name}".rouge
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
    par = PdfBook::NTitre.new(book:book, level:2, titre:anchored(grand_titre), pindex:0)
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
      entete = @sample_recipe_entete || "Si le fichier recipe.yaml ou recipe_collection.yaml contient…"
      print_as_code(sample_recipe.dup, entete)
    elsif recipe
      entete = @recipe_entete || "Si le fichier recipe.yaml ou recipe_collection.yaml contient…"
      print_as_code(recipe.dup, entete)
    end
  end

  # Pour afficher l’exemple de la vraie recette
  # 
  def print_sample_real_recipe
    print_as_code(sample_real_recipe.dup, @sample_real_recipe_entete)
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
    str = "~~~\n#{str}\n~~~"
    __print_texte(str, entete, 2)
  end

  # Méthode pour afficher le texte donné en exemple
  # Attention, il peut contenir (il contient même certainement) des
  # code à évaluer (format markdown, code ruby, etc.) donc il faut
  # tout échapper pour que ça s'affiche correctement
  # 
  def print_sample_texte
    entete = @sample_texte_entete || "Si le fichier « texte.pfb.md » contient…"
    str = sample_texte.dup
    str = str.gsub(/\*/, '\\*').gsub('_', '\_').gsub('<','&lt;').gsub(/"/,'\\"')
    __print_texte(str, entete, 3)
  end

  def print_texte(str)
    return if str == :none
    str = last_corr_for_texte_real_book(str) if real_book?
    entete = @texte_entete || "Le livre final (document PDF) contiendra :"
    __print_texte(str, entete, 3)
  end

  # Juste avant d’inscrire le texte pour un real-book, on peut faire
  # des corrections de dernière minutes
  # (inauguré pour écrire le message de retour de la construction du
  #  real book)
  def last_corr_for_texte_real_book(str)
    # 
    # La marque qui permet d’inscrire le retour du livre réel
    # 
    if str.match?('_building_resultat_')
      res = real_book.building_resultat || '(Aucun retour, tout s’est bien passé)'
      res = res.gsub(/\e/, '').gsub(/\[0m/,'').gsub(/\[0;[0-9][0-9]m/,'').gsub(/(👍|🍺|🥂)/,'')
      str = str.gsub('_building_resultat_', res)
      # puts "str = #{str.inspect}".jaune
    end
    return str
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

  # ATTENTION : Les données suivantes ne sont pas définies lorsque
  # le module de la fonctionnalité est loadé
  def __path
    @__path ||= File.join(FEATURES_FOLDER, filename)
  end

  def __folder
    @__folder ||= File.dirname(__path)
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

    # @return toujours la valeur (possiblement corrigée)
    def set_or_get(key, value = nil, entete = nil)
      if value.nil?
        # instance_variable_get("@#{key}")
        val = instance_variable_get("@#{key}")
        val = correct_string_value(val) if val.is_a?(String)
        return val
      else
        if entete
          entete  = correct_string_value(entete) 
          instance_variable_set("@#{key}_entete", entete)
        end
        instance_variable_set("@#{key}", value)
        return value
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
      # if Prawn4book.second_turn?
      #   puts "\nJe fais bien un second tour".jaune
      #   exit 12
      # end
      v = v.strip
      VARIABLES.each do |key, val|
        v = v.gsub(key, val)
      end

      # - Lien vers une autre fonctionnalité -
      if v.match?(/\[\[/)
        v = v.gsub(REG_LIEN_FEATURE){
          tirets = $~['tirets'].freeze
          path = $~['filename'].freeze
          feat_data = 
            if Prawn4book.first_turn?
              {}
            else
               Prawn4book::FEATURES_TO_PAGE[path] || {} # quand page encore inexistante 
            end
          tit = ($~['titre'] || (feat_data[:title] && "« #{feat_data[:title]} »") || path).dup
          if tirets
            case tirets.length
            when 2 then tit = tit.downcase
            when 1 then tit[0] = tit[0].downcase
            end
            tit = "|#{tit}"
          end
          # @return:
          if Prawn4book.first_turn?
            "#{path.gsub('/','_')}#{tit}"#.tap { |str| spy "Appel = #{str.inspect}".bleu }
          else
            if tit.match?('__page__')
              tit.gsub('__page__', feat_data[:page_number].to_s)
            else
              "#{tit} (p. #{feat_data[:page_number]})"#.tap { |str| spy "Appel = #{str.inspect}".bleu }
            end
          end
        }
      end
      return v    
    end
    REG_LIEN_FEATURE = /\[\[(?<tirets>-+?)?(?:(?<titre>.+?)\|)?(?<filename>.+?)\]\]/.freeze

    # @private
    def define_if_last_is_title
      if par = book.paragraphes.last
        par.title?
      end
    end


    # On extrait un bout de la recette courante et on la renvoie en
    # String, pour exemple.
    # 
    def extract_from_recipe(value)
      value = [value] if value.is_a?(Symbol)
      tbl = {}
      value.each do |section|
        tbl.merge!(section => Prawn4book::Recipe::DATA[section])
      end
      # La méthode #to_yaml écrit les symboles avec :key: mais je 
      # n’aime pas cette tournure donc j’enlève les premiers ":" et
      # j’ajoute également un "# ..." en haut du fichier.
      tbl.to_yaml.gsub(/:([a-zA-Z_0-9]+):/,'\1:').gsub(/^\-\-\-/,"---\n# .\..")
    end

end #/class Feature
end #/module Manual
end #/module Prawn4book
