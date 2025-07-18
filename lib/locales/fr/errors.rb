module Prawn4book

ERRORS = {

  string: {
    pps_require_ref_for_pourcent: <<~ERR,
      La méthode String#to_pps réclame en premier argument la valeur
      de référence (le 100 %) lorsqu’un pourcentage doit être calculé.
      ERR
  },



  # --- Application --- #

  app: {
    require_a_book_or_collection: <<~ERR,
      Il faut se trouver dans un dossier de livre ou de collection.
      %{path}
      … ne contient pas de recette, donc ça ne peut pas être un dossier de 
      livre ou de collection.
      ERR
  },

  errors: {
    bad_custom_errid: <<~ERR,
      Le numéro d'erreur %{n} n'est pas valide. Il est déjà utilisé.
      Par mesure de prudence, il vaut mieux utiliser les numéros 
      de 20 000 à 30 000 (avouez qu'il y a de quoi faire…).
      ERR
  },

  unfound_folder: "Le dossier '%s' est introuvable…",
  prawn_manual_unfound: "Le manuel de Prawn est introuvable. Il vous faut définir son chemin d'accès dans le fichier ./lib/constants.rb dans la constante PRAWN_MANUEL_PATH.",

  # --- Général --- #

  required_property: "La propriété %s est requise.",
  required_asterisk_properties: "Toutes les propriétés marquées d'un astérisque rouge sont requises.",
  
  invalid_data: "La donnée %s de value %s est invalide.", 

  # --- LE LIVRE ---

  book: {
    not_in_collection: 'Le livre « %{title} » n’appartient pas à une collection.',

    require_margins_definition: <<~EOT,
      Les marges du livre doivent être toutes définies. Dans le cas 
      contraire, la mise en page risque de changer lorsque vous les
      définirez explicitement.
      Pour le moment, elles sont mises à :
      %{margins}
      Il faut définir %{missings} dans la recette, de cette manière :

      ---
      book_format:
        page:
          margins:
      %{missings_yaml}

      Consultez le mode d’emploi pour avoir une explication sur ces
      définitions de marge.
      EOT

  },

  # --- FABRICATION DU LIVRE ---

  building: {
    require_pdf: "Il faut toujours le livre en construction pour pouvoir calculer le leading",
    require_line_height: "Un leading n'a de sens que par rapport à une hauteur de ligne.",
    too_much_errors_on_properties: "Trop d'erreurs rencontrées sur la propriété '%s'. Réglez le problème avant de reprendre la fabrication du livre.",
    unfound_included_file: "Le fichier à inclure '%s' est introuvable (même dans le dossier du livre ou de la collection).",
    book_not_built: "Malheureusement le book PDF ne semble pas avoir été produit.",
  
    bat_fatal_error: <<~ERR,
      Pour produire un livre BAT (Bon À Tirer) il faut absolument corriger
      l’erreur fatale suivante (ou retirer l’option -bat) :
      %{err}
      ERR

    bat_no_margins: <<~ERR,
      Les marges ne doivent pas être demandées (en tout cas pas par
      l’option -margins)
      ERR
    bat_no_grid: <<~ERR,
      La grille de référence ne doit pas être affichée dans le livre
      en B.A.T. (en tout cas pas par l’option -grid). Si vraiment vous souhaitez
      imprimer un livre avec la grille de référence, pour voir, alors retirez 
      l’option -bat (je m’en voudrais trop de produire un BAT avec ce genre 
      d’artefact…)
      ERR
  },

  # --- Parsing ---

  parsing: {
    parse_required_string: <<~ERR,
      La méthode Prawn4book::PdfBook::AnyParagraph::__parse requiert une 
      chaine de caractères en premier argument. Le premier argument, 
      %s, est de classe %s.
      ERR
    paragraph_required: <<~ERR,
      Quel que soit le texte à parser/formater, le paragraphe est toujours 
      requis.
      ERR
    class_tag_formate_method_required: <<~ERR,
      La méthode #%{meth} doit être définie dans le module ParserFormaterClass
      du fichier formater.rb (ou parser.rb) du livre ou de la collection.

      # in ./formater.rb (ou ./parser.rb)

      module ParserFormaterClass
        
        def %{meth}(str, context)
          # ... définir le code ici
        end
      
      end

      Deux grandes utilisations possibles : 
      - en travaillant le texte puis en le retournant
      - en le gravant directement dans le pdf
      Pour la première utilisation, retourner simplement le texte transformé.
      Pour la deuxième utilisation, récupérer le paragraphe et le pdf du para-
      mètre `context’ et renvoyer nil pour ne pas écrire deux fois le texte :

      def %{meth}(str, context)
        pdf = context[:pdf]
        par = context[:paragraph]
        pdf.update do
          text par.text, **{size: 20}
          update_current_line
        end
        return nil
      end

      ERR
    unknown_method: <<~ERR
      Je ne sais pas comment traiter le code `%{code}'.
      Peut-être est-ce une méthode à traiter dans le module formater.rb ou
      dans le module prawn4book.rb du livre ou de la collection.

      Si le code doit retourner un texte à écrire :
      (ou alors renvoyer nil)

      # in ./formater.rb
      module ParserFormaterClass
        # En fonction du nombre d’arguments, on enverra différentes
        # chose à la méthode. Le mieux est de faire :
        #     def %{meth}(pdf, context, arg1, arg2... argN)
        # où <argX> sont les arguments transmis dans le texte.
        # Si la méthode #%{meth} attend le même nombre d’argument que
        # ceux transmis dans le texte, seuls ces arguments seront 
        # transmis. Par exemple, si la méthode définie par :
        #     def %{meth}(annee, jour)
        # et que le texte appelle :
        #     (( %{meth}(2024, 12) ))
        # alors 2024 sera mis dans annee et 12 dans jour.
        # En revanche, s’il y a plus d’arguments que ceux transmis,
        # le premier en plus sera le PrawnView en cours de gravure (le
        # pdf). Par exemple :
        #     def %{meth}(pdf, annee, jour)
        # S’il y a deux arguments en plus, le premier sera toujours le
        # pdf, mais le second sera le contexte, une table définissant
        # :book (le livre en cours de gravure) et :paragraph (le paragraphe
        # courant, donc le PFBCode appelant la méthode)
        #     def %{meth}(pdf, context, annee, jour)

        def %{meth}(pdf, context, args...)
          # ... traitement ...
        end
      end

      Ou :

      Si le texte ne doit pas retourner de code à écrire :

      # in ./prawn4book.rb
      module Prawn4book
        def self.%{meth}(...)
          # ... traitement ...
        end
      end

      ERR
  },

  # --- Modules externes (helpers, formaters, etc.) ---

  modules: {

    runtime_error: <<~ERR,
      Une erreur s'est produite en interprétant le code :
        %{code}
      (%{lieu})
      Erreur : %{err_msg}
      Backtrace
      ---------
      %{backtrace}
      ERR
  },

  user_modules: {
    runtime_error: <<~ERR,
      Une erreur s'est produite dans la méthode %{meth} d’un de vos
      modules propres (%{module}) :
        %{err}
      Contexte:
        %{context}
      Trace:
        %{trace}
      ERR
    unknown_objet: <<~ERR,
      Impossible d'exécuter '%{m}' car l'objet (ou la classe) défini 
      par '%{o}' est inconnu de nos services…
      Essayé en tant que :
        Prawn4book::PdfBook::PFBCode.%{o}
        Prawn4book::PdfBook::AnyParagraph.%{o}
        Prawn4book.%{o}
        PrawnHelpersMethods.%{o}
        Class %{o}
      ERR
    unknown_method: <<~ERR,
      Impossible d'exécuter '%{c}' car la méthode #%{m} est
      inconnue de %{o}.
      Implémenter %{o}#%{m} si nécessaire.
      ERR
    wrong_arguments_count: <<~ERR,
      La méthode '%{c}' attend %{n} arguments. C'est un nombre
      impossible. Elle devrait recevoir entre 0 et %{max} arguments.
      ERR
  },
  
  # --- COMMANDES ---

  commands: {
    open: {
      dont_know_how_to: 'Je ne sais pas comment ouvrir %{ca}.'
    },
    calc: {
      dont_know_how_to: 'Je ne sais pas comment calculer %{ca}.'
    },
  },

  # --- Aide ---

  help: {
    unknown_assistant: 'Impossible de trouver un assistant ou une aide pour %s…',
  },

  # --- Pages ---

  pages: {

    unfound: <<~ERR,
      Le numéro de page %{num} est introuvable.
      Je rectifie le numéro en fonction du nombre de pages (%{nb}), mais 
      il faudra corriger le problème car les effets indésirables sont 
      imprévisibles.
      Backtrace: 
      %{bt}
      ERR

    # -- Page des crédits (Colophon) --
    credits: {
      notfit: <<~ERR,
        Les crédits dépassent la page d’impression. Je réduis la taille
        des polices pour obtenir un résultat satisfaisant.
        ERR

      unable_to_reduce: <<~ERR,
        Je ne parviens pas à réduire la taille de la page des crédits, même
        en réduisant la fonte (elle passe en dessous des 5, ce qui la rend 
        invisible).
        Solution : il faut réduire le nombre d’informations, et particuliè-
        rement les informations sur plusieurs lignes (comme les adresses).
        ERR
      disposition_unknown: <<~ERR,
        La disposition '%{dispo}' pour le colophon (page des crédits)
        est inconnue. 
        Elle doit valoir 'distribute' (centré verticalement), 'top' (aligné
        en haut) ou 'bottom' (aligné en bas).
        ERR
    },
  
  }, #/ pages:

  # --- Texte du livre ---

  paragraph: {
    print: {
      unknown_error: <<~ERR,
        Problème avec le Prawn4book::NTextParagraph contenant le texte :
        %{text}
        Problème : %{err}
        %{backtrace}
        ERR
    },

    unfound_puce_image: <<~ERR,
      Impossible de trouver l'image de la puce avec le chemin absolu
      ou relatif : %{path}
      ERR

    bad_ruby_code: <<~ERR,
      Impossible d'évaluer le code ruby :
      <<<
        %{code}
      >>>
      Il a produit l'erreur :
       %{err}
      Quatre dernières traces :
        %{trace}
      ERR

    formate: {
      unknown_method: <<~ERR,
        La méthode #%{mname} est inconnue de l'instance paragraphe.
        Pour fixer ce problème, vous pouvez l'implémenter dans le fichier
        helpers.rb :

        # in ./helpers.rb
        module Prawn4book
          class PdfBook::NTextParagraph # Ou AnyParagraph pour tous
          def %{mname}(str)
            ... Traitement de +str+ ... 
          end
        end
        end
        ERR
    },

    unable_to_instantiate_with_type: <<~ERR,
      Impossible de formater le paragraphe :
      string: %{s} 
      index: %{i}
      options: %{opts}
      Erreur: %{e}
      Ligne: %{ln}
      ERR

    note_undefined: <<~ERR,
      Note de page indéfinie. Une marque de note appelée a été placée,
      (de numéro #%{last_mark}) mais sa définition n’a pas été posée
      (la dernière définition porte le numéro #%{last_def}) comme dans 
      le code exemple ci-dessous.

          Un texte avec un appel de note^^ qui devra être 
          défini plus loin pour savoir à quoi fait référence
          la note en question. On peut en avoir une deuxième^^
          avec la même marque.
          ^^ La note doit être définie de cette manière.
          ^^ La définition de la deuxième marque, car ça va 
          toujours dans l’ordre, quand le numéro n’est pas 
          explicitement donné.
      ERR
  },

  multicolumns: {
    extra_segment_unresolved: <<~EOT,
    Dans la multicolonne de %s colonnes commençant par…
    <<< %s… >>>
    … il reste %s segment(s) de textes qui n’ont pas pu être traité, malgré
    tous nos efforts. 
    Essayez peut-être d’ajouter un item vide (avec une espace insécable)
    pour palier le problème.
    EOT
    
    extra_segment_resolved: <<~EOT,
    Dans la multicolonne de %s colonnes commençant par…
    <<< %s… >>>
    … j’ai pu remettre le segment qui restait non gravé, mais le
    résultat sera peut-être imparfait (avec une dernière colonne plus
    longue que les précédentes).
    Le problème pourrait se corriger de soi-même avec des éléments 
    supplémentaires.
    EOT
  },
  
  textfile: {
    unfound_text_file: <<~EOT,
      Le fichier texte définit par %{p} 
      est introuvable…
      EOT
  },
  unknown_pfbcode:  <<~ERR,
    Je ne sais pas traiter le code '%{code}' (page %{page})…

    Peut-être doit-il être traité comme une méthode d'instance dans le
    module PrawnHelpersMethods dans le helpers.rb du livre ou de la collection.

    # Dans ./helpers.rb
    module PrawnHelpersMethods
      def %{code}
        # ... 
      end
    end

    ERR

  # --- TABLES --- #

  table: {
    can_not_fit: <<~ERR
      Problème de dimension avec la table (elle est certainement trop grande
      ou la taille des colonnes produisent une taille trop grande.
      Peut-être aussi le contenu des cellules est-il trop grand par rapport à
      leur taille.
      Erreur soulevée : %{err}
      ERR
  },

  # --- Recette en général --- #

  recipe: {

    missing_even_default_data: <<~ERR,
      Des données sont manquantes dans la recette :
          %{data}
      Ces données devraient pourtant être définies car des valeurs par
      défaut sont fournies. Vous avez dû toucher le fichier de recette par 
      défaut… Vous n'avez plus qu'à recharger l'application…
      ERR
    main_folder_not_defined: "La propriété :main_folder n'est pas définie, dans la recette…",

    # -- Recette > Données du livre --

    book_data: {
      require_title: <<~ERR,
        Pour pouvoir faire la page de titre, le TITRE DU LIVRE est requis.
        L'ajouter dans la recette (recipe.yaml) à l'aide de :

        #<book_data>
        book_data:
          title: "<le titre du livre>"
        #</book_data>
        ERR
      require_author: <<~ERR,
        Pour pouvoir faire la page de titre, l'AUTEUR DU LIVRE est requis.
        L'ajouter dans la recette (recipe.yaml) à l'aide de :

        #<book_data>
        book_data:
          author: "<Prénom NOM>"
        #</book_data>

        S'il y plusieurs auteurs, les séparer par une virgule et bien
        mettre leur nom en capitales. Par exemple :

          author: Philippe PERRET, Marion MICHEL

        Clés alternatives : auteur, auteurs, authors
        ERR
      unfound_logo: <<~ERR,
        Impossible de faire la page de titre, le logo est introuvable
        à l'adresse %{path}
        ERR
    },
    
    # -- Recette > Page infos --

    credits_page: {
      require_info: <<~ERR,
        Je ne suis pas en mesure de produire la page d'information de fin
        de livre, il me manque ces informations : 
        %{missing_infos}
        
        Vous devez les renseigner dans la recette du livre ou de la 
        collection :

        %{missing_keys}
        
        ERR
      bad_font_definition: <<~ERR,
        La définition des fontes, pour la page des crédits est mauvaise.
        Je n'arrive pas à calculer les emplacements et les positions.
        Fonte du %{t} : %{f}
        Options : %{o}
        Height obtenu : %{h} (doit être un flottant)
        ERR
    },

  }, #/ :recipe

  # --- Fontes ---

  fonts: {
    invalid_font_params: "Les paramètres pour #font sont invalides (soit les paramètres traditionnels — font-name, {font-params} — soit un Hash contenant {:name, :size, :style}, soit une instance Prawn4book::Fonte).",
    font_argument_nil: "Les paramètres de #font doivent être définis (font-name et font-properties, Hash ou Prawn4book::Fonte)",
    leading_must_be_calculated: <<~EOT,
      Il est impératif de calculer le leading d'une police avant de l'appeler
      sans argument.
      Il faut calculer le leading de la police :
      '%{name}' (%{pms})
      On le calcule à l'aide de <fonte>.leading(<pdf>,<line_height>).
      EOT
    require_property: <<~EOT,
      La propriété :%{prop} est requise dans la définition d'une fonte. Elle
      doit être ajoutée à la donnée : %{dfont}
      EOT
    bad_formatted_data: <<~EOT,
      Les données %{bad} pour changer de fonte 
      sont invalides : %{err}

      Il faut utiliser :
        (( font(name:"<nom>", size:<taille>, style: :<style>) ))

      On peut aussi éventuellement ajouter :hname pour faire référence
      à la police plus tard :

        (( font(..., hname: 'police12') ))
        ...
        ...
        (( font('police12') ))

      EOT
    bad_formatted_color: <<~EOT,
      La couleur %{color} est mal définie. 
      Soit elle devrait être au format hexadécimal RRVVBB où R est la 
      valeur hexa de rouge, V est la valeur hexa de vert et B est la 
      valeur hexa de bleu.
      Soit elle devrait être au format CMJN, c’est-à-dire une liste
      [C, M, J, N] où C est la valeur 0-126 de Cyan, M est la valeur
      0-126 de Magenta, J est la valeur 0-126 de Jaune et N est la
      valeur 0-126 de Noir.
      EOT

    line_height_smaller_than_default_size: <<~EOT,
      La hauteur de ligne ’line_height’ défini dans le recette à 
      %{lh} devrait être plus grande ou au moins égale à la taille de
      la police par défaut qui est de %{fs}.
      Mettez un ’line_height’ plus grand dans la recette, par exemple
      à %{glh}.
      EOT
  },

  # --- Table des matières ---

  toc: {
    problem_with_title: <<~EOR,
      Un problème est survenu lors de :
        %{context}
      Erreur rencontrée :
        %{error}
      À titre indicatif, les données recette sont :
        %{data}
      (cf. plus bas le contexte)
      EOR

    cannotfit_error: <<~ERR,
      Un problème de "remplissage" est survenu dans la table des matière, 
      c’est-à-dire que le texte ne peut être mis dans le bloc défini.
      Cette erreur survient par exemple lorsque l’on veut appliquer une
      taille de numéro de page supérieure à la taille du titre.
      Pour le corriger, essayer de modifier la fonte du numéro de page pour
      qu’elle soit égale ou inférieure à la taille des titres de niveau
      correspondant.
      ERR
    write_on_non_empty_page: <<~ERR,
      On se retrouve à écrire la table des matières sur une page qui n’est
      pas vide (la page %{num}). Il faut ajouter des pages dédiées à la 
      table des matières soit manuellement (expliciement dans le livre avec
      des « (( new_page )) ») soit dans la recette en réglant la valeur de
      « table_of_content: pages_count: » (en donnant à :pages_count une
      valeur paire pour ne pas décaler tout le livre).
      ERR

    must_add_even_pages_count: <<~ERR,
      Le nombre de pages dédiées à la table des matières (ici %{num} défini
      par la valeur « table_of_content: pages_count: » de la recette) doit
      être supérieure à zéro ou paire pour ne pas bousculer toute la mise en
      page (c’est-à-dire pour conserver les belles-pages à leur place et les
      fausses-pages).

      J’ajoute 1 pour obtenir un nombre paire mais il serait bon de modifier
      cette valeur pour éviter ce message.
      ERR
  },

  # --- Maison d'éditions ---

    publisher: {
      logo_unfound: "Logo introuvable à l'adresse '%s'",
      logo_not_same_extname: "Les deux images doivent avoir la même extension.", 
    },

  # --- Bibliographie --- #

  biblio: {
    unfound: 'Impossible de trouver la bibliographie d’identifiant %{bib}',
    custom_format_method_error: <<~ERR,
      Une erreur a été levée par votre méthode BibliographyFormaterModule#%{method}
      (qui doit être définie dans le module formater.rb)
      Erreur : %{err}::%{err_class}

      Merci de bien vouloir corriger cette erreur et de relancer la fabrication
      du livre.

      module BibliographyFormaterModule

        def %{method}(bibitem)
          ### ERREUR ###
          ### %{err} ###
        end

      end
      ERR
    instanciation_requires_book: "Une livre est requis, pour l'instanciation d'une bibliographie.",
    data_undefined: "La recette du livre ou de la collection ne définit aucun donnée bibliographique (consulter le mode d'emploi pour remédier au problème ou lancer l'assistant bibliographies).",
    biblios_malformed: <<~ERR,
      La recette bibliographie devrait être une table (un item par 
      type d'élément).
      ERR
    formater_required: "Un fichier 'formater.rb' devrait exister dans '%s' pour définir la mise en forme à adopter pour la bibliographie.",
    formater_malformed: "Le fichier formater.rb devrait définir le module 'BibliographyFormaterModule'\n(bien vérifier le nom, avec un pluriel)…",
    biblio_malformed: "La donnée recette de la bibliographie '%{tag}' est malformée : ",
    malformation: {
      title_undefined: <<~ERR,
        %{prefix}
        Le titre de la bibliographie doit absolument être défini dans
        la recette de la collection ou du livre en particulier.

        # in recipe.yaml / recipe_collection.yaml
        #<bibliographies>
        bibliographies:
          %{tag}:
            # ...
            title:
        #</bibliographies>

        ERR
      path_undefined: <<~ERR,
        %{prefix}
        Le chemin d'accès au données de la bibliographie %{tag} doit 
        être défini et non nil.
        Ajouter cette information au fichier recette de la collection ou du
        livre :

        # in recipe.yaml / recipe_collection.yaml
        #<bibliographies>
        bibliographies:
          %{tag}:
            # ...
            path:
        #</bibliographies>
        ERR
      path_unfound: <<~ERR,
        %{prefix}
        Les données des fiches bibliographiques est introuvable…
        %{path} a été cherché en tant que :
          - chemin absolu,
          - chemin relatif dans le dossier du livre,
          - chemin relatif dans le dossier de la collection si c’est une
            collection.
        ERR
    },
    bad_format_bibitem: "Le format '%s' est un format de données bibliographique invalide.",
    biblio_method_required: "Le module BibliographyFormaterModule dans formater.rb doit définir la méthode 'biblio_%s'…",
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette…",
    biblio_item_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
    
    bibitem: {
      undefined: <<~ERR,
        L'item de bibliographie "%{id}" est introuvable (ni en fichier
        .txt, ni en fichier .yaml ni en fichier .json).
        Il doit être créé.
        ERR
      requires_title: <<~ERR,
        Problème avec l'élément bibliographique  `%{id}' 
        de la bibliothèque : `%{tag}'
        Cet élément bibliographique requiert obligatoirement un titre défini par 
        la clé `:title' ou par la clé définie par :main_key dans la définition de 
        la bibliographie dans le livre de recette.
        ERR
      bad_arguments_count: <<~ERR,
        Dans le module BibliographyFormaterModule du fichier formater.rb,
        la méthode `%{method_name}' ne reçoit pas le bon nombre d'arguments.
        Une méthode de formatage d'un élément de bibliographie doit toujours
        recevoir : <item bibligraphique>, <context>, <valeur fournie>

        C'est-à-dire : 

        # in ./formater.rb
        module BibliographyFormaterModule
          def %{method_name}(bibitem, context, actual)
            # ...
          end
        end
        ERR
      bad_arguments_count_biblio: <<~ERR,
        Dans le module BibliographyFormaterModule du fichier formater.rb,
        la méthode `%{method_name}' ne reçoit pas le bon nombre d'arguments.
        Une méthode de formatage d'un élément de bibliographie dans la biblio
        elle-même doit toujours recevoir : <item bibligraphique> et <pdf>.
        Votre méthode reçoit %{nb_args}.

        C'est-à-dire : 

        # in ./formater.rb
        module BibliographyFormaterModule
          def %{method_name}(bibitem, pdf)
            # ...
          end
        end
        ERR

    },
    title_already_exists: "Ce titre existe déjà.",
    tag_already_exists: "Ce tag est déjà utilisé. Choisissez-en un autre.",
    bad_tag: 'Tag non conforme. Il ne devrait contenir que des lettres minuscules.',
    not_an_existing_file: "Le path fourni ne renvoie ni à un fichier ni à un dossier (en valeur absolue ou relative).",
    warn_end_with_s: "Ce tag finit par 's'. En général, les tags sont au singulier.\nMais si vous êtes sûr de vous, pas de problème.",
    # - cross-referenre -
    uncrossable: "Le livre %s n'est pas “croisable”. ",
    crossable_requires_refs_path: "Un livre “croisable” nécessite de définir le chemin d'accès à son dossier ou son fichier de références (:refs_path dans sa fiche).",
    book_requireds_building_for_refs:"Il faut construire le livre pour obtenir ses références",
    crossable_refs_path_unfound: "Le chemin d'accès au fichier de référence du livre est introuvable (in %s)",
    crossable_requires_recipe_or_refsfile: "Un livre ”croisable” nécessite un fichier recette (quand c'est un prawn-book) ou un fichier références 'references.yaml' (quand c'est un livre quelconque).",
  }, #/biblio

  # --- Index Personnalisés ---

  index: {

    invalid: <<~ERR,
      L’index personnalisé d’identifiant '%{id}' est invalide :
      %{err}
      ERR

    missing_item_treatment_method: <<~ERR,
      Aucune méthode de traitement des items d’index personnalisé %{id} 
      n’est implémenté.
      Pour y remédier, dans un fichier `parser.rb’ ou `prawn4book.rb’,
      implémenter la méthode #index_%{id} dans un module CustomIndexModule:

      module CustomIndexModule

        def index_%{id}(id, output, context)
          output ||= id
          # ... traitement ...
          #
          # Trois retours possibles :
          # 1) le texte simple à écrire dans la page
          # return output # à écrire dans le livre
          # 2) l’identifiant (transformé) et le texte à écrire
          # return [new_id, output]
          # 3) la table des informations à enregistrer dans l’occurrence
          return {id: }
        end

      end

      Notez que si "%{id}(" n’est pas un index mais un mot suivi d’une
      parenthèse collée, alors il faut échapper la parenthèse pour que
      le mot ne soit pas pris pour un index. Écrivez "%{id}\\(" au
      lieu de "%{id}(".
      ERR

    bad_params_count_in_item_treatment_method: <<~ERR,
      La méthode #index_%{id} devrait recevoir trois paramètres :

      module CustomIndexModule

        # @param id [String]
        #     Identifiant de l’item de l’index
        #
        # @param output [String]
        #     Optionnellement, le texte à écrire dans le livre. S’il
        #     n’est pas défini, c’est +id+ qui sera utilisé.
        #
        # @param context [Hash]
        #     Table contenant :pdf (le Prawn::PdfView en cours de
        #     construction), :paragraph (l’instance du paragraphe qui
        #     contient l’item d’index). On peut s’en servir, notamment
        #     pour récupérer le numéro de paragraphe ou de page.
        #
        def index_%{id}(id, output, context)
          # ...
        end

      end

      ERR

    missing_print_method: <<~ERR,
      La méthode d’impression de l’index personnalisé %{id} doit 
      être implémentée.

      module CustomIndexModule

      end
      ERR

    bad_params_count_in_print_method: <<~ERR,
      La méthode d’impression de l’index personnalisé %{id} 
      (#print_index_%{id}) devrait recevoir un paramètre, 
      le document en construction (pdf).
      ERR
  },

  # --- Références --- #

  references: {
    target_already_exists: <<~ERR,
      La référence '<-(%{id})' existe déjà dans le livre…
      (à la page %{page})
      ERR
    target_undefined: <<~ERR.strip,
      Cible '<-(%{id})' introuvable…
      ERR
    cross_book_undefined: "Le livre d'identifiant '%s' n'est pas défini pour les références croisées…",
    cross_path_undefined: "Aucune path n'est définie pour le livre '%s'…",
    cross_book_unfound: "Le livre d'identifiant '%s' est introuvable au path '%s'…",
    cross_book_data_unfound: "Le livre '%s' (%s) ne possède pas de fichier 'references.yaml' définissant ses références…",
    cross_ref_unfound: "La référence '%s' dans le livre identifié '%s' est inconnue.",
    bib_livre_not_defined: "La bibliographie 'livre' n'est pas définie. Consultez le manuel pour plus d'information.",
    book_undefined_in_bib_livre: "Le livre d'identifiant '%s' n'est pas défini dans la bibliographie 'livre'.",
  
    no_lien_seul_on_line: <<~ERR,
      Un « appel » à une cible de référence ne doit jamais se trouver
      seul sur une ligne. Mettre le texte (( %{code} )) à un meilleur endroit.
      ERR

    no_num_parag_in_pfbcode: <<~ERR,
      En mode de pagination ’%{pagin}’ on ne peut pas avoir de ligne 
      de code PFB (entre doubles parenthèses) contenant une définition de
      cible de référence. Une telle ligne ne possède pas de numéro de 
      paragraphe et elle n’existe donc pas physiquement dans le livre).
      
      Solution : définir la cible ’%{cible}’ dans le texte d’un 
      vrai paragraphe, avant ou après.
      ERR
  }, #/:references

  abbreviations: {

    two_definitions: <<~ERR,
      Deux définitions différentes existent pour l’abréviation ’%{abbr}’
      à la page %{page} du livre :
      %{premiere} ≠ %{seconde}
      Il faut en choisir une seule.
      ERR
  },

  images: {
    unfound: <<~ERR,
      L'image '%{filename}' est introuvable (ni dans le dossier de la 
      collection si le livre appartient à une collection, ni dans le dossier 
      'images' du livre, ni en tant que path relatif ou absolu).
      ERR
    logo_page_title_unfound: <<~ERR,
      L’image pour le logo de la page de titre, à l’adresse :
      %{path}
      est introuvable.
      ERR

    passage_sous_page: <<~ERR, 
      L’image flottante '%{img}' (page #%{page}) qui doit apparaitre
      aux côtés du texte « %{text} »
      est trop basse, elle passe sous la page.
      Il faut soit la mettre avec un texte plus haut, soit la mettre avec un
      texte de la page suivante. Je ne peux pas prendre cette décision pour
      vous.
      ERR

    floating_text_under_zero: <<~ERR,
      Problème de texte passant sous le zéro (sans box 3 à faire) avec
      l’image flottante '%{img}' (page #%{page}). Le texte est le suivant :
      %{text}
      ERR

    floating_image_too_big: <<~ERR,
      L’image flottante '%{img}' (page #%{page}) prend trop de place,
      il n’en reste pas assez pour le texte (erreur Prawn::Errors::CannotFit
      générée).
      Peut-être avez-vous simplement oublié de définir le 'width' de cette 
      image flottante ? (par exemple 'width:"50%"')
      ERR

    floating_image_with_no_text: <<~ERR,
      L’image flottante '%{img}' (page #%{page}) n’a aucun texte à côté
      elle.
      Il faut soit retirer des lignes au-dessus (si lines_before est défini
      et supérieur à 0), soit ajouter des "!" devant un ou deux paragraphes
      supplémentaires avant l’image pour les enrouler autour de cette image.
      ERR
  },
}
end #/module Prawn4book
