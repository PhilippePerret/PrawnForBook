=begin

  Class PdfBook::Recipe
  ---------------------
  Pour les recettes de livre (pas de collection)

=end
module Prawn4book
class PdfBook
class Recipe

  attr_reader :pdfbook

  def initialize(pdfbook)
    @pdfbook = pdfbook
    @real_data = {}
  end

  # --- Public General Methods ----

  def [](key)
    get(key)
  end

  def get(key)
    real_data[key.to_sym] || real_data.merge!(key.to_sym => get_data(key))
  end

  def info(key)
    real_data[:info][key]
  end


  # --- Precidate Methods ---

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

  def table_of_content?
    :TRUE == @hastdm ||= true_or_false(get(:table_of_content)[:display] === true)
  end

  def page_info?
    :TRUE == @writepageinfo ||= true_or_false(get(:page_info)[:display] === true)
  end


  # --- Precise Recipe Data ---

  def title
    @title ||= get(:book_title)
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
    @data_collection ||= pdfbook.collection? ? pdfbook.collection.data : {}
  end


DEFAULT_DATA = {
  info: {},
  num_page_style: 'num_page',
  headers: {},
  footers: {},
  page_info: {}
}

end #/class Recipe
end #/class PdfBook
end #/module Prawn4book
