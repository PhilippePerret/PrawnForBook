=begin

  Les méthodes/propriétés de ce module peuvent être appelée par le 
  code.

  Chaque méthode a accès à `pdf' et `pdfbook', respectivement 
  l'instance du livre (qui peut retourner pdfbook.title, etc. ou
  tout donnée de la recette par pdfbook.recipe.get(:cle, default))
  et l'instance du constructeur de la page (qui peut retourner
  notamment pdf.page_number, la page courante, ou pdf.curseur, la
  hauteur actuelle du curseur).

=end
module PrawnHelpersMethods

  def ma_methode(arg1, arg2)
    # Je peux utiliser :
    # pdf (pdf.cursor, pdf.page_number, pdf.paragraph_number)
    # pdfbook (pdfbook.title, pdfbook.collection, pdfbook.recipe)
    
  end

end #/module PrawnHelpersMethods
