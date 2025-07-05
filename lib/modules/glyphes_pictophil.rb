class PictoPhil
  class << self

    # @api
    # 
    # Point d'entrée pour voir la liste des glyphes (caractères) dans
    # la police PictoPhil
    def show_glyph_list
      puts "Je dois apprendre à afficher la liste des caractères PictoPhil".jaune
      if glyph_list.is_a?(Array)
        # <= La liste des glyphes a été établie
        # => On actualise le fichier qui les montre
        update
      elsif pdf_exists?
        # <= La liste des glyphes n'a pas pu être établie
        # => On ouvrir le fichier par défaut
        open_pdf
      else
        # <= Liste glyphes impossible à lire + PDF inexistant
        # => On ne peut rien faire
        puts "Désolé, mais je ne peux pas vous montrer la liste des glyphes. Il semble que votre version de P4B soit erronée…".rouge
      end

    end

    # TEMP_LINE = '%{name} = <font name="PictoPhil">%{lettre}</font>'.freeze
    TEMP_LINE = 'lettre(%{lettre},%{name})'.freeze
    def update
      update_build_text_file
      update_build_book || return
      open_pdf
    end

    GLYPH_NAME_TO_GLYPH = {
      '.null'     => :NOT_PRINTED,
      '.notdef'   => :NOT_PRINTED,
      'uni2011'   => {name: 'Trait d’union insécable', lettre: '‑'},
      'CR'        => :NOT_PRINTED, # sinon plante
      'space'     => :NOT_PRINTED  # idem
    }

    def update_build_text_file
      File.delete(text_path) if File.exists?(text_path)
      begin
        write "(( new_page ))"
        write "Liste actuelle des caractères de la police PictoPhil\n"
        glyph_list.each do |glyphe|
          dglyphe = GLYPH_NAME_TO_GLYPH[glyphe] || {name: glyphe, lettre: glyphe}
          unless dglyphe == :NOT_PRINTED
            write TEMP_LINE % dglyphe 
          end
        end
        write "Fin de la liste des caractères"
      ensure
        @rf.close unless @rf.nil?
      end
    end

    def update_build_book
      res = Prawn4book.run_build_in(folder)
      if res[:status] == 0
        if File.exists?(book_path)
          puts "🍺 Construction du livre exécuté avec succès".vert
          FileUtils.mv(book_path, pdf_path)
          puts "Sortie:" + res[:output]
          return true
        else
          puts "La commande a bien fonctionné, mais bizarrement le book\nn'a pas été produit…".orange
          puts "Error: #{res[:error]}".orange
          puts "Sortie:" + res[:output]
        end
      else
        puts "Un problème est survenu : #{res[:error]}".rouge
        return false
      end
    end

    # Raccourci
    def write(str); rf.write "#{str}\n" end
    def rf
      @rf ||= File.open(text_path, "a")
    end

    def open_pdf
      `open "#{pdf_path}"`
    end


    def pdf_exists?
      File.exists?(pdf_path)
    end

    def text_path
      @text_path ||= File.join(folder, 'texte.pfb.md')
    end

    def pdf_path
      @pdf_path ||= File.join(folder, 'pictophil_glyphs.pdf')
    end

    def book_path
      @book_path ||= File.join(folder, 'book.pdf')
    end

    def folder
      @folder ||= File.join(MANUAL_FOLDER,'PictoPhil')
    end


    def glyph_list
      @glyph_list ||= begin
        stdout, stderr, status = Open3.capture3("otfinfo -g ./resources/fonts/Pictophil/Pictophil-Regular.ttf")
        if status == 0
          stdout.strip.split("\n")
        else
          puts "Impossible d'exécuter la commande : #{stderr}".rouge
          err = 
          case stderr
          when /No such file or directory/ then "[ERREUR FATALE] La police est introuvable… Recharger l'application pour remédier au problème."
          else "- Erreur indéfinie -"
          end
          puts err.rouge
          nil
        end
      rescue Errno::ENOENT
        # Err: Commande otfinfo introuvable
        nil
      end
    end



  end #/class << self
end