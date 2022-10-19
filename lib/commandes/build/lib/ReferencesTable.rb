module Prawn4book
class PdfBook
class ReferencesTable

  attr_reader :pdfbook
  attr_reader :table

  attr_accessor :second_turn

  def initialize(pdfbook)
    @pdfbook = pdfbook  
  end

  ##
  # Initialisation
  # 
  def init
    puts "Je dois apprendre à détruire l'évenuel fichier existant".jaune
    @table = {}
  end

  ##
  # Ajout d'une référence rencontrée
  # 
  # @param ref_id {String} IDentifiant de la référence
  # @param ref_data {Hash} Données de la référence, contient
  #         {:page, :paragraph}
  def add(ref_id, ref_data)
    return if second_turn
    ref_id = ref_id.to_sym
    if table.key?(ref_id)
      raise "Reference '#{ref_id}' already exists."
    else
      table.merge!(ref_id => ref_data)
    end
  end

  ##
  # Récupération d'une référence
  # Au premier tour, si elle n'est pas définie, on indique qu'il
  # faudra recommencer un tour.
  def get(ref_id)
    ref_id = ref_id.to_sym
    if table.key?(ref_id)
      pdfbook.pagination_page? ? "page #{table[ref_id][:page]}" : "paragraphe #{table[ref_id][:paragraph]}"
    else
      set_on_appel_sans_reference
      "-REF #{ref_id} MISSING-"
    end
  end

  def save
    puts "Je dois apprendre à enregistrer les références".jaune
  end

  # --- Predicate Methods ---

  # @return true Si le livre contient des références
  # 
  def any?
    table.count > 0
  end

  # @return true si un appel est resté sans référence
  # (cela se produit quand un appel de référence se trouve avant
  # la référence en question — donc sur une page ou un paragraphe 
  # avant)
  def has_one_appel_sans_reference?
    :TRUE == @hasoneappelsansref
  end
  # Quand on trouve un appel de référence sans référence
  # définie.
  def set_on_appel_sans_reference
    @hasoneappelsansref = :TRUE
  end


end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
