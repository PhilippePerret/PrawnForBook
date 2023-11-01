=begin
  Gestion des erreurs au cours de la fabrication
  Pour les consigner et les redonner à la fin.

=end

# Pour exposer une méthode qui permettra d'enregistrer une erreur
# mineur au cours de la construction.
def building_error(err_message, **options)
  Prawn4book::PrawnView::Error.add_building_error(err_message, **options)
end

def add_erreur(err_message, **options)
  Prawn4book::PrawnView::Error.add_building_error(err_message, **options)
end

def add_notice(mg_message, **options)
  Prawn4book::PrawnView::Error.add_building_notice(mg_message, **options)
end
alias :add_message :add_notice
  

module Prawn4book
class PrawnView
class Error
class << self

  def add_building_error(err_message, **params)
    @errors << {message: err_message, params: params}
  end

  def add_building_notice(msg, **params)
    @notices << {message:msg, params: params}
  end

  def report_building_errors
    puts "\n\n"
    unless @errors.empty?
      num_len = @errors.count.to_s.length
      titre = "ERREURS MINEURES (#{@errors.count})"
      puts "#{titre}\n#{'-'*titre.length}".orange
      @errors.each_with_index do |derror, idx|
        puts "[#{(idx + 1).to_s.rjust(num_len,'0')}] #{derror[:message]}".orange
      end
    end
    unless @notices.empty?
      titre = "Notifications (#{@notices.count})"
      puts "\n#{titre}\n#{'-'*titre.length}".bleu
      @notices.each_with_index do |dnotice, idx|
        puts "[#{idx + 1}] NOTICE : #{dnotice[:message]}".bleu
      end
    end
  end


  def reset
    @errors   = []
    @notices  = []
  end

end #/<< self
end #/class Error
end #/class PrawnView
end #/module Prawn4book
