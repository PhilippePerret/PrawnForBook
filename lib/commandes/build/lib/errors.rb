=begin
  Gestion des erreurs au cours de la fabrication
  Pour les consigner et les redonner à la fin.

=end

# Pour exposer une méthode qui permettra d'enregistrer une erreur
# mineur au cours de la construction.
def building_error(err_message, options = nil)
  Prawn4book::PrawnView::Error.add_building_error(err_message, options)
end

module Prawn4book
class PrawnView
class Error
class << self

  def add_building_error(err_message, params)
    @errors << {message: err_message, params: params}
  end

  def report_building_errors
    return if @errors.empty?
    puts "Nombre d'erreurs mineures survenues : #{@errors.count}".rouge
    @errors.each_with_index do |derror, idx|
      puts "ERROR #{idx + 1}: #{derror[:message]}".rouge
    end
  end

  def reset
    @errors = []
  end

end #/<< self
end #/class Error
end #/class PrawnView
end #/module Prawn4book
