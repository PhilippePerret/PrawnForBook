=begin

  Construction de la page d'index

=end
module Prawn4book
class PageIndex

  # --- INSTANCE ---

  attr_reader :pdfbook
  attr_reader :table_index

  def initialize(pdfbook)
    @pdfbook = pdfbook
    @table_index = {}
  end

  # - raccourci -
  def recipe
    @recipe ||= pdfbook.recipe
  end

  ##
  # Construction de la page d'index, à l'endroit où on se trouve
  # du livre
  # 
  # Cf. ci-dessous, dans #add, les données qu'on a obtenues des
  # mots à indexer.
  # 
  def build(pdf)
    # 
    # S'il n'y a aucun mot indexé, on s'en retourne tout de suite
    # 
    return if table_index.empty?
    # 
    # La clé à utiliser pour la page ou le paragraphe
    # 
    key_num = pdfbook.page_number? ? :page : :paragraph
    # 
    # Le titre de la page d'index
    # 
    titre = PdfBook::NTitre.new(pdfbook, text:"Index", level:1)
    titre.print(pdf)
    # 
    # Police et taille
    # 
    ft = pdf.font(recipe.index_font_name, size: recipe.index_font_size, style: recipe.index_font_style)
    table_index.sort_by do |canon, dcanon|
      dcanon[:canon_for_sort]
    end.each do |canon, dcanon|
      pdf.move_cursor_to_next_reference_line
      pdf.text "#{canon} : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}"
    end

  end

  ##
  # Pour ajouter un mot indexé à la table
  # 
  # @param dmot {Hash} Donnée du mot à indexer. Contient :
  #   :mot        Le mot tel qu'il se présente dans le texte
  #   :canon      Le mot canonique, s'il est différent du mot
  #   :page       Le numéro de page du mot
  #   :paragraph  Le numéro de paragraphe du mot
  # 
  def add(dmot)
    canon = (dmot[:canon]||dmot[:mot]).downcase
    dmot.merge!(canon: canon)
    table_index.key?(canon) || begin
      cfsort = canon.normalized
      table_index.merge!(canon => {canon_for_sort: cfsort, items: []})
    end
    table_index[canon][:items] << dmot
  end

end #/class PageIndex
end #/module Prawn4book
