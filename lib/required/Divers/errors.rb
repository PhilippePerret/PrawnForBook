# Pour déclencher une erreur de recette
class RecipeError < StandardError
end
class PrawnBuildingError < StandardError; end
class PrawnFatalError < StandardError; end

# Pour produire une erreur fatale par son numéro d'erreur
class FatalPrawForBookError < StandardError
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

  def error_by_num(err_id)
    @errors_by_num ||= {
      # -- Recette(s) ---
      500   => Prawn4book::ERRORS[:recipe][:page_infos][:require_info],
      610   => Prawn4book::ERRORS[:recipe][:page_infos][:bad_font_definition],
      # -- Tables --
      3000  => Prawn4book::ERRORS[:table][:can_not_fit],
      # -- Bibliographies --
      710   => Prawn4book::ERRORS[:biblio][:malformation][:title_undefined],
      711   => Prawn4book::ERRORS[:biblio][:malformation][:path_undefined],
      712   => Prawn4book::ERRORS[:biblio][:malformation][:path_unfound],
      713   => Prawn4book::ERRORS[:biblio][:bibitem][:requires_title],
      730   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count],
      731   => Prawn4book::ERRORS[:biblio][:bibitem][:bad_arguments_count_biblio],
      740   => Prawn4book::ERRORS[:biblio][:custom_format_method_error],
      # -- Modules ---
      1000  => Prawn4book::ERRORS[:parsing][:class_tag_formate_method_required],
      1001  => Prawn4book::ERRORS[:unknown_pfbcode],
      1100  => Prawn4book::ERRORS[:modules][:runtime_error],
    }
    @errors_by_num[err_id]
  end

end
