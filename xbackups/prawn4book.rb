#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Module principal pour produire un PDF prêt pour l'impression
  avec Prawn

=end

require 'bundler'

$LOAD_PATH.unshift __dir__
puts "__dir__ = #{__dir__.inspect}"

Dir.chdir(__dir__) do
  # Bundler.require(:plugins)
  Bundler.require
end

require_relative 'lib/required'
raise "Il ne faut plus appeler ce script. Jouer la commande 'bk' ou 'prawn-for-book' ou 'pfb' ou 'prawn-book'"
Prawn4book.run
