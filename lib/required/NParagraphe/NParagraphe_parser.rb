module Narration
class InputSimpleFile
class NParagraphe

  REG_LINE = /^IMAGE\[(.+?)\]$/

  attr_reader :line

  def initialize(line)
    @line = line
  end

  # Quand le paragraphe vient du fichier texte initial, on le
  # déduit de la ligne (pour connaitre son type)
  def parse
    case line
    when REG_LINE
      parse_as_image(line) # => PdfBook::NImage
    when /^\#{1,4}/
      parse_as_titre(line) # => PdfBook::NTitre
    else 
      PdfBook::NTextParagraph.new({raw_line: line})
    end
  end

  def parse_as_image(line)
    dimg = line.match(REG_LINE)[1]
    dimg || raise("L'image '#{line}' est mal formatée.")
    if dimg.start_with?('{') && dimg.end_with?('}')
      dimg      = eval(dimg)
      img_path  = dimg[:path]||dimg[:file]||dimg[:name]||dimg[:filename]
    else
      img_path  = dimg
      dimg      = {}
    end
    dimg.merge!(path: img_path)
    PdfBook::NImage.new(dimg)
  end

  def parse_as_titre(line)
    prefix, titre = line.match(/^(\#{1,4}) (.+)$/)[1..2]
    level = prefix.length
    text  = titre.strip
    PdfBook::NTitre.new({level:level, text:text})
  end


end #/class NParagraphe
end #/class PdfBook
end #/module Narration

def log(str)
  STDOUT.puts str.jaune
end
