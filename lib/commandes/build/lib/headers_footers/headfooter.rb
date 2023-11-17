module Prawn4book
  

  private


    # Reçoit un tiers quelconque (:left, :center ou :right) et 
    # retourne une valeur [String] formatée prête à recevoir les
    # paramètres de la page où il doit être inscrit
    # 
    # Retourne une table contenant :text, :align
    def prepare_tiers(tiers_sym)
      
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

end #/module Prawn4book
