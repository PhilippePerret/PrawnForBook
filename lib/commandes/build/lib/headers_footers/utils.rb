module Prawn4book

  def self.fnss2Fonte(font_str)
    dfont = font_str.split('/')
    # La couleur se présente soit sous la forme ’FF00DD’ soit sous la
    # forme CMYK ’[10,100,50,47]’
    color = dfont[3]
    begin
      color = color && (color.length == 6 ? color : eval(color))
    rescue Exception => e
      PFBFatalError.new(653, {color: dfont[3].inspect})
    end
    # On l’instancie et on la retourne
    Fonte.new(name: dfont[0], style: dfont[1].to_sym, size: dfont[2].to_pps, color: color)
  end

end
