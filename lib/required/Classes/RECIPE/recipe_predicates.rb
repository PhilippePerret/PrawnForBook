#
# Module des méthodes prédicates
# 
module Prawn4book
class Recipe

  # @return true s'il faut numéroter les pages
  def numeroration?
    :TRUE == @numeroter ||= true_or_false(format_page[:numerotation] != 'none')
  end

  # --- Pages à insérer ---

  def skip_page_creation?
    format_page[:skip_page_creation] == true
  end

  def page_de_garde?
    inserted_pages[:page_de_garde] == true
  end

  def page_faux_titre?
    inserted_pages[:faux_titre] == true
  end

  def page_de_titre?
    inserted_pages[:page_de_titre] == true
  end

  def page_infos?
    inserted_pages[:page_infos] == true
  end

  # --- Numérotation des pages et des paragraphes ---

  # @return true s'il faut numéroté les pages (avec l'indice de page
  # ou l'incide de paragraphe suivant la valeur de page_num_type)
  def page_number?
    :TRUE == @numeroterpage ||= true_or_false(format_page[:numerotation] == 'pages')
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

  # --- Entêtes et pieds de page ---

  def no_headers_footers?
    format_page[:no_headers_footers] == true
  end


  # --- Table des matières ---

  def tdm_numerotation?
    :TRUE == @numerotertdm ||= true_or_false(table_of_content[:numeroter])
  end


end #/class Recipe
end #/module Prawn4book
