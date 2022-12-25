require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class P4BCode < AnyParagraph

  attr_reader :raw_code

  # {Hash} Contenant la définition qui doit affecter le paragraphe
  # suivant (cette instance a été mise dans la propriété :pfbcode
  # du paragraphe)
  # p.e. {font_size: 42}
  attr_reader :parag_style

  def initialize(pdfbook, raw_code)
    super(pdfbook)
    @raw_code = raw_code[3..-3].strip
    treat_as_next_parag_code if @raw_code.match?(/^\{.+?\}$/)
  end

  def print(pdf)
    case raw_code
    when /^\{.+?\}$/
      # Rien à faire de ce paragraphe puisque c'est une définition
      # du style, position, etc. du paragraphe suivant.
      spy "Parag_style = #{parag_style.inspect}"
    when 'new_page', 'nouvelle_page'
      pdf.start_new_page
    when 'tdm', 'toc'
      pdf.init_table_of_contents
    when 'index'
      pdfbook.page_index.build(pdf)
    when /^biblio/
      treate_as_biblio(pdf)
    else
      puts "Je ne sais pas traiter #{raw_code.inspect}"
    end

  end

  ##
  # Traitement d'un code qui doit affecter le paragraphe
  # suivant.
  # 
  def treat_as_next_parag_code
    @is_for_next_paragraph = true
    @isnotprinted = true # pour ne pas l'imprimer
    @parag_style = eval(raw_code)
  end

  # --- Formatage Methods ---

  ##
  # Traitement spécial quand le code est une marque de bibliographie,
  # comme par exemple '(( biblio(livre) ))'
  # Il faut :
  #   - extraire le tag de la bibliographie
  #   - prendre la bibliographie instanciée
  #   - l'imprimer dans le livre
  def treate_as_biblio(pdf)
    bib_tag = raw_code.match(/^biblio\((.+)\)$/)[1]
    bib = Bibliography.get(bib_tag) || begin
      puts "Impossible de trouver la bibliographie '#{bib_tag}'…".rouge
      return
    end
    bib.print(pdf)
  end

  # Pour pouvoir obtenir une valeur de style "inline" en faisant
  # simplement 'pfbcode[:width]' (depuis un paragraphe)
  def [](key)
    parag_style[key]
  end

  # --- Predicate Methods ---
  def paragraph?  ; false end
  def pfbcode?    ; true  end

  def for_next_paragraph?
    @is_for_next_paragraph === true
  end

end #/class P4BCode
end #/class PdfBook
end #/module Prawn4book
