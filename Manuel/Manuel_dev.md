# Prawn To KDP



> Prawn to KDP est une application devant permettre de produire un fichier PDF prêt pour l’impression à partir d’un fichier texte formaté simplement (~markdown)



~~~

		TEXTE 												FICHIER
		SIMPLE					=>  						PDF
		FORMATAGE 								POUR L'IMPRESSION
		
~~~



## Synopsis général

~~~
- Instanciation d'un livre avec 'prawn-for-book init' ('pfb init')
	Un assistant permet de définir les données minimales
- On lance la fabrication du livre à l'aide de 'prawn-for-book build'

Il se passe alors :

- Instanciation du livre (Prawn4book::PdfBook)
- Instanciation du texte du livre (@inputfile = Prawn4book::PdfBook::InputTextFile)
- Appel de Prawn4book::PrawnView (héritant de Prawn::View) pour 'generate' du fichier
	PDF
	* On regarde si un module propre de formatage est défini, à ajouter en extension de
		Prawn::Document (PrawnDoc) qui permettra de traiter certains paragraphes.
		L'idée est la suivante : si le paragraphe commence par "balise:Le texte du parag.",
		alors 'balise' est considéré comme une balise de formatage qui doit appeler la
		méthode 'formate_balise' de ce module.
	* L'appel commence par définir 'pdf_config', configuration générale donnée en second
		argument de la méthode #generate pour définir la taille, les marges, certaines
		options, etc.
	* La méthode #generate entre en action
	* Elle boucle sur tous les @paragraphes de l'InputTextFile du PdfBook qui sont des
		instances correspondant à leur type (text, image, etc.).
- Si des références ont été trouvées (plus exactement : des appels à ces références), on 
	recommence l'opération depuis le départ pour ajouter ces références au texte puisque la
	première fois, une table a été générée.
TODO:
- Quand toutes les pages ont été produite dans le pdf, on appelle les méthodes de
	répétition pour, par exemple, régler les pieds de page avec les numéros de page.
/:TODO

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
    class PrawnDoc
    
  	# Classe pour une image
    class NImage
      
    # Class pour un titre
    class NTitre
      
~~~

