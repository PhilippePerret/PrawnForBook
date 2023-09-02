class String

  DIMENSION_REG = /([0-9.,]+)(mm|cm|dm|m|ft|in|yd)/.freeze

  # Rectification de la méthode #to_f pour pouvoir traiter les
  # dimensions comme "3mm"
  # 
  alias :real_to_f :to_f
  def to_f
    if self.match?(DIMENSION_REG)
      self.match(DIMENSION_REG) {
        nombre = $1.real_to_f.freeze
        unite  = $2.to_sym.freeze
        return nombre.send(unite)
      }
    else
      self.real_to_f
    end
  end


end
