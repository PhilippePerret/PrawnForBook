module Prawn4book
module Manual
class Feature

  # Pour généraliser la fabrication des features puces
  def data_for_puce(subtitle:, puce:, size:, left:, vadjust:, hadjust: nil)
    subtitle(subtitle)
    rec = ['---']
    rec << 'book_format:'
    rec << '  text:'
    rec << '    puce:'
    rec << "      text: #{puce.inspect}"
    rec << "      size: #{size}"
    rec << "      left: #{left}mm" if left
    rec << "      hadjust: #{hadjust}mm" if hadjust
    rec << "      vadjust: #{vadjust}mm" if vadjust

    real_recipe(rec.join("\n")) 

    _ps = (vadjust && vadjust > 1) ? 's' : ''

    real_texte <<~EOT
      * Ceci est une puce `#{puce.inspect}` de #{size} points, remontée de #{vadjust} point#{_ps}, avec les autres paramètres laissés intacts,
      * Le second item identique,
      * Le troisième.
      EOT

    msg = ["![page-1](align: :center)"]
    if vadjust
      msg << "*(Noter dans la recette l’ajustement vertical de la puce grâce à la propriété `vadjust` mise à `#{vadjust}`)*"
    end
    if hadjust
      msg << "*(Noter dans la recette l’ajustement horizontal de la puce grâce à la propriété `hadjust` mise à `#{hadjust}`)*"
    end
    msg << "(( new_page ))"

    texte(msg.join("\n"))

  end

end #/class Feature
end #/module Manual
end #/module Prawn4book
