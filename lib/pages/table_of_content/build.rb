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
    me = my = self
    
    # 
    # On se rend sur la page voulue
    # 
    pdf.go_to_page(tdm.page_number)
    spy "On rejoint la page #{tdm.page_number} pour écrire la TdM".jaune
    pdf.move_down(recipe_tdm[:lines_before] * tdm_line_height)
    #
    # Il faudrait calculer la hauteur totale de la table des 
    # matières pour bien la placer sur un certain nombre de pages
    # 

    # Si on doit numéroter, on doit calculer la taille de la boite
    # pour le numéro, pour chaque niveau de titre. Pour ce faire,
    # on doit donc, pour chaque niveau de titre, relever le nombre
    # (numéro de page ou hybrid) le plus grand.
    # 
    (1..recipe_tdm[:level_max]).each do |n|
      recipe_tdm["level#{n}".to_sym].merge!(numero_max: "xx")
    end
    begin
      tdm.each_titre do |titre|
        PFBFatalError.context = "#{titre.inspect}"
        next if titre.level > recipe_tdm[:level_max]
        num = titre.numero.to_s
        niv = titre.level
        key = "level#{niv}".to_sym
        len = num.length
        recipe_tdm[key].merge!(numero_max: num) if len > recipe_tdm[key][:numero_max].length
      end
    rescue Exception => e
      raise PFBFatalError.new(850, {context: "Calcul du chiffre le plus grand", error: e.message, data: recipe_tdm.inspect})
    end

    # L’indentation peut avoir été donnée en string, on la corrige
    # partout
    recipe_tdm.each do |k, rdata|
      next unless rdata.is_a?(Hash)
      if rdata[:indent].is_a?(String)
        recipe_tdm[k][:indent] = rdata[:indent].to_f
      end
    end

    # - Couleur normale -
    pdf.update do
      fill_color "000000"
      font(Fonte.default) # TODO 
    end


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
      # - On ne prend pas au-dessus du niveau de titre voulu -
      next if titre.level > recipe_tdm[:level_max]
      # 
      # Si le niveau de titre change, il faut aussi changer les
      # données courantes
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
        separator     = cdata[:separator]||'.'
        titre_width   = cdata[:titre_width]
        numero_width  = cdata[:numero_width]
      end
      # 
      # Le titre à inscrire (avec )
      # 
      content = titre.content # par défaut (si non numéroté)
      if me.numeroter?
        pdf.update do

          titre_width = width_of(content)

          ####################################
          ### Impression du NUMÉRO DE PAGE ###
          ####################################
          float {
            span(numero_width, **{position: :right}) { 
              text(titre.numero.to_s, **{size: cdata[:numero_size]})
            }
            # Les lignes d’alignement
            # sep = "#{" #{separator}" * 100}"
            sep = "#{" #{separator}" * 30}"
            text_box(sep, **{
              at:[indent + 10, cursor + line_height],
              width: bounds.width - (indent + 10 + numero_width),
              height: 18,
              overflow: :truncate,
            })
          }
        end
      end

      ############################
      ### Impression du TITRE  ###
      ############################
      spy "[1020] Impression du titre #{content.inspect} (niveau #{titre.level})".bleu
      pdf.update do
        toptions = {
          at:[indent, cursor], 
          width: titre_width, 
          # height: (my.tdm_line_height),
          height: 18,
          inline_format: true,
        }

        spy "       options: #{toptions.inspect}".bleu
        text_box(content, **toptions)
        move_down(my.tdm_line_height)
        # Passer à la page suivante si trop peu de reste
        start_new_page if cursor < 20
      end

      # break # pour voir

    end #/fin de loop

  end

  ##
  # Méthode qui définit dans recipe_tdm[:level<+level+>] les données
  # utiles pour les placements. Une fois pour toutes, pour ne pas
  # avoir à les recalculer pour tous les titres de même niveau
  # 
  def define_values_for_niveau_titre(pdf, level)
    
    my = self

    # Clé de niveau de titre
    key_level = "level#{level}".to_sym

    # Données actuelles du niveau de titre
    cdata = recipe_tdm[key_level]

    # Largeur du numéro (en fonction du numéro le plus grand de ce
    # niveau de titre)
    # 
    font_size_numero = cdata[:numero_size] == :same ? cdata[:size] : cdata[:numero_size]
    numero_width = nil
    pdf.update do
      font(cdata[:font], **my.data_font_for(cdata.merge(size: font_size_numero)))
      numero_width = pdf.width_of(cdata[:numero_max] || "xxx")
    end
    cdata.merge!(numero_width: numero_width)
    # - Application de la fonte pour ce titre -
    pdf.font(cdata[:font], **data_font_for(cdata))
    # - Largeur du niveau de titre -
    begin
      titre_width = pdf.bounds.width - cdata[:numero_width] - (cdata[:indent]||0)
    rescue Exception => e
      puts "Problème avec cdata = #{cdata.inspect}".rouge
      puts e.message.rouge
      exit
    end
    cdata.merge!(titre_width: titre_width)
    # On retourne la table
    return cdata
  end

  def data_font_for(dfont)
    datafont = {size: dfont[:size]}
    datafont.merge!(style: dfont[:style]) unless dfont[:style].nil?
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
