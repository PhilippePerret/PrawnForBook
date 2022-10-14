module Prawn4book


  def self.open_something
    case CLI.components[0]
    when NilClass # => le livre (pdf, txt, etc.)
      open_book
    when 'manuel'
      if CLI.option(:dev) || CLI.option(:edition)
        `open -a Typora "#{USER_MANUAL_MD_PATH}"`
      else
        `open -a Preview "#{USER_MANUAL_PATH}"`
      end
    when 'book'
      PdfBook.current.open_book
    when 'package-st'
      `subl "#{PACKAGE_SUBLIME_TEXT}"`
    else
      puts "Je ne sais pas comment ouvrir #{CLI.components[0].inspect}"
    end
  end

  def self.open_book
    book = PdfBook.current
    book || raise("Il n'y a pas de livre courant. Ouvrir un Terminal au dossier d'un livre Prawn4Book.")
    if CLI.option(:edition)
      `subl -n "#{book.folder}"`
    else
      book.open_book
    end    
  end


PACKAGE_SUBLIME_TEXT = File.join(Dir.home,'Library','Application Support','Sublime Text','Packages','Prawn4Book')

end #/ module Prawn4book
