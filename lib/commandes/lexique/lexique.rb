=begin
  Bac à sable de l'application, pour faire des essais
=end
module Prawn4book
  # ::runner
  class Command
    def proceed
      searched = CLI.components.first || ask_for_mot_to_search || return
      isearch = LexicalSearch.new(searched)
      isearch.proceed
    end
    def ask_for_mot_to_search
      Q.ask("Terme à rechercher :".jaune)
    end
  end #/Command

#################       CLASS LexicalSearch      #################
# Pour une recherche lexicale
# 
class LexicalSearch
  attr_reader :search
  attr_reader :lexique
  def initialize(search)
    @search   = search
    @lexique  = Lexique.new
  end
  def proceed
    clear
    puts "Recherche de #{search.inspect}…\n".jaune
    lexique.parse(search)
    puts "\nNombre d'éléments trouvés : #{lexique.founds}\n\n".jaune
  end
end

###################       CLASS Lexique      ###################

class Lexique
  attr_reader :founds
  def initialize
    @founds = nil
  end

  def parse(str)
    @founds = 0
    definition    = false
    current_terme = nil
    File.readlines(path).each do |line|
      if line.start_with?('  ') # définition
        if definition
          STDOUT.write line.bleu
        elsif line.match?(str)
          @founds += 1
          STDOUT.write "(dans #{current_terme})\n#{line}".gris
        end
        next # dans tous les cas on passe à la suite
      end
      # 
      # On ne passe ici que lorsque c'est un terme
      # 
      current_terme = line
      if line.match?(str)
        STDOUT.write line.bleu
        @founds += 1
        definition = true
      else
        definition = false
      end
    end
  end

  def path
    @path ||= File.join(__dir__,'lib','lexique.txt')
  end
end

end #/module Prawn4book
