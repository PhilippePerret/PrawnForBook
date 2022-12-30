=begin

Module contenant des méthodes mixin pour simplifier le travail et 
éviter les répétitions dans les définitions.
=end
module Prawn4book
module TTYFacilitators

  # @param [Array<Hash>] abs_data Liste des choix tty-prompt de base
  #     Chaque élément doit donc contenir les données de base que 
  #     sont :name et :value.
  #     La :value doit être la propriété de l'objet et :name doit 
  #     être le nom de la propriété.
  #     On peut définir en plus un type qui va définir la valeur
  #     finale à donner. Les types sont :
  #       :int      Pour un entier
  #       :float    Pour un flottant
  #       :bool     Pour un booléan (déterminera aussi le formulaire)
  # 
  def tty_define_object_with_data(abs_data, odata)
    TTYDefiner.new(self, abs_data, odata).defining
  end

class TTYDefiner

  attr_reader :klasse
  attr_reader :abs_data
  attr_reader :odata

  def initialize(klasse, abs_data, odata)
    @klasse   = klasse
    @abs_data = abs_data
    @odata    = odata
  end

  def defining
    define_table_prop_to_dchoix(abs_data)
    # 
    # Boucle tant que l'utilisateur veut définir des choses
    # 
    while true # tant qu'on doit définir des choses
      clear unless debug?
      puts "odata : #{odata.inspect}"
      # 
      # Définir les choix en fonction des nouvelles valeurs
      # 
      choices, selected = define_choix_pour_objet_properties(abs_data, odata)
      # 
      # Pour sélectionner la valeur à définir
      # 
      case (prop = Q.select(PROMPTS[:Define].jaune, choices, {per_page:choices.count, default: selected, show_help:false, echo:false}))
      when :finir then return odata
      else define_object_property(prop, odata)
      end
    end #/fin while
  end

  def define_choix_pour_objet_properties(abs_data, odata)
    # 
    # Préparer les menus
    # 
    @abs_data_preparees ||= begin
      max_len = 0
      abs_data.map.with_index do |dchoix, idx|
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
      prop      = dchoix[:value]
      selected  = dchoix[:index] if selected.nil? && odata[prop].nil?
      dchoix.merge(name: "#{dchoix[:raw_name]} : #{odata[prop]||'---'}")
    end

    return [[CHOIX_FINIR] + cs, selected]
  end

  def define_object_property(prop, odata)
    data_choix  = table_prop_to_dchoix[prop]
    def_value   = data_choix[:default]
    cur_value   = odata[prop]
    # --- Valeur choisie ---
    question = "#{data_choix[:name]} : ".jaune
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
          klasse.send(data_choix[:meth], odata)
        else
          Q.ask(question, {default: odata[prop]})
        end
      end
    # --- Après le choix ---
    value = case data_choix[:type]
    when :int     then value.to_i
    when :float   then value.to_f
    when :sym     then value.to_sym
    when :string  then value.to_s
    when NilClass then value
    else klasse.send(data_choix[:type], value)
    end
    odata.merge!(prop => value)
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

end #/class TTYDefiner
end #/module TTYFacilitators
end #/module Prawn4book
