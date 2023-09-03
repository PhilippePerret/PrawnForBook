module Prawn4book
class PdfBook
class InputTextFile
class Paragraphe

  REG_IMAGE = /^IMAGE\[(.+?)\]$/


  class << self
    
    @codenextparag = nil

    def code_for_next_paragraph=(pfbcode)
      @codenextparag = pfbcode
    end

    def code_for_next_paragraph
      return @codenextparag
    end

  end #/<< self

  ##################    INSTANCE    ##################

  attr_reader :pdfbook
  attr_reader :line

  def initialize(pdfbook, line)
    @pdfbook = pdfbook
    @line = line
  end

  # Quand le paragraphe vient du fichier texte initial, on le
  # déduit de la ligne (pour connaitre son type)
  # 
  # C'est ici qu'est décidé la nature du paragraphe, titre, image,
  # paragraphe ou autre.
  # 
  # @return L'instance de paragraphe instancié
  # 
  def parse
    iparag =
      case line
      when Array
        # => PdfBook::NTable
        PdfBook::NTable.new(pdfbook, {lines: line, pfbcode: self.class.code_for_next_paragraph})
      when REG_IMAGE
        parse_as_image(line) # => PdfBook::NImage
      when /^\#{1,6} /
        parse_as_titre(line) # => PdfBook::NTitre
      when /^\(\( (.+) \)\)$/
        PdfBook::PFBCode.new(pdfbook, line)
      else 
        PdfBook::NTextParagraph.new(pdfbook, **{
          raw_line: line, 
          pfbcode:  self.class.code_for_next_paragraph
        })
      end
    # 
    # Le pdfcode vient d'être attribué, on le remet à 
    # nil
    # 
    if iparag.pfbcode? && iparag.for_next_paragraph?
      self.class.code_for_next_paragraph = iparag
    elsif self.class.code_for_next_paragraph
      self.class.code_for_next_paragraph = nil
    end

    return iparag
  end

  def parse_as_image(line)
    dimg = line.match(REG_IMAGE)[1]
    dimg || raise("L'image '#{line}' est mal formatée.")
    spy "dimg = #{dimg.inspect}"
    if dimg.start_with?('{') && dimg.end_with?('}')
      # 
      # Définition moderne de l'image par un dictionnaire JSON
      # 
      dimg      = eval(dimg)
      img_path  = dimg[:path]||dimg[:file]||dimg[:name]||dimg[:filename]
    elsif dimg.match?(/\|/) && dimg.match?(/\{/)
      # 
      # Nouvelle division entre le chemin d'accès et les propriétés
      # 
      # TODO
    elsif dimg.match?('\|')
      # 
      # Vieille ivision avec toutes les propriétés séparées par 
      # des '|'
      # 
      img_props = dimg.split('|').map { |n|n.strip }
      img_path = img_props[0]
      dimg = {style:img_props[1]}
      # dimg = {class:img_props[1], alt:img_props[2], style:img_props[3]}
    else
      # 
      # Simple path de l'image
      # 
      img_path  = dimg
      dimg      = {}
    end
    dimg.merge!(
      path:     img_path,
      pfbcode:  self.class.code_for_next_paragraph # code avant (if any)
    )
    return PdfBook::NImage.new(pdfbook, dimg)
  end

  def parse_as_titre(line)
    prefix, titre = line.match(/^(\#{1,6}) (.+)$/)[1..2]
    return PdfBook::NTitre.new(pdfbook, {
      level:    prefix.length,
      text:     titre.strip,
      pfbcode:  self.class.code_for_next_paragraph # code avant (if any)
    })
  end


end #/class NParagraphe
end #/class InputTextFile
end #/class PdfBook
end #/module Prawn4book

def log(str)
  STDOUT.puts str.jaune
end
