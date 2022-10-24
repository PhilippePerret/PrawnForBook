module Prawn4book
class PdfBook
class << self
  # = main =
  def proceed_init_with_assistant(cdata, force)
    clear

    # Avertissement préliminaire
    puts "
    Attention, cet assistant n'est pas à jour, des informations
    importantes ne sont pas prises en comptes. Utiliser plutôt les 
    modèles.
    Il n'est vraiment pas assez à jour, je renonce pour le
    moment jusqu'à ce qu'il soit actualisé.

    ".bleu
    return

    cdata ||= {}

    # --- POUR L'ESSAI ---
    cdata = {
      book_title:     "Mon livre",
      collection:     true,
      book_id:        'mon_livre',
      auteurs:        ['Marion MICHEL', 'Philippe PERRET'],
      main_folder:    "/Users/philippeperret/Programmes/Prawn4book/tests/essais/books/une_collection/mon_livre",
      text_path:      true,
      dimensions:     :collection,
      marges:         :collection,
      interligne:     :collection,
      opt_num_parag:  :collection,
      fonts:          nil, # :collection 
    }

    if cdata[:collection] === true
      cdata.merge!(instance_collection: Collection.new(cfolder))
    end


    RECIPE_PROPERTIES.each do |prop|
      if force
        send("define_#{prop}".to_sym, cdata)
      else
        is_defined_or_define(prop, cdata) || return # pour interrompre
      end
    end

    # 
    # On retire l'instance de collection
    # 
    cdata.delete(:instance_collection)

    #
    # On ajout des propriétés qui devront être définies de façon
    # plus complexe
    # 
    cdata.merge!(
      header: {
        from_page: 10, to_page: 200,
        disposition: '| -%titre1- |',
        style: {font:pdfbook.second_font, size:8, style: :bold}
      },
      footer: {
        from_page: 1, to_page: 220,
        disposition: '| | -%num',
        style: {font:pdfbook.second_font, size:9}
      },
      titles: {
        level1: { font: pdfbook.second_font, size: 30 },
        level2: { font: pdfbook.second_font, size: 26 },
        level3: { font: pdfbook.second_font, size: 20 },
        level4: { font: pdfbook.second_font, size: 16 },
      }

    )

    # puts cdata.inspect

    # 
    # L'instance du book
    # 
    book = PdfBook.new(cdata[:main_folder])

    # 
    # On crée le fichier de recette du livre
    # 
    book.create_recipe(cdata)

    puts "(jouer '#{COMMAND_NAME} open recipe' pour ouvrir le fichier recette du livre et régler d'autres valeurs comme le pied de page ou les titres)".gris
    puts "(jouer '#{COMMAND_NAME} manuel' pour ouvrir le manuel de l'application et voir notamment comment définir l'entête et le pied de page.)".gris
    puts "\n\n"
    
  end

end #/class << self
end #/class PdfBook
end #/module Prawn4book
