=begin
  Bac à sable de l'application, pour faire des essais

  Il suffit de :
  * si nécessaire, se placer dans le dossier voulu
  * écrire le code ci-dessous dans la méthode play_sandbox
  * jouer la commande 'pfb sandbox'

=end
require './lib/commandes/build/lib/PrawnView'
module Prawn4book
  # ::runner
  class Command
    def proceed
      Prawn4book.play_sandbox
    end
  end #/Command

  def self.play_sandbox
    clear


    # if test?
    #   puts "TEST MODE".bleu
    # end

    puts "DEFAULT_FONTS_KEYS : #{DEFAUT_FONTS.pretty_inspect}"

    bookfolder = mkdir(File.join(APP_FOLDER,'tmp','essais'))
    bookpath = File.join(bookfolder,'booktest.pdf')
    File.delete(bookpath) if File.exist?(bookpath)

    book  = Prawn4book::PdfBook.new(bookfolder)
    # pdf   = PrawnView.new(book, {})

    Prawn::Document.generate(bookpath) do
    # pdf.update do
      # props = {style: :bold_italic, size: 20} # fonctionne
      # props = {style: :italic_bold, size: 20} # ne fonctionne pas
      # props = {style: :italic, size: 20} # vaut pour oblique
      # props = {name: 'Helvetica', style: :italic, size: 30}
      # props = {name: 'Times', size: 30} # ne fonctionne pas

      font('Times', {style: :italic, size:40})
      text "Un texte quelconque pour voir."

    end

    # pdf.save_as(bookpath)

  end
end #/module Prawn4book
