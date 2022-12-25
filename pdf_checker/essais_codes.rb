#!/usr/bin/env ruby -wU
require 'pdf/inspector'

FOLDER_BOOKS = File.expand_path(File.join(__dir__, '..','tests','all_books','books'))

your_pdf_document = File.join(FOLDER_BOOKS,'hello_book','book.pdf')

# rendered_pdf = your_pdf_document.render
# rendered_pdf = your_pdf_document
# rendered_pdf = PDF::Reader.new(your_pdf_document)
rendered_pdf = File.open(your_pdf_document,'r')

text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
text_analysis.strings # => ["foo"]

puts text_analysis.strings.inspect
