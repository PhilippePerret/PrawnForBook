module Prawn4book

TERMS = {
  book_format: 'format (taille livre, marges, etc.)',
  biblios: 'bibliographies',
  book_data: 'du livre',
  book_infos: 'informations (last page) sur le livre',
  fonts: 'fontes',
  footer: 'pied de page',
  format: 'format',
  header: 'entête',
  headers_and_footers:'entêtes et pieds de page',
  inserted_pages: 'Page à insérer (faux-titre, etc.)',
  no:   'non',
  other_default_values:'autres valeurs par défaut',
  page:         'page',
  paragraph:    'paragraphe',
  publisher:    'éditeur/édition',
  publishing:   'maison d’édition',
  recipe_options: 'options (pagination, etc.)',
  titles: 'titres',
  wanted_pages: 'pages désirée (faux-titre, infos, etc.)',
  yes: 'oui',
}

PROMPTS = {

  # --- Généralités ---
  Abandon: 'Abandonner', # plus fort que "Renoncer"
  cancel: 'Renoncer',
  Define: 'Définir',
  Edit: 'Éditer', 
  end_without_save: 'Finir sans enregistrer',
  Finir: 'Finir',
  finir: 'Finir',
  Folder: 'Dossier : ',
  New: 'Nouveau',
  save: 'Enregistrer',

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
    should_i_open_recipe_file: 'Dois-je ouvrir le fichier recette ?',
    should_i_add_code_to_recipe: 'Dois-je ajouter le code ci-dessus au fichier recette ?',
    wannado_define_titles: "Voulez-vous définir les propriétés pour les titres ?",
    which_data_recipe_to_define: "Quelles données voulez-vous définir ?",
  }, # / :recipe

  # --- Maison d'édition ---
  publishing: {
    ask_move_logo: "Copier un logo existant déjà ?",
    ask_for_logo_original_path: "Chemin d'accès complet au logo à copier",
  },

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

  }, #/ :fonts

  # --- Bibliographie ---
  biblio: {
    new_one: "Nouvelle bibliographie",
    title_of_new_biblio: "Titre de la nouvelle bibliographie : ",
    tag_uniq_and_simple_minuscules: "Identifiant singulier, unique et simple (minuscules) : ",
    title_level: "Niveau de titre",
    show_on_new_page: "L'afficher sur une nouvelle page ?",
    aspect_of_new_biblio: "Aspect de la bibliographie",
    create_a_new_biblio: "Faut-il créer une autre bibliographie ?",
    folder_or_file_of_data_biblio: "Dossier ou fichier des données bibliographiques (chemin relatif ou absolu) : ",
    should_i_create_file_in: "Dois-je créer un fichier YAML dans %s avec l'identifiant '%s' ?",
  }, #/:biblio

  # --- Headers et footers ---
  headfoot: {
    new_dispo: 'Nouvelle disposition', 
    headfoot_to_choose: 'Head-foot à utiliser'
  },
}

PROMPTS[:recipe].merge!(warning_book_in_collection: <<-TEXT)

  Ce livre est dans une collection. Je ne dois mettre dans sa 
  recette que les propriétés propre à un livre.

TEXT


end #/module Prawn4book
