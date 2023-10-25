module Prawn4book


  def self.first_turn?
    @@turn == 1
  end
  def self.second_turn?
    @@turn == 2
  end
  def self.third_turn?
    @@turn == 3
  end
  def self.turn=(value)
    @@turn = value
  end

  def self.requires_third_turn
    @@third_turn = true
  end
  def self.require_third_turn?
    @@third_turn ||= false
    @@third_turn === true
  end


end #/module Prawn4book
