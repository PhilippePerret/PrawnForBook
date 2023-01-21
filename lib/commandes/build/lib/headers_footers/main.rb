module Prawn4book
class PrawnView
  ##
  # Méthode principale qui invoque la construction des entêtes et
  #  pieds de page sur tout le livre
  # 
  def build_headers_and_footers(pdfbook, pdf)
    HeadersFooters.new(pdfbook, pdf).build
  end
end #/class PrawnView

class HeadersFooters
  
  # Exposition du livre et du pdf
  attr_reader :book, :pdf

  # Exposition des données de page préparées
  attr_reader :data_pages

  def initialize(book, pdf)
    @book = book
    @pdf  = pdf  
  end

  # = main =
  # 
  # Construction de toutes les dispositions
  # 
  def build
    data? || return
    # 
    # On donne les données Headfooters à la class Headfooter
    # 
    Headfooter.data = headfooters
    # 
    # On prépare les données des pages pour qu'elles soient 
    # le plus efficiente possibles (en fait, on crée une instance
    # par chaque page qui permettra de la manipuler plus facilement)
    # 
    prepare_data_pages
    # 
    # Boucle sur chaque disposition défini
    # (une disposition correspond à un type d'entête et de pied de
    #  page défini(s) pour un nombre de pages données)
    # 
    dispositions.each do |dispo_id, dispo_data|
      Disposition.new(self, dispo_data.merge(id: dispo_id)).build
    end  
  end

  # - Predicate Methods -

  # @return [Boolean] false s'il n'y a pas de données
  def data?
    not(data.nil? || data.empty? || dispositions.empty? || headfooters.nil? || headfooters.empty?)
  end
  
  # - Pages Methods -

  ##
  # Prépare la propriété publique @data_pages de cette disposition
  # Elle contiendra en clé le numéro de page et en valeur l'instance
  # BookPage
  # 
  def prepare_data_pages
    # 
    # On indique le type de numérotation à la classe
    # 
    BookPage.set_numero_page(book.recipe.page_number?)
    # 
    # Pour consigner les titres courants au fil des pages
    # 
    current_titles_per_level = {1 => nil, 2 => nil, 3 => nil}
    # 
    # Table qui contiendra toutes les données (-> @data_pages)
    # 
    tbl = {}
    # 
    # Boucle sur chaque page du livre (relevées pendant la 
    # construction)
    # 
    # spy "book.pages = #{book.pages.pretty_inspect}"
    # exit
    book.pages.each do |page_num, dpage_init|
      # 
      # Quelquefois, pour le moment, des titres peuvent se glisser
      # malencontreusement dans les données de page
      # 
      next if not(dpage_init.is_a?(Hash))

      dpage = dpage_init.dup
      # spy "dpage = #{dpage.inspect}".gris
      (4..7).each do |niv|
        dpage.delete(:"title#{niv}") if dpage.key?(:"title#{niv}")
        dpage.delete(:"TITLE#{niv}") if dpage.key?(:"TITLE#{niv}")
      end
      (1..3).each do |niv|
        dpage.delete(:"TITLE#{niv}") if dpage.key?(:"TITLE#{niv}")
        kniv = :"title#{niv}"
        dpage[kniv] = nil if dpage[kniv] == ''
      end

      # 
      # Quelques données ajoutées 
      # 
      dpage.merge!(num_page: page_num) # pas :numero (utilisé comme helper)
      #
      # Traitement du titre de niveau 1
      # 
      if dpage[:title1].nil?
        dpage.merge!(current_title1: current_titles_per_level[1])
      else
        current_titles_per_level.merge!({
          1 => dpage[:title1], 2 => nil, 3 => nil
        })
      end
      #
      # Traitement du titre de niveau 2
      # 
      if dpage[:title2].nil?
        dpage.merge!(current_title2: current_titles_per_level[2])
      else
        current_titles_per_level.merge!({
          2 => dpage[:title2], 3 => nil
        })
      end
      #
      # Traitement du titre de niveau 3
      # 
      if dpage[:title3].nil?
        dpage.merge!(current_title3: current_titles_per_level[3])
      else
        current_titles_per_level.merge!({3 => dpage[:title3]})
      end

      tbl.merge!(page_num => BookPage.new(dpage))
    end

    @data_pages = tbl
  end

  # - Data -

  def dispositions
    @dispositions ||= data[:dispositions] || {}
  end
  def headfooters
    @headfooters ||= data[:headfooters]
  end
  def data
    @data ||= book.recipe.headers_footers
  end

end #/class HeadersFooters
end #/module Prawn4book
