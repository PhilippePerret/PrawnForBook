

def exit_if_no_document
  File.exist?(PDF_PATH) || begin
    puts "Fichier introuvable : #{PDF_PATH}".rouge
    puts "
    Placer le document PDF dans le dossier :
     #{__dir__}
    avec le nom 'tested.pdf'
    OU donner le chemin d'accès complet au fichier en premier
    argument.
    ".gris
    exit 1
  end
end

def montre(label, valeur)
  puts "\n++++ #{label} : ".bleu + valeur.inspect
end

#
# Méthode qui affiche les méthodes des instances +inst+
def expose_methods_of(ins)
  montre "Méthodes propres à #{ins.class}", ins.class.instance_methods(false)
end

def expose_methods_return_of(what, what_str)
  methodes_ok = []
  what.class.instance_methods(false).each do |methode|
    begin
      puts "\n+++ ##{methode} de #{what_str} +++".bleu
      retour = what.send(methode).inspect
      retour_str = retour.to_s
      if retour_str.length > 1000
        retour = "[TRONQUÉ] #{retour_str[0..1000]} [...]"
      end
      puts retour
      methodes_ok << methode
    rescue ArgumentError => e
      puts "La méthode #{what_str}##{methode} attend des arguments : #{e.message}".rouge
    rescue LocalJumpError => e
      puts "Problème avec la méthode #{what_str}##{methode} : #{e.message}".rouge
    end
  end
  puts "\n\nMéthodes de #{what_str} qui ont pu être données : #{methodes_ok.join(', ')}".bleu
end
