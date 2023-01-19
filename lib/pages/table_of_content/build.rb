module Prawn4book
class Pages
class TableOfContent

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)

    # 
    # On sait que la table des matières (son emplacement) est défini
    # lorsque son @page_number est défini. Si ça n'est pas le cas,
    # on ne fait rien.
    # 
    if pdf.tdm.page_number.nil?
      spy "Pas de table des matières.".jaune
      return
    end

    #
    # Raccourci de l'instance Prawn4Book::Tdm
    # 
    tdm = pdf.tdm
    # 
    # Raccourci de cette instance
    # 
    me = self
    
    # 
    # On se rend sur la page voulue
    # 
    pdf.go_to_page(tdm.page_number)
    pdf.move_cursor_to_top_of_the_page
    spy "On rejoint la page #{tdm.page_number} pour écrire la TdM".jaune
    #
    # Il faudrait calculer la hauteur totale de la table des 
    # matières pour bien la placer sur un certain nombre de pages
    # 
    pdf.move_down(recipe_tdm[:lines_before] * tdm_line_height)

    # 
    # Si on doit numéroter, on doit calculer la taille de la boite
    # pour le numéro, pour chaque niveau de titre. Pour ce faire,
    # on doit donc, pour chaque niveau de titre, relever le nombre
    # le plus grand.
    # 
    (1..recipe_tdm[:level_max]).each do |n|
      recipe_tdm["level#{n}".to_sym].merge!(numero_max: "xx")
    end
    tdm.each_titre do |titre|
      num = titre.numero.to_s
      niv = titre.level
      key = "level#{niv}".to_sym
      len = num.length
      recipe_tdm[key].merge!(numero_max: num) if len > recipe_tdm[key][:numero_max].length
    end

    # 
    # Les données de titre courante
    # (pour ne pas avoir à répéter chaque fois les fontes, par
    # exemple)
    # C'est la donnée :level<level> de la recette qui sera mise
    # dans cette table.
    # 
    cdata = {}
    # 
    # On procède à l'écriture de la table des matières
    # 
    tdm.each_titre do |titre|
      # 
      # On ne prend pas au-dessus du niveau de titre voulu
      # 
      next if titre.level > recipe_tdm[:level_max]
      # 
      # Si le niveau de titre change, il faut aussi changer les
      # données courante
      # 
      if titre.level != cdata[:level]
        key_level = "level#{titre.level}".to_sym
        if recipe_tdm[key_level].key?(:numero_width)
          cdata = recipe_tdm[key_level]
          pdf.font(cdata[:font], **data_font_for(cdata))
        else
          cdata = me.define_values_for_niveau_titre(pdf, titre.level)
        end
        indent        = cdata[:indent]
        separator     = cdata[:separator]
        titre_width   = cdata[:titre_width]
        numero_width  = cdata[:numero_width]
        spy "numero_width = #{numero_width.inspect}".rouge
      end
      # 
      # Le contenu
      # 
      content = 
        if me.numeroter?
          pdf.update do
            float {
              span(numero_width, **{position: :right}) { text(titre.numero.to_s, **{size: cdata[:numero_size]})}
            }
          end
          # pdf.float do
          #   pdf.span(numero_width, **{position: :right}) { pdf.text titre.numero.to_s }
          # end
          "#{titre.content} #{" #{separator}" * 100}"
        else
          titre.content
        end
      # spy "Titre dans la table des matières : #{content.inspect}".orange
      # spy "Écrit à left: #{indent}, cursor: #{pdf.cursor} sur #{titre_width}, avec une hauteur de #{tdm_line_height.inspect}".orange
      pdf.text_box(content, **{at:[indent, pdf.cursor], width: titre_width, height: (tdm_line_height), overflow: :truncate})
      # pdf.text content
      pdf.move_down(tdm_line_height)
    end

  end

  ##
  # Méthode qui définit dans recipe_tdm[:level<+level+>] les données
  # utiles pour les placements. Une fois pour toutes, pour ne pas
  # avoir à les recalculer pour tous les titres de même niveau
  # 
  def define_values_for_niveau_titre(pdf, level)
    # 
    # 
    # 
    key_level = "level#{level}".to_sym
    # 
    # Données actuelles
    # 
    cdata = recipe_tdm[key_level]
    # 
    # Largeur du numéro (en fonction du numéro le plus grand de ce
    # niveau de titre)
    # 
    font_size_numero = cdata[:numero_size] == :same ? cdata[:size] : cdata[:numero_size]
    pdf.font(cdata[:font], **data_font_for(cdata.merge(size: font_size_numero))) do
      numero_width = pdf.width_of(cdata[:numero_max] || "xxx")
      cdata.merge!(numero_width: numero_width)
    end
    # 
    # Application de la fonte pour ce titre
    # 
    pdf.font(cdata[:font], **data_font_for(cdata))
    # 
    # Largeur du niveau de titre
    # 
    titre_width = pdf.bounds.width - cdata[:numero_width] - cdata[:indent]
    cdata.merge!(titre_width: titre_width)
    # 
    # On retourne la table
    # 
    spy "Table de données pour le titre ##{level} : #{cdata.inspect}".bleu
    return cdata
  end

  def data_font_for(dfont)
    datafont = {size: dfont[:size]}
    datafont.merge!(style: dfont[:style]) unless dfont[:style].nil?
    spy "datafont = #{datafont.inspect}".orange
    return datafont
  end

  # @return [Boolean] true s'il faut numéroter la table des matières
  def numeroter?
    recipe.tdm_numerotation?
  end

  # @return [Boolean] true si la numérotation se fait par les pages
  def num_page?
    recipe.page_number?
  end

  # @return [Integer] Hauteur de ligne (si elle est définie)
  def tdm_line_height
    @tdm_line_height ||= recipe_tdm[:line_height]
  end

  def recipe_tdm
    @recipe_tdm ||= recipe.table_of_content
  end

end #/class TableOfContent
end #/class Pages
end #/module Prawn4book
