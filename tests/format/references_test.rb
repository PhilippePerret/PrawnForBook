=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/references_test.rb

  Pour tester toutes les références dans un texte, références
  normales (après et avant le texte) et références croisées (dans
  un autre texte)


=end
require 'test_helper'
require_relative 'generated_book/required'
class ReferencesTestor < Minitest::Test

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
  
  def tester_un_livre_avec(props, texte)
    # - Préparation -
    props = {
      # top_margin:           40,
      top_margin:           30,
      page_de_garde:        false,
      page_de_titre:        false,
      numeroter_titre:      true,  # TODO Rendre opérationnel
      numerotation:         'parags',
      logo:                 'logo.jpg',
      indent:               0,
    }.merge(props)
    # ===> TEST <===
    recipe = Factory::Recipe.new(book.folder)
    recipe.build_with(**props)
    book.build_text(texte)
    book.build
    # ===> VÉRIFICATIONS DE BASE <===
    la_base_du_livre_est_contenue
  end

  def la_base_du_livre_est_contenue
    ftext = Factory::Text

  end

  def texte_with_ref_for_pages
    <<~TEXT

    TEXT
  end

  def texte_with_ref_for_parags
    <<~TEXT
    Un premier paragraphe qui contient une cible(( (cible) )).
    Un autre paragraphe qui contient la référence ((( ->(cible) ))) à cette cible.
    (( saut_de_page ))
    Je fais référence à ça ((( ->(post_cible) ))).
    Un paragraphe sans rien.
    Le paragraphe qui mentionne la post-cible(( (post_cible) )).
    (( saut_de_page ))
    Une autre référence ((( ->(cible) ))) à la cible ((( ->(cible) ))).
    TEXT
  end
  def retired
    <<~TEXT
    Un premier paragraphe qui contient une cible(( (cible) )).
    Un autre paragraphe qui contient la référence ((( ->(cible) ))) à cette cible.
    (( saut_de_page ))
    Je fais référence à ça (( ->(post_cible) )).
    Un paragraphe sans rien.
    Le paragraphe qui mentionne la post-cible(( (post_cible) )).
    (( saut_de_page ))
    Une autre référence ((( ->(cible) ))) à la cible ((( ->(cible) ))).
    TEXT
  end

###################       LES TESTS      ###################
  

  def test_references_precedentes_mode_parags
    # return if focus?
    resume "
    Test des références
    (mode paragraphes)
    Des cibles qui précèdent l'appel sont bien traitées
    "

    # ===> TEST <===
    tester_un_livre_avec({numerotation: 'parags'}, texte_with_ref_for_parags)
    page(1).has_text('Un premier paragraphe qui contient une cible.', "La cible a bien été traitée.")
    page(1).has_text("Un autre paragraphe qui contient la référence (paragraphe 1) à cette cible.")
    mini_success "Les cibles définies avant sont bien référencencées"
    page(3).has_text("Une autre référence (paragraphe 1) à la cible (paragraphe 1).")
    mini_success "Un appel à la même cible peut se faire de plusieurs endroits et même dans la même phrase."
    page(2).has_text("Je fais référence à ça (paragraphe 5).")
    page(2).has_text("Le paragraphe qui mentionne la post-cible.")
    mini_success "Un appel peut être défini avant la définition de la cible."
  end

  def test_references_precedentes_mode_page
    return if focus?
    resume "
    Test des références
    (mode page)
    Des cibles qui précèdent l'appel sont bien traitées
    "

    texte = "Un premier paragraphe pour passer le premier (ne pas avoir 1).\nUn paragraphe qui contient une cible(( (cible) )).\n(( new_page ))\nUn autre paragraphe qui contient la référence ((( ->(cible) ))) à cette cible."
    # ===> TEST <===
    tester_un_livre_avec({numerotation: 'pages'}, texte)
    page(1).has_text('Un paragraphe qui contient une cible.', "La cible a bien été traitée.")
    page(2).has_text("Un autre paragraphe qui contient la référence (page 1) à cette cible.")
    mini_success "Les références avec cible avant sont bien traitées"

  end

  def test_custom_prefix
    return if focus?
    resume "
    Test des références
    On peut utiliser un préfixe particulier pour l'appel.
    "
    skip "à traier"
  end

  def test_references_suivante
    return if focus?
    resume "
    Test des références
    Des cibles qui suivent l'appel sont bien traitées
    "
  end


  def test_references_croisees
    return if focus?
    resume "
    Test des références
    Des cibles dans d'autres livres sont bien traitées.
    "
  end


private

  def page(x)
    pdf.page(x)
  end

end #/class GeneratedBookTestor
