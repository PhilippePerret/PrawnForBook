require 'clir'
require 'pdf/inspector'
require 'pdf/reader'

Dir["#{__dir__}/required/**/*.rb"].each{|m|require(m)}
