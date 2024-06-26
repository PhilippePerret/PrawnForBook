=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class PageIndex

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  PAGE_DATA = {
    aspect: {
      canon:  {
        font: {name:'Police/style/taille/couleur pour le canon', default: 'Times/bold/12/000000', values: Fonte.method(:as_choices)},
      },
      number:  {
        font: {name:'Police/style/taille/couleur pour les numéros', default: 'Times//12/000000', values: Fonte.method(:as_choices)},
      },
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 

  ##
  # Pour ajouter un mot indexé à la table @table_index
  # 
  # @param dmot {Hash} Donnée du mot à indexer. Contient :
  #   :mot        Le mot tel qu'il se présente dans le texte
  #   :canon      Le mot canonique, s'il est différent du mot
  #   :page       Le numéro de page du mot
  #   :paragraph  Le numéro de paragraphe du mot
  # 
  def add(dmot)
    canon = (dmot[:canon]||dmot[:mot]).downcase
    dmot.merge!(canon: canon)
    table_index.key?(canon) || begin
      cfsort = canon.normalized
      table_index.merge!(canon => {canon_for_sort: cfsort, items: []})
    end
    table_index[canon][:items] << dmot
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
