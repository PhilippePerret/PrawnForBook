module Prawn4book
    
  # @runner
  class Command
    def proceed
      puts <<~EOT
        #{Prawn4book::NAME.bleu} (#{Prawn4book::SUBNAME})
        Version: #{Prawn4book::VERSION}
        Folder: #{APP_FOLDER}
        EOT
    end
  end #/Command

end #/module Prawn4book
