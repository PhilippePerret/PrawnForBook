require 'yaml'
require 'fileutils'
require 'precedences'
# require 'log_in_file'
require 'prawn'
require 'prawn/table'
require "prawn/measurement_extensions" # Pour pouvoir utiliser 1.cm etc.
Prawn::Fonts::AFM.hide_m17n_warning = true

require 'clir'
CLI.set_options_table({
  e: :edition, 
  c: :cursor, 
  g: :grid,
  t: :export_text, # pfb build -t
  nouprefs: :no_update_registered_refs,
})

#
# Pour insérer des svg dans les documents
# Cf. https://github.com/mogest/prawn-svg
# Note : penser à utiliser 'color_mode: :cmyk'
require 'prawn-svg'

module Prawn4book
  # @return true si on doit faire un retour "doux" (quand on utilise
  # une console qui ne sort pas la couleur, par exemple)
  def self.soft_feedback?
    :TRUE == @softfeedback ||= true_or_false(CLI.option(:soft_feedback))
  end
end

if Prawn4book.soft_feedback?
  # Il faut charger tout de suite le surclassement des méthodes pour
  # que les textes localisés, chargés par constants.rb, qui utilisent
  # des méthodes couleurs, ne soient pas en couleur.
  require_relative "modules/soft_feedback_overwritings"
end

require_relative 'required/Divers/constants'

require_relative 'required/Divers/PrawnOwner'
module Prawn4book; class PdfBook < PrawnOwner; end; end
module Prawn4book; class Collection < PrawnOwner; end; end

require_relative 'required/Classes/ParagraphAccumulator'

# - Tous les modules fonctionnels -
Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}

module Prawn4book
  include UtilsMethods
end 
