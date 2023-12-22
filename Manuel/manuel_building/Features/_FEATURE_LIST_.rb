module Prawn4book

  # TOUT = true # ou nil, attention ! (pas false)
  TOUT = nil

  # TOUT_RECETTE = TOUT || nil
  TOUT_RECETTE = TOUT || true
  # 
  # TOUT_DEF_MINI = TOUT || nil
  TOUT_DEF_MINI = TOUT || true

  TOUT_PAGES_SPECS = TOUT || nil
  # TOUT_PAGES_SPECS = TOUT || true

  # TOUT_COMPORTEMENT = TOUT || nil
  TOUT_COMPORTEMENT = TOUT || true

  TOUT_BOOK_FORMAT = TOUT || nil
  # TOUT_BOOK_FORMAT = TOUT || true

  TOUT_HEADFOOT = TOUT || nil
  # TOUT_HEADFOOT = TOUT || true
  # 
  TOUT_PUCES = TOUT || nil
  # TOUT_PUCES = TOUT || true
  # 
  TOUT_IMAGE = TOUT || nil
  # TOUT_IMAGE = TOUT || true
  # 
  # TOUT_EXPERT = TOUT || nil
  TOUT_EXPERT = TOUT || true

  TOUT_TUTORIEL = TOUT || nil
  # TOUT_TUTORIEL = TOUT || true

  # TOUT_AIDE = TOUT || nil
  TOUT_AIDE = TOUT || true

  TOUT_REFS = TOUT || nil
  # TOUT_REFS = TOUT || true

  TOUT_BIBLIO = TOUT || nil
  # TOUT_BIBLIO = TOUT || true

  # FORMAT_PRECIS = TOUT || nil # format livre/page
  FORMAT_PRECIS = TOUT || true

  # TOUT_ANNEXE = TOUT || nil
  TOUT_ANNEXE = TOUT || true

  # @note
  #   Avec ’##’ devant, ce sont les fonctionnalités qui étaient "en
  #   route avant le changement du traitement de la recette"
  # 
  FEATURE_LIST = [

    # -- Généralités --
    'generalites/grand_titre',
    'generalites/quick_overlook',
    'generalites/forces_de_prawn',
    TOUT && 'generalites/deux_fichiers_de_base',
    TOUT && 'generalites/doubles_parentheses',

    #--- Définitions minimales ---#
    TOUT_DEF_MINI && 'minimales/grand_titre', # Long texte

    #---Recette---#
    'recette/grand_titre',
    TOUT_RECETTE && 'recette/recette_livre',
    TOUT_RECETTE && 'recette/recette_collection',
    TOUT_RECETTE && 'recette/book_data',
    TOUT_RECETTE && 'definir_format_livre',
    TOUT_RECETTE && 'recette/definition_fontes',
    TOUT_RECETTE && 'recette/fonte_par_defaut',
    TOUT_RECETTE && 'recette/publisher',

    #---Contenu_textuel_(intro)---#
    TOUT && 'texte/grand_titre',
    TOUT && 'format_markdown_du_texte',

    #--- Comportement de Prawn-for-book ---#
    TOUT_COMPORTEMENT && 'comportement/grand_titre',
    TOUT_COMPORTEMENT && 'comportement/align_on_reference_lines',
    # Ajouter :
    #  - colonnes multiples
    #  - typographies (espaces avant ponctuation doubles, guillemets)

    #---PagesSpeciales---#
    TOUT_PAGES_SPECS && 'pages_speciales/grand_titre',
    TOUT_PAGES_SPECS && 'pages_speciales/pages_speciales',
    TOUT_PAGES_SPECS && 'pages_speciales/table_des_matieres',
    TOUT_PAGES_SPECS && 'pages_speciales/credits_page',
    TOUT_PAGES_SPECS && 'pages_speciales/title_page',
    TOUT_PAGES_SPECS && 'pages_speciales/faux_titre',
    TOUT_PAGES_SPECS && 'pages_speciales/index_page',

    #---Entetes/Pied-de-page---#
    TOUT_HEADFOOT && 'header_footer/grand_titre',
    TOUT_HEADFOOT && 'header_footer/par_defaut',
    TOUT_HEADFOOT && 'header_footer/exemple_complexe',

    #---Aides conception---#
    TOUT_AIDE && 'aide/grand_titre',
    TOUT_AIDE && 'aide/manuel_et_autres_aides',
    TOUT_AIDE && 'aide/snippets',
    TOUT_AIDE && 'aide/assistants',
    TOUT_AIDE && 'aide/erreurs_et_notices',
    TOUT_AIDE && 'aide/afficher_grille_reference_et_marges',
    TOUT_AIDE && 'aide/exporter_texte',

    #__Texte_Details___#
    TOUT && 'texte_detail/grand_titre',
    TOUT && 'texte_detail/indentation',
    TOUT && 'texte_detail/hauteur_de_ligne',

    #---Puces---#
    TOUT_PUCES && 'puces/puces',
    TOUT_PUCES && 'puces/losange',
    TOUT_PUCES && 'puces/black_losange',
    TOUT_PUCES && 'puces/square',
    TOUT_PUCES && 'puces/black_square',
    TOUT_PUCES && 'puces/bullet',
    TOUT_PUCES && 'puces/black_bullet',
    TOUT_PUCES && 'puces/finger',
    TOUT_PUCES && 'puces/black_finger',
    TOUT_PUCES && 'puces/big_hyphen',
    TOUT_PUCES && 'puces/custom_image',

    #-Images-#
    TOUT_IMAGE && 'images/grand_titre',
    TOUT_IMAGE && 'images/inserer_images',
    TOUT_IMAGE && 'images/images_flottantes',
    TOUT_IMAGE && 'images/format_legende',
    
    TOUT_REFS && 'references/cross_references',
    TOUT_REFS && 'hyperlinks',
    TOUT_REFS && 'notes_de_page',
    TOUT_REFS && 'notes_de_page_formatage',
    TOUT_REFS && 'tables/tables',

    #---Bibliographies---#
    TOUT_BIBLIO && 'bibliographies/grand_titre',
    TOUT_BIBLIO && 'bibliographies/introduction',
    TOUT_BIBLIO && 'bibliographies/customisation',

    #---Format précis livre et pages ---
    # 
    FORMAT_PRECIS && 'format_precis/grand_titre',
    FORMAT_PRECIS && 'format_precis/definition_marges',
    FORMAT_PRECIS && 'format_precis/double_colonnes',

    #---Changements_comportements_par_default---#
    # 'change_fonte_for_next_paragraph',
    # 'alignement_du_texte',

    #---Mode_Expert---#
    TOUT_EXPERT && 'expert/grand_titre',
    TOUT_EXPERT && 'expert/mode_expert',
    TOUT_EXPERT && 'expert/contexte_erreurs',
    TOUT_EXPERT && 'expert/injection_code',
    TOUT_EXPERT && 'expert/evaluation_code_ruby',
    TOUT_EXPERT && 'expert/bibliographies',
    TOUT_EXPERT && 'expert/multi_colonnes',
    TOUT_EXPERT && 'expert/formaters',

    #---Tutoriel de prise en main---#
    # Note : en faire plutôt un livre séparé
    TOUT_TUTORIEL && 'tutoriel/grand_titre',
    TOUT_TUTORIEL && 'tutoriel/installation',

    #---Annexe---#
    TOUT_ANNEXE && 'annexe/grand_titre',
    TOUT_ANNEXE && 'annexe/reconstruction_manuel',
    TOUT_ANNEXE && 'annexe/package_sublime_text',
    TOUT_ANNEXE && 'annexe/markdown_all_marks',
    TOUT_ANNEXE && 'annexe/format_yaml',
    TOUT_ANNEXE && 'annexe/font_string',
    TOUT_ANNEXE && 'annexe/definition_couleur',
    TOUT_ANNEXE && 'images/rogner_svg',
    TOUT_ANNEXE && 'annexe/synopsis_creation',
    TOUT_ANNEXE && 'annexe/installation_application',
    TOUT_ANNEXE && 'annexe/constantes',
    TOUT_ANNEXE && 'annexe/_liste_exhaustive_features_',

  ].compact

=begin
      titres/titres
      pagination
      pagination/numeroter_pages_vierges
      pagination/aspect_numero
      pagination/numerotation
      
      pages_initiales
      numerotation_des_paragraphes
      definir_police_par_defaut
      pseudo_format_markdown
      guils_et_apos
      les_fontes
      book_in_collection
      gestion_tirets_conditionnels
      veuves_orphelines_et_lignes_de_voleur
      references_autres_livres
      placement_sur_ligne_quelconque
      change_margins_on_the_fly
      export_livre_numerique

      annexe/couleur_hexadecimale

=end
 
end
