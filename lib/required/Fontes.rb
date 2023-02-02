=begin

  Class Prawn4book::Fonte
  -----------------------
  Pour la gestion facile des fontes dans l'application.

  Permet de centraliser tout ce qui concerne les fontes.

  Avoir des instances permet de faire 'fonte.font', 'fonte.size', 
  etc.

=end
module Prawn4book
class Fonte
####################       CLASSE      ###################
class << self

  # @return [Prawn4book::Fonte] l'instance fonte par défaut ultime,
  # c'est-à-dire qu'elle existe toujours. 
  # 
  # @note
  #   Soit elle retourne la première fonte définie dans la recette
  #   Soit elle retourne la première fonte par défaut de Prawn
  def default_fonte
    @default_fonte ||= begin
      if book && book.recipe.default_font
        new(book.recipe.default_font, **{style: book.recipe.default_style, size:default_size})
      else
        default_fonte_times
      end
    end
  end

  def default_size
    @default_size ||= begin
      if book && book.recipe.default_size
        book.recipe.default_size
      else
        11
      end
    end
  end

  def default_fonte_times
    @default_fonte_times ||= new("Times-Roman", **{size: default_size, style: :roman})
  end

  # @prop [Prawn4book::PdfBook] Instance du livre courant
  # 
  # @api private
  def book
    @book ||= begin
      Prawn4book::PdfBook.current? && Prawn4book::PdfBook.current
    end
  end

end #/<< self Fonte
###################       INSTANCE      ###################

attr_reader :name, :style, :size
attr_reader :hname

def initialize(font_name, data)
  @data   = data
  @name   = font_name
  @style  = data[:style]
  @size   = data[:size]
  @hname  = data[:hname] # a human name
end

# @return [Hash] la table des valeurs pour le second argument de
# Prawn::Document#font
def params
  @params ||= {style: style, size: size}
end
end #/class Fonte
end #/module Prawn4book
