module Prawn4book
class PdfBook
class Glossary

  attr_reader :book
  attr_reader :pdf

  def initialize(book)
    @book = book
  end

  # Gravure du glossaire
  def print(pdf)
    return unless required?

    # Exposer
    @pdf = pdf

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

    my = self

    pdf.update do
      font(my.fonte)
      my.items.each do |hitem|
        text(hitem[:term], **{inline_format:true, styles:[:bold]})
        bounding_box([30, cursor], width: bounds.width - 30) do
          text(hitem[:definition], **{inline_format:true})
        end
        update_current_line
      end

      start_new_page
    end
  end #/print


  # Return true si on doit afficher le glossaire
  def required?
    not(@is_not_required) && not(path.nil?)
  end


  def items
    @items ||= begin
      current_word = nil
      liste = []
      File.read(path).split("\n").each do |line|
        if line.start_with?(/[ \t]/.freeze) && current_word
          liste.last[:definition] << line.strip
        else
          current_word = line.strip
          liste << {term: current_word, definition: []}
        end
      end
      liste.each do |hword|
        definition = hword[:definition].join("\n")
        paragraphe = PdfBook::UserParagraph.new(pdf, definition, nil)
        definition = AnyParagraph.__parse(definition,**{paragraph:paragraphe, pdf:pdf})
        hword[:definition] = definition
      end
      liste.sort { |a, b| a[:term].downcase <=> b[:term].downcase }
    end
  end

  def title
    @title ||= recipe[:title] || TERMS[:Glossary]
  end

  def title_level
    @title_level ||= recipe[:title_level] || 2
  end

  def path
    @path ||= book.file_exist?([recipe[:path],"glossary.txt","glossaire.txt"])
  end

  def fonte
    @fonte ||= Fonte.get_in(recipe).or_default
  end

  def recipe
    @recipe ||= begin
      r = book.recipe.glossary
      @is_not_required = r === false
      r = {} if r === false
      r
    end
  end

end #/class Glossary
end #/class PdfBook
end #/module Prawn4book
