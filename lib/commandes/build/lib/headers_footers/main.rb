module Prawn4book
class PrawnView
  ##
  # Méthode principale qui invoque la construction des entêtes et
  #  pieds de page sur tout le livre
  # 
  def build_headers_and_footers(book)
    HeadersFooters.new(book, self).build
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
    #
    # On ne fait rien s'il ne faut pas placer de header/footer.
    # 
    # @note
    #   Par défaut, il y a toujours au moins un pied de page avec le
    #   numéro de la page. Pour qu'il n'y ait pas de données, il faut 
    #   que l'utilisateur l'ait explicitement stipulé.
    # 
    data? || return
    # 
    # On donne les données Headfooters à la class Headfooter
    # 
    # @pourquoi ?
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
  # 
  # @notes
  # 
  #   * Elle contient en clé le numéro de la page et en valeur 
  #     l'instance BookPage
  # 
  #   * Cette méthode permet de gérer aussi le fait qu'une grande
  #     table, qui tient sur plusieurs pages, ne génère pas de 
  #     nouvelle page (start_new_page) et que ces autres pages ne
  #     sont donc pas numérotées.
  #     Le problème a été réglé (bug #99) en traitant les pages
  #     ajoutées par une méthode d'helper ou de formator.
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
    # Pour s'assurer que toutes les pages sont traitées
    # 
    continous_numero = 0
    #
    # Pour mettre les numéros de pages qu'il faudra ajouter
    # à book.pages
    # PLUS MAINTENANT. TOUTES LES PAGES DOIVENT AVOIR ÉTÉ CRÉÉES
    # 
    # added_pages_numeros = []
    # 
    # Boucle sur chaque page du livre
    # 
    # @notes 
    # 
    #   * Elles ont été relevées pendant la construction du livre
    #     dans la méthode 
    # 
    # spy "book.pages = #{book.pages.pretty_inspect}"
    # exit
    # book.pages.each do |page_num, dpage_init|
    book.pages.each do |page|
      #
      # Le numéro continue attendu
      # 
      continous_numero += 1

      # raise "Numéro de page ne correspond pas" if page.number != continous_numero

      #
      # Traitement du titre de niveau 1
      # 
      if page.data[:titres][1].nil?
        page.data[:titres].merge!(current_title1: current_titles_per_level[1])
      else
        current_titles_per_level.merge!({
          1 => page.data[:titres][1], 2 => nil, 3 => nil
        })
      end
      #
      # Traitement du titre de niveau 2
      # 
      if page.data[:titres][2].nil?
        page.data[:titres].merge!(current_title2: current_titles_per_level[2])
      else
        current_titles_per_level.merge!({
          2 => page.data[:titres][2], 3 => nil
        })
      end
      #
      # Traitement du titre de niveau 3
      # 
      if page.data[:titres][3].nil?
        page.data[:titres].merge!(current_title3: current_titles_per_level[3])
      else
        current_titles_per_level.merge!({3 => page.data[:titres][3]})
      end

      #
      # On essaie de passer cette page si elle n'a pas de contenu
      # (note : on ne le fera qu'ici pour relever les titres 
      #  courants)
      next if page.no_content?

      #
      # On crée l'instance pour la page
      # TODO : Il faudrait fonctionner avec la même instance 
      # PdfBook::Page, ne pas avoir à en créer une nouvelle.
      tbl.merge!(page.number => BookPage.new(book, pdf, page.data))
    end

    @data_pages = tbl
  end

  # - Data -

  def dispositions
    @dispositions ||= data[:dispositions] || dispositions_default
  end
  def headfooters
    @headfooters ||= data[:headfooters] || headfooters_default
  end
  def data
    @data ||= book.recipe.headers_footers || data_default
  end

  private

    # - Données par défaut -

    def data_default
      return nil if book.recipe.no_headers_footers?
      {
        dispositions: {
          numerotation_pages: {
            name: "Pages numéro",
            footer_id: :numeropage,
            header_id: nil
          }
        },
        headfooters: {
          numeropage: {
            name: "Numéro de page au centre des pages",
            font_n_style: 'Helvetica/regular',
            size: 10,
            pg_left: {align: :left, content: :numero},
            pd_right: {align: :right, content: :numero},
          }
        }
      }      
    end
end #/class HeadersFooters
end #/module Prawn4book
