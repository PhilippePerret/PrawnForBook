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
  },

  # --- FABRICATION DU LIVRE ---

  building: {
    require_pdf: "Il faut toujours le livre en construction pour pouvoir calculer le leading",
    require_line_height: "Un leading n'a de sens que par rapport à une hauteur de ligne.",
    too_much_errors_on_properties: "Trop d'erreurs rencontrées sur la propriété '%s'. Réglez le problème avant de reprendre la fabrication du livre.",
    unfound_included_file: "Le fichier à inclure '%s' est introuvable (même dans le dossier du livre ou de la collection).",
    book_not_built: "Malheureusement le book PDF ne semble pas avoir été produit.",
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
        def %{meth}(pdf, context, ...)
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
    }
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
        de livre, il me manque ces informations : 
        %{missing_infos}
        
        Vous devez les renseigner dans la recette du livre ou de la 
        collection :

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
      L’index personnalisé d’identifiant '%{id}' est invalide :
      %{err}
      ERR

    missing_item_treatment_method: <<~ERR,
      Aucune méthode de traitement des items de cet index personnalisé n’est
      implémenté.
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
      Un « appel » à une cible de référence ne doit jamais se trouver
      seul sur une ligne. Mettre le texte (( %{code} )) à un meilleur endroit.
      ERR
  }, #/:references

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
  },
}
end #/module Prawn4book
