module Prawn4book
  
  # @runner
  class Command
    def proceed
      if CLI.components.empty?
        check_if_current_book_or_return || return
        clear unless debug?
        puts "LISTE DES ASSISTANTS\n".bleu
        # choices = choices_with_precedences(choices_assistant)
        # assistant = Q.select("Quel assistant lancer ?".jaune, choices, {per_page: choices.count})

        dass = choices_with_precedences(choices_assistants,__dir__) do 
          "Quel assistant lancer ?"
        end || return

        case dass[:type]
        when :page
          run_assistant_page(dass[:path])
        when :assistant
          proceed_assistant_for(dass[:what])
        end
      else
        # 
        # Si un objet est déjà défini
        # 
        what = CLI.components.first
        if File.exist?(File.join(__dir__, 'assistants', "#{what}.rb"))
          proceed_assistant_for(what)
        elsif File.exist?(file = File.join(folder_pages,"#{what}"))
          run_assistant_page(file)
        else
          puts "Je ne sais pas comment assister #{what.inspect}…".orange
        end
      end
    end # méthode appelée par défaut

    def run_assistant_page(path)
      require path
      Prawn4book::Pages.run_assistant(File.basename(path))
    end

    def proceed_assistant_for(what)
      pdfbook = check_if_current_book_or_return || return
      require_relative "assistants/#{what}"
      Prawn4book::Assistant.send("assistant_#{what}".to_sym, pdfbook)
    end


    def folder_pages
      @folder_pages ||= File.join(APP_FOLDER,'lib','pages')
    end

    def choices_assistants
      @choices_assistants ||= begin
        cs = Dir["#{folder_pages}/*"].map do |assistant_page_folder|
          next unless File.directory?(assistant_page_folder)
          assistant_name = File.basename(assistant_page_folder).titleize.gsub(/_/,' ')
          next if assistant_name == 'Special pages abstract'
          {name: "Assistant #{assistant_name}", value: {type: :page, path: assistant_page_folder}}
        end.compact
        # TODO Ajouter les autres assistants
        Dir["#{APP_FOLDER}/lib/commandes/assistant/assistants/*.rb"].each do |pth|
          file_name = File.basename(pth).sub(/\.rb$/,'')
          assistant_name = file_name.titleize.gsub(/_/, ' ')
          cs << {name:"Assistant #{assistant_name}", value: {type: :assistant, what: file_name.sub(/^assistant_/,'')}}
        end
        cs << {name: PROMPTS[:cancel], value: nil}
        cs
      end
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
