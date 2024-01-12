module Prawn4book

  WARNING_LEVEL_ERROR = 1
  FATAL_LEVEL_ERROR   = 16

# Pour déclencher une erreur de recette
class RecipeError < StandardError
end
class PrawnBuildingError < StandardError; end
class PrawnFatalError < StandardError; end

# Pour pouvoir faire :
#   PFBError[num_error] % {data}
# pour récupérer une erreur défini par FatalPrawForBookError, par
# exemple pour la méthode add_erreur.
class PFBError
  def self.[](err_num)
    "[##{err_num}] #{PFBFatalError.error_by_num(err_num)}"
  end
  def self.context=(value)
    PFBFatalError.context = value
  end
  def self.context_add(value)
    PFBFatalError.context ||= ""
    PFBFatalError.context = "#{PFBFatalError.context}\n#{value}"
  end
end

# Pour produire une erreur fatale par son numéro d'erreur
class PFBFatalError < StandardError

  # Pour ajouter du contexte (c'est-à-dire mieux savoir où se 
  # déclenche et surtout "pour quoi" se déclenche une erreur)
  # 
  # @syntax
  #     
  #   PFBFatalError.context = "<le contexte>"
  # 
  @@context = nil

  def self.context=(value)
    @@context = value
  end
  def self.context; @@context || '' end

  def initialize(err_id, temp_data = {})
    if temp_data.is_a?(Hash) && temp_data[:backtrace] === true
      temp_data.merge!(backtrace: self.class.backtracize(temp_data[:error]))
    end
    err_msg = build_message(err_id, temp_data)
    super(err_msg)
  end

  def build_message(err_id, temp_data)
    err = self.class.error_by_num(err_id)
    err = err % temp_data unless temp_data.nil?
    err = "[##{err_id}] #{err}"
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

  # Numéros d'erreurs à utiliser avec PFBFatalError.new(<num err>, <data>)
  def self.error_by_num(err_id)
    @@error_by_num ||= {
      # -- Base --
      1     => Prawn4book::ERRORS[:app][:require_a_book_or_collection],
      2     => Prawn4book::ERRORS[:errors][:bad_custom_errid],
      # -- Book --
      10    => Prawn4book::ERRORS[:book][:not_in_collection],
      11    => Prawn4book::ERRORS[:book][:require_margins_definition],
      # -- Fichier texte --
      50    => Prawn4book::ERRORS[:textfile][:unfound_text_file],
      # -- Paragraphes --
      100   => Prawn4book::ERRORS[:paragraph][:print][:unknown_error],
      101   => Prawn4book::ERRORS[:paragraph][:bad_ruby_code],
      102   => Prawn4book::ERRORS[:paragraph][:unfound_puce_image],
      103   => Prawn4book::ERRORS[:paragraph][:formate][:unknown_method],
      104   => Prawn4book::ERRORS[:paragraph][:unable_to_instantiate_with_type],
      105   => Prawn4book::ERRORS[:paragraph][:note_undefined],
      # -- Construction --
      150   => Prawn4book::ERRORS[:building][:bat_fatal_error],
      151   => Prawn4book::ERRORS[:building][:bat_no_margins],
      152   => Prawn4book::ERRORS[:building][:bat_no_grid],
      # -- Multi-colonnes --
      180   => Prawn4book::ERRORS[:multicolumns][:extra_segment_unresolved],
      181   => Prawn4book::ERRORS[:multicolumns][:extra_segment_resolved],
      # -- Pages --
      200   => Prawn4book::ERRORS[:pages][:unfound],
      201   => Prawn4book::ERRORS[:pages][:credits][:notfit],
      202   => Prawn4book::ERRORS[:pages][:credits][:unable_to_reduce],
      203   => Prawn4book::ERRORS[:pages][:credits][:disposition_unknown],
      # -- Images --
      250   => Prawn4book::ERRORS[:images][:unfound],
      252   => Prawn4book::ERRORS[:images][:logo_page_title_unfound],
      253   => Prawn4book::ERRORS[:images][:passage_sous_page],
      254   => Prawn4book::ERRORS[:images][:floating_text_under_zero],
      255   => Prawn4book::ERRORS[:images][:floating_image_too_big],
      256   => Prawn4book::ERRORS[:images][:floating_image_with_no_text],
      # -- Commandes (divers) --
      300   => Prawn4book::ERRORS[:commands][:open][:dont_know_how_to],
      301   => Prawn4book::ERRORS[:commands][:calc][:dont_know_how_to],
      # -- Recette (voir aussi en 800) ---
      499   => Prawn4book::ERRORS[:recipe][:missing_even_default_data],
      500   => Prawn4book::ERRORS[:recipe][:credits_page][:require_info],
      610   => Prawn4book::ERRORS[:recipe][:credits_page][:bad_font_definition],
      # -- Fontes --
      650   => Prawn4book::ERRORS[:fonts][:leading_must_be_calculated],
      651   => Prawn4book::ERRORS[:fonts][:require_property],
      652   => Prawn4book::ERRORS[:fonts][:bad_formatted_data],
      653   => Prawn4book::ERRORS[:fonts][:bad_formatted_color],
      654   => Prawn4book::ERRORS[:fonts][:line_height_smaller_than_default_size],
      # -- Bibliographies --
      700   => Prawn4book::ERRORS[:biblio][:unfound],
      701   => Prawn4book::ERRORS[:biblio][:biblio_undefined],
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
      # -- Table des matières --
      850   => Prawn4book::ERRORS[:toc][:problem_with_title],
      851   => Prawn4book::ERRORS[:toc][:cannotfit_error],
      852   => Prawn4book::ERRORS[:toc][:write_on_non_empty_page],
      853   => Prawn4book::ERRORS[:toc][:must_add_even_pages_count],
      # -- Modules ---
      1000  => Prawn4book::ERRORS[:parsing][:class_tag_formate_method_required],
      1001  => Prawn4book::ERRORS[:unknown_pfbcode],
      1002  => Prawn4book::ERRORS[:parsing][:unknown_method],
      1100  => Prawn4book::ERRORS[:modules][:runtime_error],
      # -- Références --
      2000  => Prawn4book::ERRORS[:references][:no_lien_seul_on_line],
      2001  => Prawn4book::ERRORS[:references][:target_already_exists],
      2002  => Prawn4book::ERRORS[:references][:target_undefined],
      2003  => Prawn4book::ERRORS[:references][:no_num_parag_in_pfbcode],
      # -- Abréviations --
      2100  => Prawn4book::ERRORS[:abbreviations][:two_definitions],
      # -- Index Personnalisés --
      2500  => Prawn4book::ERRORS[:index][:invalid],
      2501  => Prawn4book::ERRORS[:index][:missing_item_treatment_method],
      2502  => Prawn4book::ERRORS[:index][:bad_params_count_in_item_treatment_method],
      2503  => Prawn4book::ERRORS[:index][:missing_print_method],
      2504  => Prawn4book::ERRORS[:index][:bad_params_count_in_print_method],
      # -- Tables --
      3000  => Prawn4book::ERRORS[:table][:can_not_fit],
      # -- Modules utilisateurs personnalisés --
      5000  => Prawn4book::ERRORS[:user_modules][:runtime_error],
      5001  => Prawn4book::ERRORS[:user_modules][:unknown_objet],
      5002  => Prawn4book::ERRORS[:user_modules][:unknown_method],
      5003  => Prawn4book::ERRORS[:user_modules][:wrong_arguments_count],
      # -- Divers --
      6000  => Prawn4book::ERRORS[:string][:pps_require_ref_for_pourcent],
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

end #/class PFBFatalError


# - Raccourci, notamment pour @context -
# Pour faire : PFBContextError.call("Le contexte")
PFBContextError = PFBFatalError.method(:context=)


end #/module Prawn4book
