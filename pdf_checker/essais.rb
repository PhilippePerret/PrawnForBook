#!/usr/bin/env ruby
=begin

  Ce module est une ultime tentative pour comprendre le 
  fonctionnement de PDF::Reader et PDF::Inspector

  On doit donner en premier argument le path absolu du fichier
  PDF qu'on prend en exemple, on l'introduire dans ce dossier avec
  le nom 'tested.pdf'



=end
require_relative 'lib_essais/required'

PDF_PATH = ARGV[0] || File.expand_path('./tested.pdf')

exit_if_no_document

clear

Pins    = PDF::Inspector::Page.analyze_file(PDF_PATH)
Tins    = PDF::Inspector::Text.analyze_file(PDF_PATH)
Reador  = PDF::Reader.new(PDF_PATH)
tReador = 'PDF::Reader'


# expose_methods_of(Pins)
# expose_methods_of(Tins)
expose_methods_of(Reador)

# expose_methods_return_of(Reador, tReador)

puts Reador.page(1).class.instance_methods(false)
