=begin
  
  Insertion de la page d'informations à la fin du livre, 
  indiquant toutes les personnes ayant participé au livre

=end
module Prawn4book
class PrawnView

  def insert_page_infos
    # @pdfbook = pdfbook # déjà mis avant ?
    # 
    # Pour raccourcir
    # 
    book = pdfbook

    #
    # Le titre du livre
    # 
    titre = pdfbook.titre

    #
    # On insert toujours une nouvelle page
    # 
    start_new_page

    #
    # On doit se retrouver sur une belle page
    # 
    unless page_match?(:odd, page_number)
      start_new_page
    end

    #
    # Mise en forme voulue
    # 
    font "Garamond", size: 12 # TODO pouvoir le régler

    #
    # Options générales
    # 
    top = bounds.height - 50
    options = {
      at:     [0, top],
      width:  bounds.width,
      height: 16,
      align:  :center,
      valign: :center,
    }

    # 
    # Liste des données qui seront inscrites
    # 
    # Chaque élément contient :
    # 
    # ["valeur", margin bottom|nil]
    publisher    = book.recette.publisher
    [
      [publisher[:name]           , nil],
      [publisher[:site]           , nil],
      [publisher[:adresse]        , nil],
      [publisher[:mail]           , nil],
      ['', nil],
      [publisher[:siret]          , nil],
      ['——————', nil],
      ['Contact', nil],
      [publisher[:contact]        , nil],
      ['——————', nil],
      [depot_legal                  , nil],
      ["ISBN : #{page_info[:isbn]}" , nil],
      ['——————', nil],
      ["Conception & rédaction"     , nil],
      [conception_redaction         , nil],
      ['Mise en page'               , nil],
      [mise_en_page                 , nil],
      ['Couverture'                 , nil],
      [page_info[:cover]            , nil],
      ['Relectures et correction'   , nil],
      [correction                   , nil],
      ['——————', nil],
      [page_info[:print]            , nil],

    ].each do |text, mg|
      next if text.nil?
      mg ||= line_height
      top += mg
      options[:at][1] = top
      text_box(text, options)
    end

    #
    # On se positionne au bon endroit pour écrire le texte
    # 
    text_box(titre, options)

    #
    # Le recto de la page
    # 
    start_new_page
    
  end

  def conception_redaction
    ary = (page_info[:conception]||[]) + recette.auteurs
    ary.uniq.pretty_join
  end

  def mise_en_page
    page_info[:mep]&.pretty_join
  end

  def depot_legal
    "Dépôt légal : #{page_info[:depot_bnf]}"
  end

  def correction
    page_info[:corrections]&.pretty_join
  end

  def page_info
    @page_info ||= pdfbook.recette[:page_info] || {}
  end

  def recette
    @recette ||= pdfbook.recette
  end

end #/class PrawnView
end #/module Prawn4book
