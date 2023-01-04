=begin

Test permettant de tester la création interactive d'un
nouveau livre from scratch

=end
require 'test_helper'
require_relative 'lib/required'

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
    Test d'une création complète d'un livre (à l'aide de l'initiateur)
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
      general: {
        folder:   'book_essais',
        title:    "Un livre d’essais",
        id:       'book_essais',
        auteur:   'Philippe Perret',
        subtitle: "Un livre en essai pour faire\\ndes tests notamment au niveau\\ndes interlignes et lignes de\\nréférences.",
        isbn:     '546-5-12598-24-7',
      },
      editor: {
          name: 'Icare Éditions',
          adresse: "295 impasse des Fauvettes\\n13400 Aubagne",
          site: 'https://www.icare-editions.fr',
          mail: 'editions@icare-editions.fr',
          contact: 'contact@icare-editions.fr',
        },
      format: {
          width: '203.5mm',
          height: '125mm',
          orientation: 'landscape',
          top_margin: '10mm',
          ext_margin: '11mm',
          bot_margin: '12mm',
          int_margin: '13mm',
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
        level1: {
            font:"Keyb", size:24, new_page: :RET
          }
        },
    }

    # - On détruit le dossier du livre avant de commencer -
    book_folder = File.join(__dir__,'essais', book_data[:general][:folder])
    FileUtils.rm_rf(book_folder) if File.exist?(book_folder)
    refute File.exist?(book_folder)

    checker_recipe = TRecipe.new(File.join(book_folder,'recipe.yaml'))

    action "Je rentre les informations générales…"
    dd = book_data[:general]
    tosa << [
      :RET,           # un livre
      dd[:folder]    , :RET,       # dossier
      :RET, # confirmation du path du dossier
      :RET, # Pour choisir les données générales
      :RET, dd[:title], :RET,      # le titre
      :RET, dd[:subtitle], :RET,   # le sous-titre
      dd[:id]        , :RET,       # identifiant
      dd[:auteur]    , :RET,       # auteur
      dd[:isbn]      , :RET,       # ISBN
    ]

    # Première vérification de la recette
    checker_recipe.has_data(dd)

    # --- Définition des fontes ---
    action "Je choisis les fontes"
    tosa << [
      :DOWN, :RET,    # pour définir les fontes
      :RET,           # dans dossier système
      *6.down,
      :SPACE,         # je choisis la sixième
      :DOWN, :SPACE,  # je choisis la septième
      :DOWN, :SPACE,  # je choisis la huitième
      :RET,           # Je valide le choix
      "Geneva", :RET, # Nom de la première police
      :RET,           # style normal
      "Keyb", :RET,   # Nom de deuxième police
      :DOWN, :RET,    # style Regular
      "Foufe", :RET,  # Nom de troisième police
      *2.DOWN, :RET,  # style italique
      *3.down, :RET   # pour finir
    ]

    rdata = checker_recipe.get_data[:fonts]
    assert rdata, "Les fontes devraient être définies"
    [
      ['Geneva', :normal],
      ['Keyb', :regular],
      ['Foufe', :italic]
    ].each do |font_name, font_style|
      font_name = font_name.to_sym
      assert rdata.key?(font_name), "Les fontes devrait définir le nom #{font_name.inspect}"
      assert rdata[font_name].key?(font_style), "La police #{font_name.inspect} devrait définir le style #{font_style.inspect}."
    end

    # --- Définition du format
    action "Je fais entrer les données de format du livre"
    tosa << [:DOWN, :DOWN, :RET] # pour définir le format
    dd = book_data[:format]
    tosa << [:DOWN, :RET, dd[:width], :RET]     # largeur du livre
    tosa << [*2.DOWN, :RET, dd[:height], :RET]  # hauteur du livre
    tosa << [*3.down, :RET]                     # l'orientation
    if dd[:orientation] == 'portrait'
      tosa << :RET
    else
      tosa << [:DOWN, :RET]
    end
    # - les marges -
    [:top, :ext, :bot, :int].each_with_index do |bord, idx|
      value = dd["#{bord}_margin".to_sym]
      tosa << [*(4 + idx).down, :RET, value, :RET]
    end
    #  On s'arrête là pour le format
    # Note TODO : l'idée est de faire un tableau qui dise comment
    # modifier une valeur. Par exemple, pour modifier la marge
    # haute, on saura qu'il faut 4.down, :RET, value, :RET et 
    # enregistrer avec un nouveau :RET
    tosa << :RET # enregistrer le format

    data_titre = {
      font:           [:RET],
      size:           [*1.DOWN, :RET],
      line_before:    [*2.DOWN, :RET],
      line_after:     [*3.DOWN, :RET],
      interlignage:   [*4.DOWN, :RET],
    }
    data_tosa = {
      titres: {
        move_n_choose: [*3.down, :RET],
        level1: {
          move_n_choose: [:DOWN, :RET],
          new_page:       [*5.DOWN, :RET],
          belle_page:     [*6.DOWN, :RET],
        },
        level2: { move_n_choose: [*2.DOWN, :RET]},
        level3: { move_n_choose: [*3.DOWN, :RET]},
        level4: { move_n_choose: [*4.DOWN, :RET]},
        level5: { move_n_choose: [*5.DOWN, :RET]},
        level6: { move_n_choose: [*6.DOWN, :RET]},
        level7: { move_n_choose: [*7.DOWN, :RET]},
      }
    }
    Object.const_set('DATA_TOSA', data_tosa)
    (1..7).each do |niv|
      DATA_TOSA[:titres][:"level#{niv}"].merge!(data_titre)
    end
    tosa << DATA_TOSA[:titres][:move_n_choose] # pour Les données titres
    tosa << DATA_TOSA[:titres][:level1][:move_n_choose] # éditer les données du titre 1
    
    [
      :leve1
    ].each do |levelX|
      tosa << DATA_TOSA[:titres][levelX][:move_n_choose]
      [:font, :size, :new_page].each do |prop|
        value = book_data[:titres][levelX]
      end
    end
    return

    tosa << [
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
