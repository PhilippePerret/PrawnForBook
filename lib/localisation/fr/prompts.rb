module Prawn4book

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
    should_i_open_recipe_file: 'Dois-je ouvrir le fichier recette ?',
    should_i_add_code_to_recipe: 'Dois-je ajouter le code ci-dessus au fichier recette ?',
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

  }, #/ :fonts

  # --- Bibliographie ---
  biblio: {
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
end #/module Prawn4book
