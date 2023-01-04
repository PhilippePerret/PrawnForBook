=begin

Test permettant de tester la création interactive d'un
nouveau livre from scratch

=end
require 'test_helper'
require_relative 'lib/required'
require_relative 'lib/recipe_helpers'

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
        subtitle: 'Un livre en essai pour faire\\\\ndes tests notamment au niveau\\\\ndes interlignes et lignes de\\\\nréférences.',
        isbn:     '546-5-12598-24-7',
      },
      publisher: {
          name: 'Icare Éditions',
          adresse: '295 impasse des Fauvettes\\\\n13400 Aubagne',
          site: 'https://www.icare-editions.fr',
          logo: '---',
          siret: '123365457895',
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
          level: 1,
          font: 'Keyb', 
          size:24, 
          new_page: true, belle_page: true, lines_before: 8, 
          lines_after:8, interlignage:13
        },
        level2: {
          level: 2,
          font:"Foufe", 
        }
      },
    }

    # - On détruit le dossier du livre avant de commencer -
    book_folder = File.join(__dir__,'essais', book_data[:general][:folder])
    recipe_path = File.join(book_folder,'recipe.yaml')


    checker_recipe = TRecipe.new(recipe_path)
    
    dd = book_data[:general]
    if false # true pour jouer depuis le départ

      FileUtils.rm_rf(book_folder) if File.exist?(book_folder)
      refute File.exist?(book_folder)

      action "Je rentre les informations générales…"
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

    else
      #
      # Si on ne joue pas cette partie, il faut confirmer que le
      # livre est connu et qu'il faut conserver les données
      # 
      tosa << [:RET, dd[:folder], :RET, :RET, :RET]
    end

    if false # true pour définir les fontes
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
    end #/if pour passer

    if false # true pour définir le format
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
      # # - les marges -
      # [:top, :ext, :bot, :int].each_with_index do |bord, idx|
      #   value = dd["#{bord}_margin".to_sym]
      #   tosa << [*(4 + idx).down, :RET, value, :RET]
      # end

      #  On s'arrête là pour le format
      tosa << :RET # enregistrer le format
    end #/if pour passer
    

    # - Recipe Helpers -
    Object.const_set('IR', InitRecipe.new(recipe_path, tosa))

    if false # true si on doit le faire
      dd = book_data[:titres]
      IR.goto(:titres)

      dlev1 = dd[:level1]
      tosa << [:DOWN, :RET] # titre1
      tosa << [:RET] # font
      IR.choose_font(dlev1[:font])
      tosa << [:RET, dlev1[:size].to_s, :RET] # size
      tosa << [:RET, dlev1[:lines_before].to_s, :RET]   # lines before
      tosa << [:RET, dlev1[:lines_after].to_s, :RET]    # lines after
      tosa << [:RET, dlev1[:interlignage].to_s, :RET]   # interligne
      tosa << [:RET, (dlev1[:new_page] ? 'y' : 'n'), :RET]   # Nouvelle page
      tosa << [:RET, (dlev1[:belle_page] ? 'y' : 'n'), :RET]   # Belle page
      tosa << :RET # finir/enregistrer

      tosa.has_in_last_lines("Titre de niveau 1 : Keyb/24.0 - 8/8 - 13.0")

      dlev2 = dd[:level2]
      tosa << [*2.down, :RET] # titre2
      tosa << :RET # font
      IR.choose_font(dlev2[:font])
      # On ne définit que la fonte, pour le titre 2
      tosa << [*4.up, :RET] # finir/enregistrer

      tosa << :RET # Enregistrement des données titres définies

      # --- On vérifie que la recipe contienne bien ces données ---
      checker_recipe.has_data(dd)
    end #/if on doit le faire

    if false # true pour jouer
      IR.goto(:inserted_pages)
      tosa << :RET # on les garde telles qu'elles
    end


    if false # true pour entrer la maision d'édition
      IR.goto(:publisher)
      dd = book_data[:publisher]
      [:name, :adresse, :site, :logo, :siret, :mail, :contact
      ].each do |prop|
        tosa << [:RET, dd[prop], :RET]
      end
      tosa << :RET # enregsitrer

      # --- Vérification ---
      checker_recipe.has_data(dd)
    end

    # --- Information de dernière page ---
    IR.goto(:infos)

    # --- Vérifications ---
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
