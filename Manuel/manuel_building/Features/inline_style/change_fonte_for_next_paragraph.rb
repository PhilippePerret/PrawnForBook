Prawn4book::Manual::Feature.new do

  titre "Changer la fonte du paragraphe suivant"

  description <<~EOT
    Il est très facile de changer la fonte d’un prochain paragraphe en utilisation la *stylisation en ligne*, par exemple grâce au code suivant.
    EOT

  sample_texte <<~EOT #, "Autre entête"
    Ce paragraphe est dans la police par défaut ou courante.
     
    \\(( font\\(name:"Helvetica", size:8, style: :normal, hname: "maPolice") ))
    Ce paragraphe est dans la nouvelle police.
     
    Ce paragraphe est à nouveau dans la police courante.
     
    \\(( font\\("maPolice") ))
    Il suffit ensuite de faire appel à l’autre police par son nom pour l’appliquer à nouveau à un paragraphe.
     
    Et on retrouve ensuite la police courante.
    EOT

  texte(:as_sample)


end
