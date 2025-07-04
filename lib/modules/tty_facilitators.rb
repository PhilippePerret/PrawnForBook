=begin

Module contenant des méthodes mixin pour simplifier le travail et 
éviter les répétitions dans les définitions.

:name       Attribut traditionnel de tty-prompt, ce qui est affiché
:value      Attribut traditionnel de tty-prompt, la valeur qui sera
            retournée suivant le choix. En général, c'est le nom de
            la propriété.

- Tous les autres attributs sont optionnels -
:required   Si true, la donnée est absolument requise
:type       Type de la donnée, qui permet de la modifier en sortie Les
            valeurs sont définies ci-dessous, à TYPES DE DONNÉE
:values     Si défini, on sait que les valeurs doivent être choisies
            dans un ensemble de valeurs données. Ces valeurs peuvent
            être définies de deux façons, comme une méthode (:values
            est alors un Symbol) ou comme procédure (:values est alors
            une [Proc]). Pour la valeur exact de cet attribut, cf.
            ATTRIBUT SYMBOL OU PROCÉDURE.
:value_method 
            [Symbol|Proc] La méthode ou la procédure à utiliser quand
            la valeur affichée ne doit pas être celle consignée. Peut
            servir par exemple pour remplacer 'true' par "oui" ou "vrai"
            La méthode peut recevoir 0, 1 ou 2 arguments. Le premier
            sera la valeur brut dans la donnée, le second sera la table
            complète des données.
:meth       [Symbol] La méthode à utiliser quand le type de donnée est
            :custom. Permet d'obtenir une donnée quelconque. Par défaut
            elle peut recevoir 1 ou 2 arguments. La donnée complète
            en premier et, éventuellement pour une hiérarchie profonde,
            la clé de l'autre donnée. Cela permet d'imbriquer des
            données très profondément. Cf. ci-dessous "Imbrication
            profonde des données"
:if         Permet de définir si la propriété doit être affichée pour
            la donnée courante ou page
:valid_if   [Symbol|Proc] Méthode de validation. Renvoie true si la 
            donnée est valide. Pour la valeur exact de cet attribut,
            cf. ATTRIBUT SYMBOL OU PROCÉDURE.
:invalid_if [Symbol|Proc] Méthode d'invalidation. Renvoie nil si la
            donnée est valide et un message d'erreur quand la donnée
            est invalide. Pour la valeur exact de cet attribut, cf.
            ATTRIBUT SYMBOL OU PROCÉDURE.

TYPES DE DONNÉE
---------------
(attribut :type)
:int      Un entier
:float    Un flottant
:sym      Un symbol
:url      Une adresse web
:custom   Données quelconque, personnalitée.


ATTRIBUT SYMBOL OU PROCÉDURE
----------------------------
Plusieurs attributs peuvent être définis par un [Symbol] ou par une
[Proc]édure. Quand c'est un symbol, c'est le nom d'une méthode à
appeler, avec en premier argument la valeur à traiter (valeur de la
propriété éditée) et en second argument la donnée complète ([Hash]).
Cette méthode peut être définie dans le facilitateur, dans l'instance
qui utilise le module, ou dans la classe de cette instance.

IMBRICATION PROFONDE DES DONNÉES
--------------------------------
Lorsque des données complexes sont imbriquées, on utilise un type
de données :custom et une méthode définie par :meth. La méthode
définie par :meth peut recevoir deux arguments, la donnée totale et
la clé dans la donnée totale. Par exemple :
data_objet = {donnee: nil}
data_absolue = [
  {name: "Ma données", value: :donnee, type: :custom, meth: :methode_de_donnee}
]
sous_data_absolue = [
  ...
  {name:"Ma sous-donnée", value: :sous_donnee, type: :custom, meth: :methode_de_sous_donnee}
  {name:"Autre sous-donnée", value: :subdata, type: :custom, meth: :methode_de_sous_donnee}
  ...
]

# J'envoie au facilitator (rappel = le module doit être inclus dans
# la classe pour pouvoir l'appeler comme ça)
if tty_define_object_with_data(data_absolue, data_objet)
  # à la fin, pour la sauver si tout est ok
  save
end

# La méthode de donnée, si elle doit recevoir des méthodes complexes
# Ici, +key+ sera égal à :donnee
# @note
#   Où c'est intéressant, c'est lorsque plusieurs données font appel
#   à la même méthode, pour pouvoir les distinguer.
def methode_de_donnee(data_objet, key)
  sous_data = data_objet[key]
  if tty_define_object_with_data(sous_data_absolue, sous_data)
    # Si tout est OK, on peut mettre la valeur dans les data complètes
    # de l'objet
    data_objet.merge!(key => sous_data)
  end
end

# La sous-methode de donnée, pour descendre encore dans l'imbrication
# Ici, +key+ sera égal à :sous_donnee ou à :subdata
def methode_de_sous_donnee(sous_data, key)
  subsub = sous_data[key]
  if tty_define_object_with_data(autre_absolue, subsub)
    sous_data.merge!(key => subsub)
  end
end

=end
module Prawn4book
module TTYFacilitators

  ##
  # Facilitator de définition de données quand elles sont sur un seul
  # niveau (table simple avec clé=>valeur)
  # 
  # @return [Boolean] true en cas de données ok, false en cas
  # d'abandon.
  # 
  # @param [Array<Hash>] abs_data Liste des choix tty-prompt de base
  #     Chaque élément doit donc contenir les données de base que 
  #     sont :name et :value. Cf. le détail ci-dessus
  # @param [Hash] odata Table des données de la donnée à éditer.
  # @param [Hash] options Table d'options
  # @option options [String] :title Le titre à donner
  # 
  def tty_define_object_with_data(abs_data, odata, **options)
    # 
    # On consigne les valeurs d'origine pour les remettre en cas
    # d'abandon
    # 
    consigne_init_data(odata)
    # 
    # On procède à l'édition de la donnée
    # 
    ok = TTYDefiner.new(self, abs_data, odata, options).defining
    # 
    # En cas d'abandon, on remet les valeurs d'origine
    # 
    retrieve_init_data(odata) if not ok
    # 
    # On retourne le résultat
    # 
    return ok
  end

  def consigne_init_data(dd)
    @getter_data = {}
    dd.each { |k,v| @getter_data.merge!( k => v ) }
  end

  def retrieve_init_data(odata)
    @getter_data.each { |k, v| odata.merge!( k => v ) }
  end

class TTYDefiner

  attr_reader :klasse
  attr_reader :abs_data
  attr_reader :odata

  def initialize(klasse, abs_data, odata, **options)
    @klasse   = klasse
    @abs_data = abs_data
    @odata    = odata
    @options  = options
  end

  # @return [Boolean] true en cas de données ok, false en cas
  # d'abandon.
  def defining
    define_table_prop_to_dchoix(abs_data)
    # 
    # Pour afficher un message
    # 
    msg = nil
    # 
    # Boucle tant que l'utilisateur veut définir des choses
    # 
    while true # tant qu'on doit définir des choses
      clear unless debug?
      # puts "odata : #{odata.inspect}"
      # 
      # Pour écrire un message
      # 
      puts "\n  #{msg.split("\n").join("\n  ")}\n" unless msg.nil?
      msg = nil
      # 
      # Définir les choix en fonction des nouvelles valeurs
      # 
      choices, selected = define_choix_pour_objet_properties(abs_data, odata)
      # 
      # Pour sélectionner la valeur à définir
      # 
      begin
        case (prop = Q.select(title.jaune, choices, {per_page:choices.count, default: selected, show_help:false, echo:false}))
        when :finir
          return true unless (msg = object_data_valid?)
        when :cancel
          return false
        else 
          define_object_property(prop, odata)
        end
      rescue TTY::Reader::InputInterrupt
        return false
      end
    end #/fin while
  end

  # @return [Boolean] true si les données @odata sont valides, 
  # c'est-à-dire si les données requises sont fournies.
  def object_data_valid?
    abs_data.each do |ddata|
      prop = ddata[:value]
      return ERRORS[:required_asterisk_properties].rouge if ddata[:required] && odata[prop].nil?
    end
    return nil # ok
  end

  def define_choix_pour_objet_properties(abs_data, odata)
    # 
    # Préparer les menus
    # 
    @abs_data_preparees ||= begin
      max_len = 0
      abs_data.select do |dchoix|
        # On ne prend que les attributs à définir (quand la condition :if est définie)
        dchoix[:if].nil? || estimate_if(dchoix, odata)
      end.map.with_index do |dchoix, idx|
        name = dchoix[:name]
        max_len = name.length if name.length > max_len
        dchoix.merge(raw_name: name, index: idx + 2) #  + 2 car 1) commence à 1 et 2) le choix "Finir" sera ajouté au-dessus
      end.each do |dchoix|
        hd = dchoix[:required] ? '* '.rouge : '  '

        dchoix[:raw_name] = hd + dchoix[:raw_name].ljust(max_len)
      end
    end
    selected = nil
    cs = @abs_data_preparees.map do |dchoix|
      prop    = dchoix[:value]
      value   = real_value_for(prop, dchoix, odata)
      def_value   = default_value_for(dchoix, odata)
      thename =
        if value.nil?
          selected  = dchoix[:index] if selected.nil?
          "#{dchoix[:raw_name]} : #{def_value || '---'}"
        else
          "#{dchoix[:raw_name]} : #{value}".vert
        end
      dchoix.merge(name: thename)
    end
    cs.unshift(CHOIX_FINIR)
    cs.push(CHOIX_CANCEL)
    return [ cs, selected ]
  end

  def real_value_for(prop, dchoix, odata)
    value = odata[prop]
    if dchoix[:value_method]
      case dchoix[:value_method]
      when Proc
        proced = dchoix[:value_method]
        case proced.arity
        when 0 then proced.call
        when 1 then proced.call(value)
        when 2 then proced.call(value, odata)
        end
      when Symbol
        meth = dchoix[:value_method]
        case klasse.method(meth).arity
        when 0 then klasse.send(meth)
        when 1 then klasse.send(meth, value)
        when 2 then klasse.send(meth, value, odata)
        end
      end
    else
      value
    end
  end

  def default_value_for(dchoix, odata)
    prop = dchoix[:value]
    cval = odata[prop]
    return nil unless cval.nil?
    def_value = dchoix[:default]
    case def_value
    when Proc
      if def_value.arity == 0
        def_value = def_value.call
      elsif def_value.arity == 1
        def_value = def_value.call(odata)
      end
    when Symbol
      if klasse.respond_to?(def_value)
        def_value =
          case klasse.method(def_value).arity
          when 0 then klasse.send(def_value) 
          when 1 then klasse.send(def_value, odata) 
          when 2 then klasse.send(def_value, odata, dchoix)
          end
      end
    end
    return def_value
  end

  ##
  # Estimation de l'attribut :if pour la donnée +odata+
  # @return [Boolean] true si la donnée répond à la condition :if, 
  # false otherwise
  def estimate_if(dchoix, odata)
    methode = dchoix[:if] 
    case methode
    when Symbol
      if self.respond_to?(methode)
      elsif klasse.respond_to?(methode)
      elsif klasse.class.respond_to?(methode)
      end.send(methode, odata)
    when Proc
      methode.call(odata)
    end 
  end

  def define_object_property(prop, odata)
    data_choix  = table_prop_to_dchoix[prop]
    def_value   = default_value_for(data_choix, odata)
    cur_value   = odata[prop]
    # --- Valeur choisie ---
    question = "  #{data_choix[:name]} : ".jaune
    # 
    # Pour un message, d'erreur par exemple
    # 
    msg = nil
    # 
    # On boucle tant que la valeur n'est pas bonne
    # 
    while true
      clear unless debug?
      # 
      # S'il y a un message à afficher
      # 
      puts "\n  #{msg}" if msg
      # 
      # Pour laisser toujours de l'air au-dessus
      # 
      puts "\n"
      # 
      # La valeur donné par l'utilisateur
      value = 
        if data_choix[:values]
          # 
          # On doit prendre parmi ces valeurs
          # 
          case data_choix[:values]
          when Range
            Q.slider(question, data_choix[:values].to_a, {default: odata[prop]||def_value})
          else
            values = values_for_select(data_choix)
            selected = nil
            values.each_with_index do |value, idx|
              selected = (idx + 1) and break if value.to_s == cur_value.to_s
            end
            Q.select(question, values, {per_page: values.count, default: (selected||def_value)})
          end
        else
          case data_choix[:type]
          when :bool
            Q.yes?(data_choix[:name].jaune)
          when :custom
            case klasse.method(data_choix[:meth]).arity
            when 1
              klasse.send(data_choix[:meth], odata)
            when 2
              klasse.send(data_choix[:meth], odata, prop)
            else
              raise "La méthode #{klasse}#{data_choix[:meth]} possède un mauvais nombre d'arguments (devrait en avoir 1 ou 2)."
            end
          # when :int
          #   #
          #   # Quand c'est un entier, on peut utiliser un curseur
          #   # 
          #   get_value_as_integer()
          else
            # 
            # Le cas commun
            # 
            Q.ask(question, {default: odata[prop]||def_value, show_help:nil})
          end
        end
      # Pour éviter les erreurs
      value = nil if value.to_s == ''
      # --- Après le choix ---
      unless value.nil?
        value = case data_choix[:type]
        when :int     then value.to_i
        when :float   then value.to_f
        when :sym     then value.to_sym
        when :string  then value.to_s
        when NilClass then value
        when :custom  then value
        when :bool    then value
        else klasse.send(data_choix[:type], value)
        end
      end
      # --- S'il y a des méthodes de validation ---
      msg = data_validating(data_choix, prop, value, odata)
      break if msg.nil?
    end #/boucle while la data n'est pas valide
    # --- Si c'est bon, on peut enregistrer la valeur ---
    odata.merge!(prop => value)
  end

  ##
  # Validation de la donnée
  # 
  # @return [NilClass|String] Either nil if +value+ is ok, error
  # message otherwise.
  # 
  def data_validating(data_choix, prop, value, odata)
    if data_choix[:required] && value.nil?
      return (ERRORS[:required_property] % prop.inspect).rouge
    end
    if data_choix[:invalid_if]
      err = run_method_validate(data_choix[:invalid_if], value, odata)
      return err.rouge unless err.nil?
    end
    if data_choix[:valid_if]
      ok = run_method_validate(data_choix[:valid_if], value, odata)
      if ok
        return nil
      else
        return (ERRORS[:invalid_data] % [prop.inspect, value.inspect]).rouge
      end
    end
    return nil # ok
  end

  def run_method_validate(methode, value, odata)
    case methode
    when Symbol
      if klasse.respond_to?(methode)
        klasse
      elsif self.respond_to?(methode)
        self
      elsif klasse.class.respond_to?(methode)
        klasse.class
      end.send(methode, value, odata)
    when Proc
      methode.call(value, odata)
    end
  end

  def values_for_select(data_choix)
    case data_choix[:values]
    when Symbol then 
      meth = data_choix[:values]
      if self.respond_to?(meth)
        self.send(meth)
      elsif klasse.respond_to?(meth)
        klasse.send(meth)
      elsif klasse.class.respond_to?(meth)
        klasse.class.send(meth)
      else
        raise "Je ne trouve personne qui réponde à la méthode #{meth.inspect}…".rouge
      end
    when Array
      data_choix[:values]
    else
      raise "Je ne sais pas traiter des valeurs (:values) autres que Array et Symbol"
    end
  end

  def table_prop_to_dchoix
    @table_prop_to_dchoix
  end

  def define_table_prop_to_dchoix(abs_data)
    tbl = {}
    abs_data.each do |dchoix|
      tbl.merge!(dchoix[:value] => dchoix)
    end
    @table_prop_to_dchoix = tbl
  end

  # - Options Methods -

  def title
    @title ||= @options[:title] || PROMPTS[:Define]
  end

end #/class TTYDefiner
end #/module TTYFacilitators
end #/module Prawn4book
