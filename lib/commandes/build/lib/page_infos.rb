=begin
  
  Insertion de la page d'informations à la fin du livre, 
  indiquant toutes les personnes ayant participé au livre

=end
module Prawn4book
class PrawnView

  def insert_page_infos
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
    font pdfbook.first_font, size: 12

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
    publisher = recette.publishing
    # 
    # On écrit toutes les informations
    [
      [publisher[:name]           , nil],
      [publisher[:site]           , nil],
      [publisher[:adresse]        , nil],
      [publisher[:mail]           , nil],
      [''                         , nil],
      [publisher[:siret]          , nil],
      ['——————'                   , nil],
      ['Contact'                  , nil],
      [publisher[:contact]        , nil],
      ['——————'                   , nil],
      [depot_legal                , nil],
      [isbn                       , nil],
      ['——————'                   , nil],
      ["Conception & rédaction"   , nil],
      [conception_redaction       , nil],
      ['Mise en page'             , nil],
      [mise_en_page               , nil],
      ['Couverture'               , nil],
      [cover_conception           , nil],
      ['Relectures et correction' , nil],
      [correction                 , nil],
      ['——————'                   , nil],
      [printing_infos             , nil],

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

  ##
  # Met en forme une information sur des gens, donnée sous forme
  # de patronyme (ou de liste de patronymes séparés par des virgules)
  # et mail optionnel (ou liste de mails séparés par des virgules)
  # 
  # @return [String] Quelque chose comme "Prénom NOM (mail)" ou
  # "Prénom NOM (mail), Prénom NOM (mail)"
  # 
  # @param [Hash] dpeople Données sur les gens
  # @option dpeople [String] patro Le ou les patronymes
  # @option dpeople [String] mail  Le ou les mails
  # 
  def traite_people_in(dpeople)
    people = dpeople[:patro] || return
    people = people.match?(',') ?
                people.split(',').map{|n|n.strip} : [people]
    mails  = dpeople[:mail]
    mails  = mails.to_s.match?(',') ?
                mails.split(',').map{|n|n.strip} : [mails]
    people.map.with_index do |patro, idx|
      patro = "#{patro} (#{mails[idx]})" unless mails[idx].nil?
      patro
    end.pretty_join
  end

  # @return [String] Les concepteurs et auteurs (sans doublons)
  def conception_redaction
    ary = (concepteurs + auteurs).uniq.pretty_join
  end
  
  # @return [Array<String>] Concepteurs (sous forme {:patro, :mail})
  def concepteurs
    page_infos[:conception][:patro].to_s.split(',').map{|n|n.strip}
  end

  def auteurs
    recette.auteurs.to_s.split(',').map{|n|n.strip}
  end

  # @return [String] Concepteurs de la couverture
  def cover_conception
    traite_people_in(page_infos[:cover])
  end

  # @return [String] Le metteur en page
  def mise_en_page
    traite_people_in(page_infos[:mise_en_page])
  end

  # @return [String] Le correcteur
  def correction
    traite_people_in(page_infos[:correction])
  end

  def isbn        ; "ISBN : #{recette.isbn}"              end
  def depot_legal ; "Dépôt légal : #{recette.depot_legal}" end

  def printing_infos
    imprimerie = page_infos[:printing][:name]
    localite   = page_infos[:printing][:lieu]
    imprimerie = "#{imprimerie} (#{localite})" unless localite.nil?
    return imprimerie
  end


  def page_infos
    @page_infos ||= recette.page_infos
  end

  def recette
    @recette ||= pdfbook.recette
  end

end #/class PrawnView
end #/module Prawn4book
