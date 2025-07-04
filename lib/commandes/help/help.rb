module Prawn4book

class Command
  def proceed
    methode =
      case ini_name
      when 'aide', 'help'
        if CLI.components[0].nil?
          :display_mini_help
        else
          require_relative 'lib/Manuel_Searcher'
          return ManuelSearcher.search(CLI.components[0])
        end
      when 'manuel', 'manual' 
        :open_user_manuel
      when 'manuel-prawn', 'prawn-manual', 'prawn-manuel'
        :open_prawn_manual
      when 'manuel-prawn-table'
        :open_prawn_table_manual
      else 
        # Note : les assistants passent aussi par ici
        # cf. ci-dessous
        (help? && CLI.components[0].nil?) ? :display_mini_help : :display_help
      end
    Prawn4book.send(methode)
  end
end #/Command


  def self.display_help
    clear
    #
    # L'élément après le "help/aide"
    # 
    chose = CLI.components[0].to_s
    # 
    # On détermine précisément la chose pour laquelle il faut de
    # l'aide.
    # 
    case chose.downcase
    when 'fontes','fonts','police','polices'
      traite_with_assistant('fontes')
    when 'tdm', 'table des matières', 'table of content'
      traite_as_page_speciale('table_of_content')
    when 'bib', 'biblio','bibliography','bibliographies'
      traite_with_assistant('bibliographies')
    when 'head', 'entête', 'entete','header','headers','footer','footers','pied-de-page'
      traite_with_assistant('headers_footers')
    when 'pub', 'me', 'publisher', 'publisher', 'éditeur', 'édition'
      traite_with_assistant('publisher')
    when 'data', 'données'
      traite_as_page_speciale('book_data')
    when 'format', 'formatage', 'aspect'
      traite_as_page_speciale('book_format')
    when 'page titre', 'page de titre', 'title page'
      traite_as_page_speciale('page_de_titre')
    when 'index', 'page index', 'index page'
      traite_as_page_speciale('page_index')
    when 'infos', 'page infos', 'infos page'
      traite_as_page_speciale('credits_page')
    else
      puts (ERRORS[:help][:unknown_assistant] % chose.inspect).rouge
    end
  end

  def self.traite_with_assistant(thing)
    cmd = Command.new('assistant').load
    cmd.proceed_assistant_for(thing)
  end

  def self.traite_as_page_speciale(thing)
    require "./lib/pages/#{thing}"
    Prawn4book::Pages.run_assistant(thing)    
  end

  def self.display_mini_help
    clear
    less(MINI_AIDE)
  end

  def self.open_user_manuel
    if CLI.option(:dev)
      `open -a Typora "#{USER_MANUAL_MD_PATH}"`
    else
      `open -a Preview "#{USER_MANUAL_PATH}"`
    end
  end


  def self.open_prawn_manual
    if File.exist?(PRAWN_MANUEL_PATH)
      `open "#{PRAWN_MANUEL_PATH}"` 
    else
      puts ERRORS[:prawn_manual_unfound].rouge
    end
  end

  def self.open_prawn_table_manual
    `open "#{PRAWN_TABLE_MANUAL}"`
  end

# @constant
# Aide minimum qui s'affiche lorsque l'on met la
# commande sans aucun argument
MINI_AIDE = <<-TEXT


********************************
*** #{'pfb'.jaune} mini aide ***

#{'pfb build'.jaune}
    Construire le livre du livre courant.
    Ajouter l'option '-open' pour l'ouvrir après fabrication.

#{'pfb open'.jaune}
    Ouvrir un élément quelconque, dossier du livre, de la collection,
    manuel de Prawn-for-book, manuel de Prawn etc.

#{'pfb manuel'.jaune}
    Manuel PDF
    Ajouter '-dev' pour ouvrir la version markdown annotable.

#{'pfb init'.jaune}
    Initier un nouveau livre dans le dossier courant.

#{'pfb choose <biblio>'.jaune}
    Pour choisir un item dans une bibliographie courante.
    Note : le terminal doit être ouvert dans un dossier de
    livre ou de collection.

#{'pfb cibles'.jaune}
    Pour pouvoir choisir une cible à copier-coller dans
    le texte.

#{'pfb assistant'.jaune}
    Permet de choisir un assistant et de le jouer.

#{'pfb install'.jaune}
    Pour installer ou définir les snippets dans Sublime Text

#{'pfb script'.jaune}
    Pour jouer un script (natif ou propre au livre/à la collection)
    On peut utiliser 
    'pfb script <nom script partiel> ./images/<nom image partiel>'

#{'pfb aide "<mot>"'.jaune}
    Rechercher le mot <mot> dans l’aide.
    Si c’est une expression régulière, l’entourer par des 
    balances (#{'pfb aide "/<expression régulière>/"'.jaune})

#{'pfb aide fontes'.jaune}
    Assistant en ligne pour produire la donnée :fonts du 
    fichier recette.

#{'pfb aide biblio'.jaune}
    Assistant en ligne pour produire la donnée :biblio du 
    fichier recette.

#{'pfb upgrade'.jaune}
    Pour mettre à niveau le livre ou la collection courante, 
    c'est-à-dire, principalement, pour créer les nouveaux éléments.

#{'pfb aide'.jaune}
    Aide en ligne pour pfb (cette aide-ci)

TEXT

# @constant
# Aide qui s'affiche lorsque l'on utilise l'option
# -h/--help ou que l'on joue la commande 'aide/help'
INLINE_AIDE = <<-TEXT

********************************
***  AIDE DE #{'pfb'.jaune}  ***
********************************

L'application Prawn-For-Book permet de produire des PDF prêts à 
l'impression (professionnelle) grâce à Ruby et le gem 'Prawn' à 
partir d'un texte au format réduit.

#{'pfb manuel'.jaune}
    Pour ouvrir le manuel complet de l'application

AIDE RAPIDE
===========

Création d'un nouveau livre
---------------------------
(ou d'une nouvelle collection)

* Ouvrir un Terminal dans le dossier où créer le nouveau livre,
  (le dossier qui contiendra le dossier du livre)
* Jouer #{'pfb init'.jaune},
* répondre aux questions posées
> Cela produit le fichier 'receipe.yaml' qui contient la 
  "recette" du livre (ou la recette de la collection)
TEXT
end #/ module Prawn4book
