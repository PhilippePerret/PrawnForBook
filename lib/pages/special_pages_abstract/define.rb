=begin
  
  Méthodes communes pour la définition de la page

=end
module Prawn4book
class SpecialPage

  def define
    while true
      clear
      puts "Assistant #{page_name}\n".bleu
      data_choix = Q.select("Définir :".jaune, choices_properties, {per_page:choices_properties.count})
      case data_choix
      when NilClass then return
      when :save
        save_recipe_data
        break
      else
        # Propriété à définir
        value = edit_value(data_choix)
        data_choix[:value] = value
        # choices_properties[data_choix[:index]][:value] = data_choix
        choices_properties[data_choix[:index]][:name] = "#{data_choix[:name]} : #{value}"
        set_current_value_for(data_choix[:simple_key], value)
      end
    end
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

  # @return [Array<Hash>] La liste des choix de propriétés
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
      [{name: PROMPTS[:save], value: :save}] + choices + [ {name:PROMPTS[:cancel].rouge, value:nil} ]
    end
  end

  def add_choice(choices, dchoice, simple_key)
    @choice_index ||= 0
    @choice_index += 1 # le premier est "Enregistrer"
    val = get_current_value_for(simple_key) || dchoice[:default]
    choices << {name: "#{dchoice[:name]} : #{val}", value: dchoice.merge({value: val, index: @choice_index, simple_key: simple_key}), default: dchoice[:default]}
  end


end #/class SpecialPage
end #/module Prawn4book
