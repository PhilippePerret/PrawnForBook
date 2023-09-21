=begin

  Commande 'build'
  Commande principale qui construit le livre à partir de la recette
  et du texte fourni.

=end
module Prawn4book
class Command
  #
  # Méthode appelée quand on doit construire le livre (`pfb build')
  # 
  def proceed
    PdfBook.current.generate_pdf_book
  end
end #/Command
class PdfBook

  # Pour exposer les données des pages (à commencer par les
  # paragraphes et les longueurs de texte)
  attr_reader :pages

  # Pour exposer les titres courants par niveau en cours
  # de fabrication (pour alimenter la données pages et 
  # permettre ensuite le traitement des pieds de page et
  # entêtes)
  attr_reader :current_titles

  # @prop Instance {Prawn4book::PdfHelpers}
  attr_reader :pdfhelpers

  # [ARRAY] Liste des numéros de pages qui ne doivent pas être
  # numérotées même si elles ont du contenu (par défaut par exemple,
  # la page de faux-titre, la page d'infos du livre, mais n'importe
  # quelle page peut être sans numérotation — cf. le manuel)
  attr_reader :pages_without_pagination

  def generate_pdf_book
    spy "Génération du livre #{ensured_title.inspect}".bleu
    # 
    # Initialiser le suivi des titres par niveau
    # 
    @current_titles = {}

    # 
    # --- INITIALISATIONS ---
    # 

    # - Bibliographies -
    require 'lib/pages/bibliographies'
    Bibliography.init
    # - paragraphes texte -
    PdfBook::AnyParagraph.init_first_turn
    # - table de références -
    table_references.init

    #
    # On requiert tous les parseurs/formateurs personnalisés
    # 
    require_custom_parsers_formaters

    #
    # S'il existe une méthode de reset propre au livre ou à la 
    # collection, on l'invoque
    # 
    Prawn4book.reset(true) if Prawn4book.respond_to?(:reset)

    #
    # On doit parser le texte avant pour voir si le livre est
    # conforme
    # 
    spy "-> PARSE DU TEXTE".bleu
    inputfile.parse
    spy "<- /PARSE DU TEXTE".bleu

    #
    # Le livre doit être conforme, c'est-à-dire posséder les 
    # éléments requis
    # 
    conforme? || return

    # 
    # = PREMIÈRE PASSE =
    # 
    # Pour récupérer les références (if any)
    # (il y en aura 2 si des références avant sont trouvées)
    # 
    ok_book = build_pdf_book

    # 
    # Si des références ont été trouvées, on actualise le fichier
    # des références du livre.
    # 
    table_references.save if table_references.any?

    # 
    # = DEUXIÈME PASSE =
    # 
    # Si des appels de références avant ont été trouvées, on refait
    # une passe pour les appliquer.
    # 
    if table_references.has_one_appel_sans_reference?
      #
      # S'il existe une méthode de reset propre au livre ou à la 
      # collection, on l'invoque
      # 
      Prawn4book.reset(false) if Prawn4book.respond_to?(:reset)

      table_references.second_turn = true
      PdfBook::AnyParagraph.init_second_turn
      #
      # Construction finale du livre
      # (mais elle peut se faire à la première passe s'il n'y a
      #  pas de références arrières)
      # 
      ok_book = build_pdf_book
    end

    #
    # S'il faut ouvrir le livre
    # 
    open_book if CLI.option(:open) && ok_book

  end

  ##
  # = main =
  # 
  # Méthode principale pour générer le PDF du livre
  # Elle prépare le document Prawn::View (PrawnView) et boucle
  # sur tous les paragraphes du texte pour les formater et les
  # ajouter au PDF en les parsant/helpant/formatant.
  # 
  # @note
  #   PrawnView hérite de Prawn::View (comme conseillé par le code de Prawn.
  # 
  def build_pdf_book
    clear unless debug?
    
    # 
    # Détruire le fichier PDF final s'il existe déjà
    # (note : il existe toujours si c'est un deuxième tour)
    # 
    File.delete(pdf_path) if File.exist?(pdf_path)

    #
    # Pour consigner les erreurs mineures en cours de construction
    # 
    PrawnView::Error.reset

    my = self

    #
    # Avec Prawn::View au lieu d'étendre Prawn::Document
    #    
    pdf = PrawnView.new(self, pdf_config)

    #
    # Pour mettre les pages qu'il faut garder sans numéro
    # 
    @pages_without_pagination = []

    #
    # Méthode appelée automatiquement à chaque création de page
    # dans le livre.
    # 
    pdf.on_page_create do
      # puts "Nouvelle page créée : #{pdf.page_number}".orange
      my.add_page(pdf.page_number)
    end

    # pdf.before_render do
    #   puts "Je dois rendre quelque chose"
    # end

    # Pour pouvoir l'atteindre partout
    # note : je ne suis pas sûr de m'en servir. J'utilise plutôt
    # PdfBook.current et en restant extrêmement prudent.
    Metric.pdf = pdf
    
    # 
    # On définit la clé à utiliser (numéro de page ou numéro de
    # paragraphe) pour les éléments de bibliographie (plus exacte- 
    # ment : leurs occurrences)
    #   - page        On utilise le numéro de page
    #   - paragraph   On utilise le numéro de paragraphe
    #   - hybrid      On utilise un numéro "page-paragraphe"
    # 
    Bibliography.page_or_paragraph_key = recipe.references_key

    #
    # Pour consigner les informations sur les pages, à commencer
    # par les paragraphes (numéros) s'ils sont numérotés
    # 
    @pages = {}

    # 
    # = FONTS =
    # 
    # Empacketage
    # 
    pdf.define_required_fonts(book_fonts)

    #
    # Y a-t-il une DERNIÈRE PAGE définie en options de commande
    # Si oui, on ne doit construire le livre que juste que là
    # 
    pdf.last_page   = CLI.options[:last] ? CLI.options[:last].to_i : 100000

    # 
    # Initier UNE PREMIÈRE PAGE, si on a demandé de la sauter
    # au départ (on le demande pour qu'elle prenne en compte les
    # définitions de marge, etc.)
    # 
    pdf.start_new_page if skip_page_creation?

    #
    # Initier la table des matières (je préfère faire mon 
    # instance plutôt que d'utiliser l'outline de Prawn)
    # 
    spy "Instanciation de la table des matières".gris
    tdm = Prawn4book::Tdm.new(self, pdf)
    pdf.tdm = tdm

    #
    # - Premières pages -
    # 
    
    pdf.start_new_page      if page_de_garde?   # && pdf.first_page < 2 [1]
    pdf.build_faux_titre    if page_faux_titre? # && pdf.first_page < 3
    pdf.build_page_de_titre if page_de_titre?   # && pdf.first_page < 4
    #
    # [1] En reprenant le programme, pdf.first_page n'est plus 
    #     défini. La seule méthode first_page qui existe est 
    #     celle de la disposition des entêtes et pieds de page
    #
    
    # Toujours commencer sur la BELLE PAGE
    # 
    pdf.start_new_page if pdf.page_number.even?

    # 
    # ========================
    # - TOUS LES PARAGRAPHES -
    # ========================
    # 
    # cf. modules/pdfbook/generate_builder/paragraphes.rb
    # 
    pdf.print_paragraphs(inputfile.paragraphes)

    # ESSAI
    # page = pdf.page
    # puts "page ##{page.number}: #{page.xobjects}"

    #
    # - PAGES SUPPLÉMENTAIRES -
    # 
    # @note
    #   Sauf la page d'index qui s'appelle directement dans le
    #   texte par la marque '(( index ))'
    # 
    # Écriture des pages supplémentaires obtenues par le 
    # parser, if any
    # 
    if defined?(PrawnCustomBuilderModule)
      extend PrawnCustomBuilderModule
      __custom_builder(pdf)
    end

    # 
    # - PAGE INFOS -
    # 
    if page_infos?
      if pdf.last_page > pdf.page_number
        pdf.build_page_infos
      else
        spy "Ce n'est pas la dernière page, on n'écrit donc pas la page d'infos.".rouge
      end
    end

    # 
    # - TABLE DES MATIÈRES -
    # 
    pdf.build_table_of_contents

    #
    # = ENTETE & PIED DE PAGE =
    # 
    # Écriture des numéros de page ou numéros de paragraphes
    # En bas de toutes les pages qui le nécessitent.
    # 
    pdf.build_headers_and_footers(self, pdf)

    #
    # Affichage du rapport final
    # 
    if defined?(ParserParagraphModule) && ParserParagraphModule.respond_to?(:report)
      ParserParagraphModule.report
    end

    # Avec l'option -g/--grid on peut demander l'affichage de la 
    # grille de référence
    #
    pdf.draw_reference_grids if display_reference_grid?

    # 
    # Avec l'option --display_margins, on affiche les marges
    # 
    pdf.draw_margins if display_margins?

    #
    # Enregistrement du code du livre dans son fichier pour produire
    # le document PDF final.
    # 
    pdf.save_as(pdf_path)

    #
    # Afficher les erreurs mineures si on en a rencontrées
    # 
    PrawnView::Error.report_building_errors

    if File.exist?(pdf_path)
      puts "\nLe book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
      puts "\n"
      return true
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
      return false
    end
  end

  ##
  # Requiert tous les modules de parsing, formating et helping.
  # 
  def require_custom_parsers_formaters

    #
    # S'il existe un module ruby général
    # (par exemple pour reseter certaines données)
    # 
    custom_modules_prawn4book.each { |m| require(m) }

    #
    # S'il existe des modules de formatage propre au livre (et/ou à la
    # collection) il faut le(s) charger.
    #
    custom_parser_paths.each { |m| require(m) }

    #
    # - Modules de formatages -
    # 
    custom_formater_paths.each { |m| require(m) }

    #
    # - Modules d'helpers -
    # 
    custom_helper_paths.each { |m| require(m) }

    #
    # On les distribue
    # 
    if defined?(PrawnHelpersMethods)
      spy "Inclusion du module PrawnHelpersMethods dans PdfBook::AnyParagraph".bleu
      Prawn4book::PdfBook::AnyParagraph.include(PrawnHelpersMethods)
    end
    if defined?(ParserFormater)
      spy "Inclusion du module ParserFormater dans PdfBook::AnyParagraph".bleu
      Prawn4book::PdfBook::AnyParagraph.include(ParserFormater)
    end
    if defined?(ParserFormaterClass)
      spy "Extension du module ParserFormaterClass dans PdfBook::AnyParagraph".bleu
      Prawn4book::PdfBook::AnyParagraph.extend(ParserFormaterClass)
    end

    if defined?(PdfBookFormatageModule)
      spy "Extension du module PdfBookFormatageModule dans PrawnView".bleu
      PrawnView.extend PdfBookFormatageModule
    end
    if defined?(FormaterParagraphModule)
      spy "Inclusion du module FormaterParagraphModule dans NTextParagraph".bleu
      NTextParagraph.include(FormaterParagraphModule)
    end
    if defined?(TableFormaterModule)
      spy "Extension du module TableFormaterModule dans NTable".bleu
      NTable.extend(TableFormaterModule)
    end

    Prawn4book::PdfBook::AnyParagraph.custom_paragraph_parser_exists = 
      defined?(ParserParagraphModule) && ParserParagraphModule.respond_to?(:paragraph_parser)

  end

  def display_reference_grid?
    CLI.option(:display_grid)
  end
  def display_margins?
    CLI.option(:display_margins)
  end


  # --- Titles Methods ---
  
  # Donnée de page par défaut
  # 
  # Il s'agit des données qui servent à consigner les premiers et
  # derniers paragraphes de chaque page, ainsi que le titre courant
  # 
  DEFAULT_DATA_PAGE = {
    first_par:nil, last_par: nil,
    content_length: 0,
    title1: '', title2:'', title3:'', title4:'', title5:'', title6:''}

  def add_page(num_page)
    #
    # On met les valeurs par défaut dans la donnée de page
    # 
    pages.merge!(num_page => DEFAULT_DATA_PAGE.dup)
    #
    # On lui donne tous les titres courants
    # 
    current_titles.each do |ktitre, titre|
      pages.merge!(
        ktitre => titre,
        ktitre.upcase => (titre && titre.upcase)
      )
    end
  end

  # Lorsqu'un paragraphe (NTextParagraph|NTitre) est créé, on 
  # renseigne la ou les pages sur lesquels il se trouve.
  # 
  # @param parag {NTextParagraph} L'instance du paragraphe qui
  #               vient d'être imprimé
  def set_paragraphs_in_pages(parag)

    # - raccourcis -
    pfirst_num  = parag.first_page
    plast_num   = parag.last_page
    parag_num   = parag.numero

    # 
    # Faut-il créer la page de départ ou la page de fin du 
    # paragraphe ?
    # Note : le plus souvent, c'est la même page
    # 
    pages[pfirst_num] || add_page(pfirst_num)
    pages[plast_num]  || add_page(plast_num)

    pag_first = pages[pfirst_num]
    pag_last  = pages[plast_num]

    # 
    # Si le premier paragraphe de la page de départ du 
    # paragraphe n'est pas défini, c'est ce paragraphe
    # 
    pag_first.merge!(first_par: parag_num) if pag_first[:first_par].nil?
    # 
    # Si le premier paragraphe de la page de fin n'est
    # pas défini, on le met à ce paragraphe
    # 
    pag_last.merge!(first_par: parag_num) if pag_last[:first_par].nil?
    # 
    # Dans tous les cas on met le dernier paragraphe de
    # la première et de la dernière page à ce paragraphe
    # 
    pag_first.merge!(last_par: parag_num)
    pag_last.merge!(last_par: parag_num)

    # 
    # --- INDICATION DE LA LONGUEUR ---
    # 
    # On ajoute la longueur de contenu à la page
    # (pour le moment, juste pour savoir qu'elle n'est pas vide)
    #
    moitie = parag.length / 2
    pag_first[:content_length] += moitie
    # 
    # Si le paragraphe se trouve sur deux pages, on divise arbitrai-
    # rement par deux, car pour le moment le compte exact importe 
    # peu)
    # 
    if plast_num != pfirst_num
      pag_last[:content_length] += moitie
    else 
      pag_first[:content_length] += moitie
    end
  end

  # Pour mettre le paragraphe +parag+ en titre courant de son niveau
  # @param parag {PdfBook::NTitre}
  # @param num_page {Integer} Numéro de la page courante au moment du
  #                 titre. Noter qu'elle a été ajoutée à @pages à
  #                 l'écriture du paragraphe.
  def set_current_title(parag, num_page)
    ktitre = "title#{parag.level}".to_sym
    @current_titles.merge!(ktitre => parag.text)
    # 
    # S'il faut créer cette nouvelle page
    # 
    pages[num_page] || add_page(num_page)
    pages[num_page].merge!(
      ktitre => parag.text,
      ktitre.upcase => parag.text.upcase
    )
    # 
    # Tous les titres de niveau suivant doivent être
    # ré-initialisés
    # 
    ((parag.level + 1)..6).each do |level|
      ktit = "title#{level}".to_sym
      @current_titles.merge!(ktit => nil)
      pages[num_page].merge!(ktit => "")
    end

  end

  # @return true si les données sont conformes, false dans le
  # cas contraire.
  # 
  # C'est un peu de l'intrusion, mais on en profite aussi, ici, pour
  # instancier les bibliographies qui sont définies.
  def conforme?
    # 
    # Si la page de titre est demandée, il faut s'assurer que les
    # informations minimales sont fournies (titre et auteur) et que
    # s'il faut un logo, son path est défini et renvoie à un fichier
    # existant.
    # 
    if recipe.page_de_titre?
      spy "La page de titre est démandée".jaune
      not(titre.nil?)     || raise(FatalPrawnForBookError.new(800))
      not(auteurs.nil?)   || raise(FatalPrawnForBookError.new(801))
      unless logo_defined? == logo_exists?
         raise(FatalPrawnForBookError.new(802, {path: recipe.logo_path}))
      end
    else
      spy "La page de titre N'EST PAS démandée".jaune
    end

  rescue FatalPrawnForBookError => e
    raise e
  rescue PrawnBuildingError => e
    formated_error(e)
    spy "👎 Le livre n'est pas conforme.".rouge
    return false
  rescue Exception => e
    formated_error(e)
    spy "🤪 ERREUR SYSTÉMIQUE.".rouge
    return false
  else
    spy "👍 Le livre est conforme".vert
    return true
  end

  private

    # @return [Boolean] true si le logo est défini pour le livre ou
    # la collection
    # 
    # @api private
    def logo_defined?
      recipe.logo_defined?
    end

    def logo_exists?
      logo_defined? && File.exist?(recipe.logo_path)
    end

end #/class PdfBook
end #/module Prawn4book
