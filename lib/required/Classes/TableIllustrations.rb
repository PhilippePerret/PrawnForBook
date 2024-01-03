require_relative 'SpecialTable'
module Prawn4book
class PdfBook
class TableIllustrations < SpecialTable

  attr_reader :images

  def initialize(book)
    super
    @images = []
    PROTECTED_PROPERTIES << :@images
    @has_print_mark = false # sera mis à true si (( tdi )) dans texte
    PROTECTED_PROPERTIES << :@has_print_mark
  end

  # Gravure de la table des illustration
  # 
  def print(pdf, premier_tour)
    super
    return unless required? || premier_tour

    # On passe toujours à la page suivante
    pdf.start_new_page

    # Si le glossaire doit être mis sur une belle page,
    # il faut s’assurer qu’on s’y trouve
    if recipe[:belle_page] == true && pdf.page_number.even?
      pdf.start_new_page
    end

    # - Écriture du titre sur une nouvelle page -
    unless title_level < 1
      titre = PdfBook::NTitre.new(book:book, titre:title, level:title_level, pindex:0 )
      titre.print(pdf)
    else
      move_to_line(1)
    end

    if premier_tour
    
      @has_print_mark = true # pour requérir un second tour

      page_count.times { pdf.start_new_page }

      return # On s’arrête là pour la premier tour
    end


    my = self

    pdf.update do
      font(my.fonte)
      my.images.each do |image|
        text("#{image.picture_name} p. #{image.page}")
      end

      start_new_page
    end

  end #/print

  # Pour ajouter une image
  # 
  # @note
  #   Seulement au premier tour
  # 
  # @param [AnyParagraph::NImage] image
  #   L’image, une fois imprimée dans le livre
  # 
  def add(image)
    return if Prawn4book.second_turn?
    @images << image
  end

  # Return true si on doit afficher le glossaire
  def required?
    not(@is_not_required) && @has_print_mark
  end

  # Nombre de pages prévues pour la table des illustrations
  def page_count
    @page_count ||= recipe[:page_count] || 2
  end

end #/class Glossary
end #/class PdfBook
end #/module Prawn4book
