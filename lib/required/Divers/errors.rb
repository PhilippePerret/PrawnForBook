module Prawn4book

# Pour déclencher une erreur de recette
class RecipeError < StandardError
end
class PrawnBuildingError < StandardError; end
class PrawnFatalError < StandardError; end

# Pour pouvoir faire :
#   Prawn4bookError[num_error] % {data}
# pour récupérer une erreur défini par FatalPrawForBookError, par
# exemple pour la méthode add_erreur.
class Prawn4bookError
  def self.[](err_num)
    FatalPrawnForBookError.error_by_num(err_num)
  end
end

# Pour produire une erreur fatale par son numéro d'erreur
class FatalPrawnForBookError < StandardError

  # Pour ajouter du contexte (c'est-à-dire mieux savoir où se 
  # déclenche et surtout "pour quoi" se déclenche une erreur)
  # 
  @@context = nil

  def self.context=(value)
    @@context = value
  end
  def self.context; @@context || '' end

  def initialize(err_id, temp_data = nil)
    if temp_data[:backtrace] === true
      temp_data.merge!(backtrace: self.class.backtracize(temp_data[:error]))
    end
    err_msg = build_message(err_id, temp_data)
    super(err_msg)
  end

  def build_message(err_id, temp_data)
    err = self.class.error_by_num(err_id)
    err = err % temp_data unless temp_data.nil?
    err = "[#{err_id}] #{err}"
    if self.class.context
      err = "#{err}\nContext:\n-------\n#{self.class.context}"
    end
    return err
  end

  # Réduit le backtrace pour :
  #   - n'afficher que les 7 dernières traces
  #   - réduire les chemins d'accès (en distinguant bien les
  #     module personnalisés des modules de PrawnForBook)
  def self.backtracize(err)
    err.backtrace[0..6].collect do |b| 
      b.sub(/#{APP_FOLDER}/.freeze, '<pfb>')
        .sub(/#{folder_for_backtrace}/.freeze, origine_for_backtrace)      
    end.join("\n  ")
  end

  # @return [String] Le dossier à considérer pour réduire les
  # chemin d'accès concernant les modules de la collection ou
  # du livre.
  def self.folder_for_backtrace
    @@folder_for_backtrace ||= if book.in_collection?
        book.collection.folder
      else
        book.folder
      end
  end
  # @return [String] '<collection>' ou '<book>' pour indiquer
  # d'où vient le(s) module(s) ayant généré l'erreur.
  def self.origine_for_backtrace
    @@origine_for_backtrace ||= if book.in_collection?
      '<collection>'
    else
      '<book>'
    end
  end

  # @return [String] Le nom du module (fichier) ayant généré
  # l'erreur en dernier. C'est normalement le module utilisateur
  # comme formater.rb ou helpers.rb
  def self.get_last_script(err)
    pth, numline, meth = err.backtrace.first.split(':')
    File.basename(pth)
  end

  # Le livre courant
  def self.book
    @@book ||= Prawn4book::PdfBook.current
  end

  # Numéros d'erreurs à utiliser avec FatalPrawnForBookError.new(<num err>, <data>)
  def self.error_by_num(err_id)
    @@error_by_num ||= {
      # -- Base --
      1     => Prawn4book::ERRORS[:app][:require_a_book_or_collection],
      2     => Prawn4book::ERRORS[:errors][:bad_custom_errid],
      # -- Book --
      10    => Prawn4book::ERRORS[:book][:not_in_collection],
      # -- Fichier texte --
      50    => Prawn4book::ERRORS[:textfile][:unfound_text_file],
      # -- Paragraphes --
      100   => Prawn4book::ERRORS[:paragraph][:print][:unknown_error],
      101   => Prawn4book::ERRORS[:paragraph][:bad_ruby_code],
      102   => Prawn4book::ERRORS[:paragraph][:unfound_puce_image],
      200   => Prawn4book::ERRORS[:paragraph][:formate][:unknown_method],
      # -- Commandes (divers) --
      300   => Prawn4book::ERRORS[:commands][:open][:dont_know_how_to],
      # -- Recette (voir aussi en 800) ---
      499   => Prawn4book::ERRORS[:recipe][:missing_even_default_data],
      500   => Prawn4book::ERRORS[:recipe][:page_infos][:require_info],
      610   => Prawn4book::ERRORS[:recipe][:page_infos][:bad_font_definition],
      # -- Fontes --
      650   => Prawn4book::ERRORS[:fonts][:leading_must_be_calculated],
      651   => Prawn4book::ERRORS[:fonts][:require_style],
      652   => Prawn4book::ERRORS[:fonts][:bad_formatted_data],
      # -- Bibliographies --
      700   => Prawn4book::ERRORS[:biblio][:unfound],
      710   => Prawn4book::ERRORS[:biblio][:malformation][:title_undefined],
      711   => Prawn4book::ERRORS[:biblio][:malformation][:path_undefined],
      712   => Prawn4book::ERRORS[:biblio][:malformation][:path_unfound],
      713   => Prawn4book::ERRORS[:biblio][:bibitem][:requires_title],
      714   => Prawn4book::ERRORS[:biblio][:bibitem][:undefined],
      730   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count],
      731   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count_biblio],
      740   => Prawn4book::ERRORS[:biblio][:custom_format_method_error],
      # -- Recette(s) ---
      800   => Prawn4book::ERRORS[:recipe][:book_data][:require_title],
      801   => Prawn4book::ERRORS[:recipe][:book_data][:require_author],
      802   => Prawn4book::ERRORS[:recipe][:book_data][:unfound_logo],
      # -- Modules ---
      1000  => Prawn4book::ERRORS[:parsing][:class_tag_formate_method_required],
      1001  => Prawn4book::ERRORS[:unknown_pfbcode],
      1002  => Prawn4book::ERRORS[:parsing][:unknown_method],
      1100  => Prawn4book::ERRORS[:modules][:runtime_error],
      # -- Références --
      2000  => Prawn4book::ERRORS[:references][:no_lien_seul_on_line],
      2001  => Prawn4book::ERRORS[:references][:target_already_exists],
      2002  => Prawn4book::ERRORS[:references][:target_undefined],
      # -- Tables --
      3000  => Prawn4book::ERRORS[:table][:can_not_fit],
      # -- Modules utilisateurs personnalisés --
      5000  => Prawn4book::ERRORS[:user_modules][:runtime_error],
      5001  => Prawn4book::ERRORS[:user_modules][:unknown_objet],
      5002  => Prawn4book::ERRORS[:user_modules][:unknown_method],
      5003  => Prawn4book::ERRORS[:user_modules][:wrong_arguments_count],
      # 
      # 20 000 à 30 000 : réservés au livre/collection
    }
    @@error_by_num[err_id]
  end

  # Pour ajouter des erreurs, soit avec un Hash, soit une seule 
  # erreur.
  def self.add_errors(key, message = nil)
    if not(key.is_a?(Hash))
      key = {key => message}
    end
    key.each do |k, msg|
      if error_by_num(k) 
        raise new(2, {n: k.to_s})
      else
        @@error_by_num.merge!(k => msg)
      end
    end
  end
  class << self
    alias :add_error :add_errors
  end

end #/class FatalPrawnForBookError


# - Raccourci, notamment pour @context -
# Pour faire : PFBContextError.call("Le contexte")
PFBContextError = FatalPrawnForBookError.method(:context=)
# Pour faire : PFBError.context = "Le contexte"
PFBError = FatalPrawnForBookError

end #/module Prawn4book
