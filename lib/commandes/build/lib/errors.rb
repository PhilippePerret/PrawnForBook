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

# Pour exposer une méthode qui permettra d'enregistrer une erreur
# fatale au cours de la construction. Une erreur fatale de ce type
# n’interrompt pas le programme mais doit absolument être corrigée
# lorsqu’on veut produire la version finale du livre.
# 
# @param err_message [String]
#   Le texte du message
# 
# @param owner [AnyClass]
#   Le propriétaire de l’erreur, souvent celui qui l’a provoquée.
#   Rappel : on peut aussi utiliser PFBError.context = .... pour 
#   préciser dans quel contexte se produit l’erreur
# 
# @param keep_it [Bool]
#   Pour conserver l’erreur même au cours d’un tour suivant. Il faut
#   utiliser cette propriété lorsque l’erreur n’est déclenché qu’une
#   seule fois et au premier tour (rappel : les autres erreurs sont 
#   effacées à chaque nouveau tour).
# 
def add_fatal_error(err_message, owner = nil, keep_it = false)
  Prawn4book::PrawnView::Error.add_building_fatal_error(err_message, **{owner:owner, keep: keep_it})
end
alias :add_erreur_fatale :add_fatal_error

def add_notice(mg_message, owner = nil)
  Prawn4book::PrawnView::Error.add_building_notice(mg_message, **{owner:owner})
end
alias :add_message :add_notice
  

module Prawn4book
class PrawnView
class Error
class << self

  attr_reader :fatal_errors

  def add_building_error(err_message, **params)
    @errors << {message: err_message, params: params}
  end

  def add_building_fatal_error(err_message, **params)
    err_data = {message: err_message, params: params}
    if Prawn4book.bat?
      # En mode "bon à tirer" aucune erreur fatale ne doit survenir
      err_msg = compose_message_from_data(err_data)
      raise PFBFatalError.new(150, {err: err_msg})
    else
      @fatal_errors << err_data
    end
  end

  def add_building_notice(msg, **params)
    @notices << {message:msg, params: params}
  end

  def report_building_errors
    line_fin = "-"*40
    puts "\n\n"
    unless @errors.empty?
      num_len = @errors.count.to_s.length
      titre = "ERREURS MINEURES (#{@errors.count})"
      puts "#{titre}\n#{'-'*titre.length}".orange
      @errors.each_with_index do |derror, idx|
        msg = compose_message_from_data(derror)
        puts "[#{(idx + 1).to_s.rjust(num_len,'0')}] #{msg}".orange
      end
      line_fin = line_fin.orange
    end
    unless @notices.empty?
      titre = "\nNotifications (#{@notices.count})"
      puts "\n#{titre}\n#{'-'*titre.length}".bleu
      @notices.each_with_index do |dnotice, idx|
        msg = compose_message_from_data(dnotice)
        puts "[#{idx + 1}] NOTICE : #{msg}".bleu
      end
    end
    unless @fatal_errors.empty?
      num_len = @fatal_errors.count.to_s.length
      titre = "\nERREURS FATALES (#{@fatal_errors.count})"
      puts "#{titre}\n#{'-'*titre.length}".rouge
      @fatal_errors.each_with_index do |derror, idx|
        msg = compose_message_from_data(derror)
        puts "[#{(idx + 1).to_s.rjust(num_len,'0')}] #{msg}".rouge
      end
      line_fin = line_fin.rouge
    end
    line_fin = line_fin.bleu if no_error?
    puts line_fin
  end

  def no_error?
    @fatal_errors.empty? && @errors.empty?
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
    @errors       = []
    @fatal_errors ||= []
    @fatal_errors = @fatal_errors.select { |e| e[:params][:keep] }
    @notices      = []
  end

end #/<< self
end #/class Error
end #/class PrawnView
end #/module Prawn4book
