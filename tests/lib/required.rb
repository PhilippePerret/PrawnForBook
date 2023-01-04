=begin
@usage
  require_relative 'lib/required'
=end
Dir["#{__dir__}/required/*.rb"].each{|m|require(m)}
Dir["#{__dir__}/classes/*.rb"].each{|m|require(m)}
