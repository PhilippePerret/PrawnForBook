=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class PageInfos

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
  PAGE_DATA = {
    conception: {
      patro: {name:'Conception', default: 'Prénom NOM'},
      mail:  {name:'Mail du concepteur', default: nil}
    },
    mise_en_page: {
      patro: {name:"Mise en page", default: 'Prénom NOM'},
      mail:  {name:'Mail du metteur en page', default: nil},
    },
    correction: {
      patro: {name:'Corrections', default: 'Prénom NOM'},
      mail:  {name:'Mail du correcteur', default: nil}, 
    },
    cover: {
      patro: {name:'Couverture', default: 'Prénom NOM'},
      mail:  {name:'Mail du créateur de couverture', default: nil}, 
    },
    aspect: {
      libelle: {
        font: {name:'Police pour les libellés (p.e. "Mise en page")', default: :first_police_name},
        size: {name:'Taille pour les libellés', default: 10},
      },
      value: {
        font: {name:'Police pour la valeur (p.e. le nom)', default: :first_police_name},
        size: {name:'Taille pour la valeur', default: 11}
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
  #   (get_data_in_recipe[:fonts]||polices_default).map do |font_name, dfont|
  #     {name: font_name, value: font_name}
  #   end
  # end
  # def polices_default
  #   {'Times' => true, 'Helvetica' => true, 'Courier' => true}
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
