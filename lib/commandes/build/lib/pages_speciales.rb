=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PrawnView

  # --- CONSTRUCTION DE LA TABLE DES MATIÈRES ---

  # Cette méthode ne sert qu'à construire les pages qui doivent
  # servir pour la table des matières. La table des matières vérita-
  # ble sera construite dans la méthode  :
  #   Praw4book::PdfBook::Tdm#output
  #   cf. le fichier PdfBook_TdM.rb
  # 
  def init_table_of_contents
    # 
    # Toujours la mettre sur une nouvelle page, comme c'est l'usage
    # 
    start_new_page
    # 
    # On prend les données de la table des matières
    dtoc = tdm.data
    # 
    # Instancier un titre pour la table des matières
    # 
    unless dtoc[:title] === false
      titre = PdfBook::NTitre.new(pdfbook, text:dtoc[:title], level:dtoc[:title_level])
      titre.print(self)
      dtoc[:first_line] || dtoc.merge!(first_line: 5)
    end
    # 
    # On mémorise le numéro de page de la table des matières
    # 
    dtoc.merge!(page_number: page_number)
  end

  # --- CONSTRUCTION DES PAGES DE TITRES ---

  ##
  # Construction du faux titre
  #
  def build_faux_titre
    require_relative 'faux_titre'
    insert_faux_titre
  end

  def build_page_de_titre
    require_relative 'page_de_titre'
    insert_page_de_titre
  end

  def build_page_infos
    require_relative 'page_infos'
    insert_page_infos
  end


end #/PrawnDoc
end #/Prawn4book
