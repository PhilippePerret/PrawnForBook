# require 'test_helper'
# module Prawn4book
# class PdfBook
# class NParagraphe

#   alias :real_parse :parse
#   def parse(line)
#     reset_all_type
#     real_parse(line)
#   end

#   ##
#   # Permet de vérifier que le paragraphe ne possède aucun des
#   # type (image, titre, etc.) sauf celui spécifié
#   def is_only_type(test, actual_type)
#     [
#       :real?, :image?, 
#       :titre_n1?, :titre_n2?, :titre_n3?, :titre_n4?
#     ].each do |type|
#       if actual_type == type
#         test.assert self.send(type), ":#{type} devrait retourner true"
#       else
#         test.refute self.send(type), ":#{type} devrait retourner false"
#       end
#     end
#   end #/is_only_type

#   def reset_all_type
#     [
#       :real, :image, :titre_n1, :titre_n2, :titre_n3, :titre_n4
#     ].each do |typ| instance_variable_set("@istype#{typ}", nil) end
#   end

# end #/class NParagraphe
# end #/class PdfBook
# end #/module Prawn4book

# class NParagrapheClassTest < Minitest::Test

#   def setup
    
#   end


#   # @return une instance paragraphe vierge
#   def iparag(data = nil)
#     Narration::PdfBook::NParagraphe.new(data)
#   end

#   def tes t_respond_to_parse
#     assert_respond_to iparag, :parse
#   end

#   def tes t_parse_do_parse_the_line
#     ip = iparag
#     ip.parse("Lorem ipsum pour voir ce que c'est")
#     ip.is_only_type(self, :real?)
#     ip.parse("IMAGE[mon/image.jpg]")
#     ip.is_only_type(self, :image?)
#     assert_equal ip.content, "mon/image.jpg"
#     ip.parse("# Grand titre pour voir")
#     ip.is_only_type(self, :titre_n1?)
#     ip.parse("## Titre normal")
#     ip.is_only_type(self, :titre_n2?)
#     ip.parse("### Sous-titre pour voir")
#     ip.is_only_type(self, :titre_n3?)
#     ip.parse("#### Un sous-sous titre")
#     ip.is_only_type(self, :titre_n4?)
#   end

#   def tes t_parse_a_image
#     ip = iparag
#     ip.parse("IMAGE[mon/image.jpg") # oubli de "]"
#     refute ip.image?

#     ip.parse("IMAGE[mon/image.jpg]")
#     assert ip.image?
#     assert_equal ip.content, "mon/image.jpg"

#     ip.parse("IMAGE[{path:'mon/img.jpg'}]")
#     assert ip.image?
#     assert_equal ip.content, "mon/img.jpg"
#   end

#   def tes t_parse_a_title
#     ip = iparag
#     [
#       ["# Un grand titre", "Un grand titre"],
#       ["#   Un grand titre\t", "Un grand titre"]
#     ].each do |line, expected|
#       ip.parse(line)
#       assert ip.titre_n1?, "'#{line}' devrait être un titre de niveau 1"
#       assert_equal ip.content, expected
#       assert_equal ip.level, 1, "Le niveau de titre de '#{line}' devrait être 1"
#     end
#   end
# end
