=begin
  Pour la gestion de la table des matières du livre
=end
module Prawn4book
class PdfBook
class Tdm

  # Instance Prawn4book::PdfBook
  attr_reader :pdfbook

  # Instance Praw4book::PdfFile < Prawn::Document
  attr_reader :pdffile

  # Contenu de la table des matières, une table avec
  # en identifiant l'identifiant de la section (titre
  # principal) et en valeur une table identique mais
  # de niveau inférieur
  attr_reader :content

  def initialize(pdfbook, pdffile)
    @pdfbook = pdfbook
    @pdffile = pdffile
    @content = []
  end

  #
  # Pour construire la table des matières sur la page
  # +on_page+
  # 
  def output(on_page)
    pdf = self.pdffile
    pdf.font 'Garamond', size:12
    pdf.go_to_page(on_page)
    pdf.move_cursor_to(pdf.bounds.height - 50)
    content.each do |l1_data|
      pdf.text_box "#{l1_data[:titre].text}.....#{dest(l1_data[:page])}", at: [0, pdf.cursor], height:20, width:pdf.bounds.width
      pdf.move_down(20)
      l1_data[:items].each do |l2_data|
        pdf.text_box "#{l2_data[:titre].text}.....#{dest(l2_data[:page])}", at: [20, pdf.cursor], height:20, width:pdf.bounds.width
        pdf.move_down(20)
        l2_data[:items].each do |l3_data|
          pdf.text_box "#{l3_data[:titre].text}.....#{dest(l3_data[:page])}", at: [40, pdf.cursor], height:20, width:pdf.bounds.width
          pdf.move_down(20)
          l3_data[:items].each do |l4_data|
            pdf.text_box "#{l4_data[:titre].text}.....#{dest(l4_data[:page])}", at: [40, pdf.cursor], height:20, width:pdf.bounds.width
            pdf.move_down(20)
          end
        end
      end
    end
  end

  ##
  # En règle général, la valeur retournée est le numéro de page
  # à mettre en regard du titre. Mais lorsque la numérotation des
  # pages se fait avec les numéros de premier et dernier paragraphe,
  # c'est cela qu'il faut renvoyer.
  def dest(num_page)
    if numerotation_page_with_num_parag?
      data_page = pdfbook.pages[num_page]
      "#{data_page[:first_par]}-#{data_page[:last_par]}"
    else
      num_page
    end
  end

  def numerotation_page_with_num_parag?
    pdfbook.num_page_style == 'num_parags'
  end

  #
  # Pour ajouter le titre +titre+ {PdfBook::NTitre} à la
  # table des matières
  # 
  def add_title(titre, num_page)
    if titre.level == 1
      # 
      # Initiation d'un grand titre
      # 
      @current_level1 = content.count
      content << {titre:titre, items: [], page: num_page}
      @current_level2 = 0
      @current_level3 = 0
      @current_level4 = 0
      return
    elsif titre.level == 2
      container = content[@current_level1]
      @current_level2 = container[:items].count
      @current_level3 = 0
      @current_level4 = 0
    elsif titre.level == 3
      container = content[@current_level1][:items][@current_level2]
      @current_level3 = container[:items].count
      @current_level4 = 0
    elsif titre.level == 4
      container = content[@current_level1][:items][@current_level2][:items][@current_level3]
      @current_level4 = container[:items].count
    else
      # Ce niveau de titre n'est pas enregistré
      return
    end
    container[:items] << {titre:titre, items:[], page: num_page}
  end


end #/Tdm
end #/class PdfBook
end #/module Prawn4book
