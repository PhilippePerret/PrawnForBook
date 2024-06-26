require_relative 'utils'
require 'delegate'

module Prawn4book
class InitedThing
class BuilderFile < SimpleDelegator

  attr_reader :build_fname

  # = main = 
  # 
  # Construction du fichier
  # 
  def build(filename)
    @build_fname = filename

    #
    # Que faut-il faire si c'est un livre dans une collection et
    # que la collection possède ce fichier ?
    # 
    case use_file_collection_if_exist?
    when :useit   then return true
    when :cancel  then return false
    end

    #
    # Que faut-il faire si ce fichier existe déjà ?
    # 
    case keep_file_if_exist?
    when :keep    then return true
    when :cancel  then return false
    else
      # on continue
    end

    #
    # Création du fichier
    # 
    create_build_file

    #
    # Régler les variables éventuelles
    # 
    define_file_variables if File.exist?(build_fpath)

    # 
    # Confirmer la création ou produire l'erreur
    # 
    return confirm_create_build_file
  end

  def create_build_file
    FileUtils.mkdir_p(File.dirname(build_fpath))
    FileUtils.cp(template_for(build_fname), build_fpath)
  end

  # Les variables se trouvent dans des %{...}
  def define_file_variables
    sleep 0.3
    code = File.read(build_fpath)
    return if not(code.match?(REG_VARIABLE))
    code = code.gsub(REG_VARIABLE) do
      key = $1.to_sym.freeze
      BOOK_DATA.key?(key) || raise("Erreur systémique : la clé #{key} est inconnue des BOOK_DATA…")
      data_key = BOOK_DATA[key]
      data_key[:value] ||= begin
        value = Q.ask("Valeur pour : #{data_key[:hname]} ?".jaune)
        value = nil if value.to_s.strip.empty?
        value ||= data_key[:default]
      end
      data_key[:value] # inscription dans le code
    end
    File.write(build_fpath, code)
  end
  REG_VARIABLE = /\%\{(.+?)\}/.freeze


  def confirm_create_build_file
    if File.exist?(build_fpath)
      puts "Fichier #{build_fname} créé avec succès.".vert
      return true
    else
      puts "Fichier #{build_fname} introuvable, bizarrement…".rouge
      return false
    end    
  end

  def use_file_collection_if_exist?
    return false unless book? && in_collection?
    return false unless File.exist?(collection_file(build_fname))
    puts "
    Un fichier #{build_fname} existe pour la collection.
    ".jaune
    choices = [
      {name:'Utiliser celui-là', value: :useit},
      {name:'En créer un autre pour le livre', value: :newone},
      {name:'Renoncer', value: :cancel}
    ]
    return Q.select("Que dois-je faire ?".jaune, choices, per_page:choices.count)
  end

  def keep_file_if_exist?
    return nil unless File.exist?(build_fpath)
    File.ask_what_to_do_with_file(build_fpath, build_fname)
  end

  def build_fpath
    @build_fpath ||= File.join(folder, build_fname)
  end

end #/class BuilderFile
end #/class InitedThing
end #/module Prawn4book
