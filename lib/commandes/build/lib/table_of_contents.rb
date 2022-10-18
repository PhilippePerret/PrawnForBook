=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PrawnView

  attr_accessor :tdm_page

  # --- CONSTRUCTION DE LA TABLE DES MATIÈRES ---

  # Cette méthode ne sert qu'à construire les pages qui doivent
  # servir pour la table des matières. La table des matières vérita-
  # ble sera construite dans la méthode  :
  #   Praw4book::PdfBook::Tdm#output
  #   cf. le fichier PdfBook_TdM.rb
  # 
  def build_table_des_matieres
    self.tdm_page = page_number
    font "Nunito", size: 20 # TODO À régler
    text "Table des matières"
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
