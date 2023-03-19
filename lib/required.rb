require 'yaml'
require 'fileutils'
require 'precedences'

require 'prawn'
require 'prawn/table'
require "prawn/measurement_extensions" # Pour pouvoir utiliser 1.cm etc.
Prawn::Fonts::AFM.hide_m17n_warning = true

require 'clir'
CLI.set_options_table({
  e: :edition, c: :cursor, g: :grid})

#
# Pour insérer des svg dans les documents
# Cf. https://github.com/mogest/prawn-svg
# Note : penser à utiliser 'color_mode: :cmyk'
require 'prawn-svg'

require_relative 'required/constants'

require_relative 'required/PrawnOwner'
module Prawn4book; class PdfBook < PrawnOwner; end; end
module Prawn4book; class Collection < PrawnOwner; end; end


Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}

module Prawn4book
  include UtilsMethods
end 
