=begin

Test permettant de tester la création interactive d'un
nouveau livre from scratch

=end
require 'test_helper'

class InitBookTestor < Minitest::Test

  def setup
    super
    # set_mode_interactive
  end

  def teardown
    super
    # set_mode_inputs
  end

  def test_init_book_complete

    resume "
    Test d'une création complète d'un livre
    "

    synopsis "
    « Complète » ici signifie que toutes les données
    seront fournies, qu'il n'y aura donc aucune donnée
    par défaut.
    - entrée des données
    - entrée d'un premier texte
    - création du livre
    "

    tosa = OSATest.new({
      app:'Terminal', 
      delay: 0.1,
      window_bounds: [10,10,1000,800]
    })

    tosa.new_window
    tosa.run "cd '#{__dir__}/essais'"
    tosa.run 'pfb init'

    book_data = {
      folder:   'book_essais',
      title:    "Un livre d’essais",
      id:       'book_essais',
      auteur:   'Philippe Perret',
      subtitle: <<~TXT,
      Un livre en essai pour faire
      des tests notamment au niveau
      des interlignes et lignes de
      références.
      TXT
      editor: {
          name: 'Icare Éditions',
          adresse: "295 impasse des Fauvettes\n13400 Aubagne",
          site: 'https://www.icare-editions.fr',
          mail: 'editions@icare-editions.fr',
          contact: 'contact@icare-editions.fr',
        },
      format: {
          width: '127mm',
          height: '203mm',
          orientation: 'portrait',
          top_margin: '20mm',
          ext_margin: '15mm',
          bot_margin: '20mm',
          int_margin: '25mm',
        },
      infos: {
          concepteur: 'Benoit Padrix',
          cover:      'Hugo Desprat',
          isbn:       '8-2568-45687-8',
          depot:      "2e semestre #{Time.now.year + 1}",
          mep:        'Cédric DE MONTDÉNARD',
          corrections: 'Marion MICHEL',
        },
      options: {
          numero_parag: 'y',

        },
      fontes: true,
      titres: {
        niv1_belle_page: 'y',
        new_page_after_niv1: 'y',
        font_niv1: 'Geneva',
        size_niv1: '18',
        top_niv1: '2',
        bot_niv1: '4',
        leading_niv1: '0',
        },
    }

    # - On détruit le dossier du livre avant de commencer -
    book_folder = File.join(__dir__,'essais', book_data[:folder])
    FileUtils.rm_rf(book_folder) if File.exist?(book_folder)
    refute File.exist?(book_folder)

    action "Je rentre les informations en répondant aux questions…"
    tosa << [
      :RET,           # un livre
      book_data[:folder]    , :RET,       # dossier
      :RET, # confirmation du dossier
      book_data[:title]     , :RET,       # le titre
      book_data[:id]        , :RET,       # identifiant
      book_data[:auteur]    , :RET,       # auteur
      book_data[:subtitle]  , {key:'d', modifiers:[:control]},
      :RET, #pour définir tout de suite les valeurs
      #  - Éditor -
      :RET, # données éditeur
      book_data[:editor][:name], :RET,
      book_data[:editor][:adresse], {key:'d', modifiers:[:control]},
      book_data[:editor][:site], :RET,
      :RET, # chemin du logo par défaut
      book_data[:editor][:mail], :RET,
      book_data[:editor][:contact], :RET,
      # - Format -
      :RET, # pour régler le format
      book_data[:format][:width], :RET,
      book_data[:format][:height], :RET,
      book_data[:format][:orientation], :RET,
      book_data[:format][:top_margin], :RET,
      book_data[:format][:ext_margin], :RET,
      book_data[:format][:bot_margin], :RET,
      book_data[:format][:int_margin], :RET,
      # - Pages désirées -
      :RET, # pour choisir les pages désirées
      :RET, # page de garde
      'n', :RET, # PAS de page de faux titre
      :RET, # page de titre
      :RET, # page d'informations de fin
      # - Informations de fin sur le livre -
      :RET, # définir les informations de fin
      book_data[:infos][:concepteur], :RET,
      book_data[:infos][:cover], :RET,
      book_data[:infos][:isbn], :RET,
      book_data[:infos][:depot], :RET,
      book_data[:infos][:mep], :RET,
      book_data[:infos][:corrections], :RET,
      :RET, # imprimé à la demande
    ]
    # - Options -
    if book_data[:options].nil? || book_data[:options].empty?
      tosa << :DOWN
    else
      tosa << [
            :RET, # pour définir les options
            book_data[:options][:numero_parag], :RET,
          ]
      if book_data[:options][:numero_parag] == 'y'
        tosa << :DOWN
      end
      tosa << :RET

    end
    # - Fontes -
    if book_data[:fontes].nil?
      tosa << :DOWN
    else
      tosa << [
        :RET, # pour choisir les fontes
        :RET, # pour choisir les fontes systèmes
        :DOWN, :DOWN, :DOWN, :DOWN, :DOWN, :DOWN, :SPACE, # Geneva
        :DOWN, :DOWN, :SPACE, # Monaco
        :DOWN, :SPACE, # New York
        :RET, # achever le choix des fontes systèmes
        :DOWN, :DOWN, :DOWN, :RET, # pour finir
        "Geneva", :RET, 
        :RET, # style normal
        "Monaco", :RET, 
        :RET, # style normal
        "NewYork", :RET, 
        :RET, # style normal
      ]
    end
    # - Données titres -
    if book_data[:titres].nil? || book_data[:titres].empty?
      tosa << :DOWN
    else
      tosa << [
        :RET, # définir les titres
        :RET, # définir les propriétés pour les titres
        book_data[:titres][:niv1_belle_page], :RET,
        book_data[:titres][:new_page_after_niv1], :RET,
        book_data[:titres][:font_niv1], :RET,
        book_data[:titres][:size_niv1], :RET,
        book_data[:titres][:top_niv1], :RET,
        book_data[:titres][:bot_niv1], :RET,
        book_data[:titres][:leading_niv1], :RET,
      ]
      if book_data[:titres][:niv2].nil?
        tosa << ['n', :RET]
      else
        raise "Il faut définir le niveau 2"
      end
    end
    # - Entête et pied de page
    tosa << :DOWN
    # - Données bibliographiques
    tosa << :DOWN
    # - finir -
    tosa << :RET

    # --- Vérification ---
    sleep 1
    assert File.exist?(book_folder)
    mini_success "Le dossier du livre a bien été créé."
    [
      'recipe.yaml', 'texte.pfb.md', 'parser.rb', 'formater.rb', 'helpers.rb'
    ].each do |filename|
      assert File.exist?(File.join(book_folder,filename)), "Le fichier #{filename.inspect} aurait dû être créé…"
    end
    mini_success "Les fichiers de base ont été créés avec succès."

    # # 
    # # Il faut mettre le logo dans le dossier image 
    # # NON, normalement, le constructeur s'en charge
    # # 
    # folder_images = File.join(book_folder, 'images')
    # logo_path = File.join(folder_images, 'logo.jpg')
    # FileUtils.cp(File.join('resources','templates','logo.jpg'), logo_path)
    # mkdir(folder_images)

    action "Je demande la construction du livre…"
    tosa.run "cd '#{book_folder}'"
    tosa.run 'pfb build'
    sleep 5

    book_pdf = File.join(book_folder,'book.pdf')
    assert File.exist?(book_pdf), "Le fichier PDF du livre devrait exister (à l'adresse #{book_pdf.inspect}…"

    tosa.finish

  end

end #/InitBookTestor < Minitest::Test
