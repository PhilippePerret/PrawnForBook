=begin
  Pour la gestion de la table des matières du livre
=end
module Prawn4book
class PdfBook
class Tdm

  LINE_HEIGHT = 20

  NUMERO_WIDTH = 50

  #
  # Distance du numéro de page/paragraphes avec la marge droite
  # Peut-être redéfinie dans les recettes par 
  # :tdm{:dist_num_from_rmargin}
  NUMERO_FROM_RIGHT_MARGIN = 0


  # Instance Prawn4book::PdfBook
  attr_reader :pdfbook

  # Instance Praw4book::PrawnDoc < Prawn::Document
  attr_reader :pdf

  # Contenu de la table des matières
  # Une liste avec les titres qui se suivent, chaque élément est
  # un hash qui contient :titre (l'instance NTitre) et la page
  attr_reader :content

  def initialize(pdfbook, pdf)
    @pdfbook  = pdfbook
    @pdf      = pdf
    @content  = []
  end

  #
  # Pour construire la table des matières sur la page
  # +on_page+
  # 
  def output(on_page)
    pdf.go_to_page(on_page)
    # pdf.stroke_axis # pour voir les axes
    pdf.move_cursor_to(pdf.bounds.height - 50)
    suivi = ('Écriture du titre #%{num}/' + content.count.to_s).vert
    content.each_with_index do |data_titre, idx|
      begin
        write_at(suivi % {num: idx+1}, 2, 0)
        write_title(data_titre)
      rescue Exception => e
        puts "\nProblème avec le titre : #{data_titre.inspect}".rouge
        puts "-> #{e.message}".rouge
        puts e.backtrace[-3..-1].join("\n").rouge
      end
    end
    puts "\n\n"
  end

  ##
  # Écrit le titre défini par les +data+
  # @param {Hash} data
  #   :titre  Instance PdfBook::NTitre du titre
  #           Définit notamment :text et :level
  #   :page   Numéro de page où se trouve le titre
  def write_title(data)
    titre     = data[:titre]
    return if titre.level > 4 # TODO pouvoir le définir
    idxtitre  = titre.level - 1
    indent    = [0, 15, 30, 45][idxtitre]  # TODO Pouvoir le régler
    fsize     = [14, 12, 10, 10][idxtitre] # TODO Pouvoir le régler

    # 
    # Font pour ce niveau de titre
    # 
    # 
    # Numéro pour la pagination
    # 
    numero = destination(data[:page])
    numero = numero.to_s
    # 
    # Largeur de la pagination
    # 
    pdf.font 'Garamond', size: 11
    wnum = pdf.width_of(numero)

    hauteur_cursor = pdf.cursor.freeze

    # 
    # Écriture du texte
    # 
    pdf.font( 'Garamond', size: fsize)
    # puts "Titre «#{titre.text.inspect}» (level: #{titre.level.inspect}) - indent:#{indent.inspect} — width num: #{wnum.inspect} - page_width: #{page_width.inspect}"
    titre_width = page_width - (indent + wnum)
    # puts "=> titre_width = #{titre_width.inspect}"
    # pdf.text_box "#{titre.text}#{' .' * 50}", at: [indent, pdf.cursor], width:titre_width, overflow: :truncate #, height:LINE_HEIGHT
    
    # pdf.span pdf.bounds.width, position: indent, overflow: :truncate, inline_format: true do
    #   pdf.text "#{titre.text}#{' .' * 30}", overflow: :truncate
    # end

    # 
    # Écriture de la pagination
    # 
    pdf.move_cursor_to(hauteur_cursor)
    pdf.font 'Garamond', size: 11
    pdf.text_box "#{'. ' * 50} #{numero.strip}", width: page_width - wnum, align: :right, overflow: :truncate
    # pdf.span page_width - wnum, position: 0 do
    #   pdf.text "#{' .' * 50} #{numero}", align: :right
    # end

    pdf.move_down(LINE_HEIGHT)

  end

  def page_width
    @page_width ||= pdf.bounds.width
  end


  ##
  # En règle général, la valeur retournée est le numéro de page
  # à mettre en regard du titre. Mais lorsque la numérotation des
  # pages se fait avec les numéros de premier et dernier paragraphe,
  # c'est cela qu'il faut renvoyer.
  def destination(num_page)
    if numerotation_page_with_num_parag?
      data_page = pdfbook.pages[num_page]
      "#{data_page[:first_par]}-#{data_page[:last_par]}"
    else
      num_page
    end
  end
  alias dest destination

  def numerotation_page_with_num_parag?
    pdfbook.recette.style_numero_page == 'num_parags'
  end

  #
  # Pour ajouter le titre +titre+ {PdfBook::NTitre} à la
  # table des matières
  # 
  def add_title(titre, num_page)
    @content << {titre:titre, page: num_page}
  end


end #/Tdm
end #/class PdfBook
end #/module Prawn4book
