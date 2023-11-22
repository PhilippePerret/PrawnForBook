=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PrawnView

  ##
  # Construction de la table des matières
  # 
  def build_table_of_contents
    @current_titles = {
      1 => "Table des matières", 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 
    }
    require 'lib/pages/table_of_content'
    spy(:on)
    page = Prawn4book::Pages::TableOfContent.new(self)
    page.build(self) # mais seulement si elle est définie
    spy(:off)
  end

  ##
  # Construction du faux titre
  #
  def build_faux_titre
    require_relative 'faux_titre'
    insert_faux_titre
  end

  def build_page_de_titre
    require 'lib/pages/page_de_titre'
    page = Prawn4book::Pages::PageDeTitre.new(self)
    page.build(self)
  end

  def build_page_infos
    @current_titles = {
      1 => "Page des infos", 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 
    }
    require 'lib/pages/page_infos'
    page = Prawn4book::Pages::PageInfos.new(self)
    page.build(self)
  end

  def build_page_index
    @current_titles = {
      1 => "Index", 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 
    }
    require 'lib/pages/page_index'
    page = Prawn4book::Pages::PageIndex.new(self)
    page.build(self)
  end



  # --- CONSTRUCTION DE LA TABLE DES MATIÈRES ---

  # Préparation de la page où sera écrite la table des matières
  # 
  def init_table_of_contents
    # 
    # Toujours la mettre sur une nouvelle page, comme c'est l'usage
    # 
    start_new_page
    # 
    # Recette pour la table des matières
    # 
    tdata = book.recipe.table_of_content
    # 
    # Instancier un titre pour la table des matières
    # 
    unless tdata[:no_title] || tdata[:title].nil? || tdata[:title] == '---'
      titre = PdfBook::NTitre.new(book:book, titre:tdata[:title], level:tdata[:title_level], pindex:nil)
      titre.print(self)
      book.pages[page_number].add_content_length(tdata[:title].length + 3)
    end
    # 
    # On mémorise le numéro de page de la table des matières
    # 
    tdm.page_number = page_number
  end

end #/PrawnView
end #/Prawn4book
