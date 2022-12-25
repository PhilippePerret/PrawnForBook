#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Module principal pour produire un PDF prêt pour l'impression
  avec Prawn

=end

$LOAD_PATH.unshift __dir__

require_relative 'lib/required'
Prawn4book.run
