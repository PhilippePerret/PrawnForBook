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



  # --- CONSTRUCTION DE LA TABLE DES MATIÈRES ---

  # Préparation de la page où sera écrite la table des matières
  # 
  def init_table_of_contents

    # Recette pour la table des matières
    tdata = book.recipe.table_of_content

    # On passe toujours sur la page suivante
    start_new_page

    # Instancier un titre pour la table des matières
    # 
    unless tdata[:no_title] || tdata[:title].nil? || tdata[:title] == '---'
      titre = PdfBook::NTitre.new(book:book, titre:tdata[:title], level:tdata[:title_level], pindex:nil)
      titre.print(self)
      book.pages[page_number].add_content_length(tdata[:title].length + 3)
    end

    # Il faut toujours se placer sur une page paire (gauche) sauf si
    # :not_on_even est true
    if page_number.odd? && not(tdata[:not_on_even])
      start_new_page
    end

    # On mémorise le numéro de première page de cette table des
    # matières
    first_toc_page_number = page_number.freeze

    # Le nombre de pages à ajouter est défini par :pages_count qui
    # doit impérativement être un nombre pair.
    added = tdata[:pages_count] || 2
    if added.odd? || added == 0
      add_erreur(PFBError[853] % {num: added})
      added += 1
    end

    # On ajoute autant de pages que voulu (une page a déjà été
    # ajoutée plus haut)
    (added - 1).times do start_new_page end

    # On mémorise le numéro de page de cette table des matières
    # (il peut y en avoir plusieurs)
    # 
    tdm.add_page_number(first_toc_page_number)
  end

  # Méthode qui produit la TABLE DES ILLUSTRATIONS dans la livre
  # 
  def build_list_of_illustrations
    msg = "Je dois apprendre à produire une table des illustrations"
    puts "\n#{msg.rouge}"
    add_erreur(msg)
  end

end #/PrawnView
end #/Prawn4book
