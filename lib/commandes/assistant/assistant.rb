module Prawn4book
  
  # @runner
  class Command
    def proceed
      if CLI.components.empty?
        check_if_current_book_or_return || return
        clear unless debug?
        puts "LISTE DES ASSISTANTS\n".bleu
        assistant = Q.select("Quel assistant lancer ?".jaune, choices_assistants, {per_page: choices_assistants.count})
        assistant || return
        case assistant[:type]
        when :page
          require assistant[:path]
          Prawn4book::Pages.run_assistant(File.basename(assistant[:path]))
        when :assistant
          proceed_assistant_for(assistant[:what])
        end
      end
    end # méthode appelée par défaut

    def choices_assistants
      @choices_assistants ||= begin
        cs = Dir["#{APP_FOLDER}/lib/pages/*"].map do |assistant_page_folder|
          next unless File.directory?(assistant_page_folder)
          assistant_name = File.basename(assistant_page_folder).titleize.gsub(/_/,' ')
          next if assistant_name == 'Special pages abstract'
          {name: "Assistant #{assistant_name}", value: {type: :page, path: assistant_page_folder}}
        end.compact
        # TODO Ajouter les autres assistants
        Dir["#{APP_FOLDER}/lib/commandes/assistant/lib/assistant_*.rb"].each do |pth|
          file_name = File.basename(pth).sub(/\.rb$/,'')
          assistant_name = file_name.titleize.gsub(/_/, ' ')
          cs << {name:assistant_name, value: {type: :assistant, what: file_name.sub(/^assistant_/,'')}}
        end
        cs << {name: PROMPTS[:cancel], value: nil}
        cs
      end
    end

    def proceed_assistant_for(what)
      pdfbook = check_if_current_book_or_return || return
      require_relative "lib/assistant_#{what}"
      Prawn4book::Assistant.send("assistant_#{what}".to_sym, pdfbook)
    end

    def check_if_current_book_or_return
      PdfBook.current? || begin
        puts MESSAGES[:assistant][:require_book_folder].orange
        return false
      end
      PdfBook.current
    end
  end #/Command

end #/Prawn4book
