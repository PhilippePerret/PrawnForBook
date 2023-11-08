Prawn4book::Manual::Feature.new do

  titre "Les références croisées"

  description <<~EOT
    <-(cross_references)Les *références croisées* permettent de faire référence, dans un livre, à une autre partie du livre ou même, avec _PFB_, à une partie d’un autre livre. Typiquement, c’est le "cf. page 12" qu’on trouve dans un ouvrage.
    Les *références croisées* fonctionne à partir d’une *cible*, la partie du livre à rejoindre, et d’un *lien* vers cette cible.
    Dans _PFB_, la référence vers la cible pourra avoir trois formats différents :
    * le numéro de page,
    * le numéro de paragraphe,
    * le numéro de page et de paragraphe (format hybride).
    On choisit ce format dans
    EOT

  sample_texte <<~EOT
    On définit une cible avec `\\<-(<nom cible>)` et un lien vers cette cible avec `\\->(<nom cible>)`.
    Le texte ci-dessous, par exemple, est défini avec :
    J’ai dans cette phrase une cible\\<-(exemple_cible).
    \\(( new_page ))
    La cible se trouve à la page \\->(exemple_cible).

    EOT

  texte <<~EOT
    J’ai dans cette phrase une cible<-(exemple_cible).
    (( new_page ))
    La cible se trouve à la page ->(exemple_cible).
    EOT

end
