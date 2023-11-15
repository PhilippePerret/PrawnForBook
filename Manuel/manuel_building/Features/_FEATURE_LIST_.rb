module Prawn4book

  #
  # @note
  #   Avec ’##’ devant, ce sont les fonctionnalités qui étaient "en
  #   route avant le changement du traitement de la recette"
  # 
  FEATURE_LIST = %w{

      forces_de_prawn
      #deux_fichiers_de_base
      recette/juste_titre
      recette/recette_livre
      recette/recette_collection
      definition_fonte
      format_markdown_du_texte
      #---Puces---
      puces/puces
      puces/losange
      ##puces/black_losange
      ##puces/square
      ##puces/black_square
      ##puces/bullet
      ##puces/black_bullet
      ##puces/finger
      ##puces/black_finger
      ##puces/big_hyphen
      ##puces/custom_image
      ##image_inserer
      #cross_references
      #hyperlinks
      ##notes_de_page
      ##notes_de_page_formatage
      #tables/tables
      ###---PagesSpeciales---###
      #pages_speciales/pages_speciales
      #change_fonte_for_next_paragraph
      ###---Changements_comportements_par_default---###
      #alignement_du_texte
      ##---Mode_Expert---###
      #expert/mode_expert
      ##expert/contexte_erreurs
      ##expert/injection_code
      ###---Annexe---###
      ##annexe/annexe
      #annexe/markdown_all_marks
      annexe/format_yaml
      #image_rogner_svg
      #annexe/synopsis_creation
      #_liste_exhaustive_features_

  }
=begin
      definition_marges
      definir_format_livre
      titres/titres
      pagination
      pagination/numeroter_pages_vierges
      pagination/aspect_numero
      pagination/numerotation
      table_des_matieres
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
      evaluation_code_ruby
      change_margins_on_the_fly
      export_livre_numerique
      export_text

      annexe/couleur_hexadecimale

=end
 
end
