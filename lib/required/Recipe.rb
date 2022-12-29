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


  # --- Precidate Methods ---

  def collection?
    :TRUE == @incollection ||= true_or_false(check_if_collection)
  end
  def paragraph_number?
    :TRUE == @numeroterpar ||= true_or_false(get(:opt_num_parag))
  end

  def skip_page_creation?
    :TRUE == @skipfirst ||= true_or_false(get(:skip_page_creation) === true)
  end

  def page_de_garde?
    :TRUE == @haspagegarde ||= true_or_false(inserted_pages[:page_de_garde])
  end

  def page_faux_titre?
    :TRUE == @hasfauxtitre ||= true_or_false(inserted_pages[:faux_titre])
  end

  def page_de_titre?
    :TRUE == @haspagetitre ||= true_or_false(inserted_pages[:page_de_titre])
  end

  def page_info?
    :TRUE == @writepageinfo ||= true_or_false(inserted_pages[:page_infos])
  end


  # --- Precise Recipe Data ---

  def book_id
    @book_id ||= book_data[:book_id]
  end
  def title
    @title ||= book_data[:book_title]
  end
  def subtitle
    @subtitle ||= book_data[:book_subtitle].gsub(/\\n/, "\n")
  end
  def publisher
    @publisher ||= book_data[:publisher]
  end
  def auteurs
    @auteurs ||= book_data[:auteurs]
  end



  def page_info
    @page_info ||= get(:page_info)
  end

  def headers
    @headers ||= get(:headers)
  end
  def footers
    @footers ||= get(:footers)
  end

  def style_numero_page
    @numero_page_style ||= get(:num_page_style)
  end

  def line_height
    @line_height ||= get(:line_height, DEFAULT_LINE_HEIGHT)
  end

  # --- Blocs de données ---

  def fonts_data
    @fonts_data ||= get(:fonts, {})
  end
  alias :fonts :fonts_data

  def book_data
    @book_data ||= get(:book_data, {})
  end

  def titles_data
    @book_titles ||= get(:titles, {})
  end

  def inserted_pages
    @inserted_pages ||= get(:inserted_pages, {})
  end

  def page_infos
    @page_infos ||= get(:page_infos, {})
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

  def data_collection
    @data_collection ||= collection? ? owner.collection.data : {}
  end


  private

  def path
    @path ||= owner.recipe_path
  end

    ##
    # @return true si le livre appartient vraiment à une collection,
    # en checkant que cette collection existe bel et bien.
    def check_if_collection
      datacoll = data[:collection]
      return false if datacoll.nil?
      if datacoll === true
        return File.exist?(File.join(File.dirname(owner.folder),'recipe_collection.yaml'))
      else
        # Si :collection n'est pas true, c'est le path du dossier
        # de la collection, quand le livre ne se trouve pas dedans
        # (ce qui est pourtant préférable)
        return File.exist?(datacoll)
      end
    end

end #/class Recipe
end #/module Prawn4book
