=begin

  Ce fichier définit les modules : 

    - BibliographyFormaterModule
    - FormaterParagraphModule

=end

=begin

  BibliographyFormaterModule
  ----------------------------

  Module de formatage des bibliographies.

  PRINCIPE
  --------
    Si la bibliographie 'film' existe, alors il faut implémenter la
    méthode 'biblio_film' qui recevra en premier élément l'instance
    de l'élément bibliographique et retournera le texte formaté 
    pour l'affichage de la bibliographie des films.

=end
module BibliographyFormaterModule

  # # Par exemple, pour une bibliographie de balise 'film'
  # def biblio_film(film)
  #   '% {title.upcase} de % {writers}, % {year}' % film.data
  # end

end

=begin

  FormaterParagraphModule
  -----------------------

  Module de formatage des textes dans les paragraphes

=end
module FormaterParagraphModule # Ce nom est absolument à respecter

  # # Par exemple, si la balise 'custag' existe, on doit implémenter
  # # la méthode ci-dessous qui recevra le texte dans le texte et
  # # retournera le texte à écrire dans le texte final.
  # def __formate_custag(string)
  #   return "<font name=\"Arial\" size=\"8\">#{string}</font>"
  # end
end

