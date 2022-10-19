module FormaterBibliographiesModule

  def biblio_livre(book)
    c = []
    book.instance_eval do
      c << title
      c << auteurs
      c << annee
      c << editeur
    end

    return c.join(', ')
  end


  def biblio_film(film)
    c = []
    film.instance_eval do
      c << title
      c << annee
      c << realisateur
    end
    return c.join(', ')
  end
end
