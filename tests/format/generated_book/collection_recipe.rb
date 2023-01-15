require_relative 'abstract_recipe'
module GeneratedBook
class Collection
class Recipe < AbstractRecipe

  REAL_PATH_DATA = {
    # -- Données de la collection --
    name:             [:collection_data, :name],
    # -- Éditeur --
    publisher_name:   [:publishing, :name],
    logo:             [:publishing, :logo_path],
    # -- Imprimerie --
    imprimerie:       [:page_infos, :printing, :name],
    imprimerie_ville: [:page_infos, :printing, :lieu],
    # -- Format des livres --
    leading:      [:book_format, :text, :leading],
    line_height:  [:book_format, :text, :line_height],
    book_height:  [:book_format, :book, :height],
    page_height:  [:book_format, :book, :height],
    height:       [:book_format, :book, :height],
    margin_top:   [:book_format, :page, :margins, :top],
    margin_left:  [:book_format, :page, :margins, :left],
    margin_bot:   [:book_format, :page, :margins, :bot],
    margin_bottom:[:book_format, :page, :margins, :bot],
    margin_right: [:book_format, :page, :margins, :right],
    indent:       [:book_format, :text, :index],
    # - les pages à insérer -
    page_de_titre:  [:inserted_pages, :page_de_titre],
    page_de_garde:  [:inserted_pages, :page_de_garde],
    faux_titre:     [:inserted_pages, :faux_titre],
    page_infos:     [:inserted_pages, :page_infos],
    # - les titres -
    titre1_on_next_page:  [:titles, :level1, :next_page],
    titre1_on_belle_page: [:titles, :level1, :belle_page],
    titre1_lines_before:  [:titles, :level1, :lines_before],
    titre1_lines_after:   [:titles, :level1, :lines_after],
    titre1_font_size:     [:titles, :level1, :size],
    titre2_lines_before:  [:titles, :level2, :lines_before],
    titre2_lines_after:   [:titles, :level2, :lines_after],
    titre2_font_size:     [:titles, :level2, :size],
  }

attr_reader :collection
def initialize(collection)
  super
  @collection = collection
end

def recipe_name; 'collection_recipe.yaml' end


end #/class Recipe
end #/class Collection
end #module GeneratedBook
