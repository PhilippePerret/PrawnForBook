module FormaterParagraphModule

  # Définition simple d'un style de paragraphe
  def formate_gros(par)
    par.font_family = 'Bangla'
    par.font_style  = :bold
    par.font_size   = 13
    par.margin_left = 50
  end

  # Constructeur complexe
  def build_tip_paragraph(par, pdf)
    pdf.font("Bangla", size: 6)
    pdf.text "À FORMATER : #{par.text}"
  end

end

module BibliographyFormaterModule

  def biblio_livre(book)
    c = []
    book.instance_eval do
      c << title.upcase
      c << annee
      fauteurs = auteurs.is_a?(String) ? [auteurs] : auteurs
      fauteurs = fauteurs.map {|a| a.patronize }.pretty_join
      c << fauteurs
      c << editeur
    end
    return c.join(', ')
  end


  def biblio_film(film)
    film.instance_eval do
      f_auteurs = auteurs
      f_auteurs = f_auteurs.pretty_join if f_auteurs.is_a?(Array)
      film.data.merge!(title_maj: film.title.upcase)
      c = ["<i>#{film.title.upcase}</i>"]
      c << " (#{film.title_fr.upcase})" if film.data[:title_fr]
      c << ", #{film.annee}"
      c << ", scénario : #{f_auteurs}"
      c << ", réalisation : #{realisateur}"
      return c.join('')
    end
  end

  def biblio_gadget(gad)
    
    
  end
end
