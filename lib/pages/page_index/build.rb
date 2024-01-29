module Prawn4book
class Pages
class PageIndex

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    spy "-> Construction de la page d'index".jaune
    # 
    # S'il n'y a aucun mot indexé, on s'en retourne tout de suite
    # 
    return if table_index.empty?
    # 
    # La clé à utiliser pour la page ou le paragraphe
    #   - page        On utilise le numéro de page
    #   - paragraph   On utilise le numéro de paragraphe
    #   - hybrid      On utilise un numéro "page-paragraphe"
    # 
    key_num = recipe.references_key
    # 
    # Le titre de la page d'index
    # 
    titre = PdfBook::NTitre.new(book:pdfbook, titre:"Index", level:1, pindex: 0)
    titre.print(pdf)

    #
    # Le livre définit peut-être INDEX, qui est une table avec en
    # clé le canon qu’on utilise dans le texte et en valeur la vraie
    # valeur qu’il faut donner au mot indexé dans la page d’index
    # Si cette constante n’est pas définie, il faut l’initialiser
    # 
    unless defined?(INDEX)
      Prawn4book.const_set('INDEX',{})
    end

    # 
    # Boucle sur la table des index 
    # 
    table_index.sort_by do |canon, dcanon|
      # 
      # Classement des canons dans l'ordre
      # 
      dcanon[:canon_for_sort]
    end.each do |canon, dcanon|
      # 
      # Regrouper les index qui ont la même page (si numérotation
      # par page) ou le même paragraphe (si numérotation par 
      # paragraphe).
      # 
      # @rappel (pour comprendre cette partie)
      #   canon       C’est le mot indexé
      #   reférence   C’est l’endroit où on le trouve, une page, un
      #               paragraphe ou les deux
      #   occurrence  C’est un item du canon dans le texte, à une
      #               référence donnée (page, paragraphe…)
      # 
      #   Une occurrence est donc liée à une référence précise (le
      #   canon se trouve à la page 12 par exemple).
      #   Une occurrence a aussi un :poids qui indique son importance
      #   à la référence donnée. Ce poids peut être, par order d’im-
      #   portance : :main, :normal ou :minor.
      # 

      new_items = []
      table_ref = {} # pour ranger par page/paragraphe
      dcanon[:items].each do |dmot|
        ref = dmot[key_num] # La référence en fonction de la pagination
        table_ref.merge!(ref => {count: 0, poids: dmot[:poids]}) unless table_ref.key?(ref)
        # - Comptage du nombre d’occurrences -
        # 
        # @note
        #   TODO: On pourrait ajouter une option pour dire de ne
        #   pas indiquer le nombre d’occurrences par référence.
        # 
        # PRINCIPE 1 : si une des occurrences a un poids :main 
        # (important), on ne compte qu’une seule occurrence, même 
        # s’il y en a d’autres (elle sera mise en exergue par le 
        # style).
        # PRINCIPE 2 : à partir du moment où un canon a une référence
        # a un poids fort, on n’incrémente plus ses occurrences. 
        # PRINCIPE 3 : si le poids pour la référence est :minor et
        # qu’une occurrence à un poids :normal, ce nouveau poids 
        # prend le dessus.
        poids_occ = dmot[:poids]
        poids_ref = table_ref[ref][:poids]

        if poids_occ == :main
          table_ref[ref].merge!(count: 1, poids: :main)
        elsif not(poids_ref == :main)
          if poids_occ == :normal && poids_ref == :minor 
            table_ref[ref].merge!(poids: :normal)
          end
          table_ref[ref][:count] += 1
        end
      end
      new_items = table_ref.map do |ref, dmot|
        fois  = dmot[:count]
        poids = dmot[:poids]
        if fois > 1
          {key_num => {refs:"#{ref} (x#{fois})", poids: poids}}
        else
          {key_num => {refs:ref, poids:dmot[:poids]}}
        end
      end
      dcanon.merge!(items: new_items)
    end.each do |canon, dcanon|
      pdf.font(canon_fonte)
      # pdf.move_to_next_line
      txt = INDEX.key?(canon.downcase.to_sym) ? INDEX[canon.downcase.to_sym] : canon
      segments = [
        {text: "#{txt} : ", font: canon_fonte.name, size: canon_fonte.size, styles: canon_fonte.styles, color: canon_fonte.color},
      ]
      # - Ajout de chaque occurrence -
      dcanon[:items].map do |dmot|
        drefs = dmot[key_num]
        font_data = 
          case drefs[:poids]
          when :main  then number_main_fonte_data
          when :minor then number_minor_fonte_data
          else number_fonte_data
          end
        segments << font_data.merge(text: drefs[:refs].to_s)
        segments << hash_virgule
      end
      # On retire le dernier pour mettre un point et s’il y a plus
      # de deux éléments, on ajoute "et" au lieu de la dernière 
      # virgule
      segments.pop
      segments << hash_point
      if segments.count > 3
        segments[-3] = hash_et
      end
      # -- Gravure du canon et ses références --
      # Note : ça passe automatiquement à la ligne, ne rien faire.
      pdf.formatted_text(segments)
    end
    spy "<- /construction de l'index".jaune
  end

  def hash_virgule
    @hash_virgule ||= canon_fonte_data.merge(text:', ')
  end
  def hash_et
    @hash_et ||= canon_fonte_data.merge(text:' et ')
  end
  def hash_point
    @hash_point ||= canon_fonte_data.merge(text:'.')
  end

  def sizes_nombre_occurrences
    @sizes_nombre_occurrences ||= {
      normal: number_fonte.size - 1,
      main:   number_main_fonte.size - 1,
      minor:  number_minor_fonte.size - 1
    }
  end

  def number_fonte_data
    @number_fonte_data ||= {
      font:   number_fonte.name, 
      size:   number_fonte.size, 
      styles: number_fonte.styles, 
      color:  number_fonte.color
    }.freeze
  end

  def number_main_fonte_data
    @number_main_fonte_data ||= {
      font:   number_main_fonte.name, 
      size:   number_main_fonte.size, 
      styles: number_main_fonte.styles, 
      color:  number_main_fonte.color
    }.freeze
  end

  def number_minor_fonte_data
    @number_minor_fonte_data ||= {
      font:   number_minor_fonte.name, 
      size:   number_minor_fonte.size, 
      styles: number_minor_fonte.styles, 
      color:  number_minor_fonte.color
    }.freeze
  end

  def canon_fonte_data
    @canon_fonte_data ||= {
      font:   canon_fonte.name,
      size:   canon_fonte.size,
      styles: canon_fonte.styles,
      color:  canon_fonte.color
    }.freeze
  end

  def canon_fonte
    @canon_fonte ||= begin
      Fonte.get_in(recipe_data_aspect[:canon]).or_default
    end
  end
  def number_fonte
    @number_fonte ||= begin
      Fonte.get_in(recipe_data_aspect[:number]).or(canon_fonte)
    end
  end
  def number_main_fonte
    @number_main_fonte ||= Fonte.get_in(recipe_data_number[:main]).or(number_fonte)
  end
  def number_minor_fonte
    @number_minor_fonte ||= Fonte.get_in(recipe_data_number[:minor]).or(number_fonte)
  end

  def recipe_data_number
    @recipe_data_number ||= recipe_data_aspect[:number] || {}
  end

  def recipe_data_aspect
    @recipe_data_aspect ||= recipe_data[:aspect] || {}
  end

  def recipe_data
    @recipe_data ||= recipe.page_index
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
