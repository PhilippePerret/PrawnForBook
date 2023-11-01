class String

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
      nombre  = self[0..-3].to_f
      nombre.send(unite.to_sym)
    end
  end

end #/class String

class Array
  def proceed_unit
    self.collect { |e| String.proceed_unit(e) }
  end
end
class Integer
  def proceed_unit; self  end
end
class Float
  def proceed_unit; self  end
  alias :real_pt2mm :pt2mm
  def pt2mm
    real_pt2mm(self)
  end
end
class NilClass
  def proceed_unit; nil   end
  def to_sym; nil end
end
