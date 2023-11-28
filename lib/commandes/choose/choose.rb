require 'lib/pages/bibliographies'
module Prawn4book
class Command
  def proceed
    book = Prawn4book::Bibliography.init
    clear
    biblio_tag = CLI.components[0]
    case biblio_tag
    when NilClass
      puts "Mettez après 'choose' le tag de la bibliographie dans laquelle il faut chercher l'item (par exemple 'pfb choose film').".jaune
    else
      biblios = book.recipe.bibliographies
      dbiblio = biblios[biblio_tag.to_sym] || begin
        puts "La bibliographie #{biblio_tag.inspect} est inconnue…".rouge
        puts "Bibliographies connues : #{biblios.keys.inspect}.".rouge
        puts "Je dois apprendre à chercher dans #{biblio_tag.inspect}".jaune
        return
      end
      biblio = Prawn4book::Bibliography.new(book, biblio_tag)
      choices = 
        if biblio.par_fiche?
          puts biblio.items # aucun pour le moment
          Dir["#{biblio.folder}/*.yaml"].map do |cpath|
            affixe = File.basename(cpath,File.extname(cpath))
            {name: affixe, value: affixe}
          end
        else
          biblio.items.values.map do |item|
            { name: item.id, value: item.id }
          end
        end
      choix = Q.select("", choices, **{per_page: 10, filter: true})
      str = "#{biblio_tag}(#{choix})"
      clip(str, false)
      puts "Le texte #{str.inspect} a été mis dans le presse-papier.".vert
    end
  end
end #/class Command
end #/Prawn4book
