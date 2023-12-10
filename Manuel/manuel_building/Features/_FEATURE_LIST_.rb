module Prawn4book

  # TOUT = nil
  TOUT = true

  TOUT_RECETTE = TOUT || nil
  # TOUT_RECETTE = TOUT || true

  #
  # @note
  #   Avec ’##’ devant, ce sont les fonctionnalités qui étaient "en
  #   route avant le changement du traitement de la recette"
  # 
  FEATURE_LIST = [

    # -- Généralités --
    'generalites/grand_titre',
    'generalites/forces_de_prawn',
    TOUT && 'generalites/deux_fichiers_de_base',
    TOUT && 'generalites/doubles_parentheses',

    #---Recette---#
    'recette/grand_titre',
    TOUT_RECETTE && 'recette/recette_livre',
    TOUT_RECETTE && 'recette/recette_collection',
    TOUT_RECETTE && 'recette/book_data',
    TOUT_RECETTE && 'definition_marges',
    TOUT_RECETTE && 'definir_format_livre',
    TOUT_RECETTE && 'recette/definition_fonte',
    TOUT_RECETTE && 'recette/publisher',

    #---Contenu_textuel_(intro)---#
    # 'texte/grand_titre',
    # 'format_markdown_du_texte',

    #---PagesSpeciales---#
    # 'pages_speciales/grand_titre',
    # 'pages_speciales/pages_speciales',
    # 'pages_speciales/table_des_matieres',
    # 'pages_speciales/credits_page',
    # 'pages_speciales/title_page',

    #---Entetes/Pied-de-page---#
    # 'header_footer/grand_titre',
    # 'header_footer/par_defaut',
    # 'header_footer/exemple_complexe',

    #__Texte_Details___#
    # 'texte_detail/grand_titre',

    #---Puces---#
    # 'puces/puces',
    # 'puces/losange',
    # 'puces/black_losange',
    # 'puces/square',
    # 'puces/black_square',
    # 'puces/bullet',
    # 'puces/black_bullet',
    # 'puces/finger',
    # 'puces/black_finger',
    # 'puces/big_hyphen',
    # 'puces/custom_image',

    #-Images-#
    'images/grand_titre',
    'images/inserer_images',
    'images/images_flottantes',
    'images/format_legende',
    
    # 'references/cross_references'
    # 'hyperlinks',
    # 'notes_de_page',
    # 'notes_de_page_formatage',
    # 'tables/tables',

    #---Bibliographies---#
    'bibliographies/grand_titre',
    'bibliographies/introduction',
    'bibliographies/customisation',

    #---Changements_comportements_par_default---#
    # 'change_fonte_for_next_paragraph',
    # 'alignement_du_texte',

    #---Mode_Expert---#
    'expert/grand_titre',
    'expert/mode_expert',
    # 'expert/contexte_erreurs',
    # 'expert/injection_code',
    'expert/evaluation_code_ruby',
    'expert/bibliographies',

    #---Annexe---#
    # 'annexe/grand_titre',
    # 'annexe/package_sublime_text',
    # 'annexe/markdown_all_marks',
    TOUT && 'annexe/format_yaml',
    # 'annexe/font_string',
    # 'annexe/definition_couleur',
    # 'images/rogner_svg',
    # 'annexe/synopsis_creation',
    # '_liste_exhaustive_features_',

  ].compact

=begin
      titres/titres
      pagination
      pagination/numeroter_pages_vierges
      pagination/aspect_numero
      pagination/numerotation
      align_on_reference_lines
      pages_initiales
      numerotation_des_paragraphes
      definir_police_par_defaut
      pseudo_format_markdown
      guils_et_apos
      les_fontes
      book_in_collection
      gestion_tirets_conditionnels
      veuves_orphelines_et_lignes_de_voleur
      afficher_grille_reference_et_marges
      references_autres_livres
      placement_sur_ligne_quelconque
      change_margins_on_the_fly
      export_livre_numerique
      export_text

      annexe/couleur_hexadecimale

=end
 
end
