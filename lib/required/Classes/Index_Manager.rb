module Prawn4book
class PdfBook
class IndexManager

  # [Prawn4book::PdfBook] Le livre en construction
  attr_reader :__book

  # [Hash] Table de tous les index personnalisés
  attr_reader :items

  def initialize(book)
    @__book = book
    @items  = {}
  end

  # S’il y a un second tour, on remet tout à zéro pour ne pas
  # doubler les références
  def drain_second_tour
    @items = {}
  end

  # @return l’index personnalisé [Prawn4book::PdfBook::Index] d’id
  # +index_id+ ou le crée s’il n’existe pas.
  def get(index_id)
    items[index_id] ||= PdfBook::Index.create(__book, index_id)
  end

end #/class IndexManager

###############################################################
###############################################################
###############################################################

###############################################################
###                                                         ###
###       Class Prawn4book::PdfBook::Index                  ###
###                                                         ###
###############################################################
class Index
  class << self

    # Création d’un index personnalisé
    # 
    # @note
    #   - Elle se fait la toute première fois où l’on rencontre
    #     dans le texte un index personnalisé, sous la forme :
    #     "indexid(mot)"
    #   - Un index doit absolument être valide, où la création lève
    #     une erreur fatale.
    #     TODO: Peut-être faudrait-il imaginer, pour ce genre de cas,
    #     un traitement plus "doux" des erreurs qui la signale 
    #     simplement en poursuivant la construction. Car après tout,
    #     un item d’index peut simplement être remplacé par son mot :
    #       "une phrase avec perso(Selma) et perso(Gene)"
    #     =>
    #       "une phrase avec Selma et Gene"
    #
    # @param book [Prawn4book::PdfBook]
    #   Le livre en construction
    # 
    # @param index_id [String|Symbol]
    #   Identifiant du nouvel index
    # 
    # 
    # @return l’index [Prawn4book::PdfBook::Index] créé
    # 
    def create(book, index_id)
      index_id = index_id.to_sym
      newi = new(book, index_id)
      newi.is_valid_or_raise
      return newi
    end

  end #/<< self Prawn4book::PdfBook::Index

  #
  # --- INSTANCE Prawn4book::PdfBook::Index ---
  # 

  # [Symbol] Identifiant de l’index personnalisé
  # C’est donc le "mot" qui est utilisé avant les parenthèses, par
  # exemple dans "Ceci est un perso(personnage) indexé."
  attr_reader :__id

  # Le livre en construction
  attr_reader :__book

  # Liste des items de cet index personnalisé. Par exemple la
  # liste des personnes pour un index ’people’
  attr_reader :items

  def initialize(book, index_id)
    @__book = book
    @__id   = index_id
    @items  = {}
  end

  # Méthode permettant d’ajouter un item d’index ou/et une occurrence
  # pour cet item.
  # 
  # @param item_id [String]
  #   L’identifiant de l’item (le premier ou le second mot dans la
  #   parenthèse)
  # 
  # @param output [String]
  #   Le texte à écrire (mais peut être modifié par la méthode
  #   personnalisée de traitement #index_<index id>)
  # 
  # @param context [Hash]
  #   paragraph: Le paragraphe contenant l’item indexé
  #   Peut définir :importance qui peut avoir la valeur :main ou
  #   :minor (cette importance est fixée par l’ajoute de "!" pour
  #   :main ou "." pour :minor au tout début, avant l’identifiant
  #   lui-même, donc)
  # 
  # @return [String] Le texte à écrire
  # 
  def add(item_id, output, **context)
    data_item = {
      id:           item_id,
      paragraph:    context[:paragraph],
      output:       output,
      real_output:  output,
      weight:       context.delete(:occurrence_weight)
    }

    # On traite cet item avec la méthode personnalisée qui doit
    # obligatoirement exister(*)
    # Elle peut, en fonction de son retour :
    # - modifier le texte à écrire
    # - modifier l’identifiant de l’item
    # - ajouter des données pour l’item
    # 
    case real_output = call_index_methode(item_id, output, context)
    when String
      data_item.merge!(real_output: real_output)
    when Array
      item_id, real_output = real_output
      data_item.merge!(real_output: real_output, id: item_id)
    when Hash
      if real_output.key?(:output) and not(real_output.key?(:real_output))
        real_output.merge!(real_output: real_output.delete(:output))
      end
      data_item.merge!(real_output)
    when NilClass # pour dire de ne rien écrire
      data_item.merge!(real_output: '')
    else
      # Erreur
    end

    # Identifiant qui a pu être rectifié
    item_id = data_item[:id]

    # Instancier l’item s’il n’existe pas
    items.merge!(item_id => []) unless items.key?(item_id)

    # On ajoute cette occurrence
    items[item_id] << data_item
    # On retourne ce qu’il faut écrire
    return data_item[:real_output]
  end

  # (*) Maintenant :
  #   - soit dans le module CustomIndexModule avec un préfixe
  #     'index_' (methode -> index_methode) avec trois arguments 
  #   - soit dans le module PrawnHelpersMethods, sans préfixe et
  #     avec des arguments dynamiques (si 2, le contexte)
  def call_index_methode(item_id, output, context)
    case @nbp 
    when 3 then send(treat_item_method_name, item_id, output, **context)
    when 2 then send(treat_item_method_name, item_id, **context)
    when 1 then send(treat_item_method_name, item_id)
    end
  end

  # Méthode appelée quand on demande à inscrire l’index personnalisé
  # dans le livre.
  # 
  # @note
  #   Cette méthode n’est pas une obligation, entendu que les index
  #   personnalisés peuvent servir aussi à simplement collecter des
  #   informations sans pour autant les résumer à la fin du livre.
  # 
  def print(pdf)
    self.respond_to?(printing_method_name) || \
      raise(PFBFatalError.new(2503, {id: __id}))
    nbp = self.method(printing_method_name).parameters.count
    nbp == 1 || raise(PFBFatalError.new(2504, {id: __id}))
    send(printing_method_name, pdf)
    pdf.update_current_line
  end

  def method_with_prefix?
    treat_item_method_name.to_s.start_with?('index_')
  end

  # Méthode appelée à la création de l’index personnalisé pour 
  # vérifier qu’il est bien défini. Si le niveau d’alerte est élevé,
  # on raise une erreur fatale. Sinon, on signale simplement le 
  # problème.
  def is_valid_or_raise
    # puts "Methodes : #{self.methods}"
    self.respond_to?(treat_item_method_name) || raise(PrawnBuildingError.new(2501))
    @nbp = self.method(treat_item_method_name).parameters.count
    puts "Nombre de paramètres : #{@nbp.inspect}"
    if method_with_prefix?
      # La méthode doit recevoir trois arguments
      @nbp == 3 || raise(PrawnBuildingError.new(2502))
    end
  rescue PrawnBuildingError => e
    err_sub_data = {
      id: __id, 
      nb_params: @nbp,
    }
    err_sub = PFBError[e.message.to_i] % err_sub_data
    err_data = {
      id: __id,
      err: err_sub,
    }
    err_num = 2500
    if __book.recipe.level_error < FATAL_LEVEL_ERROR
      err_msg = PFBError[err_num] % err_data
      add_erreur(err_msg)
    else
      raise PFBFatalError.new(err_num, err_data)
    end
  end

  def treat_item_method_name
    @treat_item_method_name ||= begin
      maybe_method = "#{__id}".to_sym 
      unless self.respond_to?(maybe_method)
        maybe_method = "index_#{__id}".to_sym
      end
      maybe_method
    end
  end

  def printing_method_name
    @printing_method_name ||= "print_index_#{__id}".to_sym
  end
end #/class Index
end #/class PdfBook
end #/module Prawn4book
