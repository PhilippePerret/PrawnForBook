require './lib/modules/tty_facilitators'
module Prawn4book
class Assistant
  # --- Point d'entrée pour l'assistant à la maison d'édition ---
  def self.assistant_publisher(owner, options = nil)
    AssistantPublisher.new(owner).define_publisher(options)
  end

class AssistantPublisher
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  def define_publisher(options = nil)
    dpublisher = owner.recipe.publisher
    if tty_define_object_with_data(DATA_PUBLISHING, dpublisher || {})
      owner.recipe.insert_bloc_data('publisher', dpublisher)
    end
  end

  # Type
  def url(value)
    value = "https://#{value}" unless value.start_with?('http')
    return value
  end

  def logo_exist?(value, dpublisher)
    return true if value.nil? || value.empty? || value == '---'
    logo_path = File.join(owner.folder, value)
    return true if File.exist?(logo_path)
    puts (ERRORS[:publisher][:logo_unfound] % logo_path).rouge
    if Q.yes?(PROMPTS[:publisher][:ask_move_logo].jaune)
      err = nil
      while true
        # - S'il y a un message d'erreur -
        puts err.rouge unless err.nil?
        # - Attendre le chemin d'accès -
        begin
          logo_original = Q.ask("#{PROMPTS[:publisher][:ask_for_logo_original_path]} : ".jaune)
        rescue TTY::Reader::InputInterrupt
          return false
        end
        if logo_original && File.exist?(logo_original)
          if File.extname(logo_original) != File.extname(logo_path)
            err = ERRORS[:publisher][:logo_not_same_extname]
          else
            mkdir(File.dirname(logo_path))
            FileUtils.cp(logo_original, logo_path)
            return true
          end
        end
        err = ERRORS[:publisher][:logo_unfound] % logo_original
        logo_original = nil
      end
    else
      return false
    end
  end

DATA_PUBLISHING = [
  {name:'Nom de l’éditeur'                , value: :name    , default: nil},
  {name:'Adresse (lignes avec \n)'        , value: :adresse },
  {name:'Site internet'                   , type: :url      , default: nil, value: :site},
  {name:'Logo (chemin dans dossier)'      , value: :logo_path, valid_if: :logo_exist?},
  {name:'Numéro SIRET'                    , value: :siret},
  {name:'Mail général'                    , value: :mail},
  {name:'Mail de contact'                 , value: :contact},
]

end #/class AssistantPublisher
end #/class Assistant
end #/module Prawn4book
