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
    book.pages.each do |page_num, dpage_init|
      # 
      # Quelquefois, pour le moment, des titres peuvent se glisser
      # malencontreusement dans les données de page
      # 
      next if not(dpage_init.is_a?(Hash))
      #
      # Quelque fois il n'y a pas de numéro de page 
      # (pourquoi ? Ça serait bien de le savoir)
      # 
      next if !page_num
      #
      # Le numéro continue attendu
      # 
      continous_numero += 1

      # puts "Traitement de la page #{page_num}".bleu

      if page_num > continous_numero
        #
        # = PROBLÈME DE PAGES MANQUANTES =
        #   (cf. pourquoi dans l'explication de la méthode)
        #   (cf. aussi pourquoi le problème semble avoir été
        #    résolu)
        # 
        # On doit créer les pages de +continous_numero+ jusqu'à
        # page_num - 1 en s'inspirant de la page de numéro
        # <continous_numero - 1>
        # 
        # NON, MAINTENANT C'EST UNE VRAI ERREUR FATALE
        # 
        raise FatalPrawnForBookError.new("Il manque une définition de page, pour une raison inconnue… Je ne peux pas construire ce livre.")
        # #
        # # puts "Problème de page(s) manquante(s) (de #{continous_numero} à #{page_num - 1})".rouge
        # page_reference = tbl[continous_numero-1]
        # dpage_ref = page_reference.data
        # #
        # # On modifie les données de la page de référence pour que 
        # # son numéro de page soit inscrit (si nécessaire)
        # # 
        # page_reference.data.merge!({
        #   content_length: 1000, 
        #   first_par: 1          
        # })

        # #
        # # On ajoute toutes les pages manquantes
        # # 
        # for i in (continous_numero...page_num) do
        #   dpage = {}
        #     .merge(dpage_ref)
        #     .merge({
        #       num_page: i,
        #       # content_length: 1000, 
        #       # first_par: 1
        #     }) 
        #   # puts "\ndpage = #{dpage.pretty_inspect}".bleu
        #   tbl.merge!(i => BookPage.new(book, pdf, dpage))
        #   continous_numero += 1
        #   # added_pages_numeros << i.freeze
        # end
      end

      dpage = dpage_init.dup
      # spy "dpage = #{dpage.inspect}".gris
      (4..7).each do |niv|
        dpage.delete(:"title#{niv}") if dpage.key?(:"title#{niv}")
      end
      (1..3).each do |niv|
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

      #
      # On essaie de passer cette page si elle n'a pas de contenu
      # (note : on ne le fera qu'ici pour relever les titres 
      #  courants)
      next if dpage[:content_length] == 0 || dpage[:first_par].nil?

      #
      # On crée l'instance pour la page
      # 
      tbl.merge!(page_num => BookPage.new(book, pdf, dpage))
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
