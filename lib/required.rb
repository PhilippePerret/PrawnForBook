require 'yaml'
require 'clir'
require 'prawn'
require "prawn/measurement_extensions" # Pour pouvoir utiliser 1.cm etc.
#
# Pour insérer des svg dans les documents
# Cf. https://github.com/mogest/prawn-svg
# Note : penser à utiliser 'color_mode: :cmyk'
require 'prawn-svg'

APP_FOLDER    = File.dirname(__dir__)
IMAGES_FOLDER = File.join(APP_FOLDER,'images')


Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}
