require 'lib/modules/tty_facilitators'

module Prawn4book
class Assistant

  # --- Assistant pour les bibliographies ---

  def self.assistant_biblios(owner)
    AssistantBiblio.new(owner).define_biblios
  end

class AssistantBiblio
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  ##
  # Méthode principale pour définir les données bibliographiques
  # (en fait, les bibliographies)
  # 
  def define_biblios
    # 
    # Un message de présentation pour rappeler ce qu'est une 
    # bibliographie dans Prawn-for-book
    # 
    puts MESSAGES[:biblio][:intro_assistant].bleu
    # 
    # Pour savoir s'il y a eu des modifications
    # 
    has_changements = false
    # 
    # Boucle tant qu'on veut définir les données
    # 
    while true
      clear unless debug?
      # 
      # Les choix
      #
      choices = choices_biblios(has_changements)
      # 
      # Un menu contenant les bibliographies déjà définies ainsi qu'un
      # bouton pour en créer une nouvelle
      # 
      case (bib_id = Q.select("#{PROMPTS[:Edit]} : ".jaune, choices, {per_page:choices.count, show_help: false}))
      when :finir
        if has_changements
          no = Q.no?("Voulez-vous perdre vraiment tous les changements ?".jaune)
          break unless no
        else
          break
        end
      when :save
        # Enregistrer les données
        owner.recipe.insert_bloc_data('biblios', biblios_data)
        break
      when :new
        # Pour créer une nouvelle bibliographie
        has_changements = true if edit_biblio(nil)
      else
        # Pour éditer une bibliographie
        has_changements = true if edit_biblio(biblios_data[bib_id])
      end
    end
    clear unless debug?
  end

  ##
  # Méthode principale pour éditer une bibliographie, ou la
  # créer si c'est nécessaire.
  # 
  # @return [Boolean] true si tout s'est bien passé
  # 
  def edit_biblio(data_biblio)
    # 
    # Pour savoir s'il s'agit d'une nouvelle disposition
    # 
    is_new_biblio = data_biblio.nil?
    data_biblio = {} if is_new_biblio
    data_biblio.merge!(is_new: is_new_biblio)
    # 
    # On utilise le facilitateur
    # 
    ok = tty_define_object_with_data(DATA_BIBLIO, data_biblio)
    # 
    # Si c'est une nouvelle bibliographaphie, on l'enregistre
    # dans les données.
    # 
    if ok && is_new_biblio
      @biblios_data.merge!(data_biblio[:tag] => data_biblio)
    end

  end

  # Test la validité du tag fourni.
  # 
  # @return [NilClass|String] nil si le tag est valide et le message
  # d'erreur otherwise.
  # 
  def tag_invalid?(tag, data_biblio)
    is_new = data_biblio[:is_new] === true
    # 
    # Ce tag doit être unique
    # 
    if is_new 
      raise ERRORS[:biblio][:tag_already_exists] if biblios_data.key?(tag)
    end
    tag.to_s.gsub(/[a-z]/,'') == '' || raise(ERRORS[:biblio][:bad_tag])
    if tag.to_s[-1] == 's'
      puts ERRORS[:biblio][:warn_end_with_s].orange
      sleep 5
    end
  rescue Exception => e
    return e.message
  else
    return nil # OK
  end

  def choices_biblios(has_changements)
    pre_menus = []
    pre_menus << {name:PROMPTS[:save].bleu, value: :save} if has_changements
    pre_menus << {name:PROMPTS[:biblio][:new_one].bleu, value: :new}
    pre_menus + 
    biblios_data.map do |biblio_id, biblio_data|
      {name: biblio_data[:title].upcase, value: biblio_id}
    end + [
      {name:PROMPTS[:finir].bleu, value: :finir}
    ]
  end

  # @return [Hash<Hash>] Table des bibliographies définies
  def biblios_data
    @biblios_data ||= owner.recipe.biblios_data
  end

DATA_BIBLIO = [
  {name: 'Titre (tel qu’affiché dans le livre)' , value: :title, required:true},
  {name: "ID (aka \"tag\", au singulier)"       , value: :tag, type: :sym, invalid_if: :tag_invalid?, required:true},
  {name: "Niveau de titre"                      , value: :title_level, type: :int},
  {name: "Bibliographie sur nouvelle page ?"    , value: :new_page, type: :bool},
  {name: 'Accès aux données (si autre que ./biblios/<tag>)', value: :data, type: :path}
]



end #/class AssistantBiblio
end #/class Assistant
end #/module Prawn4book
