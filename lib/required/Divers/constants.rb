# Nom de l'application dans laquelle ouvrir le texte seul pour
# le corriger
# @rappel
#   On sort ce texte en utilisant 'pfb build -t'
#   (c'est l'option "-t" qui demande, en même temps que la 
#    construction du livre, l'export de l'intégralité de son
#    texte)
# 
CORRECTOR_NAME = "Antidote 11"

#
# Dossier définissant les snippets pour le livre courant
# 
# @rappel
# 
#   On utilise la commande 'pfb install' dans le dossier du livre
#   pour "installe" prawn-for-book et, notamment, mettre les
#   snippets s'il y en a.
# 
SUBL_SNIPPETS_FOLDER = "/Users/philippeperret/Library/Application Support/Sublime Text/Packages/Prawn4Book/Snippet"



# --- Chemins d'accès ---
LIB_FOLDER      = File.dirname(File.dirname(__dir__)).freeze
APP_FOLDER      = File.dirname(LIB_FOLDER)
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')
COMMANDS_FOLDER = File.join(LIB_FOLDER,'commandes')

IMAGES_FOLDER   = File.join(APP_FOLDER,'images')

# --- Constantes utiles ---

# COMMAND_NAME = 'prawn-for-book'
COMMAND_NAME = 'pfb'

# @constantes
# Chemins d'accès au manuel utilisateur
USER_MANUAL_PATH    = File.join(APP_FOLDER,'Manuel','Manuel.pdf')
USER_MANUAL_MD_PATH = File.join(APP_FOLDER,'Manuel','Manuel.md')
PRAWN_MANUEL_PATH   = File.join(APP_FOLDER,'Manuel','Prawn_manual.pdf')
PRAWN_TABLE_MANUAL  = File.join(APP_FOLDER,'Manuel','Prawn_Table_manual.pdf')

# --- Chargement de toutes les locales ---
LANG = CLI.params[:lang] || 'fr'
LOCALISATION_FOLDER = File.join(LIB_FOLDER,'locales',LANG)
File.exist?(LOCALISATION_FOLDER) || begin
  puts "Le dossier localisation est introuvable (à l'adresse #{LOCALISATION_FOLDER.inspect})".rouge
  exit 100
end
Dir["#{LOCALISATION_FOLDER}/**/*.rb"].each{|m|require(m)}
# => Prawn4book::MESSAGES
# => Prawn4book::ERRORS

#
# Pour les select tty-prompt
# 
CHOIX_SAVE    = {name: Prawn4book::PROMPTS[:save].bleu  , value: :save}
CHOIX_NEW     = {name: Prawn4book::PROMPTS[:New].bleu   , value: :new}
CHOIX_FINIR   = {name: Prawn4book::PROMPTS[:Finir].bleu , value: :finir}
CHOIX_CANCEL  = {name: "#{Prawn4book::PROMPTS[:cancel]} (^c)".orange, value: :cancel}
CHOIX_ABANDON = {name: Prawn4book::PROMPTS[:Abandon].bleu, value: :cancel}
#
# Fontes PDF par défaut
#

# DEFAULT_FONTS_KEYS = DEFAUT_FONTS.keys
DEFAUT_FONTS = {}
DEFAULT_FONTS_KEYS = Prawn::Fonts::AFM::BUILT_INS.map do |font_def|
  font_name, font_style = font_def.split('-')
  font_style = case font_style
      when NilClass       then :regular
      when 'Bold'         then :bold
      when 'BoldOblique'  then :bold_italic
      when 'Oblique'      then :italic
      when 'BoldItalic'   then :bold_italic
      when 'Italic'       then :italic
      when 'Roman'        then :roman
      else
        raise "Erreur systémique : Le style de fonte #{font_style.inspect} est inconnu (pour la font #{font_def.inspect})."
      end
  font_name = "Times-Roman" if font_name == 'Times'
  DEFAUT_FONTS.merge!(font_name => {}) unless DEFAUT_FONTS.key?(font_name)
  DEFAUT_FONTS[font_name].merge!(font_style => true)
  font_name # => map
end.uniq

# puts "DEFAUT_FONTS : #{DEFAUT_FONTS.inspect}"

DATA_STYLES_FONTS = [
  {name: 'Normal'         , value: :normal        , index:1},
  {name: 'Regular'        , value: :regular       , index:2},
  {name: 'Italic'         , value: :italic        , index:3},
  {name: 'Bold'           , value: :bold          , index:4},
  {name: 'Extra-bold'     , value: :extra_bold    , index:5},
  {name: 'Light'          , value: :light         , index:6},
  {name: 'Extra-light'    , value: :extra_light   , index:7},
  {name: 'Oblique'        , value: :oblique       , index:8},
  {name: 'Bold Oblique'   , value: :bold_oblique  , index:9},
  {name: 'Bold Italic'    , value: :bold_italic   , index:10},
  {name: 'Roman'          , value: :roman         , index:11},
]

# Options pour lire n’importe quel fichier YAML correctement
YAML_OPTIONS = {symbolize_names:true, aliases: true, permitted_classes: [Date, Symbol, TrueClass, FalseClass]}.freeze

# Pour dire de ne pas interpréter s’il y a un caractère échappement
# Par exemple, si on veut trouver le caractère "(" dans 
# "blabal (bla) bla" mais pas dans "blabla \(bla) bla"
EXCHAR = /(?<!\\)/

