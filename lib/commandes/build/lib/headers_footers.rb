module Prawn4book
class PrawnView

  ##
  # Place les numéros de pages
  # (note : ne devrait pas être utilisé puisqu'on mettra plutôt
  #  le numéro des paragraphes)
  def set_pages_numbers(data_pages)
    @top_footer ||= - footer_height

    font footer_font_name, size: footer_font_size

    case pdfbook.recette.style_numero_page
    when 'num_parags'
      numerote_pages_with_paragraphs_number(data_pages)
    when 'num_page'
      numerote_pages_with_page_number
    end

  end

  def numerote_pages_with_page_number
    str = "<page>"
    odd_options = { 
      page_filter: :odd,
      at: [bounds.right - 200, @top_footer], 
      width: 200, 
      align: :right,
      start_count_at: 1
    }
    even_options = {
      page_filter: :even,
      at: [0, @top_footer], 
      width: 200, 
      align: :left,
      start_count_at: 2
    }
    number_pages str, odd_options
    number_pages str, even_options
  end

  #
  # Numérotation exceptionnelle des pages avec le numéro des
  # premiers et derniers paragraphes
  # 
  # Cf. https://github.com/prawnpdf/prawn/blob/7d4f6b8998e0627259c1036a2cd6bca65cd53f45/lib/prawn/document.rb#L572
  def numerote_pages_with_paragraphs_number(data_pages)
    common_options = {
      width: 200,
      height: 50,
      color: 'CCCCCC'
    }
    odd_options = common_options.merge({
      at: [bounds.right - 200, @top_footer],
      align: :right
    })
    even_options = common_options.merge({
      at: [0, @top_footer], 
      align: :left,
    })
    # 
    # Réglage de la fonte
    # 
    font footer_font_name, size: footer_font_size
    # 
    # Boucle sur toutes les pages (qui comportent des paragraphes)
    # 
    data_pages.each do |page_number, data_page|
      if page_match?(:odd, page_number)
        options = odd_options.dup
      else
        options = even_options.dup
      end
      go_to_page(page_number)
      str = "#{data_page[:first_par]} - #{data_page[:last_par]}"

      # Debug
      # puts "str = #{str.inspect} / #{options.inspect} / page #{page_number}"

      text_box str, options

      break if page_number === last_page

    end

  end


  def parag_number_width
    @parag_number_width ||= 7.mm
  end

  # --- Predicate Methods ---

  def paragraph_number?
    :TRUE == @hasparagnum ||= true_or_false(pdfbook.recette.paragraph_number?)
  end



  # --- Calcul Methods ---

  # @prop Hauteur du pied de page. Déterminera le cursor maximal pour
  # une page
  def footer_height
    @footer_height ||= begin
      font footer_font_name, size: footer_font_size
      height_of("Dans le pied de page")
    end
  end
  def footer_font_name
    @footer_font_name ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:font] 
      end || DEFAULT_FONT
    end
  end
  def footer_font_size
    @footer_font_size ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:size] 
      end || DEFAULT_SIZE_FONT
    end
  end

end #/class PrawnView
end #/module Prawn4book
