module Prawn4book

  def self.display_mini_help
    clear
    less(MINI_AIDE)
  end

  def self.open_user_manuel
    `open -a Preview "#{USER_MANUAL_PATH}"`
  end

  def self.display_help
    clear
    if CLI.components[0].in?(['fontes','fonts'])
      require_module('assistant', :assistant_fontes)
    else
      less(INLINE_AIDE)
    end
  end


# @constant
# Chemin d'accès au manuel utilisateur
USER_MANUAL_PATH = File.join(APP_FOLDER,'Manuel','Manuel.pdf')

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

#{'prawn-for-book aide fontes'.jaune}
    Aide en ligne pour produire la donnée :fonts du 
    fichier recette.


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
