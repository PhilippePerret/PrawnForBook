=begin

  Helpers methods pour la génération du livre

=end
module Prawn4book
class PdfBook

  # Le sous-titre, s'il existe
  def formated_sous_titre
    @formated_sous_titre ||= begin
      if recette.subtitle
        "(#{recette.subtitle.strip})"
      end
    end
  end

  # Les auteurs, formatés pour l'impression
  # 
  def formated_auteurs
    @formated_auteurs ||= begin
      recette.authors.split(',').map{|n|n.strip.titleize}.pretty_join
    end
  end

  # L'édition
  # 
  def publisher
    @publisher ||= Editor.new(recette.publisher) if recette.publisher
  end
end #/class PdfBook

class Editor
  attr_reader :name, :adresse, :logo
  def initialize(data)
    @data = data
    @data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

  # --- Predicate Methods ---
  def logo?; not(logo.nil?) end
  
end

end #/module Prawn4book
