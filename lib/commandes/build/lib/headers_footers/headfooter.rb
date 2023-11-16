module Prawn4book
module HeaderAndFooter
class HeadFoot
  
  # Class pour un "headfoot(er)", c’est-à-dire la définition des
  # trois tiers utilisés soit comme entête soit comme pied de page
  # pour un page quelconque
  # 

  attr_reader :data
  def initialize(data)
    @data = data
  end

  # Pour la construction du headfoot particulier qui va devoir être
  # inscrit, on reçoit les données, par exemple le numéro de la page,
  # les titres, etc.
  # 
  # Retourne le contenu textuel des trois tiers sous forme de table,
  # avec les mêmes clés :left, :center et :right
  def build_width(params)
    left[:text]   = left[:text] % params
    center[:text] = center[:text] % params
    right[:text]  = right[:text] % params

    return {left: left, center: center, right: right}
  end

  # Contenu du tiers LEFT
  def left
    @left ||= begin
      prepare_tiers(:left)
    end
  end
  # Contenu du tiers CENTRAL
  def center
    @center ||= begin
      prepare_tiers(:center)
    end
  end
  # Contenu du tiers DROIT
  def right
    @right ||= prepare_tiers(:right)
  end



  def left_fonte
    @left_fonte ||= begin
      data[:left_font] ? fnss2Fonte(data[:left_font]) : fonte
    end
  end

  def center_fonte
    @center_fonte ||= begin
      data[:center_font] ? fnss2Fonte(data[:center_font]) : fonte
    end
  end

  def right_fonte
    @right_fonte ||= begin
      data[:right_font] ? fnss2Fonte(data[:right_font]) : fonte
    end
  end


  def fonte
    @fonte ||= begin
      if data[:font]
        fnss2Fonte(data[:font])
      end
    end
  end


  private

    def fnss2Fonte(font_str)
      dfont = font_str.split('/')
      Fonte.new(name: dfont[0], style: dfont[1].to_sym, size: dfont[2].to_pps)
    end

    # Reçoit un tiers quelconque (:left, :center ou :right) et 
    # retourne une valeur [String] formatée prête à recevoir les
    # paramètres de la page où il doit être inscrit
    # 
    # Retourne une table contenant :text, :align
    def prepare_tiers(tiers_sym)
      tiers  = data[tiers_sym] || return # nil
      fonte  = self.send("#{tiers_sym}_font".to_sym)
      tb = {
        text:       nil, 
        align:      :center,
        font_name:  fonte.name
        style:      fonte.style, 
        size:       fonte.size,
        fonte:      fonte
      }
      
      if tiers[0] == '-'
        if tiers[-1] == '-'
          # => alignement au centre
          tb.merge!({align: :center, text: tiers[1...-1]})
        else
          # => Alignement à gauche
          tb.merge!(align: :left, text: tiers[1..-1])
        end
      elsif tiers[-1] == '-'
        tb.merge!(align: :right, text: tiers[0...-1])
      else
        tb.merge!(text: tiers)
      end

      return tb
    end

end #/HeadFoot
end #/module HeaderAndFooter
end #/module Prawn4book
