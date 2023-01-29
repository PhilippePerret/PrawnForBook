=begin
  Class Prawn4book::Bibliography::BibItem
  ---------------------------------------
  Gestion des items bibliographiques au niveau de leur définition.
  C'est dans ce module qu'on peut :
  - définir un nouvelle item de bibliographaphie
  - définir le format d'un item de bibliographie (fichier DATA_FORMAT)
    dans la bibliographie
=end
class BibItemError < StandardError ; end

module Prawn4book
class Bibliography
class BibItem

  ##
  # Méthode main appelée quand l'utilisateur veut créer un nouvel
  # item de bibliographie.
  # 
  def assiste_creation
    # 
    # Si le format des données n'est pas défini, il faut inviter
    # l'utilisateur à le créer (dépend de la bibliographie — cf. le
    # fichier bibliographiy_definition.rb)
    # 
    biblio.has_data_format? || biblio.assiste_data_format || return

  end

  # @return nil si l'item représenté par les données +ditem+ est bien
  # unique. Sinon, return [String] le message d'erreur.
  # 
  def already_exist?(ditem)
    # 
    # Il ne doit pas exister au niveau du diminutif (@id)
    # 
    # TODO
    # 
    # Il ne doit pas exister au niveau du titre (@title)
    # 
    # TODO
    return nil
  rescue BibItemError => e
    return e.message
  end

end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
