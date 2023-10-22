module Prawn4book
class Printer
class << self

  THIEF_LINE_LENGTH = 7

  # @api
  # 
  # Méthode générique universelle permettant d'écrire du texte :
  #   - sur la grille de référence (quelle que soit la hauteur de 
  #     ligne)
  #   - sans aucune veuve
  #   - sans aucune orpheline
  #   - sans aucune ligne de voleurs
  # 
  # PRINCIPE
  # --------
  # 
  #   L'écriture se fait ligne à ligne. C'est de cette manière qu'on
  #   peut gérer les lignes de voleur sur tous les paragraphes ainsi
  #   que les veuves et les orphelines aux changements de pages.
  # 
  #   Les fausses tables, quand elles passent par ici, fonctionnent
  #   colonne par colonne, en récupérant le curseur et la hauteur 
  #   pour gérer la prochaine colonne.
  #   @rappel : les "fausses-tables" ne fonctionnent pas avec les
  #   Prawn::Table, qui gèrent mal les lignes de référence pour le
  #   moment, mais avec des paragraphes simplement définis au niveau
  #   de leur left et leur width (dans :at et :width) pour simuler
  #   des tables ou des affichage tabulaires, plutôt.
  # 
  # 
  # TODO
  # ----
  # 
  #   Dans une version ultérieure, pour optimiser l'impression (i.e.
  #   l'accélérer), on pourrait ne passer par le ligne à ligne que
  #   lorsque le texte en tient pas entièrement dans la page.
  #   Dans ce système, seule la dernière ligne devra être étudiée
  #   (mais comment ?) pour savoir si elle présente une ligne de
  #   voleur.
  #
  # PARAMÈTRES
  # ----------
  # 
  # @param owner [AnyClass] 
  #   
  #   Le propriétaire qui fait la demande, a du +text+ à écrire, la 
  #   plupart du temps un [PdfBook::NTextParagraph]
  # 
  # @param pdf [Prawn4book::PrawnView]
  # 
  #   Le document Prawn::Document (PrawnView) en train d'être
  #   construit, qui produira le PDF
  # 
  # @param text [String|Formatted String]
  # 
  #   Le texte à écrire.
  # 
  # @param fonte [Prawn4book::Fonte]
  # 
  #   L'instance Fonte de la fonte.
  # 
  # @param options [Hash]
  # 
  #   Table des options telles qu'envoyé à pdf.box_text.
  # 
  #   @notes
  #     - Il sera ajouté 'dry_run:true' et 'single_line:true' pour
  #       gérer les orphelines, les veuves et les lignes de voleurs
  #       car l'écriture se fait ligne par ligne (c'est cher mais
  #       c'est précis).
  # 
  def pretty_render(
      owner:    ,
      pdf:      , 
      text:     ,
      fonte:    ,
      options:  
    )

    options = defaultize_options(options.dup, pdf)

    # Le décalage horiztontal du texte à écrire
    # 
    left = options[:at][0]

    # On établit d'abord la liste des lignes qu'on aura à écrire, en
    # résolvant les lignes de voleur (il ne doit plus y en avoir).
    # 
    # Ensuite, une fois qu'on a toutes les lignes (sous forme de box),
    # on peut les écrire.
    # 
    begin
      pdf.update do

        font(fonte)

        # Pile (stack) pour mettre les lignes à écrire du paragraphe
        # 
        # Les lignes ne seront placées qu'à la fin, une fois que l'on
        # sait s'il y a des orphelines, des veuves, des lignes de
        # voleur et des paragraphes à conserver ensemble
        # 
        paragraphe_stack = [] # pour mettre les box avant de les rendre
      

        str = text.dup

        # Tant qu'il reste du texte, on boucle pour faire toutes les
        # lignes (box) du paragraphe.
        while str.length > 0

          # Fabrication du text-box
          # ------------------------
          # text_box est une méthode surclassée pour qu'elle fonc-
          # tionne avec :dry_run (donc qu'elle n'imprime pas le para-
          # graphe et qu'elle retourne en même temps l'excédant, dé-
          # signé par +rest+ ci-dessous le box [Text::Formatted::Box
          # ou Text::Box s'il n'y a pas de formatage.
          # 
          # +rest+  [Array<Hash>] Le texte restant ou une liste vide.
          # +box+   [Text::Formatted::Box|Text::Box]
          # 
          # @note
          # 
          #   On se place toujours tout en haut de la page pour 
          #   qu'aucun calcul de passage à la page suivante ne vienne
          #   perturber la vérification. Noter que quel que soit la 
          #   longueur du paragraphe, il sera traité en entier puis-
          #   qu'on fonctionne toujours ligne à ligne ici.
          # 
          rest, box = text_box(str, **options)

          # spy "rest = #{rest.inspect}"

          #
          # S'il reste quelque chose, mais que c'est trop court, il faut
          # jouer sur le kerning du texte courant pour faire remonter le
          # texte ou faire descendre un mot.
          # 
          # Donc, ici, on va calculer le character_spacing nécessaire,
          # et on va corriger +box+ pour qu'il intègre le reste. Après
          # cette opération, +rest+ doit être vide.
          # 
          # @note TODO Il faut pouvoir régler la longueur de mot minimum
          #   C'est-à-dire la valeur du THIEF_LINE_LENGTH ci-dessous
          #   et il faut pouvoir le modifier à la volée dans le texte
          # 
          has_thief_line = rest.count > 0 && rest.first[:text].length <= THIEF_LINE_LENGTH
          if has_thief_line
            cs = treate_thief_line_in(pdf, stf, **options)
            rest, box = text_box(
              str, 
              **options.merge(kerning:true, character_spacing:-cs)
            )
            rest.count == 0 || raise("Il ne devrait rester plus rien.")
          end

          has_no_rest = rest.count == 0

          # 
          # On met toujours la ligne (c'est forcément une ligne) dans 
          # le tampon de ligne du paragraphe.
          # 
          paragraphe_stack << box

          break if has_no_rest

          str = rest[0][:text]

        end
        # /loop tant qu'il reste du texte (while str.length > 0)


        # À partir d'ici, on a dans le tampon de lignes toutes les
        # lignes du paragraphe à écrire.
        spy "Nombre lignes-box à écrire : #{paragraphe_stack.count}"

        # Faut-il passer à la page suivante pour écrire le premier
        # paragraphe ?
        first_line_on_next_page = cursor - line_height < 0

        start_new_page if first_line_on_next_page

        # On boucle sur toutes les lignes pour les écrire
        # À chaque ligne écrite il faut déplacer le curseur sur la 
        # ligne suivante.
        # 
        # is_first_line pour savoir si c'est la première et gérer les
        # orphelines.
        is_first_line = true
        while boxline = paragraphe_stack.shift

          # Nombre de lignes restantes
          nombre_restantes = paragraphe_stack.count

          is_penultimate_line = nombre_restantes == 1

          if is_first_line && (nombre_restantes > 0) &&  cursor - 2 * line_height < 0
            # => Orpheline
            # => Passer tout de suite à la page suivante
            start_new_page
          elsif is_penultimate_line && cursor - 2 * line_height < 0
            # => La suivante serait une Veuve
            # => Passer tout de suite à la page suivante pour que
            #    la ligne suivante ne soit pas seule.
            start_new_page
          end
          boxline.at = [left, cursor] # TODO: CE "0" EST À RÉGLER

          ##############################
          ### IMPRESSION DE LA LIGNE ###
          ##############################
          boxline.render

          # -- On se place sur la ligne suivante --
          move_to_next_line

          is_first_line = false
        end

      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise FatalPrawnForBookError.new(100, {
        text: text.inspect, 
        err:  e.message, 
        backtrace:(debug? ? e.backtrace.join("\n") : '')
      })
    end
    
  end #/pretty_render

  # 
  # Pour calculer le character spacing, on fonctionne ne plus en
  # plus fin : dès qu'un c-s fait supprimer la ligne de voleurs
  # on prend le précédent et on affine avec une division plus
  # fine
  def treate_thief_line_in(pdf, rest, **options)
    cs = nil # character-spacing
    snap = 0.1
    last_cs = 0
    while snap > 0.000001
      cs = last_cs
      rest = [1]
      while rest.count > 0
        cs += snap
        rest, box = pdf.text_box(str, **par_options.merge(at:[0,cursor], kerning:true, character_spacing: -cs))
        break if rest.count == 0
        last_cs = cs.dup
      end
      snap = snap / 10 # cran : 0.001 -> 0.0001
    end
    return cs
  end


  def defaultize_options(options, pdf)
    # Pour pouvoir gérer ligne à ligne
    options.merge!(dry_run: true, single_line: true)

    # Par défaut, la largeur de la page
    # (je préfère le dire explicitement)
    unless options.key?(:width)
      options.merge!(width: pdf.bounds.width)
    end

    # Par défaut, placé à gauche et tout en haut ()
    # (je préfère le dire explicitement)
    unless options.key?(:at)
      options.merge!(at: [0, pdf.bounds.height])
    else
      # pour ne pas avoir de changement de page inopportun 
      # pendant le calcul
      options[:at][1] = pdf.bounds.height
    end

    return options
  end

end #/ << self Prawn4book::Printer
end #/ class Printer
end #/ module Prawn4book
