module Prawn4book

class Command
  def proceed
    methode =
      case ini_name
      when 'manuel', 'manual' then :open_user_manuel
      else 
        help? ? :display_help : :display_mini_help
      end
    Prawn4book.send(methode)
  end
end #/Command


  def self.display_mini_help
    clear
    less(MINI_AIDE)
  end

  def self.open_user_manuel
    if CLI.option(:dev)
      `open -a Typora "#{USER_MANUEL_MD_PATH}"`
    else
      `open -a Preview "#{USER_MANUAL_PATH}"`
    end
  end

  def self.display_help
    clear
    if CLI.components[0] && CLI.components[0].in?(['fontes','fonts'])
      cmd = Command.new('assistant').load
      cmd.proceed_assistant_fontes
    else
      less(INLINE_AIDE)
    end
  end

# @constant
# Aide minimum qui s'affiche lorsque l'on met la
# commande sans aucun argument
MINI_AIDE = <<-TEXT


********************************
*** #{'prawn-for-book'.jaune} mini aide ***

#{'prawn-for-book aide'.jaune}
    Aide en ligne pour prawn-for-book

#{'prawn-for-book manuel'.jaune}
    Manuel PDF

#{'prawn-for-book init'.jaune}
    Initier un nouveau livre dans le dossier
    courant.

#{'prawn-for-book build'.jaune}
    Construire le livre du livre courant.

#{'prawn-for-book open'.jaune}
    Ouvrir le fichier PDF du livre courant.

#{'prawn-for-book open -e'.jaune}
    Ouvrir le fichier texte du livre courant dans l'éditeur de texte (Sublime Text).

#{'prawn-for-book aide fontes'.jaune}
    Aide en ligne pour produire la donnée :fonts du 
    fichier recette.

---

#{'prawn-for-book manuel -dev'.jaune}
    Manuel PDF en version markdown (édition)

TEXT

# @constant
# Aide qui s'affiche lorsque l'on utilise l'option
# -h/--help ou que l'on joue la commande 'aide/help'
INLINE_AIDE = <<-TEXT

********************************
***  AIDE DE #{'prawn-for-book'.jaune}  ***
********************************

L'application Prawn-For-Book permet de produire des PDF prêts à 
l'impression (professionnelle) grâce à Ruby et le gem 'Prawn' à 
partir d'un texte au format réduit.

#{'prawn-for-book manuel'.jaune}
    Pour ouvrir le manuel complet de l'application

AIDE RAPIDE
===========

Création d'un nouveau livre
---------------------------
(ou d'une nouvelle collection)

* Ouvrir un Terminal dans le dossier où créer le nouveau livre,
* Jouer #{'prawn-for-book init'.jaune},
* répondre aux questions posées
> Cela produit le fichier 'receipe.yaml' qui contient la 
  "recette" du livre (ou la recette de la collection)
TEXT
end #/ module Prawn4book
