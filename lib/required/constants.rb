
# --- Chemins d'accès ---
LIB_FOLDER      = File.dirname(__dir__).freeze
APP_FOLDER      = File.dirname(LIB_FOLDER)
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')
COMMANDS_FOLDER = File.join(LIB_FOLDER,'commandes')

IMAGES_FOLDER   = File.join(APP_FOLDER,'images')

# --- Constantes utiles ---

COMMAND_NAME = 'prawn-for-book'

# @constantes
# Chemins d'accès au manuel utilisateur
USER_MANUAL_PATH = File.join(APP_FOLDER,'Manuel','Manuel.pdf')
USER_MANUEL_MD_PATH = File.join(APP_FOLDER,'Manuel','Manuel.md')
