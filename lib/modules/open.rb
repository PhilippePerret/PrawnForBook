module Prawn4book


  def self.open_something
    case CLI.components[0]
    when 'manuel'
      if CLI.option(:dev)
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


PACKAGE_SUBLIME_TEXT = File.join(Dir.home,'Library','Application Support','Sublime Text','Packages','Prawn4Book')

end #/ module Prawn4book
