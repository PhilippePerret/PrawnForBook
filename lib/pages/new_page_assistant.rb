#!/usr/bin/env ruby

=begin

  Script pour créer un nouvel assistant de page

  - ouvrir un Terminal dans ce dossier
  - jouer 'new[TAB][RETURN]'
  - suivre les instructions

=end
require 'clir'

tag_name = Q.ask("Tag de la page dans la recette (par exemple 'page_de_titre')".jaune)
tag_name = tag_name.downcase.freeze
folder = File.expand_path(File.join(__dir__, tag_name))
File.exist?(folder) && raise("La page #{tag_name} existe déjà ! (dossier #{folder.inspect})")
className = tag_name.camelize
puts "Class #{className}"

#
# Le dossier principal
# 
mkdir(folder)

#
# Le loader
# 
loader_path = File.join(__dir__, "#{tag_name}.rb")
code = <<-RUBY
require_relative 'required'
module Prawn4book
class Pages
class #{className} < SpecialPage
end;end;end
require_page('#{tag_name}')
RUBY
File.write(loader_path, code)

#
# Le builder
# 
builder_path = File.join(folder, 'build.rb')
code = <<-RUBY
module Prawn4book
class Pages
class #{className}

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    
  end

end #/class #{className}
end #/class Pages
end #/module Prawn4book
RUBY
File.write(builder_path, code)

#
# Le definer
# 
definer_path = File.join(folder, 'define.rb')
code = <<-RUBY
module Prawn4book
class Pages
class #{className}

  # = main =
  #
  # Méthode principale permettant de définir la page
  # 
  def define
    super
  end

  #
  # Ci-dessous les méthodes spéciales pour définir la page
  # @note
  #   Les principales méthodes se trouvent dans la classe mère
  # 

end #/class #{className}
end #/class Pages
end #/module Prawn4book
RUBY
File.write(definer_path, code)

#
# Le fichier data
# 
data_path = File.join(folder, 'data.rb')
code = <<-RUBY
=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class #{className}

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  PAGE_DATA = {
    # Par exemple :
    # fonts: {
    #   title: {name:"Police du titre", default: 'Times', values: :police_names},
    #   subtitle: {name:"Police du sous-titre", default: 'Times', values: :police_names},
    # },
    # sizes: {
    #   title: {name:"Taille du titre", default: 18},
    #   subtitle: {name:'Taille du sous-titre', default: 16},
    # },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  # Par exemple :
  # def police_names(default_name = nil)
  #   (get_data_in_recipe[:fonts]||polices_default).map do |font_name, dfont|
  #     {name: font_name, value: font_name}
  #   end
  # end
  # def polices_default
  #   {'Times' => true, 'Helvetica' => true, 'Courier' => true}
  # end
end #/class #{className}
end #/class Pages
end #/module Prawn4book
RUBY
File.write(data_path, code)

puts "Dossier pour la page #{tag_name} créé avec succès.\n".vert
puts "Première chose à faire :\n  définir la constante PAGE_DATA dans le fichier data.rb".bleu
puts "Pour utiliser l'assistant, une fois ces données définies, jouer 'pfb assistant #{tag_name.gsub(/_/,'-')}'".bleu

