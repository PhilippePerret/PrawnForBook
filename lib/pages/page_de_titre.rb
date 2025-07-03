=begin

  Chargeur de la page (pour pouvoir l'utiliser, quelle que soit
  l'utilisation)

  C'est ce fichier qui doit être appelé pour utiliser/définir/construire
  la page :

    require './lib/pages/page_de_titre'

=end
require_relative 'required'
module Prawn4book
class Pages
class PageDeTitre < SpecialPage
end;end;end
require_page('page_de_titre')
