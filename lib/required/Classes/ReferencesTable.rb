module Prawn4book
class PdfBook
class ReferencesTable

  REG_CIBLE_REFERENCE = /^<\-\((.+?)\)$/.freeze
  REG_APPEL_REFERENCE = /^\->\((.+?)\)$/.freeze

  attr_reader :book
  attr_reader :table

  def initialize(book)
    @book = book
  end

  ##
  # Initialisation
  # 
  def init
    @table = {}
    @cross_references   = {}
    # - Références non trouvées au premier tour -
    # En clé : le ticket de poissonnerie attribué pour le texte et
    # en valeur l'identifiant de la référence qu'on doit retrouver
    # par <self>.get(ref_id) et qui retourne la référence à coller 
    # dans le texte.
    @wanted_references  = {}
  end


  # -raccourci -
  def second_turn?
    Prawn4book.second_turn?
  end

  ##
  # Ajout d'une référence interne rencontrée au cours du parsing
  # du texte (du paragraphe ou autre — titre, cellule de table, etc.)
  # 
  # @note
  #   Il s'agit uniquement des références croisées "internes", c'est
  #   à dire dans le même livre. Pour les références à d'autres li-
  #   vres, voir la méthode suivante.
  # 
  # @param ref_id {String} 
  #   IDentifiant de la référence. Il peut contenir un "|". Dans ce
  #   cas, le premier terme est la version textuelle de la référence
  #   et le deuxième terme est l’identifiant proprement dit.
  # 
  # @param ref_data {Hash} 
  #   Données de la référence, contient {:paragraph} où :paragraph
  #   est l’instance du paragraphe où se trouve la cible. En règle
  #   général, c’est un PdfBook::NTextParagraph, mais ça peut être
  #   aussi un PfbBook::PFBCode ou une table (?).
  # 
  #   Noter que dans le cas d’un PFBCode, cela signifie que la cible
  #   de la référence a été définie sur une ligne seule. Mais comme
  #   c’est une ligne identifiée comme ligne de code, elle ne sera
  #   pas numérotée (puisqu’elle n’existera pas en tant que paragra-
  #   phe physique dans le livre), donc si la référence est hybride
  #   ou doit utiliser le numéro du paragraphe, on se retrouvera avec
  #   une erreur. D’où l’erreur fatale #2003 générée dans la méthode
  #   #treate_as_cible_references du fichier PFBCode.rb
  # 
  def add(ref_id, ref_data)
    if second_turn?
      # Au second tour, on peut vérifier que la référence soit 
      # toujours placée au même endroit. Sinon, on provoque une
      # erreur.

      # {TODO}

    else
      if ref_id.match?('\|')
        ref_text, ref_id = ref_id.split('|') 
      else
        ref_text  = ref_id.dup.freeze
        ref_id    = ref_id.gsub(/<.+?>/,'')
      end
      ref_id = ref_id.to_sym
      ref_data.merge!(text: ref_text)
      if table.key?(ref_id)
        # ERROR: Double définition de référence
        raise PFBFatalError.new(2001, {id: ref_id, page: ref_data[:page]})
      else
        # - Bonne référence -
        table.merge!(ref_id => ref_data)
      end
    end
  end

  ##
  # Traitement d'une référence appartenant à un autre livre.
  # 
  # Méthode appelée lors du parse d'un texte (de paragraphe ou autre)
  # lorsqu'une référence croisée est rencontrée. Elle permet en même
  # temps de vérifier la pertinence de la référence (son existence)
  # et de renvoyer le texte à écrire.
  # 
  # @return [String] Le texte pour remplacer l'appel à la cible
  # 
  # @oaram [String] book_id   L'identifiant du livre dans la bibliographie
  # @param [String] cible     L'identifiant de la cible dans le livre
  # 
  def add_and_get_cross_reference(book_id, cible_id)
    # puts "book_id: #{book_id.inspect} / cible_id: #{cible_id.inspect}".jaune
    book = Bibliography::Livres.get(book_id) || begin
      # - quand le livre n'existe pas -
      raise PrawnBuildingError.new(ERRORS[:references][:cross_book_undefined] % book_id)
    end
    book.cible?(cible_id) || begin
      # - quand la cible n'existe pas (ou le livre) -
      PrawnBuildingError.new(ERRORS[:references][:cross_ref_unfound] % [cible_id, book_id])
    end
    
    return book.reference_to(cible_id)
  end

  ##
  # Appel d'une référence
  # ---------------------
  # C'est la méthode qui retourne l'appel vers la destination 
  # voulu. Le paragraphe est fourni car, en cas de référence croisée
  # il faut ajouter une entrée dans la bibliographie des livres.
  # Il sert aussi à gérer les références ultérieures
  # 
  # Au premier tour, si elle n'est pas définie, on indique qu'il
  # faudra recommencer un tour.
  # 
  # @param ref_id [String] 
  # 
  #   L'ID de la référence. En cas de référence à un autre livre, 
  #   on a "IDBOOK:ref_id"
  # 
  # @param paragraph [NTextParagraph] 
  # 
  #   Instance du paragraphe contetant l'appel.
  # 
  def get(ref_id, context = nil)
    paragraph = context[:paragraph]
    pdf       = context[:pdf]
    #
    # Traitement particulier des références croisées
    # TODO: Ici, apparemment, on ne traite pas le problème du texte
    # différent de l’id (avec un "|")
    # 
    return get_cross_reference(ref_id, paragraph) if ref_id.match?(/[^  ]:/.freeze)
    # 
    # Sinon, une référence simple dans le livre
    # 
    # (mais qui peut être personnalisée)
    # 
    ref_text = nil
    if ref_id.match?('\|')
      ref_text, ref_id = ref_id.split('|')
      ref_id ||= ref_text  # on peut utiliser "->(mon_id|)" (noter le trait droit)
    else
      ref_text = ref_id.dup
      ref_id = ref_id.gsub(/<.+?>/,'') # on supprime les éventuels formatages
    end
    ref_id = ref_id.to_sym
    if (ref = table[ref_id])
      #
      # - Référence définie -
      # (2e tour ou référence à un élément déjà traité)

      # - Il faut toujours qu’il y ait une marque pour la page ou
      #   le paragraphe -
      unless ref_text.match?(/_(ref|page|paragraph)_/)
        ref_text = "#{ref_text} (_ref_)"
      end
      # - Transformation de la marque -
      ref_text
        .gsub(/_ref_/, endroit_to(ref))
        .gsub(/_page_/, ref[:paragraph].page.to_s)
        .gsub(/_paragraph_/, ref[:paragraph].numero.to_s)
    elsif second_turn?
      err_msg = PFBError[2002] % {id: ref_id}
      unless @_key_table_list_has_been_done === true
        # Pour ne donner le message qu’une seule fois
        err_msg = "#{err_msg}\nPour information, la table des références (des cibles) contient : #{table.keys}"
        @_key_table_list_has_been_done = true
      end 
      add_erreur(err_msg)

      # raise PFBFatalError.new(2002, {id: ref_id, targets:table.keys})
      "### REF: #{ref_id} ###"
    else
      # - Référence non définie -
      # On passe ici quand la référence cible n'est pas encore 
      # définie (parce qu'elle se trouve plus loin, peut-être même 
      # dans le paragraphe suivant). Dans ce cas, on prend un "ticket 
      # de poissonnerie" en attendant la référence. Elle prend
      # la place de la future référence, en faisant une longueur qui
      # correspond approximativement à la longueur de la référérence
      # finale en fonction de la pagination utilisée.
      len = ref_default_length
      len += ref_text.length if ref_text != '_ref_'
      ticket_boucherie = "#{'x' * len}"
      @wanted_references.merge!(ticket_boucherie => ref_id )
      data_unknown_target = {
        paragraph:  paragraph,
        ticket:     ticket_boucherie,
        ref_id:     ref_id,
        page:       pdf.page_number,
      }
      paragraph.has_unknown_target(data_unknown_target)
      return ticket_boucherie
    end
  end

  ##
  # Enregistrement des la liste des références
  # 
  # @rappel 
  # 
  #   Cette table enregistrée dans un fichier ne sert que pour les
  #   références croisées. Pour un livre, elles sont recalculées 
  #   chaque fois.
  # 
  def save
    File.write(path, table.to_yaml)
  end



  # --- Helpers Methods ---

  # @return [String] la texte qui doit remplacer la balise target 
  # dans le texte
  # 
  # @note
  #   Les références croisées utilisent une autre méthode.
  # 
  # @param ref [Hash]
  #     Table contenant (pour le moment) :paragraph, l’instance
  #     AnyParagraph (NTextParagraph, NTable, etc.) du paragraphe
  #     où se trouve la définition de la cible.
  # 
  def endroit_to(ref)
    num_page = ref[:paragraph].page
    num_para = ref[:paragraph].numero
    case book.recipe.page_num_type
    when 'pages'
      book.recipe.reference_page_format % {page:num_page}
    when 'parags'
      if ref[:paragraph]
        book.recipe.reference_paragraph_format % {paragraph:num_para}
      else
        "#{ref[:page]}"
      end
    when 'hybrid'
      book.recipe.reference_hybrid_format % {page:num_page, paragraph:num_para}
    end
  end

  # Longueur par défaut d'une référence (le 'XX' de "Page XX"). Il
  # est utile lorsqu'on marque provisoirement, au premier tour, la
  # référence à une cible et qu'il faut, alors, que cette marque cor-
  # responde à peu près à la longueur qu'aura la référence au second
  # tour (pour que les numéros de page soient respectées, même s'il y 
  # a peu de change qu'un décalabe soit notable, mais on ne sait 
  # jamais…)
  def ref_default_length
    case book.recipe.page_num_type
    when 'pages'  then 3
    when 'parags' then 5
    when 'hybrid' then 10
    end
  end

  # --- Predicate Methods ---

  # @return true Si le livre contient des références
  # 
  def any?
    table.count > 0
  end

  # @return true si un appel est resté sans référence
  # (cela se produit quand un appel de référence se trouve avant
  # la référence en question — donc sur une page ou un paragraphe 
  # avant)
  def appels_sans_reference?
    @wanted_references.any?
  end


  # --- Path Methods ---

  def path
    @path ||= File.join(book.folder,'references.yaml')
  end

end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
