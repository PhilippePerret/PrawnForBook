=begin

  Module les données de la page
  
=end
require_folder(File.join(File.dirname(__dir__),'special_pages_abstract'))
module Prawn4book
class Pages
class PageInfos < SpecialPage

  def self.depot_bnf_default
    year = Time.now.year
    mois = Time.now.month + 6
    if mois > 12
      year += 1
      mois -= 12
    end
    if mois < 4     then '1er'
    elsif mois < 7  then '2e'
    elsif mois < 10 then '3e'
    else '4e'
    end + " trimestre #{year}"
  end

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  # Mis dans :credits_page dans la recette
  # 
  PAGE_DATA = {
    conception: {
      patro: {name:'Conception (Prénom NOM)', default: nil},
      mail:  {name:'Mail du concepteur', default: nil}
    },
    mise_en_page: {
      patro: {name:"Mise en page (Prénom NOM)", default: nil},
      mail:  {name:'Mail du metteur en page'  , default: nil},
    },
    cover: {
      patro: {name:'Couverture (Prénom NOM)', default: nil},
      mail:  {name:'Mail du créateur de couverture', default: nil}, 
    },
    correction: {
      patro: {name:'Corrections (Prénom NOM)', default: nil},
      mail:  {name:'Mail du correcteur', default: nil}, 
    },
    aspect: {
      libelle: {
        font: {name:'Police/style/taille/couleur pour les libellés', default: Fonte.method(:as_choices)},
      },
      value: {
        font: {name:'Police/style/taille/couleur pour la valeur', default: Fonte.method(:as_choices)},
      },
      disposition: {name: 'Disposition', default: 'distribute', values: :dispositions}
    },
    depot_legal: {name: "Dépôt BNF", default: depot_bnf_default},
    printing: {
      name: {name: 'Imprimerie', default: 'à la demande'},
      lieu: {name: 'Localité imprimerie', default: nil},
    }
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  # Par exemple :
  # def police_names(default_name = nil)
  #   (get_data_in_recipe[:fonts]||DEFAUT_FONTS).map do |font_name, dfont|
  #     {name: font_name, value: font_name}
  #   end
  # end

  def dispositions
    [
      {name:'Données réparties dans la page', value: 'distribute'},
      {name:'Données en bas de page', value: 'bottom'},
      {name:'Données en haut de page', value: 'top'}
    ]  
  end

end #/class PageInfos
end #/class Pages
end #/module Prawn4book
