module Prawn4book
class << self
def proceed_calc
  puts "Je dois apprendre à calculer les marges".jaune

  while true
    text_width = Q.ask("Largeur de texte voulu (en #{unit_str}) :".jaune).to_i
    break if text_width < page_width
    puts((ERRCALC[:text_width_to_big] % ["#{text_width} #{unit}", page_width_str]).rouge)
  end
  puts "Largeur de texte : #{text_width}".bleu

  while true
    header_height = Q.ask("Hauteur de l’entête en #{unit_str} (0/rien si aucun)".jaune).to_i
    break if header_height < page_height
    puts (ERRCALC[:header_height_to_big] % ["#{header_height} #{unit}", page_height_str]).rouge    
  end

  while true
    footer_height = Q.ask("Hauteur du pied de page en #{unit_str} (0/rien si aucun)".jaune).to_i
    break if footer_height < page_height
    puts (ERRCALC[:footer_height_to_big] % ["#{footer_height} #{unit}", page_height_str]).rouge    
  end
  
  while true
    text_height = Q.ask("Hauteur de texte voulu (en #{unit_str}) :".jaune).to_i
    break if (text_height + header_height + footer_height) < page_height
    puts (ERRCALC[:text_height_to_big] % ["#{text_height} #{unit}", page_height_str]).rouge
  end
  puts "Hauteur de texte : #{text_width}".bleu

  # --- On procède au calcul ---

  height_rest = page_height - (text_height + header_height + footer_height)
  height_rest = height_rest / 2

  top_margin = (header_height + height_rest).round(2)
  bot_margin = (footer_height + height_rest).round(2)

  width_rest = page_width - text_width
  tiers_rest = width_rest / 3
  int_margin = (2 * tiers_rest).round(2)
  ext_margin = tiers_rest.round(2)

  clear
  puts <<~EOT.vert
    Margin haute      : #{top_margin} #{unit}
    Margin basse      : #{bot_margin} #{unit}
    Margin intérieure : #{int_margin} #{unit}
    Margin extérieure : #{ext_margin} #{unit}

    #{"(les marges extérieure et intérieure ont été\n \
calculée en prenant deux tiers pour la marge\n \
intérieure — qui compte la reliure —\n \
et un tiers pour la marge extérieure)".gris}
    EOT

rescue CalcError => e
  puts "#{e.message}".rouge
end
end #/<< self
end #/module Prawn4book
