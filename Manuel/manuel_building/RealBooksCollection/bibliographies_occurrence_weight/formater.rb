module Prawn4book
  class Bibliography
    def monauteur(patronyme)
      prenom  = []
      nom     = []
      patronyme.split(" ").each do |pat|
        if pat.upcase == pat
          nom << pat
        else
          prenom << pat
        end
      end
      prenom = prenom.join(' ')
      nom    = nom.join(' ')
      "#{nom}, #{prenom}"
    end
  end #/class Bibliography


end # /module Prawn4book
