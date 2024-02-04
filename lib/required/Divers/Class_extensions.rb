class String


  # Reçoit soit une valeur avec des unités comme "mm" ou "cm", soit
  # une valeur en pourcentage et retourne la valeur correspondante 
  # en "points-post-script", c’est-à-dire en "point-PDF".
  # 
  # Si c’est une valeur en pourcentage, +ref+ doit être impérativement
  # fournie et correspondre à la valeur 100 % à prendre en référence.
  # 
  def to_pps(ref = nil)
    if self.strip.match?(/\%$/)
      ref || raise(ArgumentError.new(PFBError[6000]))
      str = self.strip.gsub(/ ?\%$/,'').to_i
      ref.to_f * str.to_f / 100
    else
      self.class.proceed_unit(self)
    end
  end

  # Transforme en points-pdf des valeurs fournies comme "xmm" ou
  # "xcm", etc. en utilsant Prawn::Measurements
  def self.proceed_unit(foo)
    foo.proceed_unit
  end

  # Reçoit une valeur ou une liste de valeur avec des unités et
  # retourne la valeur correspondante en nombre grâce aux méthodes
  # de Prawn::Measurements
  def proceed_unit
    if self.numeric?
      self.to_f
    else
      unite   = self[-2..-1]
      unite   = UNITE_TO_REAL_UNITE[unite] || unite
      nombre  = self[0..-3].to_f
      nombre.send(unite.to_sym)
    end
  end
  UNITE_TO_REAL_UNITE = {
    'po' => 'in'
  }

  def colorize_in(html_color)
    "<color rgb=\"#{html_color}\">#{self}</color>"
  end


  # Met tout le texte en capitales, mais en ne touchant pas aux
  # balises HTML peut-être contenues
  # 
  def all_caps
    str = self.dup
    table_html_tags = {}
    x_html_tag = 0
    str = str.gsub(/(<.+?>)/) do
      x_html_tag += 1
      k_html_tag = "_BALHTML#{x_html_tag}_"
      table_html_tags.merge!(k_html_tag => $1.freeze)
      k_html_tag
    end
    str = str.upcase
    table_html_tags.each do |ktag, real_value|
      str = str.sub(ktag, real_value)
    end
    return str
  end

end #/class String






class Array
  def proceed_unit
    self.collect { |e| String.proceed_unit(e) }
  end
end
class Integer
  def proceed_unit; self  end
  def to_pps(arg=nil); self end
  # Seconds to Horloge
  def s2h
    h = (self / 3600).to_s
    r = self % 3600
    m = (r / 60).to_s.rjust(2, '0')
    s = (r % 60).to_s.rjust(2, '0')
    "#{h}:#{m}:#{s}"
  end
  alias :real_pt2mm :pt2mm
  def pt2mm
    real_pt2mm(self)
  end
end
class Float
  def proceed_unit; self  end
  alias :real_pt2mm :pt2mm
  def pt2mm
    real_pt2mm(self)
  end
  def to_pps(arg=nil); self end
end
class NilClass
  def proceed_unit; nil   end
  def to_sym; nil end
end

class Symbol

  SYMBOL_TO_HTML_COLOR = {
    rouge: 'FF0000',
    red: 'FF0000',
    vert:  '008800',
    green:  '008800',
    bleu:  '0000FF',
    blue:  '0000FF',
    jaune: 'FCFF33',
    yellow: 'FCFF33',
  }

  def to_html_color
    SYMBOL_TO_HTML_COLOR[self]
  end

end #/class Symbol

class NilClass
  def to_pps # quand une dimension n’est pas définie
    nil
  end
end #/class NilClass


class Exception
  # Pour obtenir la ligne où s’est produite l’erreur (quand on
  # n’affiche page le backtrace)
  # 
  # @usage
  # 
  #   begin
  #     raise "Une erreur"
  #   rescue Exception => e
  #     puts "L’erreur s’est produite à la ligne #{e.line}"
  #   end
  # 
  def line
    backtrace[0].split(':')[1]
  end
end
