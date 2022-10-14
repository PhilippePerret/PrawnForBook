require 'yaml'
require 'fileutils'
require 'prawn'
require "prawn/measurement_extensions" # Pour pouvoir utiliser 1.cm etc.

require 'clir'
CLI.set_options_table({e: :edition, c: :cursor})

#
# Pour insérer des svg dans les documents
# Cf. https://github.com/mogest/prawn-svg
# Note : penser à utiliser 'color_mode: :cmyk'
require 'prawn-svg'

require_relative 'required/constants'


Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}
