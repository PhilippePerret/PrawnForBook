# =begin

#   Ce module est pensé pour être le seul à gérer toutes les 
#   mesures du livre, à commencer par les fonts.

#   Metric.default_font_size
#   Metric.current_font_size
#   Metric.default_font_name_n_style
#   Metric.current_font_name_n_style

# =end
# require 'singleton'
# module Prawn4book
# class MetricClass
#   include Singleton

#   # Instance [Prawn4book::Prawnvie]
#   attr_accessor :pdf

#   def recipe
#     @recipe ||= PdfBook.current.recipe
#   end

#   def default_font_name
#     @default_font_name ||= recipe.default_font_name
#   end
#   def default_font_style
#     @default_font_style ||= recipe.default_font_style
#   end
#   def default_font_size
#     @default_font_size ||= recipe.default_font_size
#   end

#   def current_font_size
    
#   end

#   def default_font_and_style
#     @default_font_and_style ||= begin
#       recipe.default_font_and_style
#     end
#   end

# end #/class Metric

# Metric = MetricClass.instance

# end #/module Prawn4book
