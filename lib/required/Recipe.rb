=begin

  Class PdfBook::Recipe
  ---------------------
  Pour les recettes de livre (pas de collection)

=end
module Prawn4book
class PdfBook
class Recipe

  attr_reader :pdfbook
  attr_reader :real_data

  def initialize(pdfbook)
    @pdfbook = pdfbook
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
  # Actualisation des données en mergean les nouvelles
  def update(newdata)
    @data = data.merge!(newdata)
    File.write(pdfbook.recipe_path, data.to_yaml)
  end

  def update_collection(newdata)
    @data_collection = data_collection.merge!(newdata)
    File.write(pdfbook.collection.recipe_path, data.to_yaml)
  end


  # --- Precidate Methods ---

  def collection?
    :TRUE == @incollection ||= true_or_false(check_if_collection)
  end
  def paragraph_number?
    :TRUE == @numeroterpar ||= true_or_false(get(:opt_num_parag))
  end

  def skip_page_creation?
    :TRUE == @skipfirst ||= true_or_false(get(:skip_page_creation?) === true)
  end

  def page_de_garde?
    :TRUE == @haspagegarde ||= true_or_false(get(:page_de_garde) === true)
  end

  def page_faux_titre?
    :TRUE == @hasfauxtitre ||= true_or_false(get(:faux_titre) === true)
  end

  def page_de_titre?
    :TRUE == @haspagetitre ||= true_or_false(get(:page_de_titre) === true)
  end

  def page_info?
    :TRUE == @writepageinfo ||= true_or_false(get(:infos,{})[:display] === true)
  end


  # --- Precise Recipe Data ---

  def title
    @title ||= get(:book_title)
  end

  def publisher
    @publisher ||= get(:publisher)
  end

  def auteurs
    @auteurs ||= get(:auteurs)
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
      DEFAULT_DATA.merge!(YAML.load_file(pdfbook.recipe_path, aliases: true))
    end
  end

  def data_collection
    @data_collection ||= collection? ? pdfbook.collection.data : {}
  end


  private

    ##
    # @return true si le livre appartient vraiment à une collection,
    # en checkant que cette collection existe bel et bien.
    def check_if_collection
      datacoll = data[:collection]
      return false if datacoll.nil?
      if datacoll === true
        return File.exist?(File.join(File.dirname(pdfbook.folder),'recipe_collection.yaml'))
      else
        # Si :collection n'est pas true, c'est le path du dossier
        # de la collection, quand le livre ne se trouve pas dedans
        # (ce qui est pourtant préférable)
        return File.exist?(datacoll)
      end
    end

DEFAULT_DATA = {
  info: {},
  num_page_style: 'num_page',
  headers: {},
  footers: {},
  page_info: {},
  table_des_matières: {},
}

end #/class Recipe
end #/class PdfBook
end #/module Prawn4book
