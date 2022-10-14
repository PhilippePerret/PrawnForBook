=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PrawnView

  # --- CONSTRUCTION DE LA TABLE DES MATIÈRES ---

  def build_table_des_matieres
    # Pour savoir sur quelle page construire la table des
    # matière
    on_page = page_number
    font "Nunito", size: 20 # TODO À régler
    text "Table des matières"
    # TODO Développer la TOC ici
    start_new_page
    start_new_page
  end

  # --- CONSTRUCTION DES PAGES DE TITRES ---

  ##
  # Construction du faux titre
  #
  def build_faux_titre
    require_relative 'generate_builder/faux_titre'
    insert_faux_titre
  end

  def build_page_de_titre
    require_relative 'generate_builder/page_de_titre'
    insert_page_de_titre
  end

  def build_page_infos
    require_relative 'generate_builder/page_infos'
    insert_page_infos
  end


end #/PrawnDoc
end #/Prawn4book
