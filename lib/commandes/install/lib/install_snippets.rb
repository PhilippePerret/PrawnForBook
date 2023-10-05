module Prawn4book
class PdfBook
class << self

  attr_reader :book

  def install_snippets
    #
    # Il faut qu'il y ait un livre courant
    # 
    @book = PdfBook.ensure_current || return

    #
    # Il faut que le dossier des snippets de l'éditeur (p.e. Sublime
    # Text) existe.
    # 
    File.exist?(SUBL_SNIPPETS_FOLDER) || begin
      puts <<~EOT.rouge
        Impossible de trouver le dossier des snippets de l'IDE
        défini dans la constante SUBL_SNIPPETS_FOLDER :
        #{SUBL_SNIPPETS_FOLDER}.
        Je ne peux donc pas installer les snippets.
        Redéfinir cette donnée et relancer la commande #{'pfb install'.jaune}#{'.'.rouge}
        EOT
      return
    end

    #
    # Il faut que le livre courant (ou la collection) définisse des
    # snippets, dans un dossier "snippets"
    # 
    if book_snippets.empty?
      puts "Le livre ou la collection ne définissent aucun snippets.\nJe poursuis.".bleu
      return
    end

    clear

    #
    # Si des snippets sont déjà définis, on demande quoi en faire
    # 
    cursnips = Dir["#{SUBL_SNIPPETS_FOLDER}/**/*.sublime-snippet"].collect{|p|File.basename(p)}
    unless cursnips.empty?
      puts "Les snippets suivants (propre à un livre) existent.\nQue dois-je en faire ?\n\n- #{cursnips.join("\n- ")}".jaune
      case Q.select(nil) do |q|
          q.choice "Les supprimer", :remove
          q.choice "Les conserver", :keep
          q.choice "Ouvrir le dossier et arrêter l'installation", :open
          q.choice "Ne rien faire et s'arrêter", :stop
        end
      when :remove
        remove_current_snippets
      when :keep
        # Rien à faire
      when :stop
        return
      when :open
        `open "#{SUBL_SNIPPETS_FOLDER}"`
        return
      end
    end

    book_snippets.each do |src|
      dst = File.join(SUBL_SNIPPETS_FOLDER, File.basename(src))
      FileUtils.cp(src, dst)
    end
    puts "#{book_snippets.count} snippets définis copiés dans l'IDE.\n(#{book_snippets.collect{|p|File.basename(p,File.extname(p))}.pretty_join})".bleu
  end
  #/install_snippets


  # @retrun [Array] Liste des snippets, relevés dans la collection
  # et dans le livre courant.
  def book_snippets
    @book_snippets ||= begin
      ary = []
      if book.collection
        collfolder = File.join(book.collection.folder,'snippets')
        if File.exist?(collfolder)
          ary += Dir["#{collfolder}/**/*.sublime-snippet"]
        end
      end
      bookfolder = File.join(book.folder,'snippets')
      if File.exist?(bookfolder)
        ary += Dir["#{bookfolder}/**/*.sublime-snippet"]
      end
      ary
    end
  end
  
  # -- Méthode qui détruit les snippets existants --
  def remove_current_snippets
    Dir["#{SUBL_SNIPPETS_FOLDER}/**/*.sublime-snippet"].each do |p|
      File.delete(p)
    end
  end

end #/<< self
end#/class PdfBook
end#/module Prawn4book
