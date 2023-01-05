=begin

  Gestion des précédences
  -----------------------
  Permet d'agencer une liste de choix (de type tty-prompt) de telle 
  sorte que les derniers choix de l'utilisateur sont placés en 
  premier
  
  L'USAGE le plus pratique est le suivant :

    choix = choices_with_precedences(<liste>[, __dir__]) do
      "<La question à poser>"
    end || return

=end

# Chaque commande enregistre dans son dossier son fichier de
# précédences (si elle commence par un menu). On peut également
# enregistrer n'importe quelle précédence dans un fichier stipulé
# en second argument (ou un dossier dans lequel sera créé le fichier
# invisible '.precedences').
#
# Les méthodes suivantes permettent de gérer ces précédences.
# @example
#   choix = choices_with_precedences(<liste>[,<file name>]) do
#     "<La question à poser>"
#   end || return
# 
#   Le code ci-dessus va classer la liste <liste> par précédences
#   en fonction du contenu du fichier tmp/precedences/<file name>
#   (qui doit donc être unique), afficher la sélection avec la
#   question "<Question à poser>".
#   Quand l'utilisateur aura choisi sa réponse, si elle n'est pas
#   nulle, elle sera consignée dans le fichier des précédences.
# 
# @example
#   On peut également utiliser la méthodes sans bloc :
#   choices = choices_with_precedence(<liste>[, <file name>])
#   choix = Q.select("<question>".jaune, choices, {per_page:...})
#   set_precedence(choix[,<file name>]) unless choix.nil?
# 
# @return [Array] La liste +choices+ classée selon les précédences
#         [Any]   Ou le choix, si la méthode est appelée avec un
#                 block
# @param [Array] choices Les choix tty-prompt de la commande
#     Ce sont des Hash contenant au minium :name et :value
# @param [String] filename Nom optionnel (unique) dans lequel 
#                 enregistrer les précédences. Si c'est un dossier
#                 on prend ou crée le fichier .precedences dedans
# 
def choices_with_precedences(choices, filename = nil, &block)
  renoncer_is_in = false
  filename = rationalize_file_precedences(filename)
  choices = choices.map do |x| # clone
    renoncer_is_in = true if x[:value].nil? && x[:name] == 'Renoncer'
    x
  end
  choices << CHOIX_RENONCER unless renoncer_is_in
  if File.exist?(precedences_file(filename))
    prec_ids = precedences_ids(filename)
    choices.sort!{|a, b|
      (prec_ids.index(a[:value].to_s)||10000) <=> (prec_ids.index(b[:value].to_s)||10000)
    }
  end
  choices
  #
  # Dans le cas où on utilise un block
  # 
  if block_given?
    params = block.call
    question, options = 
      if params.is_a?(String)
        [params, nil]
      else
        params
      end
    options ||= {}
    options.merge!({per_page: choices.count, echo:''})
    options.key?(:help) || options.merge!(help: '')
    choix = Q.select(question.jaune, choices, **options)
    set_precedence(choix, filename) unless choix.nil?
    return choix
  else
    return choices
  end
end

def rationalize_file_precedences(filename)
  return nil if filename.nil?
  return File.join(filename,'.precedences') if File.directory?(filename)
  return filename
end

# Définit +value+ comme la dernière valeur choisie
# @param [String] value   Valeur choisie dans le menu. C'est 
#     toujours un string, dans les premiers menus des commandes.
# 
def set_precedence(value, filename = nil)
  value = value.to_s
  pids = precedences_ids(filename)
  pids.delete(value)
  pids.unshift(value)
  File.write(precedences_file(filename), pids.join("\n"))
end

# @return [String] Path au chemin du fichier des précédencees
# @note
#   Tient compte du mode test (fichier dans tmp)
def precedences_file(filename = nil)
  if filename.nil?
    @precedences_file ||= begin
      if test?
        dossier = mkdir(File.join('tmp','test','precedences'))
        File.join(dossier, command_name)
      else
        File.join(folder,'.precedences')
      end
    end
  elsif File.exist?(filename)
    return filename
  elsif File.basename(filename) == '.precedences' && File.exist?(File.dirname(filename))
    return filename
  else
    @precedences_folder ||= begin
      hiera = test? ? ['tmp','test','precedences'] : ['tmp','precedences']
      mkdir(File.join(*hiera))
    end
    return File.join(@precedences_folder, filename)
  end
end
# @return [Array] liste des :value dans l'ordre de précédence
def precedences_ids(filename = nil)
  pfile = precedences_file(filename)
  File.exist?(pfile) ? File.read(pfile).split("\n") : [] 
end
