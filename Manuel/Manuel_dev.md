# Prawn To KDP



> Prawn to KDP est une application devant permettre de produire un fichier PDF prêt pour l’impression à partir d’un fichier texte formaté simplement (~markdown)



~~~

		TEXTE 												FICHIER
		SIMPLE					=>  						PDF
		FORMATAGE 								POUR L'IMPRESSION
		
~~~



## Classes

~~~ruby
# Espace de nom
module Prawn4book
  
  # Classe principale pour le fichier texte à balisage simple
  class InputFile

    # Classe d'un paragraphe dans le texte initial. Ce paragraphe
    # peut être une image, un titre, un paragraphe de texte, etc.
    # C'est cette classe qui produira les instances pour le livre
    # PDF
    class NParagraphe
		
      -> class PdfBook::NImage
      -> class PdfBook::NTitre
     	-> class PdfBook::NTextParagraph
      -> class PdfBook::NFormatedBlock  

  # Classe principale du livre qui sera produit
  class PdfBook
    
    # La classe qui hérite de Prawn::Document, pour générer le document
    class PdfFile
    
  	# Classe pour une image
    class NImage
      
    # Class pour un titre
    class NTitre
      
~~~

