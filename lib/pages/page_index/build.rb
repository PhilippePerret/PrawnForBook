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

      # Table provisoire pour ranger par référence
      # 
      # Car ici, il faut remplacer la même référence sur une même
      # page (ou paragraphe) par un comptage du nombre de répétition
      # (:count) qui s’affichera "x12" dans la gravure.
      # Pour ce faire, il faut remplacer la donnée dcanon[:items]
      table_ref = {} # pour ranger par page/paragraphe
      dcanon[:items].each do |dmot|
        ref = dmot[key_num] # La référence en fonction de la pagination
        
        unless table_ref.key?(ref)
          table_ref.merge!(ref => dmot.dup.merge(count: 0))
          table_ref[ref].delete(:mot)
          table_ref[ref].delete(:canon)
        end

        # On ajoute une occurrence
        table_ref[ref][:count] += 1
        # - Modification éventuelle du poids -
        # Un poids supérieur remplace toujours un poids inférieur
        poids_occ = dmot[:poids]
        poids_ref = table_ref[ref][:poids]

        if poids_occ == :main
          table_ref[ref].merge!(poids: :main)
        elsif not(poids_ref == :main)
          if poids_occ == :normal && poids_ref == :minor 
            table_ref[ref].merge!(poids: :normal)
          end
        end
      end
      new_items = table_ref.keys.sort.map {|k| table_ref[k]}
      dcanon.merge!(items: new_items)
    end.each do |canon, dcanon|
      pdf.font(canon_fonte)
      txt = INDEX.key?(canon.downcase.to_sym) ? INDEX[canon.downcase.to_sym] : canon
      puts "dcanon[:items]: #{dcanon[:items].inspect}"
      segments = Occurrences.as_formatted({
        text:           "#{txt} : ",
        fonte:          canon_fonte,
        fonte_main:     number_main_fonte,
        fonte_normal:   number_fonte,
        fonte_minor:    number_minor_fonte,
        key_ref:        key_num
      }, dcanon[:items])
      # -- Gravure du canon et ses références --
      # Note : ça passe automatiquement à la ligne, ne rien faire.
      pdf.formatted_text(segments)
    end
    spy "<- /construction de l'index".jaune
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
