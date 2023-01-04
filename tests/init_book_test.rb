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
      folder:   'book_essais',
      book_data: {
        title:    "Un livre d’essais",
        subtitle: 'Un livre en essai pour faire\\\\ndes tests notamment au niveau\\\\ndes interlignes et lignes de\\\\nréférences.',
        id:       'book_essais',
        auteurs:  'Philippe Perret',
        isbn:     '546-5-12598-24-7',
      },
      publishing: {
          name: 'Icare éditions',
          adresse: '295 impasse des Fauvettes\\\\n13400 Aubagne',
          site: 'https://www.icare-editions.fr',
          logo_path: '---',
          siret: '123365457895',
          mail: 'editions@icare-editions.fr',
          contact: 'contact@icare-editions.fr',
        },
      book_format: {
        book:{          
          width: '203.5mm',
          height: '125mm',
          orientation: 'landscape',
        },
        page:{
          margins:{
            top: '10mm',
            ext: '11mm',
            bot: '12mm',
            int: '13mm',
          }
        },
      },
      page_infos: {
          conception:   {
            patro: 'Benoit PADRIX',
            mail: '---',
          },
          mise_en_page: {
            patro: 'Cédric DE MONTDENARD',
            mail: '---',
          },
          cover:      {
            patro: 'Hugo DESPRAT',
            mail: 'hugo.desprat@gmail.com',
          },
          correction: {
            patro:'Marion MICHEL', 
            mail: 'marionmichel@gmail.com'
          },
          depot_legal: "2e semestre #{Time.now.year + 1}",
        },
      options: {
          numero_parag: 'y',

        },
      fontes: true,
      titles: {
        level1: {
          level: 1,
          font: 'Keyb', 
          size:24, 
          new_page: true, 
          belle_page: true, 
          lines_before: 8, 
          lines_after:7, 
          leading:13
        },
        level2: {
          level: 2,
          font:"Foufe", 
        }
      },
    }

    doit = true # do it

    # - On détruit le dossier du livre avant de commencer -
    book_folder = File.join(__dir__,'essais', book_data[:folder])
    recipe_path = File.join(book_folder,'recipe.yaml')


    checker_recipe = TRecipe.new(recipe_path)
    # - Recipe Helpers -
    #   (pour rejoindre les bons menus avec IR.goto(:<id menu>))
    Object.const_set('IR', InitRecipe.new(recipe_path, tosa))

    dd = book_data[:book_data]
    if doit # true pour jouer depuis le départ

      FileUtils.rm_rf(book_folder) if File.exist?(book_folder)
      refute File.exist?(book_folder)

      action "Je rentre les informations générales…"
      tosa << [
        :RET,                       # un livre
        book_data[:folder], :RET,   # dossier
        :RET, # confirmation du path du dossier
      ]
      IR.goto(:book_data)
      [:title, :subtitle, :id, :auteurs, :isbn].each do |prop|
        tosa << [:RET, dd[prop], :RET]
      end
      tosa << :RET # pour les enregistrer

      # Première vérification de la recette
      checker_recipe.has_data(dd, :book_data)

    else
      #
      # Si on ne joue pas cette partie, il faut confirmer que le
      # livre est connu et qu'il faut conserver les données
      # 
      tosa << [:RET, dd[:folder], :RET, :RET, :RET]
    end

    if doit # true pour définir les fontes
      # --- Définition des fontes ---
      action "Je choisis les fontes"
      IR.goto(:fonts)
      tosa << [
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

    if doit # true pour définir le format
      # --- Définition du format
      action "Je fais entrer les données de format du livre"
      IR.goto(:book_format)
      dd = book_data[:book_format]
      tosa << [:DOWN, :RET, dd[:book][:width], :RET]     # largeur du livre
      tosa << [*2.DOWN, :RET, dd[:book][:height], :RET]  # hauteur du livre
      tosa << [*3.down, :RET]                     # l'orientation
      if dd[:book][:orientation] == 'portrait'
        tosa << :RET
      else
        tosa << [:DOWN, :RET]
      end
      # - les marges -
      [:top, :ext, :bot, :int].each_with_index do |bord, idx|
        value = dd[:page][:margins][bord]
        tosa << [(4 + idx).down, :RET, value, :RET]
      end

      #  On s'arrête là pour le format
      tosa << :RET # enregistrer le format

      checker_recipe.has_data(dd, :book_format)

    end #/if pour passer
    
    if doit # true si on doit le faire
      dd = book_data[:titles]
      IR.goto(:titles)
      # tosa.delay = 0.7 # ralentir pour mieux voir
      dlev1 = dd[:level1]
      tosa << [:DOWN, :RET] # titre1
      tosa << [:RET] # font
      IR.choose_font(dlev1[:font])
      tosa << [:RET, dlev1[:size].to_s, :RET] # size
      tosa << [:RET, dlev1[:lines_before].to_s, :RET]   # lines before
      tosa << [:RET, dlev1[:lines_after].to_s, :RET]    # lines after
      tosa << [:RET, dlev1[:leading].to_s, :RET]   # interligne
      tosa << [:RET, (dlev1[:new_page] ? 'y' : 'n'), :RET]   # Nouvelle page
      tosa << [:RET, (dlev1[:belle_page] ? 'y' : 'n'), :RET]   # Belle page
      tosa << :RET # finir/enregistrer

      tosa.has_in_last_lines("Titre de niveau 1 : Keyb/24.0 - 8/7 - 13.0")

      dlev2 = dd[:level2]
      tosa << [2.down, :RET] # titre2
      tosa << :RET # font
      IR.choose_font(dlev2[:font])
      # On ne définit que la fonte, pour le titre 2
      tosa << [4.up, :RET] # finir/enregistrer

      tosa << :RET # Enregistrement des données titres définies

      # --- On vérifie que la recipe contienne bien ces données ---
      checker_recipe.has_data(dd, :titles)
    end #/if on doit le faire

    if doit # true pour jouer
      IR.goto(:inserted_pages)
      tosa << :RET # on les garde telles qu'elles
    end


    if doit # true pour entrer la maision d'édition
      IR.goto(:publishing)
      dd = book_data[:publishing]
      [:name, :adresse, :site, :logo_path, :siret, :mail, :contact
      ].each do |prop|
        tosa << [:RET, dd[prop], :RET]
      end
      tosa << :RET # enregsitrer

      # --- Vérification ---
      checker_recipe.has_data(dd, :publishing)
    end

    # --- Information de dernière page ---
    dd = book_data[:page_infos]
    IR.goto(:page_infos)
    # tosa.delay = 0.6
    tosa << [:RET, dd[:conception][:patro], :RET]
    tosa << [:RET, dd[:conception][:mail], :RET]
    tosa << [:RET, dd[:mise_en_page][:patro], :RET]
    tosa << [:RET, dd[:mise_en_page][:mail], :RET]
    tosa << [:RET, dd[:cover][:patro], :RET]
    tosa << [:RET, dd[:cover][:mail], :RET]
    tosa << [:RET, dd[:correction][:patro], :RET]
    tosa << [:RET, dd[:correction][:mail], :RET]
    # J'essaie le dépot légal
    tosa.delay = 1
    tosa << [2.up, :RET, dd[:depot_legal], :RET]
    tosa.fast [20.up, :RET] # pour enregistrer

    # - Vérifications infos -
    checker_recipe.has_data(dd, :page_infos)

    # Pour finir de définir la recette et passer au reste
    # (le menu "Finir" est au-dessus)
    tosa << :RET

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


    action "Je demande la construction du livre…"
    tosa.run "cd '#{book_folder}'"
    tosa.run 'pfb build'
    sleep 5

    book_pdf = File.join(book_folder,'book.pdf')
    assert File.exist?(book_pdf), "Le fichier PDF du livre devrait exister (à l'adresse #{book_pdf.inspect}…"

    tosa.finish

  end

end #/InitBookTestor < Minitest::Test
