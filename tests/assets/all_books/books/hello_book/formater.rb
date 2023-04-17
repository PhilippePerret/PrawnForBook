module BibliographyFormaterModule

  ##
  # Formatage d'une citation de livre dans le livre en exemple
  # 
  # Il y a trois formatages différents :
  #   - la première fois où le livre est cité
  #   - une autre fois proche de la dernière citation (< 10 pages)
  #   - une autre fois loin de la dernière citation (> 10 pages)
  # 
  def self.livre_in_text(livre, context, actual)
    pa = context[:paragraph]
    @@livres_cites ||= {}

    # true si c'est la toute première citation du livre
    premiere_fois = not(@@livres_cites.key?(livre.id))
    # true si le livre a été cité la dernière fois à plus
    # de 10 pages de là
    citation_lointaine = not(premiere_fois) && (pa.first_page >= @@livres_cites[livre.id][:last_page] + 10)
    
    str = "<i>#{livre.title}</i>"

    if premiere_fois
      @@livres_cites.merge!(livre.id => {last_page: pa.first_page})
      str = "#{str} (#{livre.auteur}, #{livre.annee})"
    else
      if citation_lointaine
        str = "#{str} (#{livre.annee})"
      end
      @@livres_cites[livre.id][:last_page] = pa.first_page
    end

    return str
  end

end #/module BibliographyFormaterModule
