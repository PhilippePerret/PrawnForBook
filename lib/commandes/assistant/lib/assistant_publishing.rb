require 'lib/modules/tty_facilitators'
module Prawn4book
class Assistant
  # --- Point d'entrée pour l'assistant à la maison d'édition ---
  def self.assistant_publishing(owner, options = nil)
    AssistantPublishing.new(owner).define_publishing(options)
  end

class AssistantPublishing
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  def define_publishing(options = nil)
    dpublishing = owner.recipe.publishing
    if tty_define_object_with_data(DATA_PUBLISHING, dpublishing)
      owner.recipe.insert_bloc_data('publishing', dpublishing)
    end
  end

  def logo_exist?(value, dpublishing)
    logo_path = File.join(owner.folder, value)
    return true if File.exist?(logo_path)
    puts (ERRORS[:publishing][:logo_unfound] % logo_path).rouge
    if Q.yes?(PROMPTS[:publishing][:ask_move_logo].jaune)
      err = nil
      while true
        # - S'il y a un message d'erreur -
        puts err.rouge unless err.nil?
        # - Attendre le chemin d'accès -
        begin
          logo_original = Q.ask("#{PROMPTS[:publishing][:ask_for_logo_original_path]} : ".jaune)
        rescue TTY::Reader::InputInterrupt
          return false
        end
        if logo_original && File.exist?(logo_original)
          if File.extname(logo_original) != File.extname(logo_path)
            err = ERRORS[:publishing][:logo_not_same_extname]
          else
            mkdir(File.dirname(logo_path))
            FileUtils.cp(logo_original, logo_path)
            return true
          end
        end
        err = ERRORS[:publishing][:logo_unfound] % logo_original
        logo_original = nil
      end
    else
      return false
    end
  end

DATA_PUBLISHING = [
  {name:'Nom de l’éditeur'                , default: 'Mes Éditions', value: :name},
  {name:'Adresse (lignes avec \n)'        , value: :adresse },
  {name:'Site internet'                   , type: :url, default: nil, value: :site},
  {name:'Logo (chemin dans dossier)'      , value: :logo_path, valid_if: :logo_exist?},
  {name: 'Numéro SIRET'                   , value: :siret},
  {name: 'Mail général'                   , value: :mail},
  {name:'Mail de contact'                 , value: :contact},

]

end #/class AssistantPublishing
end #/class Assistant
end #/module Prawn4book
