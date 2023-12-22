Prawn4book::Manual::Feature.new do

  titre "Indication du contexte d’erreur"

  description <<~EOT
    À titre préventif dans les méthodes personnalisées, *helpers* et autres modules, on peut indiquer le contexte qui devra être affiché en cas d’erreur.
    Cela se fait en utilisant le code `PFBError.context = \\"Le contexte\\"`.
    (( line ))
    ~~~ruby
    # ruby
    def monHelper(pdf, book)

      12.times do |i|
        # Indiquer le contexte
        PFBError.context = <<~EOC
          Dans la boucle de calcul et d’écriture du 
          chiffre, avec i = \\\\#\{i}
          EOC
        ecrire_ce_chiffre(i)
      end

      # Penser à "défaire" le contexte
      PFBError.context = nil
    end
    ~~~
    EOT

  # sample_code <<~EOT, "Exemple dans un *helper*"
  #   # ruby
  #   def monHelper(pdf, book)

  #     12.times do |i|
  #       # Indiquer le contexte
  #       PFBError.context = <<~EOC
  #         Dans la boucle de calcul et d’écriture du 
  #         chiffre, avec i = \\\#{i}
  #         EOC
  #       ecrire_ce_chiffre(i)
  #     end

  #     # Penser à "défaire" le contexte
  #     PFBError.context = nil
  #   end
  #   EOT

end
