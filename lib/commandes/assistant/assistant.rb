module Prawn4book
  
  # @runner
  class Command
    def proceed; end
    def proceed_assistant_fontes
      pdfbook = check_if_current_book_or_return || return
      Prawn4book.assistant('fontes',pdfbook)
    end
    def proceed_assistant_biblio
      pdfbook = check_if_current_book_or_return || return
      Prawn4book.assistant('biblios',pdfbook)
    end

    def check_if_current_book_or_return
      PdfBook.current? || begin
        puts MESSAGES[:assistant][:require_book_folder].orange
        return false
      end
      PdfBook.current
    end
  end #/Command

  ##
  # Méthode générale pour appeler les assistants
  # 
  def self.proceed_assistant(what,pdfbook)
    require_relative "lib/assistant_#{what}"
    send("assistant_#{what}".to_sym,pdfbook)    
  end

  # def self.cfolder
  #   @@cfolder ||= File.expand_path('.')
  # end
end #/Prawn4book
