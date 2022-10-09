=begin

Pour tenter de générer le pdf avec Prawn


=end

require_relative 'lib/required'

Prawn::Fonts::AFM.hide_m17n_warning = true

ifile_path  = File.expand_path('./texte.txt')
config_path = File.expand_path('./config.yaml')

inputfile = Narration::InputTextFile.new(ifile_path)
pdfbook   = Narration::PdfBook.new(inputfile, YAML.load_file(config_path, aliases:true))

#
# Destruction d'un ancien fichier PDF
# 
File.delete(pdfbook.pdf_path) if File.exist?(pdfbook.pdf_path)

#
# Générer le fichier PDF pour KDP
# 
pdfbook.generate_pdf_book

if File.exist?(pdfbook.pdf_path)
  puts "Fichier PDF créé avec succès".vert
else
  puts "Bizarrement, le fichier PDF ne semble pas avoir été créé".rouge
end

puts "\n\n"
