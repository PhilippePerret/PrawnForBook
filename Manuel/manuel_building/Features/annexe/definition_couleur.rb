Prawn4book::Manual::Feature.new do

  titre "Définition de la couleur"

  couleurs_html = (0..9).map do |i|
    c = (0..2).map do |ii|
      rand(256).to_s(16).rjust(2,'0')
    end.join('')
    "* <color rgb=\"#{c}\">Couleur #{c}</color>"
  end.join("\n")


  TEMP_CMJN = '* <color c="%s" m="%s" y="%s" k="%s">Couleur %s</color>'

  couleurs_cmjn = [
    TEMP_CMJN % [0,0,0,127, "[0,0,0,127]"],
    TEMP_CMJN % [127,0,0,127, "[127,0,0,127]"],
    TEMP_CMJN % [127,0,0,0, "[127,0,0,0]"],
    TEMP_CMJN % [0,127,0,127, "[0,127,0,127]"],
    TEMP_CMJN % [0,127,0,0,   "[0,127,0,0]"],
    TEMP_CMJN % [0,0,127,127, "[0,0,127,127]"],
    TEMP_CMJN % [0,0,127,0,   "[0,0,127,0]"],
    TEMP_CMJN % [127,127,127,127, "[127,127,127,127]"],
    TEMP_CMJN % [127,127,127,0, "[127,127,127,0]"]
  ]
  (0..9).each do |i|
    c = (0..3).map { |ii| rand(127) }
    c << c.inspect
    couleurs_cmjn << (TEMP_CMJN % c)
  end

  couleurs_cmjn = couleurs_cmjn.join("\n")




  description <<~EOT
    En règle générale, la couleur dans _PFB_ peut se définir de deux façons :
    * en hexadécimal (comme en HTML) à l’aide de 6 chiffres/lettres héxadécimal (donc de 0 à F),
    * en quadrichromie, avec CMJN (Cyan, Magenta, Jaune, Noir).

    ##### Couleur hexadécimale

    En hexadécimal, on a 3 paires de deux chiffres/lettres qui représentent respectivement les quantités de rouge, vert et bleu. Par exemple "AAD405" signifiera "AA" de rouge, "D4" de vert et "05" de bleu. 
    "000000" représente le noir complet, "FFFFFF" représente le blanc complet. Lorsque toutes les valeurs sont identiques (par exemple "CCCCCC") on obtient un gris (mais il existe d’autres moyens d’obtenir du gris).
    Quelques couleurs hexadécimales aléatoires :
    #{couleurs_html}

    ##### Couleur quadrichromique

    La quadrichromie, représentée souvent par "CMJN" (ou "CMYK" en anglais), est le format de la couleur en imprimerie. On aura une liste (crochets) contenant les 4 valeurs de 0 à 127 pour le Cyan (C), le Magenta (M), le Jaune (Y) et le noir (K). Par exemple "[0, 12, 45, 124]" signifiera qu’il n’y aura pas de Cyan, qu’il y aura 12 de magenta, 45 de jaune et 124 de noir.
    [0, 0, 0, 0] représente le blanc complet, [127, 127, 127, 127] le noir complet.
    Quelques couleurs quadrichromiques :
    #{couleurs_cmjn}

    EOT


end
