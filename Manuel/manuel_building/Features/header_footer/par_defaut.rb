Prawn4book::Manual::Feature.new do

  titre "Description"


  description <<~EOT
    Comme pour les autres éléments, on peut laisser les entêtes et pieds de page par défaut, ce qui signifiera n’afficher que le numéro de la page — sur les pages adéquates —, ou au contraire définir des entêtes et pieds de page très complexe et adaptés au contenu.
    Comme pour les autres éléments de _PFB_, les entêtes et pieds de page par défaut sont conçus pour être directement professionnels. C’est-à-dire que la numérotation est intelligente, elle ne numérote pas bêtement toutes les pages de la première à la dernière. Seules sont numérotées les pages qui le sont dans un livre imprimé. Sont évités les pages vides, les pages de titre ou les pages spéciales comme la [[-pages_speciales/table_des_matieres]] ou la [[-pages_speciales/page_infos]].
    EOT

end
