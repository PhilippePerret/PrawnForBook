module Prawn4book

ERRORS = {

  # --- Application --- #

  app: {
    require_a_book_or_collection: <<~ERR,
      Il faut se trouver dans un dossier de livre ou de collection.
      %{path}
      … ne contient pas de recette, donc ça ne peut pas être un dossier de 
      livre ou de collection.
      ERR
  },

  unfound_folder: "Le dossier '%s' est introuvable…",
  prawn_manual_unfound: "Le manuel de Prawn est introuvable. Il vous faut définir son chemin d'accès dans le fichier ./lib/constants.rb dans la constante PRAWN_MANUEL_PATH.",

  # --- Général --- #

  required_property: "La propriété %s est requise.",
  required_asterisk_properties: "Toutes les propriétés marquées d'un astérisque rouge sont requises.",
  
  invalid_data: "La donnée %s de value %s est invalide.", 

  # --- FABRICATION DU LIVRE ---

  building: {
    too_much_errors_on_properties: "Trop d'erreurs rencontrées sur la propriété '%s'. Réglez le problème avant de reprendre la fabrication du livre.",
    unfound_included_file: "Le fichier à inclure '%s' est introuvable (même dans le dossier du livre ou de la collection).",
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
      du fichier formater.rb du livre ou de la collection.
      # in ./formater.rb
      module ParserFormaterClass
        def %{meth}
          # ... définir le code ici
        end
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
        def %{meth}(...)
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
      Une erreur s'est produite dans un module propre :
        %{err}
      Contexte:
        %{context}
      Trace:
        %{trace}
      ERR
  },
  
  # --- Aide ---

  help: {
    unknown_assistant: 'Impossible de trouver un assistant ou une aide pour %s…',
  },

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
  
  unfound_text_file: "Le fichier texte %s est introuvable…",
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

    page_infos: {
      require_info: <<~ERR,
        Je ne suis pas en mesure de produire la page d'information de fin
        de livre, il me manque ces informations : 
        %{missing_infos}
        
        Vous devez les renseigner dans la recette du livre ou de la 
        collection :

        %{missing_keys}
        
        ERR
      bad_font_definition: <<~ERR,
        La définition des fontes, pour la page des infos (au moins) est
        mauvaise. Je n'arrive pas à calculer les emplacements et les 
        positions.
        ERR
    },

  }, #/ :recipe

  # --- Fontes ---

  fontes: {
    font_argument_nil: "Les paramètres de #font doivent être définis (font-name et font-properties, Hash ou Prawn4book::Fonte)",
    invalid_font_params: "Les paramètres pour #font sont invalides (soit les paramètres traditionnels — font-name, {font-params} — soit un Hash contenant {:name, :size, :style}, soit une instance Prawn4book::Fonte).",

  },

  # --- Maison d'éditions ---

    publishing: {
      logo_unfound: "Logo introuvable à l'adresse '%s'",
      logo_not_same_extname: "Les deux images doivent avoir la même extension.", 
    },

  # --- Bibliographie --- #

  biblio: {
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
      La recette bibliographie (:biblios) devrait être une table (un item par 
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
          biblios:
            %{tag}:
              # ...
              title:
        #</bibliographies>

        ERR
      path_undefined: <<~ERR,
        %{prefix}
        Le chemin d'accès au dossier des items doit être défini et non nil.
        Ajouter cette information au fichier recette de la collection ou du
        livre :

        # in recipe.yaml / recipe_collection.yaml
        #<bibliographies>
        bibliographies:
          biblios:
            %{tag}:
              # ...
              path:
        #</bibliographies>
        ERR
      path_unfound: <<~ERR,
        %{prefix}
        Le dossier des fiches bibliographiques est introuvable…
        (%{path}
          cherché en tant que chemin absolu ou relatif dans le dossier du 
          livre ou de la collection)
        ERR
    },
    bad_format_bibitem: "Le format '%s' est un format de données bibliographique invalide.",
    biblio_method_required: "Le module BibliographyFormaterModule dans formater.rb doit définir la méthode 'biblio_%s'…",
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette…",
    biblio_item_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
    
    bibitem: {
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

  # --- Références --- #

  references: {
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


}
end #/module Prawn4book
