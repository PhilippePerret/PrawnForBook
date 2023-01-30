=begin
  Class Prawn4book::Bibliography::BibItem
  ---------------------------------------
  Gestion des items bibliographiques au niveau de leur définition.
  C'est dans ce module qu'on peut :
  - définir un nouvelle item de bibliographaphie
  - définir le format d'un item de bibliographie (fichier DATA_FORMAT)
    dans la bibliographie
=end
require 'lib/modules/tty_facilitators'

class BibItemError < StandardError ; end

module Prawn4book
class Bibliography
class BibItem
  extend TTYFacilitators

class << self
###################       CLASSE      ###################

  ##
  # Méthode main appelée quand l'utilisateur veut créer un nouvel
  # item de bibliographie.
  # 
  # @param [Prawn4book::PdfBook] book Le livre de la bibliographie
  # @param [Prawn4book::Bibliography] L'instance bibliographie pour laquelle il faut créer le bibitem
  def assiste_creation(book, biblio)
    # 
    # Si le format des données n'est pas défini, il faut inviter
    # l'utilisateur à le créer (dépend de la bibliographie — cf. le
    # fichier bibliographiy_definition.rb)
    # 
    biblio.has_data_format? || assiste_creation_data_format(book, biblio) || return
    # 
    # 
    # 
    puts "Je dois apprendre à créer un item de bibliographie".jaune
    choices_ini = biblio.data_format.map do |dprop|
      {name: dprop[:name], value: dprop}
    end

    dbibitem = {}
    tty_define_object_with_data(biblio.data_format, dbibitem)

    puts "dbibitem= #{dbibitem.pretty_inspect}"
  end

  # @return nil si l'item représenté par les données +ditem+ est bien
  # unique. Sinon, return [String] le message d'erreur.
  # 
  def already_exist?(ditem)
    # 
    # Il ne doit pas exister au niveau du diminutif (@id)
    # 
    # TODO
    # 
    # Il ne doit pas exister au niveau du titre (@title)
    # 
    # TODO
    return nil
  rescue BibItemError => e
    return e.message
  end


  ##
  # Assistant à la création du fichier DATA_FORMAT qui définit le
  # format des données (des items) de la bibliographie définie par
  # les données +dbiblio+
  # 
  # @param [Prawn4book::PdfBook] book le livre de la bibliographie
  # @param [Prawn4book::Bibliography] biblio Bibliographie en question
  # 
  def assiste_creation_data_format(book, biblio)
    data_format_file = biblio.data_format_file
    data_format = File.exist?(data_format_file) ? YAML.load_file(data_format_file) : [
      {name: TERMS[:Title], value: :title , required:true, type: :string, uniq:true},
      {name: TERMS[:Id],    value: :id    , required:true, type: :string, uniq:true}
    ]
    edit_data_format(biblio, data_format)    
  end

  ##
  # Méthode permettant d'éditer le format des données de la bibliographie
  # +biblio+
  # 
  # @param [Prawn4book::Bibliography|Hash] Soit l'instance bibliographie dont il faut éditer les données, soit ses données
  # @param [Hash] data_format Les données du format à éditer
  # 
  # 
  def edit_data_format(biblio, data_format)
    while true # tant qu'on veut modifier/ajouter des données
      clear
      puts (PROMPTS[:biblio][:format_for_fiches_of] % biblio.tag).bleu
      puts (PROMPTS[:biblio][:help_data_format] % biblio.tag).gris
      max_len = 0
      choices = 
      [
        # Le choix pour finir (enregistrer)
        {name:PROMPTS[:Finir].bleu, value: :end},
      ] + data_format.each do |dprop|
        len = dprop[:name].length + 5
        max_len = len if len > max_len
      end.map do |dprop|
        # 
        # Mis en format de chaque propriété
        # 
        n = []
        n << "#{TERMS[:key]}: #{dprop[:value].inspect}"
        n << "#{TERMS[:format]}: #{TERMS[dprop[:type]]}"
        n << "#{TERMS[:requise]}" if dprop[:required]
        n << "#{TERMS[:uniq]}"  if dprop[:uniq]
        n << "#{TERMS[:default_value]}: #{dprop[:default].inspect}" if dprop.key?(:default)
        n << "#{TERMS[:valid_if]}: #{dprop[:valid_if]}" if dprop[:valid_if]
        n << "#{TERMS[:invalid_if]}: #{dprop[:invalid_if]}" if dprop[:invalid_if]
        n << "#{TERMS[:given_values]}" if dprop[:values]
        nom = dprop[:name].ljust(max_len)
        {name: "#{nom} #{n.join(' - ')}" , value: dprop}
      end + [
        # Le menu pour ajouter une propriété
        {name:PROMPTS[:biblio][:new_property].bleu, value: :new_prop},
      ]
      choix = Q.select(nil, choices, **{per_page: choices.count, show_help:false})
      case choix
      when :end
        File.write(biblio.data_format_file, data_format.to_yaml)
        puts (MESSAGES[:biblio][:data_format_saved] % biblio.tag).vert
        break
      when :new_prop
        dprop = {}
        if edit_format_prop(dprop)
          data_format << dprop # on l'ajoute
        end
      else
        dprop = edit_format_prop(choix)
      end
    end
  end

  ##
  # Édition de la propriété +dprop+
  # 
  def edit_format_prop(dprop)
    tty_define_object_with_data(DATA_BIBITEM_PROP, dprop)
  end

  ##
  # Méthode permettant de définir la valeur par défaut d'une propriété
  # de bibitem.
  # @note
  #   Cette valeur peut être de trois formes :
  #   - explicite (elle est donnée telle quelle) => String
  #   - Procédure (on peut décider le nombre d'arguments) => Code
  #   - Méthode (idem) => Symbol
  #
  def bibitem_prop_defaut_value(d)
    choices = [
      {name:TERMS[:A_explicit_value]  , value: :exp},
      {name:TERMS[:A_procedure]       , value: :proc},
      {name:TERMS[:A_class_method]    , value: :class_meth},
      {name:TERMS[:A_instance_method] , value: :inst_meth},
    ]
    defval_type   = Q.select("#{PROMPTS[:Type_of_data]}:".jaune, choices, **{per_page:choices.count, show_help:false})
    defval_value  = Q.ask("#{PROMPTS[:Value]}:".jaune)

    #
    # Valeur retournée
    # 
    case defval_type
    when :exp         then return defval_value
    when :proc        then return eval(defval_value)
    when :class_meth  then return defval_value.to_sym
    when :inst_meth   then return defval_value.to_sym
    end
  end

#
# Les types possibles pour une propriété de DATA_FORMAT
# 
TYPES_PROPS = [
  {name:'String'            , value: :string},
  {name:'People(s)'         , value: :people},
  {name:TERMS[:Int]         , value: :int},
  {name:TERMS[:Date_ex]     , value: :date},
  {name:TERMS[:Year]        , value: :year},
  {name:'Format'            , value: :format}, # doit respecter un format donné
  {name:TERMS[:Custom]      , value: :custom},
]

#
# Attributs d'une propriété de bib-item (définie dans le DATA_FORMAT
# de la bibliographie).
# 
DATA_BIBITEM_PROP = [

  {name:TERMS[:Name]            ,value: :name         ,type: :string, required:true},
  {name:TERMS[:Type]            ,value: :type         ,type: :sym, values:TYPES_PROPS, required:true},
  {name:TERMS[:Property_key]    ,value: :value        ,type: :sym, required:true},
  {name:TERMS[:Default_value]   ,value: :default      ,type: :custom , meth: :bibitem_prop_defaut_value},
  {name:TERMS[:Valid_method]    ,value: :valid_if     ,type: :sym},
  {name:TERMS[:Invalid_method]  ,value: :invalid_if   ,type: :sym},

]


end #/<< self BibItem
###################       /CLASSE      ###################
end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
