module Prawn4book
class Bibliography

  # --- CLASSE ---

  class << self

    # @prop Table des bibliographies
    attr_reader :items

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
    def add_occurrence_to(bib_tag, doccurrence)
      raise "Je dois apprendre à ajouter l'occurrence"
    end

    ##
    # @return l'instance de la bibliographie de tag +bib_tag+
    # 
    def get(bib_tag)
      @items[bib_tag]
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
      @items ||= {}
      bib = Bibliography.new(pdfbook, data)
      @items.merge!(bib.tag => bib)
      return bib
    end

  end #/<< self

  # --- INSTANCE ---

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
    @items    = []
  end

  # --- Printing Methods ---

  ##
  # Méthode principale appelée quand on doit écrire une table
  # des matières
  # 
  def print(pdf)
    if items.empty? 
      puts "Pas d'occurrence pour la bibliographie « #{title} ».".orange
      return
    end
    ititre = PdfBook::NTitre.new(pdfbook, text: title, level:1)
    ititre.print(pdf)

    puts "Je dois apprendre à imprimer une bibliographie".jaune
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
    @items.key?(item_id) || begin
      @items.merge!(item_id => BiblioItem.new(self, bibdata[item_id]))
    end
    @items[item_id].add(doccurrence)
  end

  # --- Helpers Methods ---

  def formated_title
    raise "Je dois apprendre à formater le titre (en fonction de son dernier placement)"
  end

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
          tbl.merge!(YAML.load_file(pth, aliases: true))
        end
        tbl 
      else
        #
        # Quand c'est un fichier 
        # 
        YAML.load_file(data_path, aliases: true)
      end
    end
  end

  # @prop Chemin d'accès soit au fichier des données soit au dossier
  # contenant les fiches des données.
  def data_path
    @data_path ||= begin
      fp = data[:data] || data['data']
      unless File.exist?(fp) # chemin d'accès absolu
        if pdfbook.collection?
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

    def initialize(biblio, data)
      @biblio = biblio
      @data   = data
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

  end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
