require "minitest/autorun"
require 'minitest/reporters'

require_relative '../lib/required'

TEST_FOLDER = __dir__.freeze

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
