=begin
  Gestion des erreurs au cours de la fabrication
  Pour les consigner et les redonner à la fin.

=end

# Pour exposer une méthode qui permettra d'enregistrer une erreur
# mineur au cours de la construction.
def building_error(err_message, **options)
  Prawn4book::PrawnView::Error.add_building_error(err_message, **options)
end

def add_erreur(err_message, owner = nil)
  Prawn4book::PrawnView::Error.add_building_error(err_message, **{owner:owner})
end

def add_notice(mg_message, owner = nil)
  Prawn4book::PrawnView::Error.add_building_notice(mg_message, **{owner:owner})
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
        msg = compose_message_from_data(derror)
        puts "[#{(idx + 1).to_s.rjust(num_len,'0')}] #{msg}".orange
      end
    end
    unless @notices.empty?
      titre = "Notifications (#{@notices.count})"
      puts "\n#{titre}\n#{'-'*titre.length}".bleu
      @notices.each_with_index do |dnotice, idx|
        msg = compose_message_from_data(dnotice)
        puts "[#{idx + 1}] NOTICE : #{msg}".bleu
      end
    end
  end

  def compose_message_from_data(dmsg)
    msg = dmsg[:message]
    pms = dmsg[:params]
    if pms[:owner]
      # Un propriétaire du message est défini. Cela se produit lors-
      # que le message a été écrit par l’utilisateur dans le texte du
      # livre.
      owner = pms[:owner]
      ip = []
      ip << "page ##{owner.page_number}" if owner.page_number
      ip << "index ligne ##{owner.pindex}" if owner.pindex
      ip << "source #{owner.source.inspect}"
      ip << "numéro paragraphe ##{owner.numero}" if owner.numero
      msg = "#{msg}\n    [informations sur le message : #{ip.join(' | ')}]"
    end

    return msg
  end


  def reset
    @errors   = []
    @notices  = []
  end

end #/<< self
end #/class Error
end #/class PrawnView
end #/module Prawn4book
