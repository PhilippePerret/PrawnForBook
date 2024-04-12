# Les boites virtuelles ajoutées à Prawn
# 
# @usage
# 
#   vbox = pdf.virtual_box([x, y], **{<data>}) => instancie la boite virtuelle
# 
#   <data>
#     width:  largeur
#     height: hauteur
# 
# 
#   vbox.add({data_element})
# 
#     Pour ajouter un élément dans la boite virtuelle
#     Ou une sous-méthode:
# 
#   vbox.add_image({data_element}) # svg ou image normale
#   vbox.add_text({data_element})
#   vbox.add_table({data_element})
# 
#   <data_element>
#     type:       Pour #add, il faut définir le type (:text, :table,
#                 :image, etc.)
#     content:    Le contenu (pour le texte)
#     path:       Le chemin d’accès à l’image ou au texte
#     data:       Les données prawn (at:, width:, font:, etc.)
# 
module Prawn
module View

  ##
  # Pour instancier une boite virtuelle
  # 
  # @usage
  #   virtual_box = pdf.virtual_box(point, **data)
  # 
  def virtual_box(point = [0,0], **data)
    VirtualBox.new(self, point, **data)
  end
  alias :make_virtual_box :virtual_box # pour correspondre à Prawn

class VirtualBox

  attr_reader :origin
  attr_reader :pdf
  attr_reader :elements

  def initialize(pdf, origin, data)
    @pdf = pdf
    @origin = Origin.new(origin)
    @elements = []
  end

  ##
  # @api
  # 
  # Grave la boite virtuelle dans son pdf
  # 
  # @param at [Array]
  #   Le point [x, y] où il faut dessiner la boite virtuelle
  # 
  # @param options [Hash]
  # 
  def draw_at(at, **options)
    new_origin = Origin.new(at)
    elements.each do |delement|
      if delement.respond_to?(:print_at)
        delement.delta_at(at).print(pdf)
      else
        delement = rectif_at(delement, new_origin)
        delement = eval_dimensions_pourcentage(delement)
        case delement.delete(:type)
        when :image
          pdf.update do
            image(delement.delete(:content), **delement)
          end
        when :svg
          pdf.update do
            svg(delement.delete(:content), **delement)
          end
        when :text
          pdf.update do
            text(delement.delete(:content), **delement)
          end
        end
      end #/hash, pas Prawn4book::Image
    end
  end
  alias :draw :draw_at # pour que ça corresponde avec Prawn

  def rectif_at(data, origin)
    data[:at][0] += origin.x
    data[:at][1] += origin.y
    return data
  end

  def eval_dimensions_pourcentage(data)
    if data[:width] && data[:width].to_s.end_with?('%')
      data.merge!(width: eval_dim(data[:width], pdf.bounds.width))
    end
    if data[:height] && data[:height].to_s.end_with?('%')
      data.merge!(height: eval_dim(data[:height], pdf.bounds.height))
    end
    return data
  end
  def eval_dim(dim, dim_ref)
    dim = dim[0...-1].to_f
    return (dim / 100) * dim_ref
  end

  ##
  # Méthode pour ajouter
  # 
  def add(element)
    case element[:type]
    when :text  then add_text(element)
    when :image then add_image(element)
    when :table then add_table(element)
    when NilClass then
      raise "Il faut absolument définir le type de l’élément de la VirtualBox de données #{element}".rouge
    else
      raise "PFB ne sait pas encore traiter les éléments de type #{element[:type].inspect} dans les VirtualBoxes.".rouge
    end
  end

  def add_image(data)
    if data.is_a?(Prawn4book::Image)
      @elements << data
    else
      path    = data.delete(:path)
      is_svg  = File.extname(path).downcase == '.svg'
      content = if is_svg
                  IO.read(path)
                else
                  path
                end
      data    = rectif_at(data, origin)
      @elements << {type: (is_svg ? :svg : :image), content: content, **data}
    end
  end

  def add_text(data)
    if data.key?(:path)
      data.merge!(content: IO.read(data.delete(:path)))
    end
    data = rectif_at(data, origin)
    @elements << {type: text, **data}
  end


  class Origin
    attr_reader :x, :y
    def initialize(point)
      if point.is_a?(Array)
        @x = point[0]
        @y = point[1]
      elsif point.is_a?(Origin)
        @x = point.x.dup
        @y = point.y.dup
      elsif point.is_a?(Hash)
        @x = point[:x] || point[:left]
        @y = point[:y] || point[:top]
      end
      @x ||= 0
      @y ||= 0
    end
  end
end #/class VirtualBox
end #/class View
end #/module Prawn
