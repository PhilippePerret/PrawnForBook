#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Module principal pour produire un PDF prêt pour l'impression
  avec Prawn

=end

require 'bundler'

$LOAD_PATH.unshift __dir__

Dir.chdir(__dir__) do
  # Bundler.require(:plugins)
  Bundler.require
end

require_relative 'lib/required'
Prawn4book.run
