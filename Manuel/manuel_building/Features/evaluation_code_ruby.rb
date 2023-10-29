Prawn4book::Manual::Feature.new do

  titre "Évaluation du code ruby"

  description <<~EOT
    Tous les codes qui se trouveront entre `\#{'#'}{...}` seront évalués en tant que code ruby, dans le cadre du livre (c'est-à-dire qu'ils pourront faire appel à des méthodes personnalisées)

    Typiquement, on peut par exemple obtenir la date courante.
    EOT

  sample_texte <<~EOT
    Une opération simple permet de savoir que 2 + 2 est égal à \#{'#'}{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{'#'}{Time.now.strftime('%d %m %Y')}.

    EOT
  
  texte <<~EOT
    Une opération simple permet de savoir que 2 + 2 est égal à \#{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{Time.now.strftime('%d %m %Y')}.

    EOT

end
