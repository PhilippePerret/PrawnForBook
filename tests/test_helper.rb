require 'pretty_inspect'
require "minitest/autorun"
require 'minitest/reporters'
require 'yaml'

require 'prawn'
require 'pdf/inspector'
require 'pdf/reader'
require 'clir'
require 'clirtest'
require 'osascript'
require 'osatest'


# Pour charger plus facilement les modules de l'application
$LOAD_PATH.unshift File.dirname(__dir__)


TEST_FOLDER = __dir__.freeze
ASSETS_FOLDER = File.join(TEST_FOLDER,'assets')

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

# 
# Avant que PDF::Checker soit vraiment un GEM
$LOAD_PATH.unshift File.join(Dir.home,'Programmes','Gems','pdf-checker','lib')
require 'pdf/checker'


require_relative '../lib/required/constants'
require_relative '../lib/required/Spy'
if CLI.options[:spy]
  spy "Initiation du Terminal d'espionnage…".bleu 
else
  puts "Ajouter l'option -spy pour utiliser l'espion".jaune
  sleep 1
end

module Minitest
  class Test
    def new_tosa
      return OSATest.new({
        app:'Terminal',
        delay: 0.5,
        window_bounds: [0,0,1200,800]
      })
    end
  end #/class Test
end #/module Minitest
