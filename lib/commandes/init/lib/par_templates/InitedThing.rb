require_relative '../required/utils'
require 'delegate'

module Prawn4book
class InitedThing
class BuilderFile < SimpleDelegator

  attr_reader :build_fname

  # def initialize(initedthing, filename)
  #   @build_fname = filename
  # end

  def build(filename)
    @build_fname = filename

    puts "@build_fname = #{build_fname.inspect}".jaune

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
    # Confirmer la création ou produire l'erreur
    # 
    return confirm_create_build_file
  end

  def create_build_file
    FileUtils.cp(template_for(build_fname), build_fpath)    
  end

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
