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
    
    pdf.update do
      # 
      # On se rend sur la page voulue
      # 
      go_to_page(tdm.page_number)
      spy "On rejoint la page #{tdm.page_number} pour écrire la TdM".jaune
      # 
      # Hauteur de ligne dans la table des matières
      # 
      tdm_line_height = me.tdm_line_height

      move_cursor_to_top_of_the_page
      move_down(10 * tdm_line_height)

      #
      # Application de la fonte voulue (ou par défaut)
      # 
      font(me.font_name, **{size:me.font_size, style: me.font_style})
      text "Pour voir si ça marche."

      # 
      # Si on doit numéroter, on doit calculer la taille de la boite
      # pour le numéro
      # 
      numero_width = 0
      if me.numeroter?
        tdm.each_titre do |titre|
          len = width_of(titre.numero.to_s)
          numero_width = len if len > numero_width
        end
        numero_width += 4 # pour avoir du blanc avant
      end
      # 
      # Largeur que prendra le titre
      # 
      titre_width = bounds.width - numero_width

      # 
      # On procède à l'écriture de la table des matières
      # 
      tdm.each_titre do |titre|
        indent      = titre.indent 
        titre_width = (titre_width - indent)
        content = 
          if me.numeroter?
            float do
              span(numero_width, **{position: :right}) { titre.numero.to_s }
            end
            "#{titre.content} #{' .' * 100}"
          else
            titre.content
          end
        spy "Titre dans la table des matières : #{content.inspect}".orange
        spy "Écrit à left: #{indent}, cursor: #{cursor} sur #{titre_width}, avec une hauteur de #{tdm_line_height.inspect}".orange
        # text_box(content, **{at:[indent, cursor], width: titre_width, height: (tdm_line_height + 10), overflow: :truncate})
        text content
        move_down(tdm_line_height)
      end

    end

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
    @tdm_line_height ||= data_tdm[:line_height]
  end

  def font_name   ; @font_name  ||= data_tdm[:font_name]  end
  def font_size   ; @font_size  ||= data_tdm[:font_size]  end
  def font_style  ; @font_style ||= data_tdm[:font_style] end

  def data_tdm
    @data_tdm ||= recipe.table_of_content
  end

end #/class TableOfContent
end #/class Pages
end #/module Prawn4book
