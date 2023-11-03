# Pour essayer des trucs avec Cmd-B
# 

tin = "un texte^^ avec une note"
cin = "un texte^112 avec une note"
tou = "un texte\\^^ avec une note"
cou = "un texte\\^112 avec une note"

texte = <<~EOT
  Ceci est un paragraphe avec une note numérotée^^ de façon automatique, bien pratique par exemple pour les notes de fin d'ouvrage.
  Ceci est un paragraphe avec une note numérotée^112 explicitement.
  
  ^^ Note de la note numérotée automatiquement.
  ^112 Note de la note numéroté explicitement.
  EOT


REG = /([^\\])\^(\^|[0-9]+)/.freeze

puts "texte match? est #{texte.match?(REG).inspect}"

# puts "tin match? est #{tin.match?(REG).inspect}"
# puts "cin match? est #{cin.match?(REG).inspect}"
# puts "tou match? est #{tou.match?(REG).inspect}"
# puts "cou match? est #{cou.match?(REG).inspect}"
