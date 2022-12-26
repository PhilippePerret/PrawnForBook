module Prawn4book

class Command
  def proceed
    methode =
      case ini_name
      when 'manuel', 'manual' then :open_user_manuel
      else 
        # Note : les assistants passent aussi par ici
        # cf. ci-dessous
        help? ? :display_help : :display_mini_help
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
    whats = case chose
    when 'fontes','fonts','police','polices'
      'fontes'
    when 'biblio','bibliography','bibliographies'
      'biblios'
    when 'entete','header','headers','footer','footers','pied-de-page'
      'headers_footers'
    else
      # 
      # C'est le nouvel assistant de page spéciale
      # 
      chose = chose.gsub(/\-/, '_').downcase
      if File.exist?(File.join(APP_FOLDER,'lib','pages',chose))
        traite_as_assistant_page_speciale(chose)
        return
      end
      puts "Je ne sais pas comment traiter l'aide pour #{chose.inspect}.".rouge
      return
    end
    cmd = Command.new('assistant').load
    if whats
      cmd.proceed_assistant_for(whats)
    else
      less(INLINE_AIDE)
    end
  end

  def self.traite_as_assistant_page_speciale(what)
    require "lib/pages/#{what}"
    classe = Prawn4book::Pages.const_get(what.camelize)
    page = classe.new(File.expand_path('.'))
    page.define
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


# @constant
# Aide minimum qui s'affiche lorsque l'on met la
# commande sans aucun argument
MINI_AIDE = <<-TEXT


********************************
*** #{'pfb'.jaune} mini aide ***

#{'pfb aide'.jaune}
    Aide en ligne pour pfb

#{'pfb manuel'.jaune}
    Manuel PDF

#{'pfb init'.jaune}
    Initier un nouveau livre dans le dossier
    courant.

#{'pfb build'.jaune}
    Construire le livre du livre courant.

#{'pfb open'.jaune}
    Ouvrir le fichier PDF du livre courant.

#{'pfb open -e'.jaune}
    Ouvrir le fichier texte du livre courant dans l'éditeur de texte (Sublime Text).

#{'pfb aide fontes'.jaune}
    Assistant en ligne pour produire la donnée :fonts du 
    fichier recette.

#{'pfb aide biblio'.jaune}
    Assistant en ligne pour produire la donnée :biblio du 
    fichier recette.

#{'pfb upgrade'.jaune}
    Pour mettre à niveau le livre ou la collection courante, 
    c'est-à-dire, principalement, pour créer les nouveaux éléments.

---

#{'pfb manuel -dev'.jaune}
    Manuel PDF en version markdown (édition)

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
* Jouer #{'pfb init'.jaune},
* répondre aux questions posées
> Cela produit le fichier 'receipe.yaml' qui contient la 
  "recette" du livre (ou la recette de la collection)
TEXT
end #/ module Prawn4book
