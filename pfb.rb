#!/usr/bin/env ruby
# encoding: UTF-8

=begin
Ce script est appelé par l'alias 'bk' ou 'prawn-book', 'pfb' ou 'prawn-for-book'
Il permet de jouer prawn-for-book avec la bonne version. 
Il faut mettre le dossier du livre en premier argument.

J'ai (juste) un petit problème : c'est qu'on se place dans le dossier de
l'application Prawn-for-book pour pouvoir exécuter 'bundler exec' et que,
donc, en sortant de cette commande, on se trouve forcément dans le dossier
de l'application. Donc j'adopte une stratégie pas très propre, mais qui
fonctionne : 
  - lorsque le dossier courant n'est pas celui de l'application, je 
    considère que c'est le dossier du livre et je le mémorise.
  - lorsque le dossier courant est celui de l'application, je relis
    le dossier mémorisé et, s'il existe encore, je le prends comme
    dossier du livre.
=end
thisapp_folder    = __dir__
CURRENT_BOOK_PATH_DATA = File.join(thisapp_folder, '.curbookdir')
maybe_book_folder = ARGV.shift
BOOT_ERRORS = {
  100 => "Il faut jouer la commande dans le dossier du livre à produire.",
  101 => 'Le livre courant "%s" est introuvable. Lancer la commande depuis son dossier.',
}
def get_last_book_dir
  raise BOOT_ERRORS[100] unless File.exist?(CURRENT_BOOK_PATH_DATA)
  book_dir = IO.read(CURRENT_BOOK_PATH_DATA).strip
  raise (BOOT_ERRORS[101] % [book_dir]) unless File.exist?(book_dir)
  book_dir
end

require_relative 'lib/required/Divers/PrawnOwner'
module Prawn4book; class PdfBook < PrawnOwner; end; end
require_relative 'lib/required/Classes/PdfBook.cls.rb'
def self.is_a_prawn4book_book?(fold)
  Prawn4book::PdfBook.is_book?(fold)
end


# puts "Je vais apprendre à lancer prawn4book avec la bonne version de ruby"
# puts "PFB est lancé depuis #{Dir.pwd}"
# puts "Mais le script pfb.rb se trouve dans le dossier courant : #{__dir__}"
# puts "Et les arguments envoyés sont : #{ARGV.inspect}"
# puts "La verson ruby est : #{RUBY_VERSION}"
# puts "ENV: #{ENV.inspect}"

BOOK_DIR = BOOK_FOLDER =
  if maybe_book_folder == thisapp_folder
    # <= La commande est jouée depuis le dossier Prawn4Book
    # => On doit relire le fichier .current_book_folder s'il existe
    #    pour connaitre le livre courant.
    get_last_book_dir
  elsif is_a_prawn4book_book?(maybe_book_folder)
    # <= Le dossier courant est un livre Praw-4-book
    # => On le mémorise pour la prochaine fois/commande
    # BOOK_DIR = ARGV[0]
    IO.write(CURRENT_BOOK_PATH_DATA, maybe_book_folder)
    maybe_book_folder
    # puts "Dossier de livre mis en courant : #{File.basename(BOOK_DIR)} (#{BOOK_DIR})"
  else
    # <= On se trouve dans un dossier quelconque, pas un livre en 
    #    tout cas
    # => On poursuit comme ça avec le livre mémorisé
    get_last_book_dir
  end

# puts "Les arguments ensuite : #{ARGV.inspect}"

begin
  require_relative 'lib/required'
  Prawn4book.run
rescue Exception => e
  puts "#{e.message}".rouge
  puts "#{e.backtrace.join("\n")}".rouge
end
