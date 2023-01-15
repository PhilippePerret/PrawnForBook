module Prawn4book
class Bibliography

  # --- CLASSE ---

  class << self

    # @prop Table des bibliographies
    attr_reader :items

    # @prop {Symbol} :page ou :paragraph en fonction du type de
    # pagination du livre.
    attr_accessor :page_or_paragraph_key

    def init
      @items = {}
    end

    def require_formaters(pdfbook)
      require pdfbook.module_formatage_path
      Bibliography.extend FormaterBibliographiesModule
    end

    # @return true s'il y a des marques bibliographiques (donc des
    # bibliographie)
    def any?
      not(items.empty?)
    end

    # Au cours du parsing des paragraphes, on utilise cette méthode
    # pour ajouter une occurrence à une des bibliographies
    # 
    # @param bib_tag {String} Tag de la bibliographie
    # @param doccurrence {Hash} Données de l'occurrence
    # 
    # @return L'instance Bibliography concernée
    # 
    def add_occurrence_to(bib_tag, bib_id, doccurrence)
      i = get(bib_tag) || begin
        erreur_fatale ERRORS[:biblio][:biblio_undefined] % [bib_tag, bib_id]
      end
      i.add(bib_id, doccurrence)
      return i
    end

    # Ajoute une occurrence pour un livre
    # La méthode est utilisée pour le moment pour les références
    # croisée
    # 
    def add_occurrence_book(book_id, paragraph)
      add_occurrence_to('livre', book_id, {page: paragraph.first_page, paragraph: paragraph.numero})
    end

    ##
    # @return l'instance de la bibliographie de tag +bib_tag+
    # 
    def get(bib_tag)
      items[bib_tag]
    end

    # @return {Regexp} L'expression régulière pour capter toutes
    # les marques de bibliographies.
    def reg_occurrences
      @reg_occurrences ||= begin
        /(#{items.keys.join('|')})\((.+?)\)/
      end
    end

    ##
    # Instancie la nouvelle bibliographie avec les données +data+
    # et l'enregistre dans les items de bibliographie.
    # 
    def instanciate(pdfbook, data)
      bib = Bibliography.new(pdfbook, data)
      items.merge!(bib.tag => bib)
      return bib
    end

  end #/<< self

  #####################     INSTANCE     #####################

  attr_reader :pdfbook
  attr_reader :data
  # Liste des occurrences
  attr_reader :items

  # @param pdfbook {Prawn4book::PdfBook} Le livre à imprimer
  # @param data {Hash} Données définies dans le fichier recette
  # 
  def initialize(pdfbook, data)
    @pdfbook  = pdfbook
    @data     = data
    @items    = {}
  end

  # --- Printing Methods ---

  ##
  # Méthode principale appelée quand on doit écrire une bibliographie
  # 
  def print(pdf)
    if items.empty? 
      puts (MESSAGES[:biblio][:no_occurrence] % [title]).orange
      return
    end
    # 
    # Titre de la bibliographie
    # 
    ititre = PdfBook::NTitre.new(pdfbook, text:title, level:title_level)
    ititre.print(pdf)
    # 
    # Méthode de classe propre à la bibliographie
    # (définie dans le formater.rb)
    # 
    methode = "biblio_#{tag}".to_sym
    # 
    # Application de la fonte
    # 
    ft = pdf.font(pdfbook.first_font, size: 10)
    items.values.sort_by do |bibitem|
      bibitem.keysort
    end.each do |bibitem|
      str = Bibliography.send(methode, bibitem)
      pdf.text "#{str} : #{bibitem.occurrences_as_displayed_list}.", inline_format: true
    end
  end

  ##
  # Pour ajouter l'item d'identifiant +item_id+ à cette bibliographie
  # 
  # @param item_id {String} Identifiant de l'item, par exemple 'ditd'
  #                         pour le film "Dancer in The Dark"
  # @param doccurrence {Hash} Données texte de l'item, c'est-à-dire
  #                     son numéro de page (:page) et son numéro de
  #                     paragraphe (:paragraph)
  # 
  def add(item_id, doccurrence)
    item_id = item_id.to_sym
    @items.key?(item_id) || begin
      ditem = bibdata[item_id] || begin
        erreur_fatale(ERRORS[:biblio][:bib_item_unknown] % [item_id.inspect, tag])
      end
      @items.merge!(item_id => BibItem.new(self, ditem))
    end
    @items[item_id].add(doccurrence)
  end

  # --- Helpers Methods ---

  # --- Volatile Data ---

  # @prop Table des données
  def bibdata
    @bibdata ||= begin
      if File.directory?(data_path)
        # 
        # Quand c'est un dossier
        #
        tbl = {}
        Dir["#{data_path}/*.yaml"].each do |pth|
          ditem = YAML.load_file(pth, aliases: true)
          item_id = ditem[:id]||ditem['id']
          tbl.merge!(item_id.to_sym => ditem)
        end
        tbl 
      else
        #
        # Quand c'est un fichier (donc déjà une table)
        # 
        YAML.load_file(data_path, aliases: true, symbolize_names: true)
      end
    end
  end

  # @prop Chemin d'accès soit au fichier des données soit au dossier
  # contenant les fiches des données.
  def data_path
    @data_path ||= begin
      fp = data[:data] || data['data']
      unless File.exist?(fp) # chemin d'accès absolu
        if pdfbook.in_collection?
          fp = File.join(pdfbook.collection.folder, fp) # collection
        end
        unless File.exist?(fp)
          fp = File.join(pdfbook.folder, fp)
        end
      end
      fp
    end
  end

  def tag; @tag ||= data[:tag]||data['tag'] end
  def title; @title ||= data[:title]||data[:titre]||data['title']||data['titre'] end
  def title_level; @title_level ||= data[:title_level]||data['title_level']||1 end



  ###############################################################
  ### Class Bibliography::BibItem
  ###
  ### Pour les items de bibliographie. Il y a un item par
  ### élément (par film, par livre, etc.) et il définit dans sa
  ### propriété :items toutes les occurrences.
  ###
  ###############################################################

  class BibItem

    # @prop Instance {Bibliography} de la bibliograhie contenant 
    # l'élément courant. C'est par exemple la bibliographie pour les
    # livre et l'élément courant est un de ces livres
    attr_reader :biblio
    # @prop {Hash} Table des données de l'élément (par exemple les 
    # donnée du livre) telles qu'elles sont définies dans les données
    # bibliographiques.
    # Noter que chacune d'entre elle pourra être atteinte sans la
    # connaitre grâce au missing_method
    attr_reader :data
    # @prop Occurences de l'élément bibliographique.
    attr_reader :items

    def initialize(biblio, data)
      @biblio = biblio
      data || raise("@data est nul pour le bibitem")
      # On symbolize les clés
      tbl = {}
      data.each {|k,v| tbl.merge!(k.to_sym => v)}
      @data   = tbl
      @items  = []
    end

    # Pour retourner la valeur d'une donnée
    def method_missing(name, *args, &block)
      return data[name] if data.key?(name)
      raise ArgumentError.new("Method `#{name}` doesn't exist.")
    end

    # Ajout d'une occurrence dans le texte pour cet élément (ce 
    # livre, ce film, etc.)
    def add(doccur)
      @items << doccur
    end

    def occurrences_as_displayed_list
      @occurrences_as_displayed_list ||= begin
        items.map {|ditem| ditem[Bibliography.page_or_paragraph_key] }.join(', ')
      end
    end

    def keysort
      @keysort ||= title.normalized
    end

  end #/class BibItem


end #/class Bibliography

Bibliography.init

end #/module Prawn4book
