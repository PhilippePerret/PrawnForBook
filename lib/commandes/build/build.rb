=begin

  Commande 'build'
  Commande principale qui construit le livre à partir de la recette
  et du texte fourni.

=end
module Prawn4book
class Command
  def proceed
    PdfBook.current.generate_pdf_book
  end
end #/Command
class PdfBook

  # Pour exposer les données des pages (à commencer par les
  # paragraphes)
  attr_reader :pages

  # Pour exposer les titres courants par niveau en cours
  # de fabrication (pour alimenter la données pages et 
  # permettre ensuite le traitement des pieds de page et
  # entêtes)
  attr_reader :current_titles

  # @prop Instance {Prawn4book::PdfHelpers}
  attr_reader :pdfhelpers

  # @prop instance ReferencesTable gérant les références du livre
  attr_reader :table_references

  def generate_pdf_book
    spy "Génération du livre #{ensured_title.inspect}".bleu
    #
    # Le livre doit être conforme, c'est-à-dire posséder les 
    # éléments requis
    # 
    check_if_conforme || return
    # 
    # Initialiser le suivi des titres par niveau
    # 
    @current_titles = {}
    # 
    # Instanciation de la table de référence
    # @note
    #   Les références sont une liste de cibles dans le texte ou dans
    #   le texte d'un autre livre, qui peuvent être atteinte depuis
    #   un pointeur dans le texte.
    # 
    @table_references = PdfBook::ReferencesTable.new(self)
    # 
    # INITIALISATIONS
    # 
    PdfBook::NTextParagraph.init_first_turn
    table_references.init
    # 
    # Première passe, pour récupérer les références (if any)
    # 
    ok_book = build_pdf_book
    # 
    # Si des références ont été trouvées, on actualise le fichier
    # des références du livre.
    # 
    table_references.save if table_references.any?
    # 
    # Si des appels de références ont été trouvées, on refait une
    # passe pour les appliquer.
    # 
    if table_references.has_one_appel_sans_reference?
      table_references.second_turn = true
      PdfBook::NTextParagraph.init_second_turn
      ok_book = build_pdf_book
    end

    if ok_book
      open_book if CLI.option(:open)
    end
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
    # 
    File.delete(pdf_path) if File.exist?(pdf_path)

    #
    # Avec Prawn::View au lieu d'étendre Prawn::Document
    # 
    spy "pdf_config: #{pdf_config.pretty_inspect}" if test?
    
    pdf = PrawnView.new(self, pdf_config)
    
    #
    # S'il existe un module de formatage propre au livre (ou à la
    # collection) il faut le charger.
    #
    if module_formatage?
      require_module_formatage
      if defined?(PdfBookFormatageModule)
        PrawnView.extend PdfBookFormatageModule
      end
      if defined?(FormaterParagraphModule)
        NTextParagraph.include(FormaterParagraphModule)
      end
    end

    # 
    # On définit la clé à utiliser (numéro de page ou numéro de
    # paragraphe) pour les éléments de bibliographie (plus exacte- 
    # ment : leurs occurrences)
    # 
    Bibliography.page_or_paragraph_key = pagination_page? ? :page : :paragraph

    # 
    # CUSTOM PARSER (if any)
    # 
    require_module_parser if module_parser?

    #
    # CUSTOM HELPERS (if any)
    # 
    require_modules_helpers(pdf) if module_helpers?

    #
    # Pour consigner les informations sur les pages, à commencer
    # par les paragraphes (numéros) s'ils sont numérotés
    # 
    @pages = {}

    # 
    # FONTS
    # 
    pdf.define_required_fonts(book_fonts)

    #
    # Y a-t-il une DERNIÈRE PAGE définie en options
    # Si oui, on ne doit construire le livre que juste que là
    # 
    pdf.last_page = CLI.options[:last].to_i if CLI.options[:last]

    # 
    # Initier une première page, si on a demandé de la sauter
    # au départ (on le demande pour qu'elle prenne en compte les
    # définitions de marge, etc.)
    # 
    pdf.start_new_page if skip_page_creation?

    # # 
    # # Calcul de la table de références (pour les lignes de référence)
    # # 
    # pdf.table_reference_grid

    # # 
    # # Calcul de leading par défaut 
    # # 
    # pdf.define_default_leading

    #
    # Initier la table des matières (je préfère faire mon 
    # instance plutôt que d'utiliser l'outline de Prawn)
    # 
    tdm = PdfBook::Tdm.new(self, pdf)
    pdf.tdm = tdm


    pdf.start_new_page if page_de_garde?


    pdf.build_faux_titre if page_faux_titre?
      
    pdf.build_page_de_titre if page_de_titre?

    # 
    # Commencer toujours sur la BELLE PAGE
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

    #
    # - PAGES SUPPLÉMENTAIRES -
    # 
    # Note : la page d'index s'appelle directement dans le
    # texte par la marque '(( index ))'
    # 
    # Écriture des pages supplémentaires obtenues par le 
    # parser, if any
    # 
    if module_parser? && defined?(PrawnCustomBuilderModule)
      extend PrawnCustomBuilderModule
      __custom_builder(pdf)
    end

    # 
    # - Page infos ? -
    # 
    pdf.build_page_infos if recette.page_info?

    # 
    # - TABLE DES MATIÈRES -
    # 
    tdm.build if pdf.table_of_contents?

    #
    # - ENTETE & PIED DE PAGE -
    # 
    # Écriture des numéros de page ou numéros de paragraphes
    # En bas de toutes les pages qui le nécessitent.
    # 
    pdf.build_headers_and_footers(self, pdf, @pages)


    if module_parser? && ParserParagraphModule.respond_to?(:report)
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

    
    pdf.save_as(pdf_path)

    if File.exist?(pdf_path)
      puts "\n\nLe book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
      puts "\n"
      return true
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
      return false
    end
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
    title1: '', title2:'', title3:'', title4:'', title5:'', title6:'',
    TITLE1: '', TITLE2:'', TITLE3:'', TITLE4:'', TITLE5:'', TITLE6:''
  }

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

  # Lorsqu'un paragraphe (NTextParagraph) est créé, on renseigne
  # la ou les pages sur lesquels il se trouve
  # 
  # @param parag {NTextParagraph} L'instance du paragraphe qui
  #               vient d'être imprimé
  def set_paragraphs_in_pages(parag)
    # 
    # Numéro de ce paragraphe
    # 
    parag_numero = parag.numero
    # 
    # Faut-il créer la page de départ du paragraphe ?
    # 
    pages[parag.first_page] || add_page(parag.first_page)
    # 
    # On prend la page de départ du paragraphe
    # 
    page_debut_parag = pages[parag.first_page]
    # 
    # Si le premier paragraphe de la page de départ du 
    # paragraphe n'est pas défini, c'est le paragraphe
    if page_debut_parag[:first_par].nil?
      page_debut_parag.merge!(first_par: parag_numero)
    end
    # 
    # Faut-il créer la page de fin du paragraphe ?
    # 
    pages[parag.last_page] || add_page(parag.last_page)
    # 
    # On prend la page de fin du paragraphe
    # 
    page_fin_parag = pages[parag.last_page]
    # 
    # Si le premier paragraphe de la page de fin n'est
    # pas défini, on le met à ce paragraphe
    # 
    if page_fin_parag[:first_par].nil?
      page_fin_parag.merge!(first_par: parag_numero)
    end
    # 
    # Dans tous les cas on met le dernier paragraphe de
    # la page à ce paragraphe
    # 
    page_fin_parag.merge!(last_par: parag_numero)
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
  def check_if_conforme
    unless recipe.biblios_data.empty?
      dbibs = recipe.biblios_data
      dbibs.is_a?(Hash) || raise("La recette bibliographie (:biblios:) devrait être une table (un item par type d'élément).")
      # 
      # On doit charger les modules utiles aux bibliographies
      # 
      Bibliography.require_formaters(self)
      module_formatage? || raise("Un fichier 'formater.rb' devrait exister pour définir la mise en forme à adopter pour la bibliographie.")
      require_module_formatage
      defined?(FormaterBibliographiesModule) || raise("Le fichier formater.rb devrait définir le module 'FormaterBibliographiesModule'\n(bien vérifier le nom, avec un pluriel)…")
      dbibs.each do |bib_id, dbib|
        bib = Bibliography.instanciate(self, dbib)
        bib.tag   || raise("Il faut définir dans la recette le :tag des bibliographies")
        bib.title || raise("Il faut définir dans la recette le titre (:title:) de la bibliographie '#{bib.tag}'.")
        bib.data[:data] || raise("Il faut définir dans la recette le chemin d'accès aux données de la bibliographie '#{bib.tag}' (:data:)…")
        File.exist?(bib.data_path.to_s) || raise("Les données pour la bibliographie '#{bib.tag}' sont introuvables\n(avec la donnée '#{bib.data[:data]}')…")
        Bibliography.respond_to?("biblio_#{bib.tag}".to_sym) || raise("Le module FormaterBibliographiesModule de formater.rb doit définir la méthode 'biblio_#{bib.tag}'…")
      end
    end

  rescue Exception => e
    puts formated_error(e)
    return false
  else
    return true
  end

end #/class PdfBook
end #/module Prawn4book
