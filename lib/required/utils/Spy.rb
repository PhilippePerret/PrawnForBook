# encoding: UTF-8
=begin

  Module Spy
  ----------
  Pour débuggage dans une autre fenêtre de Terminal
  version 0.2.1

  @usages

    spy(message)    Ecrire un message
    spy(message, true)  Forcer l'écriture même si le spy est inactif.

    spy(:on)        Activiter à l'endroit voulu
    spy(:off)       Désactiver à l'endroit voulu
  

=end
require 'clir'

def spy(msg, forcer = false)
  if msg == :on
    DebugInOtherTerm.is_stopped= false
    spy_in_term("--- SPY ON ---")
  elsif msg == :off
    spy_in_term("--- SPY OFF ---")
    DebugInOtherTerm.is_stopped= true
  else
    return if spy_stopped? && not(forcer)
    return unless debug? || spy? || forcer
    spy_in_term(msg)
  end
end
def spy_in_term(msg)
  @dterm ||= DebugInOtherTerm.new
  @dterm << msg
rescue Exception => e
  err_msg = e.message
  err_msg = "#{err_msg[0..390]} (…)" if err_msg.length > 400
  puts "Problème avec l'espion : #{err_msg}"
end

def spy?
  :TRUE == @spysrunning ||= true_or_false(CLI.options[:spy])
end

def spy_stopped?
  DebugInOtherTerm.is_stopped === true
end

#
# Class DebugTerm
# ---------------
# Permet de gérer le débug dans une autre fenêtre Terminal
# 
class DebugInOtherTerm
  # def self.current; @@current ||= new.init end

  def initialize
    init
  end

  # @prop Le terminal dans lequel envoyer le debug
  attr_reader :term # p.e. '/dev/ttys004'

  #
  # Les trois variables suivantes servent juste à savoir si c'est
  # bien le terminal en question
  # 
  attr_reader :day, :month, :logging

  ##
  # Pour écrire dans la fenêtre de débuggage
  #
  def write(msg)
    begin
      # cmd = "printf '#{msg.gsub(/'/,'’').gsub(/\{/,'\\{')}\n' > #{term}"
      cmd = "printf -- \"#{msg.gsub(/"/,'“').gsub(/\{/,'\\{')}\n\" > #{term}"
      # puts "Commande spy = #{cmd}".rouge
      `#{cmd}`
    rescue Exception => e
      `printf "Problème avec #{msg}" > #{term} (erreur : #{e.message}`
      exit
    end
  end
  alias :<< :write


  def self.is_stopped=(value)
    @@is_stopped = value
  end
  def self.is_stopped
    return @@is_stopped ||= false
  end

  def init
    get_data_if_file_exists || begin
      dterm = choose_the_term
      @term     = dterm[:term]
      @logging  = dterm[:logging]
      memorize_debug_term
    end
    return self # chainage
  end


  def get_data_if_file_exists
    if exist?
      # puts "Le fichier .debugterm existe".orange if debug?
      return good_term?(File.read(path).split("\t"))
    else
      return false
    end
  end

  # @return TRUE si la fenêtre terminal est la bonne
  def good_term?(dterm_recorded)
    # puts "dterm_recorded = #{dterm_recorded.inspect}"
    t, d, m, l = dterm_recorded
    now = Time.now
    dterm = get_term(t)
    # puts "dterm = #{dterm.inspect}"
    if dterm.any? && now.day == d.to_i && now.month == m.to_i && dterm[:logging] == l
      # puts "La fenêtre terminale est valide.".orange if debug?
      @term     = t
      @logging  = l
      return true
    else
      puts "Le terminal enregistré ne correspond pas.".orange
      return false
    end
  end

  # @return les données du terminal +tm+
  def get_term(tm)
    all_terms.each do |dterm|
      return dterm[:value] if dterm[:name] == tm
    end
    {}
  end

  # @prop {Array} Liste des terminaux
  def all_terms
    @all_terms ||= get_all_terms
  end

  # @prop {String} Terminal dans lequel tourne l'application 
  # courante (pe '/dev/ttys001')
  def app_term
    @app_term ||= `tty`.strip
  end

  # @return TRUE si le fichier contenant les infos sur le terminal
  # de debug existe.
  def exist?
    File.exist?(path)
  end

  def path
    @path ||= File.join(APP_FOLDER,'./.debugterm')
  end

  private

    def memorize_debug_term
      now = Time.now
      line = "#{term}\t#{now.day}\t#{now.month}\t#{logging}"
      File.write(path, line)      
    end

    def choose_the_term
      open_new_term_window if all_terms.count == 0
      puts ""
      my = self
      dterm = Q.select("Quelle fenêtre Terminal choisir pour le débug ?\n(tape `tty` dans la fenêtre voulue pour le savoir)\n".bleu, echo: false) do |q|
        q.choices my.all_terms
        q.choice "Ouvrir une autre fenêtre", false
        q.choice "Renoncer", nil
        q.per_page my.all_terms.count + 2
      end
      return dterm if dterm
      #
      # Choix d'ouvrir une nouvelle fenêtre
      # 
      if dterm === false
        open_new_term_window
        choose_the_term
      else
        exit 0
      end
    end

    # Pour ouvrir une nouvelle fenêtre de Terminal qui servira de
    # fenêtre de débug.
    def open_new_term_window
      `osascript -e 'tell application "Terminal" to do script "tty"'`
      sleep 1
    end

    def get_all_terms
      terms_lines = `w | egrep 's[0-9]{3,4}'`.strip
      terms_lines = terms_lines.encode('UTF-8', invalid: :replace)
      terms_lines = terms_lines.split("\n")
      return terms_lines.map do |tline|
        # 
        # On récupère le nom du terminal et son logging pour toutes
        # les fenêtres ouvertes.
        # 
        splited = tline.gsub(/\s\s+/, ' ').split(' ')
        tm = "/dev/tty#{splited[1]}"
        lo = splited[3]
        {name: tm, value: {term: tm, logging: lo}}
      end.select do |dterm|
        # 
        # Il faut retirer le term courant
        # 
        dterm[:name] != app_term
      end
    end

end #/class DebugTerm

