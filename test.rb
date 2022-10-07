=begin

  Pour tester les documents PDF produits
  
=end
require 'pdf/inspector'

# rendered_pdf = your_pdf_document.render

PDF_PATH = File.expand_path('./essai.pdf')
text_analysis = PDF::Inspector::Text.analyze(File.read(PDF_PATH))
page_analysis = PDF::Inspector::Page.analyze(File.read(PDF_PATH))
puts text_analysis.strings.inspect # => ["foo"]
puts "pages.size = #{page_analysis.pages.size}"
