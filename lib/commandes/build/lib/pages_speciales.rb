=begin

  Méthodes de construction des pages spéciales livre

=end
module Prawn4book
class PrawnView

  # Gravure des tables des matières
  # 
  def build_tables_of_contents
    return if tdm.pages_number.nil? || tdm.pages_number.empty?
    # - Inscrire une table des matières sur chaque page voulue -
    tdm.pages_number.each do |numero_page|
      book.table_of_content.print(self, numero_page)
    end
  end

  # Gravure page de titre
  # 
  def build_page_de_titre
    require 'lib/pages/page_de_titre'
    page = Prawn4book::Pages::PageDeTitre.new(self)
    page.build(self)
  end

  # Gravure page de faux titre
  # 
  def build_faux_titre
    require_relative 'faux_titre'
    insert_faux_titre
  end

  # Gravure page des crédits
  # 
  def build_credits_page
    require 'lib/pages/credits_page'
    page = Prawn4book::Pages::PageInfos.new(self)
    page.build(self)
  end

  # Gravure de l’index
  # (hors index personnalisés)
  # 
  def build_page_index
    require 'lib/pages/page_index'
    page = Prawn4book::Pages::PageIndex.new(self)
    page.build(self)
  end

end #/PrawnView
end #/Prawn4book
