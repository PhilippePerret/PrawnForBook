=begin
  
  Insertion de la page d'informations à la fin du livre, 
  indiquant toutes les personnes ayant participé au livre

=end
module Prawn4book
class PrawnDoc < Prawn::Document

  def insert_page_infos(pdfbook)
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
    page_info = book.recette[:page_info]
    editor    = book.recette.editor
    [
      [editor[:name]           , nil],
      [editor[:site]           , nil],
      [editor[:adresse]        , nil],
      [editor[:mail]           , nil],
      ['', nil],
      [editor[:siret]          , nil],
      ['——————', nil],
      ['Contact', nil],
      [editor[:contact]        , nil],
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
      mg ||= LINE_HEIGHT
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
    ary = (recette.page_info[:conception]||[]) + recette.auteurs
    ary.uniq.pretty_join
  end

  def mise_en_page
    recette.page_info[:mep].uniq.pretty_join
  end

  def depot_legal
    "Dépôt légal : #{recette.page_info[:depot_bnf]}"
  end

  def correction
    recette.page_info[:corrections].pretty_join
  end

  def recette
    @recette ||= pdfbook.recette
  end

  LINE_HEIGHT = 16

end #/class PrawnDoc
end #/module Prawn4book
