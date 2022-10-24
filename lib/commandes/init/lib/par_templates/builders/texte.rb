module Prawn4book
class InitedThing

  # @return true si le fichier a bien pu être créé
  def proceed_build_text_file
    
    case keep_text_file_if_exist?
    when :keep    then return true
    when :cancel  then return false
    else
      # on continue
    end

    return true unless Q.yes?('Dois-je créer le fichier du texte ?'.jaune) 
      
    # 
    # Construction du fichier du texte
    # 
    File.write(text_path, "<!-- Fichier texte -->\n<!-- 'pfb manuel' pour ouvrir le manuel -->\n# Grand titre\n\nPremier paragraphe.")

    confirmation_create_text_file || return

    return true
  end

  def keep_text_file_if_exist?
    return nil unless File.exist?(text_path)
    return ask_what_to_do_with_file(text_path, "fichier texte")
  end

  def confirmation_create_text_file
    if File.exist?(text_path)
      puts "Fichier texte créé avec succès.".vert
      return true
    else
      puts "Bizarrement, le fichier texte est introuvable.".rouge
      return false
    end
  end


  def text_path
    @text_path ||= File.join(folder,'texte.f4b.md')
  end

end #/class InitedThing
end #/module Prawn4book
