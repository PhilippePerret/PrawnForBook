module Prawn4book

TERMS = {
  biblios: 'bibliographies',
  book_infos: 'informations sur le livre (dernières pages)',
  fonts: 'fontes',
  format: 'format',
  format_book: 'format (taille livre, marges, etc.)',
  headers_and_footers:'entêtes et pieds de page',
  other_default_values:'autres valeurs par défaut',
  publisher: 'éditeur/édition',
  recipe_options: 'options (pagination, etc.)',
  titles: 'titres',
  wanted_pages: 'pages désirée (faux-titre, infos, etc.)', 
}

PROMPTS = {

  # --- Généralités ---
  Folder: 'Dossier : ',
  finir: 'Finir', 

  by_default: "par défaut",
  By_default: "Par défaut",
  customised: "personnalisé",
  Customised: "Personnalisé",
  i_dont_know: "Je ne sais pas",
  devons_nous_en_creer_dautres: "Devons-nous en créer d'autres ?",

  # --- Application ---

  # --- Recette --- #
  recipe: {
    data_for: 'Données %s',
    wannado_define_all_values: "Voulez-vous définir tout de suite les valeurs ?",
    should_i_open_recipe_file: 'Dois-je ouvrir le fichier recette ?',
    should_i_add_code_to_recipe: 'Dois-je ajouter le code ci-dessus au fichier recette ?',
    wannado_define_titles: "Voulez définir les propriétés pour les titres ?",
    which_data_recipe_to_define: "Quelles données voulez-vous définir ?",
  }, # / :recipe

  # --- Fontes --- #
  fonts: {
    book_fonts_folder: 'Dossier fonts du livre',
    system_fonts_folder: 'Dossier des fontes système',
    system_fonts_sup_folder: 'Dossier des fontes système supplémentaires',
    user_fonts_folder: 'Dossier des fontes utilisateur',
    collection_fonts_folder: 'Dossier fonts de la collection',
    what_is_font_name: "Nom de police principal pour la fonte '%s' : ",
    which_style_for_font: "Quel style donner à cette fonte ?",
    choose_the_fonts: "Choisir les fonts…",
    wannado_choose_fonts: "Voulez-vous définir les fontes ?",

  }, #/ :fonts

  # --- Bibliographie ---
  biblio: {
    wannado_define_biblios: "Voulez-vous définir les bibliographies ?",
    title_of_new_biblio: "Titre de la nouvelle bibliographie : ",
    tag_uniq_and_simple_minuscules: "Identifiant singulier, unique et simple (minuscules) : ",
    title_level: "Niveau de titre",
    show_on_new_page: "L'afficher sur une nouvelle page ?",
    aspect_of_new_biblio: "Aspect de la bibliographie",
    create_a_new_biblio: "Faut-il créer une autre bibliographie ?",
    folder_or_file_of_data_biblio: "Dossier ou fichier des données bibliographiques (chemin relatif ou absolu) : ",
    should_i_create_file_in: "Dois-je créer un fichier YAML dans %s avec l'identifiant '%s' ?",
  }, #/:biblio

}

PROMPTS[:recipe].merge!(warning_book_in_collection: <<-TEXT)

  Ce livre est dans une collection. Je ne dois mettre dans sa 
  recette que les propriétés propre à un livre.

TEXT

PROMPTS[:recipe].merge!(init_intro_define_values: <<-TEXT)

  (si vous ne définissez pas certaines valeurs maintenant, il 
   faudra le faire « à la main » dans le fichier recette
   directement, plus tard — ou à l'aide d'assistants
   Ces valeurs concernent toute la recette du livre, les marges,
   les bibliographies, les fontes, les infos éditeurs, etc.
  )

TEXT

end #/module Prawn4book
