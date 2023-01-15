=begin

  Class PdfBook::Recipe
  ---------------------
  Pour les recettes de livre (pas de collection)

=end
module Prawn4book
class Recipe

  attr_reader :owner
  attr_reader :real_data

  def initialize(owner)
    @owner = owner
    @real_data = {}
  end

  # --- Public General Methods ----

  def [](key)
    get(key)
  end

  def get(key, default = nil)
    real_data[key.to_sym] || begin
      keydata = get_data(key)
      real_data.merge!(key.to_sym => keydata)
      keydata
    end || default
  end

  def info(key)
    real_data[:info][key]
  end

  def data_collection
    @data_collection ||= begin
      if owner.in_collection?
        owner.collection.data
      else {} end
    end
  end

  ##
  # Actualisation des données en mergeant les nouvelles
  # @note
  #   Mais normalement, cette méthode ne doit pas être employée
  #   car elle fait perdre toutes les balises dans les commentaires…
  # @deprecated
  #   Ne pas utiliser, ces méthodes détruisent les commentaires et donc
  #   les balisages de bloc de code.
  # 
  def update(newdata)
    warn "Ne pas utiliser cette méthode, elle détruit les commentaires."
    # @data = data.merge!(newdata)
    # File.write(path, data.to_yaml)
  end
  def update_collection(newdata)
    warn "Ne pas utiliser cette méthode, elle détruit les commentaires."
    # @data_collection = data_collection.merge!(newdata)
    # File.write(owner.collection.recipe_path, data.to_yaml)
  end

  ##
  # Méthode à utiliser pour actualiser les données dans le fichier
  # recette (lorsqu'elles ne le sont pas à la main)
  # 
  # @param [String|Symbol] tag_name   Ce que c'est. Par exemple 'book_data' ou 'fonts'
  # @param [Hash] new_data Les données à insérer. Elles doivent avoir la forme {:tag_name => data} mais si ça n'est pas le cas, la méthode corrige.
  def insert_bloc_data(tag_name, new_data)
    # 
    # Le code qu'il faudra insérer
    # 
    new_data = {tag_name.to_sym => new_data} unless new_data.key?(tag_name.to_sym)
    inserted = new_data.to_yaml
    inserted = inserted[4..-1].strip if inserted.start_with?("---")
    # 
    # On recherche la balise dans le code actuel
    # 
    code    = raw_code
    dec_in, dec_out = get_offsets_tagname_in_recipe(tag_name)
    tag_in  = "#<#{tag_name}>"
    tag_out = "#</#{tag_name}>"

    if dec_in.nil?
      # 
      # Balise inexistante => on met le bloc de code à la fin.
      # 
      code = [code, tag_in, inserted.strip, tag_out].join("\n")
    else
      # 
      # Quand le bloc de code a été trouvé
      # 
      code = [code[0..dec_in].strip, inserted.strip, code[dec_out..-1].strip].join("\n")
    end
    # 
    # On écrit le code corrigé dans le fichier recette
    # 
    File.write(path, code)
  end

  def get_offsets_tagname_in_recipe(tag_name)
    code = raw_code
    tag_in  = "#<#{tag_name}>"
    tag_out = "#</#{tag_name}>"
    dec_in  = code.index(tag_in)
    dec_out = code.index(tag_out)
    if dec_in.nil?
      #
      # Balise d'entrée introuvable…
      # 
      # Si la balise de fin est pourtant définie, on signale une
      # erreur.
      dec_out.nil? || begin
        puts <<~TXT.orange
          Attention, une balise de fin (#{tag_out}) existe dans le fichier
          recette (sans balise de début). Il faudrait la supprimer pour
          ne pas avoir de problème.
        TXT
        sleep 4
      end
    else
      # 
      # Si la balise d'entrée existe
      # 
      # Il faut absolument que la balise de fin existe aussi, sinon
      # on est incapable de prendre les données (ce serait trop
      # risqué, on risquerait de prendre les données d'autres blocs)
      # 
      dec_out || raise("La balise '</#{tag_name}>' est introuvable.")
      # 
      # Mais la balise de fin peut exister mais être avant la balise
      # de début.
      # Dans ce cas, on cherche une balise de fin après. Si on la
      # trouve, on poursuit en signalant qu'il faut corriger le 
      # problème. Sinon, on s'arrête pour la même raison que 
      # ci-dessus.
      # 
      if dec_out < dec_in
        dec_out = code.index(tag_out, dec_in)
        if dec_out.nil?
          raise("Une balise '</#{tag_name}>' a été trouvée, mais avant la balise de début…")
        else
          puts <<~TXT.orange
            Attention : une balise de fin a été trouvée avant la balise
            de début. Il faudrait la supprimer.
            (je poursuis quand même en tenant compte de la deuxième)
          TXT
          sleep 4
        end
      end

      # 
      # Rectification des valeurs
      # 
      dec_in += tag_in.length
      dec_out -= 1

    end
    return [dec_in, dec_out]
  end

  def raw_code
    File.exist?(path) ? File.read(path) : "---\n"
  end


  # --- PRECIDATE METHODS ---

  def numeroration?
    :TRUE == @numeroter ||= true_or_false(book_format[:text][:numerotation] != 'none')
  end
  def paragraph_number?
    :TRUE == @numeroterpar ||= true_or_false(book_format[:text][:numerotation] == 'parags')
  end
  def page_number?
    :TRUE == @numeroterpage ||= true_or_false(book_format[:text][:numerotation] == 'pages')
  end

  def skip_page_creation?
    :TRUE == @skipfirst ||= true_or_false(book_format[:page][:skip_page_creation])
  end

  # --- Pages insérées ---

  DEFAULT_INSERTED_PAGES = {
    page_de_garde:true, faux_titre:false, page_de_titre:true, page_infos:true
  }

  def page_de_garde?
    inserted_pages[:page_de_garde]
  end

  def page_faux_titre?
    inserted_pages[:faux_titre]
  end

  def page_de_titre?
    inserted_pages[:page_de_titre]
  end

  def page_infos?
    inserted_pages[:page_infos]
  end


  # --- Volatile Data ---

  def dimensions
    @dimensions ||= [book_format[:book][:width], book_format[:book][:height]]
  end

  # Font par défaut (la première définie ou par défaut)
  def default_font
    @default_font ||= fonts_data.values.first
  end
  def default_font_name
    @default_font_name ||= begin
      (default_font ? fonts_data.keys : ["Times-Roman"]).first
    end
  end
  def default_font_style
    @default_font_style ||= begin
      if default_font then default_font[:style] end || :regular
    end
  end
  def default_font_size
    @default_font_size ||= begin
      if default_font then default_font[:size] end || 10
    end
  end


  # --- Group Recipe Data ---

  def book_id
    @book_id ||= book_data[:id]
  end
  def title
    @title ||= book_data[:title]
  end
  def subtitle
    @subtitle ||= book_data[:subtitle]&.gsub(/\\n/, "\n")
  end
  def auteurs
    @auteurs ||= book_data[:auteurs]
  end
  def isbn
    @isbn ||= book_data[:isbn] || '---'
  end
  def depot_legal
    @depot_legal ||= book_data[:depot_legal]
  end

  def headers_footers
    @headers ||= get(:headers_footers)
  end

  def style_numero_page
    @numero_page_style ||= get(:num_page_style)
  end

  def leading
    book_format[:text][:leading]
  end

  def line_height
    book_format[:text][:line_height]
  end

  # --- Blocs de données ---

  ##
  # Méthode générale utilisée pour peupler une donnée avec ses valeurs
  # par défaut.
  # @note
  #   La méthode s'appuie sur les données définies dans les "pages
  #   spcéciales" (fichier data.rb) qui définissent forcément les
  #   valeurs par défaut.
  def self.peuple_with_default_data(receiver, referencer)
    referencer.each do |k, v|
      if v.key?(:default) # => une valeur
        valdef = v[:default]
        valdef = valdef.call if valdef.is_a?(Proc)
        receiver.merge!(k => valdef) unless receiver.key?(k)
      else
        receiver.merge!(k => {}) unless receiver.key?(k)
        v.each do |sk, sv|
          if sv.key?(:default) # => une valeur
            svaldef = sv[:default]
            svaldef = svaldef.call if svaldef.is_a?(Proc)
            receiver[k].merge!(sk => svaldef) unless receiver[k].key?(sk)
          else # => une groupe de valeurs
            receiver[k].merge!(sk => {}) unless receiver[k].key?(sk)
            sv.each do |ssk, ssv|
              ssvaldef = ssv[:default]
              ssvaldef = ssvaldef.call if ssvaldef.is_a?(Proc)
              receiver[k][sk].merge!(ssk => ssvaldef) unless receiver[k][sk].key?(ssk)
            end
          end
        end
      end
    end
    return receiver
  end

  def book_format
    @book_format ||= begin
      require 'lib/pages/book_format/data.rb'
      self.class.peuple_with_default_data(get(:book_format, {}), Pages::BookFormat::PAGE_DATA)
    end
  end

  def book_data
    @book_data ||= begin
      require 'lib/pages/book_data/data.rb'
      self.class.peuple_with_default_data(get(:book_data, {}), Pages::BookData::PAGE_DATA)
    end
  end

  def page_infos
    @page_infos ||= begin
      require 'lib/pages/page_infos/data.rb'
      self.class.peuple_with_default_data(get(:page_infos, {}), Pages::PageInfos::PAGE_DATA)
    end
  end

  def page_de_titre
    @page_de_titre ||= begin
      require 'lib/pages/page_de_titre/data.rb'
      self.class.peuple_with_default_data(get(:page_de_titre, {}), Pages::PageDeTitre::PAGE_DATA)
    end
  end

  def table_of_content
    @table_of_content ||= begin
      require 'lib/pages/table_of_content/data.rb'
      self.class.peuple_with_default_data(get(:table_of_content, {}), Pages::TableOfContent::PAGE_DATA)
    end
  end

  def publishing
    @publishing ||= get(:publishing, {})
  end

  def fonts_data
    @fonts_data ||= get(:fonts, {})
  end
  alias :fonts :fonts_data

  # @return [Hash<Hash>] Les données pour les six niveaux de
  # titre.
  # @note
  #   Que ces données soient définies ou non, elles ont toujours
  #   une valeur. Les valeurs par défaut sont fixées par la méthode
  #   get_all_titles_data
  def titles_data
    @book_titles ||= get_all_titles_data
  end

  def biblios_data
    @biblios_data ||= get(:biblios, {})
  end

  def inserted_pages
    @inserted_pages ||= get(:inserted_pages, {})
  end

  def headers_footers_data
    @headers_footers_data ||= get(:headers_footers, {})
  end

  # --- Private Fonctional Methods ---

  def get_data(key)
    donnee = data[key.to_s] || data[key.to_sym]
    if donnee.nil? || donnee == :collection
      data_collection[key.to_sym]
    else
      donnee
    end
  end

  def data
    @data ||= begin
      dt = {}
      if File.exist?(path)
        dt = YAML.load_file(path, aliases: true, symbolize_names: true) || {}
      end
      DEFAULT_DATA.merge!(dt)
    end
  end

  DEFAULT_DATA = {}

  private

  ##
  # @return [Hash] Une table contenant toutes les données pour les
  # titres qu'ils soient définis ou non
  def get_all_titles_data
    tdata = get(:titles, {})
    # 
    # On s'assure qu'il y ait une donnée par niveau de titre
    # 
    (1..6).each do |niveau|
      klevel = :"level#{niveau}"
      tdata.key?(klevel) || tdata.merge!(klevel => {})
      # 
      # On s'assure que chaque titre définissent bien chaque donnée
      # 
      [:font, :size, :lines_before, :lines_after, :leading, :style
      ].each do |prop|
        tdata[klevel].key?(prop) || begin
          tdata[klevel].merge!(prop => title_default_value_prop(prop, niveau))
        end
      end
      if niveau == 1
        # 
        # Spécialement pour le titre de niveau 1
        # 
        tdata[klevel].key?(:next_page)  || tdata[klevel].merge!(next_page: true)
        tdata[klevel].key?(:belle_page) || tdata[klevel].merge!(belle_page: false)
      end
    end

    # spy "tdata des titres = #{tdata.pretty_inspect}"
    return tdata
  end

  # Définit et @return la valeur par défaut de la propriété +prop+
  # pour un titre de niveau +niveau+
  # @api private
  def title_default_value_prop(prop, niveau)
    case prop
    when :font          then "Helvetica"
    when :size          then 28 - (niveau * 2)
    when :style         then :regular
    when :leading       then 0.0
    when :lines_before  then 7 - niveau
    when :lines_after   then niveau > 3 ? 0 : (4 - niveau)
    end
  end


  def path
    @path ||= owner.recipe_path
  end

end #/class Recipe
end #/module Prawn4book
