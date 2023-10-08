module Prawn4book

# Pour déclencher une erreur de recette
class RecipeError < StandardError
end
class PrawnBuildingError < StandardError; end
class PrawnFatalError < StandardError; end

# Pour produire une erreur fatale par son numéro d'erreur
class FatalPrawnForBookError < StandardError
  def initialize(err_id, temp_data = nil)
    err_msg = build_message(err_id, temp_data)
    super(err_msg)
  end

  def build_message(err_id, temp_data)
    err = error_by_num(err_id)
    err = err % temp_data unless temp_data.nil?
    err = "[#{err_id}] #{err}"
    return err
  end

  # Réduit le backtrace pour :
  #   - n'afficher que les 5 derniers lieux
  #   - réduire les chemins d'accès (en distinguant bien les
  #     module personnalisés des modules de PrawnForBook)
  def self.backtracize(err)
    err.backtrace[0..4].collect do |b| 
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

  def error_by_num(err_id)
    @errors_by_num ||= {
      # -- Base --
      1     => Prawn4book::ERRORS[:app][:require_a_book_or_collection],
      # -- Paragraphes --
      100   => Prawn4book::ERRORS[:paragraph][:print][:unknown_error],
      200   => Prawn4book::ERRORS[:paragraph][:formate][:unknown_method],
      # -- Recette(s) ---
      499   => Prawn4book::ERRORS[:recipe][:missing_even_default_data],
      800   => Prawn4book::ERRORS[:recipe][:book_data][:require_title],
      801   => Prawn4book::ERRORS[:recipe][:book_data][:require_author],
      802   => Prawn4book::ERRORS[:recipe][:book_data][:unfound_logo],
      500   => Prawn4book::ERRORS[:recipe][:page_infos][:require_info],
      610   => Prawn4book::ERRORS[:recipe][:page_infos][:bad_font_definition],
      # -- Tables --
      3000  => Prawn4book::ERRORS[:table][:can_not_fit],
      # -- Références --
      2000  => Prawn4book::ERRORS[:references][:no_lien_seul_on_line],
      # -- Bibliographies --
      710   => Prawn4book::ERRORS[:biblio][:malformation][:title_undefined],
      711   => Prawn4book::ERRORS[:biblio][:malformation][:path_undefined],
      712   => Prawn4book::ERRORS[:biblio][:malformation][:path_unfound],
      713   => Prawn4book::ERRORS[:biblio][:bibitem][:requires_title],
      714   => Prawn4book::ERRORS[:biblio][:bibitem][:undefined],
      730   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count],
      731   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count_biblio],
      740   => Prawn4book::ERRORS[:biblio][:custom_format_method_error],
      # -- Modules ---
      1000  => Prawn4book::ERRORS[:parsing][:class_tag_formate_method_required],
      1001  => Prawn4book::ERRORS[:unknown_pfbcode],
      1002  => Prawn4book::ERRORS[:parsing][:unknown_method],
      1100  => Prawn4book::ERRORS[:modules][:runtime_error],
      # -- Modules utilisateurs personnalisés --
      5000  => Prawn4book::ERRORS[:user_modules][:runtime_error],
    }
    @errors_by_num[err_id]
  end

end

end #/module Prawn4book
