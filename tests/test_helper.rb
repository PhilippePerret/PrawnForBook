require 'pretty_inspect'
require "minitest/autorun"
require 'minitest/reporters'

require 'prawn'
require 'pdf/inspector'
require 'pdf/reader'
require 'clir'
require 'clirtest'
require 'osascript'
require 'osatest'

# require_relative '../lib/required'

TEST_FOLDER = __dir__.freeze

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

require_relative '../lib/required/constants'
require_relative '../lib/required/Spy'
spy "Initiation du Terminal d'espionnage…".bleu
