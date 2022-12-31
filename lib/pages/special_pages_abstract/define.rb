=begin
  
  Méthodes communes pour la définition de la page

=end
module Prawn4book
class SpecialPage

  def self.define(path)
    instance = new(path)
    return instance.define
  end

  # = main =
  #
  # Méthode principale permettant de définir la page
  # 
  # @param [Hash] options Options de définition
  # @option options [Boolean] :return_data If true, the method returns data rather that recording it in the recipe file.
  # 
  def define(options = nil)
    # 
    # Faudra-t-il enregistrer dans la recette ou simplement retourner
    # les données ?
    # 
    return_data = options && options[:return_data]
    # 
    # Boucle pour définir toutes les données
    # 
    while true
      clear unless debug?
      puts "Assistant #{page_name}".upcase.bleu
      choices, selected = choices_properties
      begin
        data_choix = Q.select(nil, choices, {per_page:choices.count, default:selected, show_help:nil})
      rescue TTY::Reader::InputInterrupt
        return nil
      end
      case data_choix
      when NilClass, :cancel
        return nil if return_data
        break
      when :save
        return recipe_data if return_data
        save_recipe_data
        break
      else
        # Propriété à définir
        value = edit_value(data_choix)
        data_choix[:value] = value
        # choices_properties[data_choix[:index]][:value] = data_choix
        # choices_properties[data_choix[:index]][:name] = "#{data_choix[:name]} : #{value}"
        set_current_value_for(data_choix[:simple_key], value)
      end
    end
    clear unless debug?
    return true
  end

  def edit_value(data_choix)
    value = 
      if data_choix.key?(:values)
        choices = case data_choix[:values]
        when Symbol
          send(data_choix[:values])
        when Proc
          data_choix[:values].call(recipe_data)
        when Array
          data_choix[:values]
        else
          fatal_error("Mauvaise définition de :values dans : #{data_choix.inspect} (devrait être Array, Symbol ou Proc)")
        end
        Q.select("Choisir : ".jaune, choices, {per_page:choices.count})
      else
        # 
        # Valeur à rentrer explicitement
        # 
        Q.ask("#{data_choix[:name].jaune} : ".jaune, {default: data_choix[:value]||data_choix[:default]})
      end
    #
    # Transformation automatique du type en fonction du type de la
    # valeur par défaut
    #
    case data_choix[:default]
    when Integer  then value.to_i
    when Float    then value.gsub(/,/,'.').to_f
    when String   then value.to_s
    else value
    end
  end

  # @return [Array<Hash>, Selected] La liste des choix de propriétés
  #   l'index de l'élément à sélectionner
  # @note
  #   Pour gérer la hiérarchie (imbrications), on ajoute '-' entre
  #   chaque propriété. Par exemple, @@data[:size][:sub_title] deviendra
  #   la proprité 'size-sub_title'
  def choices_properties
    @choices_properties ||= begin
      choices = []
      klasse::PAGE_DATA.each do |main_key, dmainkey|
        if dmainkey.key?(:name) && dmainkey.key?(:default)
          # Un élément à prendre
          add_choice(choices, dmainkey, "#{main_key}")
        else
          # C'est un élément à parcourir
          dmainkey.each do |key, dkey|
            if dkey.key?(:name) && dkey.key?(:default)
              # Un élément à prendre
                add_choice(choices, dkey, "#{main_key}-#{key}")
            else
              # Un élément à parcourir
              dkey.each do |subkey, dsubkey|
                add_choice(choices, dsubkey, "#{main_key}-#{key}-#{subkey}")
              end
            end
          end
        end
      end
      choices
    end
    choices, selected = ultime_mise_en_forme_choices(@choices_properties.dup)
    choices.unshift(CHOIX_SAVE)
    choices.push(CHOIX_CANCEL)
    
    return [choices, selected]
  end

  # @return [Array<Array<Hash>, Integer>] Liste des choix bien formatés en premier argument et index du choix à sélectionner en second.
  # @params [Array<Hash>] choices Liste des choix pour le select de 
  #                   tty-promp mais où les :name(s) ne sont pas 
  #                   encore réglés. Ici, on va ajouter la valeur et
  #                   régler la longueur pour que tout soit aligné.
  def ultime_mise_en_forme_choices(choices)
    max_len   = 0
    selected  = nil
    choices.each do |dchoix|
      max_len = dchoix[:name].length if dchoix[:name].length > max_len
    end.each do |dchoix|
      dvalue_choix = dchoix[:value]
      next unless dvalue_choix.is_a?(Hash)
      unless dchoix[:raw_name]
        dchoix.merge!(raw_name: dchoix[:name].freeze)
      end
      value = dvalue_choix[:value]
      selected = dvalue_choix[:index] if selected.nil? && value.nil?
      dchoix[:name] = "#{dchoix[:raw_name].ljust(max_len)} : #{value}"
      dchoix[:name] = dchoix[:name].vert unless value.nil?
    end

    return [choices, selected]
  end

  def add_choice(choices, dchoice, simple_key)
    @choice_index ||= 1 # le premier est "Enregistrer"
    @choice_index += 1 
    val = get_value(simple_key)
    choices << {name: dchoice[:name], value: dchoice.merge({value: val, index: @choice_index, simple_key: simple_key}), default: dchoice[:default]}
  end

end #/class SpecialPage
end #/module Prawn4book
