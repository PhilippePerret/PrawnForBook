Prawn4book::Manual::Feature.new do

  titre "Formatages du texte"

  description <<~EOT
    Pour styliser localement le texte, c’est-à-dire le passer en italique, en gras ou en souligné, vous pouvez utiliser les marque markdown décrites ci-dessous^^.
    ^^ Noter cependant que puisqu’il s’agit d’impression professionnelle, pour pouvoir utiliser de l’italique, du gras, etc., il faut que chaque style possède bien son fichier fonte (`ttf` ou `otf`) défini dans la recette. Voir [[recette/definition_fontes]].
    EOT

  sample_texte <<~EOT #, "Autre entête"
    Un *passage en italique*, un **autre en gras**, un __troisième souligné__ et un __***dernier avec tout***__.
    EOT

end
