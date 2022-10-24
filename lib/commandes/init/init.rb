module Prawn4book

# ::runner
class Command
  def proceed
    PdfBook.init_new_book_or_collection
  end
end #/Command

class PdfBook

  ##
  # = main =
  # 
  # Méthode principale pour définir la recette du livre
  # Soit on demande simplement un template, soit on utilise
  # l'assistant, mais il n'est pas tout à fait à jour.
  # 
  # @param cdata {Hash|Nil} Les données qui peuvent permettre de
  # définir des premières chose sur le livre dont il faut définir ou
  # redéfinir la recette.
  # 
  def self.init_new_book_or_collection(cdata = nil, force = false)
    clear
    what = choose_what_to_init || return
    case choose_how_to_init(what)
    when NilClass
      return false
    when :assistant
      init_with_assistant(cdata.merge!(what: what), force)
    when :template
      init_par_templates(what: what)
    end
  end

  #
  # --- PAR TEMPLATE ---
  # 
  def self.init_par_templates(cdata)
    require_folder(File.join(COMMAND_FOLDER,'lib','par_templates'))
    proceed_init_par_templates(cdata)
  end

  #
  # --- PAR ASSISTANT ---
  # 
  # Assistant qui permet de définir la recette du livre ou de la
  # collection
  # 
  def self.init_with_assistant(cdata = nil, force = false)
    require_folder(File.join(COMMAND_FOLDER,'lib','par_assistant'))
    proceed_init_with_assistant(cdata, force)
  end

  # 
  # Pour demander quoi initier ? (livre ou collection)
  # 
  # @return :book ou :collection
  def self.choose_what_to_init
    Q.select("\nQue dois-je faire du dossier courant (#{File.basename(cfolder)}) ".jaune, TYPE_INITIED, per_page: TYPE_INITIED.count) || return
  end

  def self.choose_how_to_init(what)
    thing = what == :book ? 'le livre' : 'la collection'
    Q.select("Comment voulez-vous initier #{thing} ?".jaune, DEFINE_RECIPE_WAYS, per_page: DEFINE_RECIPE_WAYS.count)
  end


  # ---- MÉTHODES GÉNÉRIQUES ----

  # def self.is_defined_or_define(prop, cdata)
  #   if not(cdata.key?(prop)) || cdata[prop] === nil
  #     return send("define_#{prop}".to_sym, cdata)
  #   else
  #     return true
  #   end
  # end


DEFINE_RECIPE_WAYS = [
  {name:'En copiant des modèles dans le dossier', value: :template},
  {name:'Avec un assistant pour définir chaque chose', value: :assistant},
  {name:'Renoncer', value: nil}
]

end #/class PdfBook
end #/module Prawn4book
