=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/numerotation_test.rb

  Pour tester toutes les numérotations en faisant un essai grandeur
  nature avec :
    - une table des matières
    - un index
    - une bibliographie
    - pied de page avec numéro de page/paragraphe
  Avec au choix :
    - la numérotation par page
    - la numérotation par paragraphe

  TODO
    J'en suis à 
=end
require 'test_helper'
require_relative 'generated_book/required'
class NumerotationTestor < Minitest::Test

  def setup
    super
    @book = nil
  end

  def teardown
    super
  end

  def focus?
    true # pour jouer seulement celui qui commente sa 1re ligne
    # false # pour les jouer tous
  end

  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  # Instance GeneratedBook::Book (réinitialisée à chaque test)
  def book
    @book ||= begin
      # puts "J'instancie @book".orange
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

################       UTILITAIRES DE TESTS      ###################
  
  def tester_un_livre_avec(props)
    # - Préparation -
    props.merge!({
      top_margin:           40,
      page_de_garde:        true,  # pour voir si pas de numérotation
      page_de_titre:        true,  # idem
      numeroter_titre:      true,  # TODO Rendre opérationnel
      logo:                 'logo.jpg',
      indent:               0,
      dispositions: {
        DP0001: {
          name:"Dispo titres en haut", header_id: :HF001, 
          id: :DP0001, first_page: 6, last_page: 11
        }
      },
      headfooters: {
        HF001: {
          id: :HF001,
          pg_left:  {content: :title1, casse: :all_caps, size: 16, align: :left},
          pd_right: {content: :title2, align: :right},
        },
      },
    })
    resume "
    Test de la numérotation du livre
    "
    # ===> TEST <===
    recipe = Factory::Recipe.new(book.folder)
    recipe.build_with(**props)
    book.build_text(Factory::Text.long_text_with_tdm_and_index)
    book.build
    # ===> VÉRIFICATIONS DE BASE <===
    la_base_du_livre_est_contenue
  end

  def tester_numerotation_par_page_avec(props)
    props.merge!(numerotation: 'pages')
    tester_un_livre_avec(props)
  end
  def tester_numerotation_par_paragraphes_avec(props)
    props.merge!(numerotation: 'parags')
    tester_un_livre_avec(props)
  end

###################       LES TESTS      ###################
  
  def test_adjustement_positions
    return if focus?
    
  end

  def test_numerotation_paragraphes
    return if focus?
    tester_numerotation_par_paragraphes_avec({})
    page(4).has_text("-/-").below(100)
    page(5).has_text("-/-").below(100)
    page(6).has_text("-/-").below(100)
    page(8).has_text("1/2").below(100)
    page(9).has_text("3/5").below(100)
    # - index -
    page(12).has_text(/introduction.+1, 3, 7/)
    page(12).has_text(/mot.+2, 3/)    
    mini_success "Les numéros d'index par paragragrahes sont valides."
  end

  def test_numerotation_paragraphes_autre_format
    # return if focus?
    tester_numerotation_par_paragraphes_avec({
      format_numero: 'first-last', 
      no_num_empty: true, num_only_if_num: true,
      numpag_ifno_numpar: true
    })
    page(4).not.has_text("-/-").below(100)
    page(5).not.has_text("-/-").below(100)
    page(8).has_text("1-2").below(100)
    page(9).has_text("3-5").below(100)
    page(7).has_text("7").below(100) # numéro de page
    page(12).has_text("12").below(100) # numéro de page
  end


  def test_simple_valeurs_par_defaut_num_page
    return if focus?
    tester_numerotation_par_page_avec({})
    # - les numéros de page -
    page(3).not.has_text("3").below(100)
    page(4).has_text("4").below(100)
    page(5).has_text("5").below(100)
    page(5).has_text("5").below(100)
    page(5).has_text("5").below(100)
    page(5).has_text("5").below(100)
    mini_success "Les numéros de page sont bons"
    # - headers - 
    page(8).has_text("GRAND TITRE 1").above(530)
    page(9).has_text("Troisième sous-titre").above(530)
    page(10).has_text("GRAND TITRE 2").above(530)
    page(11).has_text("Troisième sous-titre").above(530)
    mini_success "Les entêtes sont bons"
    # - l'index -
    page(12).has_text(/introduction.+8, 9, 10/)
    page(12).has_text(/mot.+8, 9/)    
    mini_success "Les numéros d'index par pages sont valides."
  end


  def la_base_du_livre_est_contenue
    ftext = Factory::Text
    page(3).has_text(["Mon plus beau livre","Marion MICHEL"])
    page(7).has_text([
      "Table des matières", ftext.long_title1, ftext.title1_subtitle1,
      ftext.title2, ftext.title2_subtitle1, ftext.title2_subtitle2,
      ftext.title3
    ])
    page(8).has_text(["Une introduction à ce livre qui doit servir", "Dans ce sous-titre, on va pouvoir tester"])
    page(9).has_text([ftext.title2, ftext.title2_subtitle1, ftext.title2_subtitle2])
    page(9).has_text("Non anim in nulla proident")
    page(12).has_text(['Index', 'introduction', 'mot'])
    mini_success "Le livre contient la base de texte sur les différentes pages"
  end



private

  def page(x)
    pdf.page(x)
  end

end #/class GeneratedBookTestor
