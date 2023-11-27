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

  # - raccourcis -
  def first_turn?; Prawn4book.first_turn? end
  def second_turn?; Prawn4book.second_turn? end
  def second_turn_required?; Prawn4book.second_turn_required? end

  # Pour exposer les titres courants par niveau en cours
  # de fabrication (pour alimenter la données pages et 
  # permettre ensuite le traitement des pieds de page et
  # entêtes)
  attr_reader :current_titles

  # @prop Instance {PdfHelpers}
  attr_reader :pdfhelpers

  ###############################
  ### GÉNÉRATION DU LIVRE PDF ###
  ###############################
  def generate_pdf_book
    
    # Initialiser le suivi des titres par niveau
    # 
    # Cette donnée permet de définir les titres de niveau 1 à 6 pour
    # toutes les pages (utile par exemple pour les entêtes ou pied de
    # page)
    # 
    @current_titles = {
      1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil
    }

    #
    # Si c'est "juste" un export du texte, il faut charger le
    # module qui s'en charge
    # 
    if export_text?
      require 'lib/modules/Exportator'
      Prawn4book.exported_book = self
    end

    #
    # Le livre doit être conforme, c'est-à-dire posséder tous les 
    # éléments requis en fonction de la définition de la recette
    # (dans la version 2, LINE, on ne teste plus le contenu avant
    # de voir la conformité)
    # 
    conforme? || return

    # 
    # --- INITIALISATIONS ---
    # 
    Prawn4book.turn = 1
    # - Bibliographies -
    require 'lib/pages/bibliographies'
    Bibliography.init
    # - paragraphes texte -
    PdfBook::AnyParagraph.init_first_turn
    # - table de références -
    # (il faut absolument l'initier une seule fois, car sinon, on 
    #  perdra les références ultérieures)
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
    # Pour consigner les erreurs mineures en cours de construction
    # 
    PrawnView::Error.reset

    #
    # === CONSTRUCTION DU LIVRE ===
    #     (PREMIÈRE PASSE/TURN)
    # 
    ok_book = build_pdf_book

    # ======================
    # === DEUXIÈME PASSE ===
    # ======================
    # 
    # Si des appels de références avant ont été trouvées, on refait
    # une passe pour les appliquer.
    # 
    if not(export_text?) && second_turn_required?

      #
      # Pour Prawn4book.second_turn?
      # 
      Prawn4book.turn = 2
      
      #
      # S'il existe une méthode de reset propre au livre ou à la 
      # collection, on l'invoque, en indique (+false+) que c'est le
      # second tour.
      # 
      Prawn4book.reset(false) if Prawn4book.respond_to?(:reset)

      # Construction finale du livre
      # (mais elle peut se faire à la première passe s'il n'y a
      #  pas de références arrières)
      # 
      ok_book = build_pdf_book

      if Prawn4book.require_third_turn?

        # =======================
        # === TROISIÈME PASSE ===
        # =======================
        # 
        # Pour le moment, elle n'est requise qu'à la construction
        # du scénodico (Livre "Dictionnaire de la Narration")
        # 

        #
        # Pour Prawn4book.third_turn?
        # 
        Prawn4book.turn = 3
      
        #
        # S'il existe une méthode de reset propre au livre ou à la 
        # collection, on l'invoque
        # 
        Prawn4book.reset(false) if Prawn4book.respond_to?(:reset)

        if PdfBook::AnyParagraph.respond_to?(:init_third_turn)
          PdfBook::AnyParagraph.init_third_turn
        end

        #
        # Construction finale du livre
        # (mais elle peut se faire à la première passe s'il n'y a
        #  pas de références arrières)
        # 
        ok_book = build_pdf_book

      end #/ fin troisième tour

    end #/ fin deuxième tour

    # 
    # Si des références ont été trouvées, on actualise le fichier
    # des références du livre.
    # 
    table_references.save if table_references.any?

    #
    # S'il faut ouvrir le livre
    # 
    open_book if CLI.option(:open) && ok_book

    #
    # Si l'export de texte était demandé, on demande s'il faut
    # l'ouvrir dans Antidote (entendu que lorsque l'export est
    # demandé, c'est souvent pour le corriger)
    # 
    if export_text?
      if Q.yes?("Voulez-vous ouvrir le texte dans le correcteur (#{CORRECTOR_NAME}) ?".jaune)
        `open -a "#{CORRECTOR_NAME}" "#{exportator.path}"`
      end
    end
  end
  #/generate_pdf_book

  # @return true s'il faut exporter le texte (par exemple pour une
  # correction dans Antidote)
  # C'est avec l'option -t (pfb build -t) qu'on obtient cet export.
  def export_text?
    :TRUE == @exportonlytext ||= true_or_false(CLI.option(:export_text))
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
    clear unless debug? || ENV['TEST']

    # Utile dans le DSL pdf.update
    my = me = self
    
    # Réinitialiser les NOTES DE PAGE
    notes_manager.drain
    
    # Avec Prawn::View au lieu d'étendre Prawn::Document
    #
    # @note
    #   Il faut l'instancier à chaque tour, sinon les pages seraient
    #   ajoutées au pdf précédent. Ici, ça ne changera qu'au niveau
    #   de la table des matières qu'il faudra recommencer. Mais pour
    #   tout les reste (à commencer par les pages), elles seront 
    #   conservées telles qu'on les a relevées la première fois.
    # 
    pdf = PrawnView.new(self, pdf_config)
    @pdf = pdf

    # Détruire le fichier PDF final s'il existe déjà
    # (note : il existe toujours si c'est un deuxième tour)
    # 
    File.delete(pdf_path) if File.exist?(pdf_path)

    # Initier la table des matières (je préfère faire mon 
    # instance plutôt que d'utiliser l'outline de Prawn)
    # 
    tdm = Tdm.new(self, pdf)
    pdf.tdm = tdm

    # Méthode appelée automatiquement à chaque création de page
    # dans le livre, qu'elle soit automatique ou forcée.
    # 
    # Mais on ne fait ça que la première fois (au premier tour). Au
    # second tour, les informations sur les pages ont été initiées et
    # n'ont pas besoin d'être reprises.
    # 
    if first_turn?
      pdf.on_page_create do
        my.add_page(pdf.page_number)
        export_text("\n#{'-'*30}\n\n") if export_text?
      end
    else
      pdf.on_page_create do
        pages[pdf.page_number].init_content
      end
    end

    # = FONTS =
    # 
    # Empacketage de toutes les fontes dans le document PDF.
    # 
    pdf.embed_fontes(book_fonts)
    if first_turn?
      # - Par défaut -
      default_fonte = Fonte.new(
        name:   recipe.default_font_name,
        style:  recipe.default_font_style,
        size:   recipe.default_font_size,
        hname:  'Fonte par défaut'
      )
      Fonte.default = default_fonte
    end

    # Initier UNE PREMIÈRE PAGE, si on a demandé de la sauter
    # au départ (on le demande pour qu'elle prenne en compte les
    # définitions de marge, etc.)
    # 
    pdf.start_new_page if skip_page_creation?

    # Fonte par défaut
    # ----------------
    # 
    #   On ne peut faire ça que si une première page existe, donc il
    #   faut impérativement que ce code se situe après avoir 
    #   démarré la première page.
    # 
    # -- Application --
    pdf.font(Fonte.default)


    # =======================
    # -   PREMIÈRES PAGES   -
    # =======================
    #     
    pdf.build_faux_titre    if page_faux_titre? && pdf.first_page < 2
    pdf.start_new_page      if page_de_garde?   && pdf.first_page < 3
    pdf.build_page_de_titre if page_de_titre?   && pdf.first_page < 4
    
    # Toujours commencer sur la BELLE PAGE
    # 
    pdf.start_new_page if pdf.page_number.even?

    # ========================
    # - TOUS LES PARAGRAPHES -
    # ========================
    # 
    inputfile.parse_and_write(pdf)

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

    pdf.update do 
      
      # =============================
      # -   TABLE(S) DES MATIÈRES   -
      # =============================
      build_tables_of_contents

      # ===========================
      # -  ENTETE & PIED DE PAGE  -
      # ===========================
      build_headers_and_footers(me)

      # ====================
      # -   PAGE CRÉDITS   -
      # ====================
      build_credits_page if my.credits_page? && last_page > page_number

      # ===========================
      # -   GRILLE DE RÉFÉRENCE   -
      # ===========================
      draw_reference_grids if my.recipe.show_grid?

      # =========================
      # -   DESSIN DES MARGES   -
      # =========================
      draw_margins if my.recipe.show_margins?

      #
      # Enregistrement du code du livre dans son fichier pour produire
      # le document PDF final.
      # 
      save_as(my.pdf_path)

    end #/pdf

    #
    # Affichage du rapport final
    # 
    if defined?(ParserParagraphModule) && ParserParagraphModule.respond_to?(:report)
      ParserParagraphModule.report
    end

    #
    # Afficher les erreurs mineures si on en a rencontrées
    # 
    PrawnView::Error.report_building_errors

    if File.exist?(pdf_path)
      pdf_relpath = pdf_path.sub("#{Dir.home}/",'')
      puts "#{MESSAGES[:building][:success] % {path: pdf_relpath}}".vert
      puts "\n"
      return true
    else
      puts ERRORS[:building][:book_not_built].rouge
      return false
    end
  end


  ##
  # Si un deuxième tour est nécessaire (car des références manquaient
  # pour les notes), on ne parse plus les paragraphes depuis le 
  # fichier, on utilise les instances créées lors du premier tour.
  # Cela permet de ne pas avoir à tout refaire.
  # 
  # [1] La seule correction à faire au paragraphe consiste à corriger
  #     les références à des cibles ultérieures (if any)
  def rewrite_paragraphs(pdf)
    paragraphes.each do |paragraphe|
      next if paragraphe.not_printed?
      if paragraphe.has_unknown_target?
        # spy "Cible introuvable".red
        # exit
        paragraphe.resolve_targets
      end
      print_paragraph(pdf, paragraphe)
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
      PdfBook::AnyParagraph.include(PrawnHelpersMethods)
    end
    if defined?(ParserFormater)
      spy "Inclusion du module ParserFormater dans PdfBook::AnyParagraph".bleu
      PdfBook::AnyParagraph.include(ParserFormater)
    end
    if defined?(ParserFormaterClass)
      spy "Extension du module ParserFormaterClass dans PdfBook::AnyParagraph".bleu
      PdfBook::AnyParagraph.extend(ParserFormaterClass)
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

    PdfBook::AnyParagraph.custom_paragraph_parser_exists = 
      defined?(ParserParagraphModule) && ParserParagraphModule.respond_to?(:paragraph_parser)

  end

  # Ajoute la page de numéro +num_page+ au PdfBook
  # 
  def add_page(num_page)

    # Au second tour, normalement, on n'a rien à faire ici
    return if second_turn?

    #
    # On met les valeurs par défaut dans la donnée de page
    # 
    data_page = {number: num_page}.merge(DEFAULT_DATA_PAGE.dup)

    #
    # On lui donne tous les titres courants
    # 
    # @note
    #   Ces titres pourront être changés en cours de route (est-ce
    #   bien raisonnable, entendu que c'est toujours le premier titre
    #   qui doit être utilisé — pour les entêtes par exemple.)
    # 
    current_titles.each do |level, titre|
      data_page[:titres].merge!( level => titre)
    end

    pages << data_page
  end

  # Donnée de page par défaut
  # 
  DEFAULT_DATA_PAGE = {
    first_par:      nil, 
    last_par:       nil,
    content_length: 0,
    titres: {}
  }


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
    pag_first.add_content_length(moitie)
    # 
    # Si le paragraphe se trouve sur deux pages, on divise arbitrai-
    # rement par deux, car pour le moment le compte exact importe 
    # peu)
    # 
    if plast_num != pfirst_num
      pag_last.add_content_length(moitie)
    else 
      pag_first.add_content_length(moitie)
    end
  end

  # Pour mettre le paragraphe +parag+ en titre courant de son niveau
  # @param parag {PdfBook::NTitre}
  # @param num_page {Integer} Numéro de la page courante au moment du
  #                 titre. Noter qu'elle a été ajoutée à @pages à
  #                 l'écriture du paragraphe.
  def set_current_title(parag, num_page)
    titre_level = parag.level.dup
    titre_text  = parag.text.dup

    # On actualise la donnée qui tient à jour les titres courants
    @current_titles[titre_level] = titre_text
    # Tous les titres de niveau suivant doivent être
    # ré-initialisés (remis à rien)
    (titre_level + 1..6).each { |lev| @current_titles[lev] = nil }

    # Ajouter ce titre à la page de numéro +num_page+
    # 
    # @note
    #   On crée la page si elle n'existe pas.
    # 
    page = pages[num_page] || add_page(num_page)
    page.add_titre(titre_level, titre_text)
    page.set_current_titles(current_titles.dup)


  end

  # @return true si les données sont conformes, false dans le
  # cas contraire.
  # 
  # C'est un peu de l'intrusion, mais on en profite aussi, ici, pour
  # instancier les bibliographies qui sont définies.
  def conforme?
    if recipe.page_de_titre?
      not(recipe.title.nil?)     || raise(PFBFatalError.new(800))
      not(recipe.authors.nil?)   || raise(PFBFatalError.new(801))
      unless recipe.logo_defined? == recipe.logo_exists?
         raise(PFBFatalError.new(802, {path: recipe.logo_path}))
      end
    end
  rescue PFBFatalError => e
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

end #/class PdfBook
end #/module Prawn4book
