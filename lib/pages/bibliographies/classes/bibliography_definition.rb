module Prawn4book
class Bibliography
###################       CLASSE      ###################
  
class << self

  # Méthode principale d'assistance à la création d'une nouvelle
  # bibliographie.
  # 
  # @return [Prawn4book::Bibliography|Nil] La nouvelle bibliographie ou
  # nil en cas de renoncement. 
  # 
  # @api public
  def assiste_creation(book)
    # 
    # L'assistant va nous permettre de créer la nouvelle 
    # bibliographie
    # 
    require 'lib/commandes/assistant/assistants/bibliographies'
    dbiblio = {}
    assistant = Prawn4book::Assistant::AssistantBiblio.new(book)
    # 
    # On demande les données (note : on peut aussi, par la même 
    # occasion, définir le format des données)
    # 
    ok = assistant.edit_biblio(dbiblio)
    return nil unless ok
    #
    # On ajoute ces données bibliographiques aux données actuelles
    # 
    main_data = assistant.main_data_biblio
    main_data.merge!(biblios: {}) unless main_data.key?(:biblios)
    main_data[:biblios].merge!(dbiblio[:tag] => dbiblio)
    # 
    # On retourne l'instance Prawn4Book::Bibliography de la nouvelle
    # bibliography créée.
    # 
    return new(book, dbiblio[:tag])
  end

end #/<< self Bibliography


###################       INSTANCE      ###################

  ##
  # Méthode principale d'assistance pour la définition du format
  # des données de la bibliographie.
  # 
  def assiste_data_format
    puts "Je dois apprendre à assister pour la création du fichier DATA_FORMAT".jaune
  end


  # @return [Boolean] true if data format file exists, false
  # otherwise
  def has_data_format?
    File.exist?(data_format_file)
  end

  # @prop [String] Path to data format file (whose defines bib-item
  # data)
  def data_format_file
    @data_format_file ||= File.join(folder,'DATA_FORMAT')
  end

###################       /INSTANCE      ###################

end #/ class Bibliography
end #/module Prawn4book
