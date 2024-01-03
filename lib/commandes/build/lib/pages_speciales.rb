=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PrawnView

  attr_accessor :table_of_content

  ##
  # Construction de la table des matières
  # Ou DES tables des matières (s’il y en a plusieurs par livre)
  # 
  def build_tables_of_contents
    # S’il n’y a pas de table des matières, on s’en retourne tout de
    # suite.
    return if tdm.pages_number.nil? || tdm.pages_number.empty?
    
    @current_titles = {
      1 => "Table des matières", 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 
    }
    require 'lib/pages/table_of_content'
    self.table_of_content = Prawn4book::Pages::TableOfContent.new(self)
    tdm.pages_number.each do |pnumber|
      self.table_of_content.build(self, pnumber) # mais seulement si elle est définie
    end
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

  def build_credits_page
    @current_titles = {
      1 => "Page des infos", 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil, 
    }
    require 'lib/pages/credits_page'
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

end #/PrawnView
end #/Prawn4book
