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
    @parag_style = {}
    if @raw_code.strip.match?(/^\{.+?\}$/)
      treat_as_next_parag_code 
    end
  end

  def print(pdf)
    case raw_code
    when /^\{.+?\}$/
      # Rien à faire de ce paragraphe puisque c'est une définition
      # du style, position, etc. du paragraphe suivant.
      spy "Parag_style = #{parag_style.inspect}"
    when 'new_page', 'nouvelle_page', 'saut_de_page'
      pdf.start_new_page
    when 'new_even_page', 'nouvelle_page_paire'
      pdf.update do
        start_new_page
        start_new_page if page_number.odd?
      end
    when 'new_odd_page', 'new_belle_page', 'nouvelle_page_impaire'
      pdf.update do
        start_new_page
        start_new_page if page_number.even?
      end
    when 'tdm', 'toc', 'table_des_matieres','table_of_contents','table_of_content'
      pdf.init_table_of_contents
    when 'index'
      pdfbook.page_index.build(pdf)
      pdfbook.pages[pdf.page_number][:content_length] += 100
    when /^biblio/
      treate_as_bibliography(pdf)
    when 'line'
      pdf.update do
        text " "
      end
    when /^([a-z0-9_]+)(?:\((.*?)\))?$/
      methode = $1.to_sym.freeze
      params  = $2.freeze
      if self.respond_to?(methode)
        #
        # Quand la méthode est définie comme méthode d'instance 
        # (avec ou sans arguments)
        #
        begin
          @pdf      = pdf
          @pdfbook  = pdfbook
          self.instance_eval(raw_code)
        rescue Exception => e
          # 
          # La méthode est peut-être mal implémentée
          # 
          raise FatalPrawForBookError.new(1100, {code:raw_code, lieu:e.backtrace.shift, err_msg:e.message, backtrace:e.backtrace.join("\n")})
        end
      elsif PrawnHelpersMethods.respond_to?(methode)
        #
        # Quand la méthode est définie comme méthode de classe
        # 
        parameters_count = PrawnHelpersMethods.method(methode).parameters.count
        str = 
          case parameters_count
          when 2 then PrawnHelpersMethods.send(methode,pdf,pdfbook)
          when 1 then PrawnHelpersMethods.send(methode,pdf)
          when 0 then PrawnHelpersMethods.send(methode)
          end
        pdf.update do
          text(str)
        end
      end
    else
      raise FatalPrawForBookError.new(1001, {code:raw_code, page: pdf.page_number})
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
  def treate_as_bibliography(pdf)
    Bibliography.print(raw_code.match(/^biblio.*?\((.+?)\)$/)[1], pdfbook, pdf)
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
