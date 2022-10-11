=begin

  Outil pour liste les titres d'un livre

=end
module Prawn4book

  class << self
    attr_reader :pdfbook
  end

  def self.run_tool
    PdfBook.current || raise("Il faut se placer dans le dossier d'un livre.")  
    @pdfbook = PdfBook.current
    pdfbook.has_text? || raise("Le livre courant ne possède pas de fichier texte…")
    pdfbook.build_titre_liste
  rescue Exception => e
    puts e.message.rouge
  end


class PdfBook

  def build_titre_liste
    clear
    puts "Fabrication de la liste des titres…".bleu

    File.open(listing_path,'w') do |f|
      f.puts "<!Produit automatiquement par la commande\n  '#{COMMAND_NAME} tools' > Listing des titres!>"
      File.readlines(text_file).each_with_index do |line, idx|
        line = line.strip
        next unless line.start_with?('#')
        num = idx + 1
        level = line.match(/(#+) /)[1].length - 1
        f.puts "#{'  ' * level}#{line.strip} [#{num}]"
      end
    end

    puts "Listing fabriqué avec succès.\n".vert
    puts <<~TEXT.gris
    Rappel
    ------
    ⌘K ⌘é (2): refermer le niveau 2
    ⌘K ⌘" (3): refermer le niveau 3
    ⌘K ⌘' (4): refermer le niveau 4
    ⌘K ⌘( (5): refermer le niveau 5
    ⌘K ⌘§ (6): refermer le niveau 6
    ---
    ⌘K ⌘J    : tout déployer 

    TEXT

    if Q.yes?('Dois-je l’ouvrir ?'.jaune)
      `subl -n "#{listing_path}"`
    end

  end

  def listing_path
    @listing_path ||= File.join(folder,'liste_titres.txt')
  end
end #/class PdfBook
end#/module Prawn4book
