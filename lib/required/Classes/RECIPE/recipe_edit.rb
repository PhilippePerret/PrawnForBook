#
# Module des méthodes d'édition de la recette
# (par les assistants)
# 
module Prawn4book
class Recipe


  ##
  # Méthode à utiliser pour actualiser les données dans le fichier
  # recette (lorsqu'elles ne le sont pas à la main)
  # 
  # @param [String|Symbol] tag_name   Ce que c'est. Par exemple 'book_data' ou 'fonts'
  # @param [Hash] new_data Les données à insérer. Elles doivent avoir la forme {:tag_name => data} mais si ça n'est pas le cas, la méthode corrige.
  def insert_bloc_data(tag_name, new_data)
    # 
    # Le code qu'il faudra insérer
    # 
    new_data = {tag_name.to_sym => new_data} unless new_data.key?(tag_name.to_sym)
    inserted = new_data.to_yaml
    inserted = inserted[4..-1].strip if inserted.start_with?("---")
    # 
    # On recherche la balise dans le code actuel
    # 
    code    = raw_code
    dec_in, dec_out = get_offsets_tagname_in_recipe(tag_name)
    tag_in  = "#<#{tag_name}>"
    tag_out = "#</#{tag_name}>"

    if dec_in.nil?
      # 
      # Balise inexistante => on met le bloc de code à la fin.
      # 
      code = [code, tag_in, inserted.strip, tag_out].join("\n")
    else
      # 
      # Quand le bloc de code a été trouvé
      # 
      code = [code[0..dec_in].strip, inserted.strip, code[dec_out..-1].strip].join("\n")
    end
    # 
    # On écrit le code corrigé dans le fichier recette
    # 
    File.write(path, code)
  end

  def get_offsets_tagname_in_recipe(tag_name)
    code = raw_code
    tag_in  = "#<#{tag_name}>"
    tag_out = "#</#{tag_name}>"
    dec_in  = code.index(tag_in)
    dec_out = code.index(tag_out)
    if dec_in.nil?
      #
      # Balise d'entrée introuvable…
      # 
      # Si la balise de fin est pourtant définie, on signale une
      # erreur.
      dec_out.nil? || begin
        puts <<~TXT.orange
          Attention, une balise de fin (#{tag_out}) existe dans le fichier
          recette (sans balise de début). Il faudrait la supprimer pour
          ne pas avoir de problème.
        TXT
        sleep 4
      end
    else
      # 
      # Si la balise d'entrée existe
      # 
      # Il faut absolument que la balise de fin existe aussi, sinon
      # on est incapable de prendre les données (ce serait trop
      # risqué, on risquerait de prendre les données d'autres blocs)
      # 
      dec_out || raise("La balise '</#{tag_name}>' est introuvable.")
      # 
      # Mais la balise de fin peut exister mais être avant la balise
      # de début.
      # Dans ce cas, on cherche une balise de fin après. Si on la
      # trouve, on poursuit en signalant qu'il faut corriger le 
      # problème. Sinon, on s'arrête pour la même raison que 
      # ci-dessus.
      # 
      if dec_out < dec_in
        dec_out = code.index(tag_out, dec_in)
        if dec_out.nil?
          raise("Une balise '</#{tag_name}>' a été trouvée, mais avant la balise de début…")
        else
          puts <<~TXT.orange
            Attention : une balise de fin a été trouvée avant la balise
            de début. Il faudrait la supprimer.
            (je poursuis quand même en tenant compte de la deuxième)
          TXT
          sleep 4
        end
      end

      # 
      # Rectification des valeurs
      # 
      dec_in += tag_in.length
      dec_out -= 1

    end
    return [dec_in, dec_out]
  end

  def raw_code
    File.exist?(path) ? File.read(path) : "---\n"
  end

  def path
    @path ||= File.join(BOOK_DIR, "recipe.yaml")
  end
  alias :recipe_path :path

end #/class Recipe
end #/module Prawn4book
