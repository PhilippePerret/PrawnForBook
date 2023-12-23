module Prawn4book
class << self
def proceed_calc
  puts "Je dois apprendre à calculer la marge intérieure".jaune
  nombre_pages = ask_for_page_count || return
end
end #/<< self
end #/module Prawn4book
