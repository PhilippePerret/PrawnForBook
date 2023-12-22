#
# Module des méthodes prédicates
# 
module Prawn4book
class Recipe

  def hybrid_numerotation?
    :TRUE == @numhybride ||= true_or_false(page_num_type == 'hybrid')
  end
  # @return true s'il faut numéroter les pages
  def numeroration?
    :TRUE == @numeroter ||= true_or_false(format_page[:numerotation] != 'none')
  end

  # --- Pages à insérer ---

  def skip_page_creation?
    format_page[:skip_page_creation] == true
  end

  def page_de_garde?
    (inserted_pages[:page_de_garde]||inserted_pages[:endpage]) == true
  end


  def faux_titre?
    faux_titre === true || faux_titre.is_a?(Hash)
  end

  def page_de_titre?
    !!(inserted_pages[:page_de_titre]||inserted_pages[:title_page])
  end

  def credits_page?
    !!(inserted_pages[:credits_page]||inserted_pages[:page_credits])
  end

  # --- Numérotation des pages et des paragraphes ---

  # @return true s'il faut mettre le numéro des pages (et seulement
  # le numéro des pages). C'est-à-dire en format de pagination normal
  # ou hybride
  def page_number?
    :TRUE == @numeroterpage ||= true_or_false(['pages','hybrid'].include?(page_num_type))
  end

  # @return true s'il faut numéroter les paragraphes
  def paragraph_number?
    :TRUE == @numeroterpar ||= true_or_false(['parags','hybrid'].include?(page_num_type))
  end

  # Si true, pas de numérotation sur les pages vides
  def no_numero_on_empty_page?
    :TRUE == @nonumontempty ||= true_or_false(format_page[:no_num_if_empty])
  end

  # Si true, on ne numérote la page avec le paragraphe que s'il y a 
  # des paragraphe. Sinon, on met le numéro de page.
  def numero_paragraph_only_if_paragraph?
    :TRUE == @numonlyifparag ||= true_or_false(format_page[:num_only_if_num])
  end

  # Si true, on met le numéro de page que s'il n'y a pas de numéro
  # de paragraphe (je ne vois pas trop la différence avec le précédent…)
  def numero_page_if_no_numero_paragraph?
    :TRUE == @numpagifnonumpar ||= true_or_false(format_page[:num_page_if_no_num_parag])
  end

  # --- Logo de la maison d'édition ---

  def logo_defined?
    not(publisher[:logo_path].nil?)    
  end

  def logo_exists?
    logo_defined? && File.exist?(logo_path)
  end

  # --- Entêtes et pieds de page ---

  def no_headers_footers?
    format_page[:no_headers_footers] == true
  end

  def show_grid?
    format_page[:show_grid] || CLI.option(:grid)
  end

  def show_margins?
    format_page[:show_margins] || CLI.option(:display_margins) || CLI.option(:margins)
  end

end #/class Recipe
end #/module Prawn4book
