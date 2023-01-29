=begin

  Assistant pour définir les bibliographies

  La refactorisation de cet assistant utilise deux choses :
  - l'assistant (ici) pour définir les généralités et la liste
    des bibliographies du livre/collection
  - les pages spéciales pour définir une bibliographie en particulier
=end
require 'lib/modules/tty_facilitators'

module Prawn4book
class Assistant

  # --- Assistant pour les bibliographies ---

  def self.assistant_bibliographies(owner)
    AssistantBiblio.new(owner).define_bibliographies
  end

class AssistantBiblio
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  ##
  # Méthode principale pour définir les données bibliographiques
  # (en fait, les bibliographies)
  # 
  def define_bibliographies
    # 
    # Un message de présentation pour rappeler ce qu'est une 
    # bibliographie dans Prawn-for-book
    # 
    puts MESSAGES[:biblio][:intro_assistant].bleu

    if tty_define_object_with_data(MAIN_DATA_BIBLIOGRAPHIES, main_data_biblio)
      owner.recipe.insert_bloc_data('bibliographies', main_data_biblio)
    end
  end

  ##
  # 
  # Méthode appelée par le menu "Les types de bibliographies" pour
  # définir les bibliographies
  # 
  # La méthode affiche une liste avec les bibliographies déjà définies
  # et permet de les modifier ou d'en définir une nouvelle.
  # 
  def define_types_bibliographies(data_bib, arg2)
    dbiblios = data_bib[:biblios] || {}
    precfile = mkdir(File.join(__dir__,'tmp'))
    precfile = File.join(precfile,'biblios')
    choix = precedencize(choices_biblios, precfile) do |q|
      q.question "Bibliographie à créer/modifier"
      q.precedences_per_index
      q.add_choice_cancel
    end
    case choix
    when NilClass
      return
    when :save
      data_bib.merge!(biblios: dbiblios)
    when :new
      if (dbiblio = edit_biblio(nil))
        dbiblio.delete(:is_new)
        dbiblios.merge!(dbiblio[:tag] => dbiblio)
      end
    else
      dbiblio = dbiblios[choix]
      if edit_biblio(dbiblio)
        dbiblios.merge!(dbiblio[:id] => dbiblio)
      end
    end
  end

  ##
  # Méthode principale pour éditer une bibliographie, ou la
  # créer si c'est nécessaire.
  # 
  # @return [Boolean] true si tout s'est bien passé
  # 
  def edit_biblio(data_biblio)
    # 
    # Pour savoir s'il s'agit d'une nouvelle disposition
    # 
    is_new_biblio = data_biblio.nil?
    data_biblio = {} if is_new_biblio
    data_biblio.merge!(is_new: is_new_biblio)
    # 
    # On utilise le facilitateur
    # 
    options = {title: PROMPTS[:data_de_la] % TERMS[:bibliography]}
    ok = tty_define_object_with_data(DATA_BIBLIO, data_biblio, **options) # => true/false
  
    # 
    # Chaque fois qu'on édite une bibliographie, on regarde si le
    # format des données a été défini et, le cas échéant, on propose
    # de le définir. Ce format des données, qui définit les propriétés,
    # permet de créer des items de façon assistée
    # C'est un fichier qui doit se trouver dans le dossier des fichers,
    # avec pour nom 'DATA_FORMAT'
    # 
    data_format_file = File.join(data_biblio[:path], 'DATA_FORMAT')
    unless File.exist?(data_format_file)
      build_data_format_file(data_biblio)
    end
    # 
    # Pour savoir s'il faut prendre en compte les données
    # 
    return ok && data_biblio
  end

  ##
  # Méthode appelée quand le fichier qui définit le format des 
  # données (DATA_FORMAT) n'existe pas, pour demander s'il faut le
  # faire et assister à sa création.
  # 
  def build_data_format_file(dbiblio)
    return unless Q.yes?((PROMPTS[:biblio][:ask_create_data_format_file]).jaune)
    data_format_file = File.expand_path(File.join(dbiblio[:path], 'DATA_FORMAT'))
    dformat = File.exist?(data_format_file) ? YAML.load_file(data_format_file) : [
        {name: "Titre (toujours requis)", value: :title, type: :string, required:true},
        {name: "Identifiant (toujours requis)", value: :id, type: :dim, required: true}
      ]
    while true # tant qu'on veut ajouter des données
      clear
      puts (PROMPTS[:biblio][:format_for_fiches_of] % dbiblio[:tag]).bleu
      puts (PROMPTS[:biblio][:help_data_format] % dbiblio[:tag]).gris
      choices = dformat.map do |dprop|
        {name: dprop[:name], value: dprop}
      end + [
        {name:PROMPTS[:biblio][:new_property].bleu, value: :new_prop},
        {name:PROMPTS[:Finir].bleu, value: :end},
      ]
      choix = Q.select(nil, choices, **{per_page: choices.count, show_help:false})
      case choix
      when :end
        puts "Données format à sauver : #{dformat.pretty_inspect}"
        if Q.yes?("#{PROMPTS[:save]}?".jaune)
          File.write(data_format_file, dformat)
        end
        break
      when :new_prop
        dprop = edit_format_prop({})
        dformat << dprop # on l'ajoute
      else
        dprop = edit_format_prop(choix)
      end
    end
  end

  def edit_format_prop(dprop)
    prop_name = Q.ask("Nom de la nouvelle propriété :".jaune, **{default: dprop[:name]})
    dprop.merge!(name: prop_name)
    prop_type = Q.select("Type de la nouvelle propriété".jaune, TYPES_PROPS, **{per_page: TYPES_PROPS.count, show_help:false})
    dprop.merge!(type: prop_type)
    prop_default = Q.ask("Valeur par défaut".jaune, **{default: dprop[:default]})
    dprop.merge!(default: prop_default)
    prop_validif = Q.ask("Méthode de validation (nom)".jaune, **{default: dprop[:validif]})
    dprop.merge!(validif: prop_validif ? prop_validif.to_sym : nil)
    return dprop
  end

  TYPES_PROPS = [
    {name:'String'            , value: :string},
    {name:'People(s)'         , value: :people},
    {name:'Entier'            , value: :int},
    {name:'Date (JJ/MM/AAAA)' , value: :date},
    {name:'Année'             , value: :annee},
    {name:'Personnalisé'      , value: :custom},
  ]

  # Test la validité du tag fourni.
  # 
  # @return [NilClass|String] nil si le tag est valide et le message
  # d'erreur otherwise.
  # 
  def tag_invalid?(tag, data_biblio)
    is_new = data_biblio[:is_new] === true
    # 
    # Ce tag doit être unique
    # 
    if is_new 
      raise ERRORS[:biblio][:tag_already_exists] if biblios_data.key?(tag)
    end
    tag.to_s.gsub(/[a-z]/,'') == '' || raise(ERRORS[:biblio][:bad_tag])
    if tag.to_s[-1] == 's'
      puts ERRORS[:biblio][:warn_end_with_s].orange
      sleep 5
    end
  rescue Exception => e
    return e.message
  else
    return nil # OK
  end

  # @return nil si le path au dossier des données (cartes) existe,
  # ou un message d'erreur dans le cas contraire
  #
  def folder_cards_not_exist?(path, data_biblio)
    path_ini = path.dup.freeze
    return if File.exist?(path)
    path = File.expand_path('.', path_ini)
    return if File.exist?(path)
    if Q.yes?((PROMPTS[:biblio][:ask_create_folder_cards] % path).jaune)
      mkdir(path)
      return nil
    end
    # - Introuvable -
    return (ERRORS[:biblio][:malformation][:path_unfound] % path_ini)
  end

  def choices_biblios
    pre_menus = []
    pre_menus << { name:PROMPTS[:biblio][:new_one].bleu, value: :new}
    pre_menus + biblios_data.map do |biblio_id, biblio_data|
      {name: biblio_data[:title].upcase, value: biblio_id}
    end
  end

  # @return [Hash<Hash>] Table des bibliographies définies
  def biblios_data
    main_data_biblio[:biblios] || {}
  end

  def main_data_biblio
    @main_data_biblio ||= owner.recipe.bibliographies || {}
  end

  ##
  # Retourne les polices pour un menu facilitator
  # 
  def police_names
    owner.recipe.fonts_data.keys + DEFAUT_FONTS.keys
  end

  def police_names_or_default
    [{name:'Par défaut', value: :default}] + police_names
  end

DATA_BIBLIO = [
  {name: "Tag de la bibliographie (id singulier)", value: :tag, type: :sym, invalid_if: :tag_invalid?, required:true},
  {name: 'Titre (tel qu’affiché dans le livre)' , value: :title, required:true},
  {name: "Niveau de titre pour affichage"       , value: :title_level, type: :int},
  {name: "Sur nouvelle page ?", value: :new_page, type: :bool},
  {name: 'Dossier des fiches', value: :path, invalid_if: :folder_cards_not_exist?, required: true},
  {name: 'Font (dans bibliographie)', value: :font, default: 1, values: :police_names_or_default},
  {name: 'Taille de police', value: :size, default: 11},
  {name: 'Style de police', value: :style, default: nil, values: :font_styles_or_default},
]


MAIN_DATA_BIBLIOGRAPHIES = [
  {name: 'Les bibliographies', value: :biblios, value_method: :hliste_of_biblios, type: :custom, meth: :define_types_bibliographies},
  {name: "Identifiant la bibliographie des livres (livre)", value: :book_identifiant, type: :sym, default: 'livre'},
  {name: 'Fonte par défaut (dans la bibliographie)', value: :font, default: 1, values: :police_names_or_default},
  {name: 'Taille de police par défaut', value: :size, default: 11},
  {name: 'Style de police par défaut', value: :style, default: nil, values: :font_styles_or_default},
]

  # @return [String] La liste humaine des bibliographies courantes
  def hliste_of_biblios
    if biblios_data.empty?
      owner.recipe.biblio_book_identifiant
    else
      ([owner.recipe.biblio_book_identifiant]+biblios_data.keys).pretty_join
    end
  end

end #/class AssistantBiblio
end #/class Assistant
end #/module Prawn4book
