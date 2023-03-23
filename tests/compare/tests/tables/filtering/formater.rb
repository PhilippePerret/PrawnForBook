module TableFormaterModule

  def all_properties(ntable)

    rouge = 'FF0000'
    vert  = '00FF00'
    bleu  = '0000FF'
    gris  = '999999'
    blanc = 'FFFFFF'

    ntable.blockcode = Proc.new do

      column(0).row(0).background_color = Prawn::Graphics::Color.rgb2hex([100,100,100])
    
      # Mettre toute une rangée dans une couleur de fond et 
      # couleur de police
      row(0).background_color = 'FCF3CF'
      row(0).text_color       = '900C3F'

      # Mettre toute une colonne dans une couleur de fond et
      # une couleur de police
      column(1).background_color  = 'D35400'
      column(1).text_color        = 'DAF7A6'

      # Largeur et hauteur de colonne et alignement
      column(1).width   = 70
      column(1).height  = 100
      column(1).align   = :center
      column(1).valign  = :bottom

      # Alignement vertical et padding sur une cellule en particulier
      column(1).row(2).valign = :top
      column(1).row(2).padding = 0

      # Padding de rangée de cellules
      row(1).padding = 20

      # Modifications de toutes les bordures
      column(0..-1).borders = [:left, :bottom]
      column(0..-1).border_width = [0.1, 3]

      # Border d'une cellule en particulier
      c = column(2).row(1)
      c.border_width = 4
      c.borders = [:top, :right, :bottom, :left]
      c.border_color = [rouge, vert, bleu, gris]
      c.border_lines = [:solid, :dashed, :dotted]

      # Définition des polices
      fontes = [
        {name:'Geneva', style: :regular, size:9, color: bleu},
        {name:'NewYork', style: :italic, size: 15, color: '2E86C1'},
        {name:'ArialBlack', style: :normal, size: 12, color: rouge},
        {name:'Courier', style: :bold, size: 11, color: gris},
        {name:'GaramondL', style: :italic, size: 16, color: blanc},
        {name:'Verdana', style: :bold_italic, size: 10, color: 'A04000'},
      ]
      lesfontes = fontes.dup
      row_num = -1
      (0..5).each do |col|
        lafonte = lesfontes.pop
        c = column(col).row(row_num += 1)
        c.font = lafonte[:name]
        c.font_style = lafonte[:style]
        c.size = lafonte[:size]
        c.text_color = lafonte[:color]
      end

      # Élargissement du texte pour qu'il tienne
      c = column(4).row(4)
      c.width   = 50
      c.height  = 40
      c.overflow = :shrink_to_fit

      # Application d'une rotation
      c = column(3).row(3)
      c.rotate = 60
      c.valign = :center
      c.align = :center

    end

      # Colspan et Rowspan
      # (Pour procéder à cette opération, on doit supprimer des
      #  cellules)
      ntable.lines[0][1] = nil
      ntable.lines[0][2] = nil
      ntable.lines[0] = ntable.lines[0].compact
      ntable.lines[0][0] = {content:ntable.lines[0][0], colspan:3}
    
    return nil
  end

end #/TableFormaterModule
