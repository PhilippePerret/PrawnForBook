module Prawn4book
class Command
  def proceed
    #
    # On s'assure qu'on est bien dans un bouquin
    # 
    book = Prawn4book::PdfBook.ensure_current
    
    clear

    # 
    # Relève des cibles dans le texte
    # 
    cibles = []
    book.inputfile.full_text.scan(/\(\( <\-\((.+)\) \)\)/) do |found|
      cibles << found[0]
    end

    #
    # Affichage des cibles pour en choisir une
    # 
    choix = Q.select("Cible à prendre :".jaune, cibles, **{per_page: 10, filter: true})

    #
    # Mise de la cible dans le presse-papier
    # 
    str = "(( ->(#{choix}) ))"
    clip(str, false)
    puts <<~MSG.bleu
      Le texte :
          #{str.inspect} 
      … qui pointe vers cette référence a été mis dans le presse-papier 
      pour être copié-collé dans le texte.
      MSG


  end #/proceed
end # /class Command
end # /module Prawn4book
