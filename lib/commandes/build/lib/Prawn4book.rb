module Prawn4book

  def self.force?
    :TRUE == @modeforce ||= true_or_false(CLI.option(:force))
  end
  def self.first_turn?
    @@turn ||= 1
    @@turn == 1
  end
  def self.second_turn?
    @@turn == 2
  end
  def self.third_turn?
    @@turn == 3
  end

  def self.turn
    @@turn
  end
  def self.turn=(value)
    @@turn = value
  end

  def self.second_turn_required?
    curbook = PdfBook.current
    curbook.table_references.appels_sans_reference? || \
    curbook.table_illustrations.required?
  end

  def self.requires_third_turn
    @@third_turn = true
  end
  def self.require_third_turn?
    @@third_turn ||= false
    @@third_turn === true
  end

  # @return true si la gravure du livre a été partielle
  def self.partial_gravure?
    @@partial_gravure === true
  end

  # @return true si on est dans une section où la gravure (lecture et
  # impression des paragraphes) a été interrompue par un ’(( stop ))’
  # 
  @@gravure_is_stopped = false
  def self.gravure_stopped?
    return @@gravure_is_stopped
  end
  def self.stop_gravure
    @@gravure_is_stopped = true
    @@partial_gravure = true
  end
  def self.restart_gravure
    @@gravure_is_stopped = false
  end

  # Méthode qui définit les constantes qui vont servir pour les
  # code (pour les simplifier)
  # 
  # @note
  #   Ces constantes, comme LINE_HEIGHT, peuvent être redéfinies à
  #   la volée au cours de la construction du livre.
  # 
  # @param pdf [Prawn::PrawnView] Document en construction
  # 
  def self.define_constants(book, pdf)
    pdf.line_height = book.recipe.line_height
    define_constant('PAGE_WIDTH', pdf.bounds.width)
    define_constant('PAGE_HEIGHT', pdf.bounds.height)
  end
  def self.define_constant(const_name, const_value, main_class = nil)
    main_class ||= self
    if main_class.constants.include?(const_name.to_sym)
      main_class.send(:remove_const, const_name)
    end
    main_class.const_set(const_name, const_value)
  end

end #/module Prawn4book
