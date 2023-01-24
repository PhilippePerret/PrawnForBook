module Prawn4book
class PdfBook
class AnyParagraph

  attr_reader :pdfbook

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  def titre?    ; false end
  def sometext? ; false end # surclassé par les filles
  def pfbcode?  ; false end

  # Sera mis à true pour les paragraphes qui ne doivent pas être
  # imprimés, par exemple les paragraphes qui définissent des 
  # propriétés pour les paragraphes suivants.
  def not_printed?
    @isnotprinted === true
  end

  def pfbcode
    @pfbcode ||= data[:pfbcode]
  end

  def length
    @length ||= text.length
  end

  # --- Cross-references Methods ---

  # Noter que ces méthodes, pour le moment, ne servent qu'à des fins
  # de check, pour voir si les références sont bien définies.

  # @return [Hash] Liste des références croisées que contient
  # le paragraphe (texte ou le titre). La clé  est l'identifiant
  # du livre (tel qu'il est défini dans la bibliographie des livres)
  # et la valeur est la liste des cibles de ce livre.
  def cross_references
    tbl = {}
    text.scan(REG_APPEL_CROSS_REFERENCE).to_a.each do |book_id, cible|
      tbl.key?(book_id) || tbl.merge!(book_id => [])
      tbl[book_id] << cible
    end
    return tbl
  end

  # @return [Boolean] True si le paragraphe (texte ou titre) contient
  # des références croisées
  # 
  def match_cross_reference?
    text.match?(/\( \->\((.+?):(.+?)\)/)
  end

REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/

REG_CIBLE_REFERENCE = /\(\( <\-\((.+?)\) \)\)/
REG_APPEL_REFERENCE = /\(\( \->\((.+?)\) +\)\)/
REG_APPEL_CROSS_REFERENCE = /\(\( \->\((.+?):(.+?)\) +\)\)/

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
