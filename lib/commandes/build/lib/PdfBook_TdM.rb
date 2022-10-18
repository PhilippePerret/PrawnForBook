=begin
  Pour la gestion de la table des matières du livre
=end
module Prawn4book
class PdfBook
class Tdm

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

  # @const Valeurs par défaut pour les données absolues de la table
  # des matières qui définissent les indentations suivant le niveau
  # de titre, les polices, les tailles, etc. Tout ce qui va permettre
  # de définir @data
  # 
  DEFAULT_VALUES = {
    font:         'Garamond',
    size:         10,
    line_height:  14,
    from_top:     50, # première ligne depuis le haut
    add_to_numero_width: 20,
    indent_per_offset: [0, 2, 4, 6, 8]
  }
  #
  # Pour construire la table des matières sur la page
  # +on_page+
  # 
  def output(on_page)
    tdm = self
    with_num_page = pdfbook.recipe[:num_page_style] == 'num_page'

    pdf.update do 
      
      # - Positionnement -
      go_to_page(on_page)
      move_cursor_to(bounds.height - tdm.data[:from_top])
      
      # - Réglages -
      tdm_line_height = tdm.data[:line_height]
      font tdm.data[:font], size: tdm.data[:size]

      # - Largeur pour le numéro -
      largeur_numero = 0
      tdm.content.each do |dtitre|
        # dtitre.delete(:titre)
        # puts "dtitre: #{dtitre.inspect}"
        len = width_of((with_num_page ? dtitre[:page] : dtitre[:paragraph]).to_s)
        largeur_numero = len if len > largeur_numero
      end
      largeur_numero += tdm.data[:add_to_numero_width]

      tdm.content.each_with_index do |data_titre, idx|
        numero_destination = (with_num_page ? data_titre[:page] : data_titre[:paragraph]).to_s
        float {
          span largeur_numero, position: :right do
            text numero_destination.to_s
          end
        }
        ititre  = data_titre[:titre]
        indent  = 10 * tdm.data[:indent_per_offset][ititre.level - 1]
        titre   = ititre.text
        largeur_titre = bounds.width - largeur_numero
        text_box "#{titre} #{' .' * 100}", at:[indent, cursor], width: largeur_titre - indent, height: 14, overflow: :truncate
        move_down(tdm_line_height)
      end
    end
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
      num_page.to_s
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
  def add_title(titre, num_page, num_parag)
    @content << {titre:titre, page: num_page, paragraph: num_parag}
  end


  # @prop Données absolues pour la table des matières
  # (police, taille, etc.)
  def data
    @data ||= DEFAULT_VALUES.merge(pdfbook.recipe[:table_of_content]||{})
  end

end #/Tdm
end #/class PdfBook
end #/module Prawn4book
