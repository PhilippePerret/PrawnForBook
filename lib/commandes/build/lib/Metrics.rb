# =begin

#   Ce module est pensé pour être le seul à gérer toutes les 
#   mesures du livre, à commencer par les fonts.
#   OBSOLÈTE
#   On s’en sert maintenant uniquement pour certains calculs

# =end
module Prawn4book
class Metrics
class << self

  # Méthode qui calcule et renvoie les 4 marges, quand elles ne sont
  # pas définies dans la recette, fonction des dimensions du livre
  # Un message d’avertissement est donné à l’utilisateur quand c’est
  # le cas, et c’est même un message d’erreur fatal en mode BAT
  # 
  # Données récupérées
  # ------------------
  #   11 cm x 17 cm   => 1.25 cm + 0.5 cm de reliure (marge int.)
  #   21 cm x 29.7 cm => 2 cm + 0.6 cm de reliure
  #   15 cm x 21 cm   => 1.5 cm à 2.5 cm + 0.5 de reliure
  # 
  #   2.5 pour marge haut et marge bas jusqu’à ??? (hauteur livre)
  #   2.0 idem jusqu’à ? (hauteur livre)
  # 
  #   1.5 à 2.0 pour marge extérieur
  #   2.0 à 2.5 pour marge intérieur 
  # 
  # Retenues
  # --------
  #   Marge intérieure
  #     2.0 cm pour largeur <= 15 cm
  #     2.5 cm pour largeur >  15 cm
  # 
  #   Marge extérieure
  #     1.5 cm pour largeur <= 15 cm
  #     2.0 cm pour largeur >  15 cm
  # 
  #   Marge haute et basse
  #     1.75 cm pour hauteur <= 17 cm
  #     2.00 cm pour hauteur 17 cm < h < 21 cm
  #     2.50 cm pour hauteur 21 cm < h
  # 
  # 
  # @param book [Prawn4book::PdfBook]
  #     Attention, ça n’est pas forcément le livre, ça peut être
  #     aussi la collection, peut-être (même si je ne suis plus 
  #     sûr que la collection passe par la recette)
  # 
  # @return [Hash] {:top, :bot, :ext, :int} Table des valeurs des
  # marges.
  # 
  def calc_margins_for(book)
    rec = book.recipe

    mm15  = '15mm'.to_pps
    mm175 = '17.5mm'.to_pps
    mm20  = '20mm'.to_pps
    mm25  = '25mm'.to_pps
    cm15  = '15cm'.to_pps
    cm17  = '17cm'.to_pps
    cm21  = '21cm'.to_pps

    page_width  = rec.book_width
    page_height = rec.book_height

    marges = {}

    if page_width > cm15
      marges.merge!(int: mm25, ext: mm20)
    else
      marges.merge!(int: mm20, ext: mm15)
    end

    if page_height > cm21
      marges.merge!(top: mm25, bot: mm25)
    elsif page_height > cm17
      marges.merge!(top: mm20, bot: mm20)
    else
      marges.merge!(top: mm175, bot: mm175)
    end

    make_error_message(book, marges)

    return marges
  end

  def make_error_message(book, default_margins)
    return if @message_missing_margins_done === true
    missings      = []
    margs_setting = {}
    format_page = book.recipe.format_page
    if format_page[:margins]
      TERMS[:les_marges_] % [:top, :bot, :ext, :int].select do |s|
        v =
          if format_page[:margins][s].nil?
            missings << s
            default_margins[s]
          else
            format_page[:margins][s]
          end
        margs_setting.merge!(s => v)
      end
    else
      # Les 4 sont manquantes
      missings = [:top, :bot, :ext, :int]
      margs_setting = default_margins.dup
    end
    add_fatal_error(PFBError[11] % {
      missings: missings.join(', '), margins: margs_setting.inspect,
      missings_yaml: missings.map{|s| "      #{s}: ..."}.join("\n")
    }, nil, true)
    @message_missing_margins_done = true
  end

end #<< self
end #/class Metric
end #/module Prawn4book
