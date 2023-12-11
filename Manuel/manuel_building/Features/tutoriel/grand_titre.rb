Prawn4book::Manual::Feature.new do

  # grand_titre "Tutoriel"
  titre("Tutoriel", 1)

  description <<~EOT
    
    Cette section présente un tutoriel de prise en main de l’application _PFB_ qu’il suffit de suivre pour réaliser confortablement son premier livre professionnel.

    #### Pré-requis du turoriel

    Pour pouvoir réaliser ce tutoriel, vous n’avez besoin de rien d’autre que l’application _PFB_ elle-même, correctement installée.
    Vous devez également avoir des rudiments concernant l’utilisation du Terminal (sur MacOs) ou de la Console (sur Windows), mais nul besoin d’être un expert pour produire un bon livre !
    Pour vous assurer que _PFB_ est bien installé, ouvrez simplement une fenêtre de Terminal (ou une Console) et tapez :
    (( line ))
    {-}`> pfb -version`
    (( line ))
    *(remarquez que tous les codes qui seront précédés de "`> `" seront à exécuter dans votre console de terminal)*
    Cette première commande _PFB_ devrait vous afficher la version de l’application que vous utilisez. Si cette version n’est pas "#{Prawn4book::VERSION}", vous devriez l’actualiser pour être à jour des dernières fonctionnalités.
    Si ce n’est pas le cas, alors il faut que vous recommenciez l’installation en suivant la procédure proposée en annexe (cf. [[annexe/installation_application]]).
    Si tout est OK, vous pouvez vous lancer à corps et à cri dans ce tutoriel !
    (( line ))
    Bon tutoriel et bonne découverte !
    EOT

end
