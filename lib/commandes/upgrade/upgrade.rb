module Prawn4book
    
  # @runner
  class Command
    def proceed; Prawn4book.upgrade_current end
  end #/Command


class << self

  def upgrade_current
    puts "Je dois apprendre à upgrader le livre ou la collection courante.".jaune
  end

end #/<< self module Prawn4book
end #/module Prawn4book
