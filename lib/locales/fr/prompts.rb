module Prawn4book

TYPO = {
  colon: ' :', # pas d’espace en anglais  
}
TERMS = {
  A_class_method: "Une méthode de classe",
  Authors: 'Auteurs',
  auto_manual: 'manuel auto-produit',
  auto_manual_bat: 'manuel auto-produit (version BAT)',
  BAT_version: 'version BAT',
  bibliography: 'bibliographie',
  biblio_item: 'item de bibliographie',
  book_format: 'format (taille livre, marges, etc.)',
  biblios: 'bibliographies',
  book_data: 'du livre',
  book_infos: 'informations (last page) sur le livre',
  cm: 'centimètres',
  coll_in_ide: 'La collection dans l’IDE',
  coll_in_finder: 'La collection dans le Finder',
  cover: 'la couverture',
  curbook_pdf: 'Le livre courant en PDF',
  curbook_in_ide: 'Le livre dans l’IDE (dossier)',
  curbook_in_finder: 'Le livre dans le Finder (dossier)',
  custom: 'personnalisé',
  Custom: 'Personnalisé',
  date: 'date',
  Date_ex: 'Date (JJ/MM/AAAA)',
  default_value: 'par défaut',
  Default_value: 'Valeur par défaut ',
  A_explicit_value: "Une valeur explicite",
  folder_manuel: "Le dossier du Manuel autoproduit",
  fonts: 'fontes',
  footer: 'pied de page',
  format: 'format',
  given_values: 'valeurs proprosées',
  Glossary: 'Glossaire',
  header: 'entête',
  headers_and_footers:'entêtes et pieds de page',
  Id: 'Identifiant',
  inch:  'pouce',
  in:  'pouce',
  inserted_pages: 'Page à insérer (faux-titre, etc.)',
  A_instance_method: 'Une méthode d’instance',
  int: 'Entier',
  Int: 'Entier',
  invalid_if: 'invalide si',
  Invalid_method: 'Méthode d’invalidation',
  ISBN: 'ISBN',
  manual_pfb: 'Le manuel de Prawn-For-Book',
  manual_prawn: 'Le manuel de Prawn',
  manual_prawn_table: 'Le manuel de Prawn::Table',
  margins: 'les marges',
  int_margin: 'la marge intérieure',
  four_margins: 'les quatre marges (:top, :ext, :bot, :int)',
  les_marges_: 'les marges %s',
  mm: 'millimètres',
  Name: 'Nom',
  no:   'non',
  other_default_values:'autres valeurs par défaut',
  package_subtext: 'Le package Sublime Text',
  page:         'page',
  paragraph:    'paragraphe',
  people: 'personne(s)',
  A_procedure: "Une procédure",
  Property_key: 'Clé de propriété',
  pt: 'point',
  publisher:    'éditeur/maison d’édition',
  recipe_options: 'options (pagination, etc.)',
  required: 'requis',
  requise: 'requise',
  string: 'String',
  Subtitle: 'Sous-titre',
  table_table_of_content: 'Table des matières',
  table_illustrations: 'Table des illustrations',
  Title: 'Titre',
  titles: 'titres',
  Type: 'Type',
  uniq: 'unique',
  valid_if: 'valide si',
  Valid_method: 'Méthode de validation',
  wanted_pages: 'pages désirée (faux-titre, infos, etc.)',
  year: 'année',
  Year: 'Année',
  yes: 'oui',
}

PROMPTS = {

  # --- Généralités ---
  Abandon: 'Abandonner', # plus fort que "Renoncer"
  Action_to_run: "Action à accomplir",
  Build_current_book: 'Produire le livre courant',
  Calc_: "Calculer…",
  cancel: 'Renoncer',
  choose_un: 'Choisir un %s',
  choose_le: 'Choisir le %s',
  choose_une: 'Choisir une %s',
  choose_la: 'Choisir la %s',
  Command_can_be_done_with: 'Cette opération peut être exécutée avec la commande :',
  creer_une: 'Créer une %s',
  creer_un: 'Créer un %s',
  Define: 'Définir',
  DefineLater: 'Définir plus tard',
  Open_in_editor: 'Dois-je ouvrir le dossier %{folder} dans l’éditeur ?',
  Open_: 'Ouvrir…',
  and_open: 'et l’ouvrir',
  Open_something: 'Ouvrir quelque chose',
  Quoi_faire: 'Que voulez-vous faire ?',
  data_de_la: 'Données de la %s',
  data_du: 'Données du %s',
  Edit: 'Éditer',
  edit_un: 'Éditer un %s',
  edit_une: 'Éditer une %s',
  end_without_save: 'Finir sans enregistrer',
  Finir: 'Finir',
  finir: 'Finir',
  Folder: 'Dossier : ',
  New: 'Nouveau',
  Page_count: 'Nombre de pages',
  save: 'Enregistrer ',
  show_grid: 'afficher la grille de référence',
  show_margins: 'afficher les marges',
  Type_of_data: 'Type de la donnée ',
  Unit: 'Unité',
  Value: 'Valeur ',

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
  publisher: {
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
    biblio_name: "Bibliographie « %s »", # "%s Bibliography" en anglais
    ask_create_data_format_file: 'Voulez-vous définir le format des données ?',
    ask_create_folder_cards: 'Dois-je créer le dossier qui contiendra les fiches ? (au path %s)',
    new_one: "Nouvelle bibliographie",
    new_property: 'Nouvelle propriété',
    format_for_fiches_of: "Format des fiches de la bibliographie “%s”",
    help_data_format: "(ci-dessous la liste des propriétés d'une fiche “%s”)",
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
