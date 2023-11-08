Prawn4book::Manual::Feature.new do

  titre "Les hyperliens"

  description <<~EOT
    Les hyperliens ("hyperlinks" en anglais) se marquent comme en pur markdown, c’est-à-dire avec `\\[\\<titre>](\\<url>)`.
    En fonction du format de sortie (`book_format: book: format:` dans la recette), le lien sera présenté de façon différente :
    * dans le format de sortie `publishing` (c’est-à-dire en livre imprimé), le lien apparaitra de cette manière : `\\<titre> (\\<url>)`.
    * dans le format de sortie `pdf` (c’est-à-dire en document PDF pas destiné à être imprimé), le lien n’affichera que le titre `\\<title>` et en cliquant dessus on pourra rejoindre l’URL spécifiée.
    *(Noter que pour rejoindre une partie du document, il vaut mieux utiliser les références croisées (page ->(cross_references))*
    EOT


end
