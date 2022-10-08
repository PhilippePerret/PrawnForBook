require "minitest/autorun"
require 'minitest/reporters'

require_relative '../lib/required'

TEST_FOLDER = __dir__.freeze

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]




# --- TEST D'INTÉGRATION ---
# 
# @usage
#   run_(<cmd>, [<input>])
# 
ENV['CLI_TEST'] = 'true'
class Minitest::Test
  def run_(cmd, inputs = nil)
    if inputs
      ENV['CLI_TEST_INPUTS'] = inputs.to_json
      res = `#{COMMAND_NAME} #{cmd}`
      return res
    end 
  end
end
