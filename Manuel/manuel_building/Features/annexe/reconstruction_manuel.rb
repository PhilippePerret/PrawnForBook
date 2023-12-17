Prawn4book::Manual::Feature.new do

  titre "Reconstruction du manuel"

  description <<~EOT
    Pour voir certaines fonctionnalités, il est nécessaire de relancer la construction de ce manuel autoproduit. Pour ce faire, suivez les étapes suivantes :
    * dans une fenêtre Terminal, jouez la commande `pfb open`,
    * dans la liste, choisir "Ouvrir le dossier du manuel",
    * ouvrir un Terminal dans ce dossier (control-clic sur le dossier puis choisir "Nouveau Terminal au dossier" ou similaire),
    * jouer la commande `pfb build` dans ce Terminal (parfois il pourrait être demandé d’ajouter l’option de débuggage, dans ce cas il faudra jouer `pfb build -debug`).
    Le manuel autoproduit se reconstruit alors en quelques secondes.
    EOT

end
