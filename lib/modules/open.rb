module Prawn4book


  def self.open_something
    case CLI.components[0]
    when 'manuel'
      `open -a Preview "#{USER_MANUAL_PATH}"`
    when 'book'
      PdfBook.current.open_book
    else
      puts "Je ne sais pas comment ouvrir #{CLI.components[0].inspect}"
    end
  end



# @constant
# Chemin d'accès au manuel utilisateur
USER_MANUAL_PATH = File.join(APP_FOLDER,'Manuel','Manuel.pdf')

end #/ module Prawn4book
