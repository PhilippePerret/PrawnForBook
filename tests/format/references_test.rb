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
      bibliographies: {
        biblios: {
          'livre' => {
          title: "Liste des livres", 
          new_page: true,
          path: 'biblios/livres'
          },
        },
      },
    }.merge(props)
    # 
    # On doit fabriquer les éléments pour que la références
    # croisée fonctionne
    # 
    biblio = Factory::Bibliography.new(book, 'livre', 'biblios/livres')
    biblio.add_item({
      id: 'livre1', 
      title: "Le Livre croisé", 
      refs_path: 'livres/livre1/references.yaml',
      auteur: "John DOE",
      isbn: "125-45698-5-65",
    })
    # - On fait le fichier de références livres 1 -
    pth_refs = File.join(book.folder,'livres','livre1','references.yaml')
    mkdir(File.dirname(pth_refs))
    File.write(pth_refs, {cross_reference: {page:2, paragraph:12}}.to_yaml)
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
    Un premier paragraphe pour passer le premier (ne pas avoir 1).
    Un paragraphe qui contient une cible(( <-(cible) )). Et puis une autre (( <-(autre_cible) )) dans le même paragraphe.
    (( new_page ))
    Un autre paragraphe qui contient la référence ((( ->(cible) ))) à cette cible. Et la référence à cette (( ->(autre_cible) )).
    TEXT
  end
  def suite_texte_with_ref_for_pages
    <<~TEXT
    (( saut_de_page ))
    Cette page présente la référence(( <-(avant) )) avant.
    (( new_page ))
    Une paragraphe sur une page sans rien, juste pour passer des pages.
    Le deuxième paragraphe est ici.
    Et le troisième est là.
    (( new_page ))
    Le texte avant ((( ->(avant) ))) doit être placé ici.
    TEXT
  end
  def suite_et_fin_texte_with_cross_ref_for_pages
    <<~TEXT
    Un paragraphe pour rien, sur la page 5 (pour connaitre la page).
    Ce paragraphe contient une référence croisée vers la (( ->(livre1:cross_reference) )).
    (( new_page ))
    (( bibliography(livre) ))
    TEXT
  end

  def texte_with_ref_for_parags
    <<~TEXT
    Un premier paragraphe qui contient une cible(( <-(cible) )).
    Un autre paragraphe qui contient la référence ((( ->(cible) ))) à cette cible.
    (( saut_de_page ))
    Je fais référence à ça ((( ->(post_cible) ))).
    Un paragraphe sans rien.
    Le paragraphe qui mentionne la post-cible(( <-(post_cible) )).
    (( saut_de_page ))
    Une autre référence ((( ->(cible) ))) à la cible ((( ->(cible) ))).
    TEXT
  end

###################       LES TESTS      ###################
  

  def test_references_precedentes_mode_parags
    return if focus?
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
    # return if focus?
    resume "
    Test des références
    (mode page)
    Des cibles qui précèdent l'appel sont bien traitées
    "
    # ===> TEST <===
    texte = texte_with_ref_for_pages + 
      suite_texte_with_ref_for_pages +
      suite_et_fin_texte_with_cross_ref_for_pages
    tester_un_livre_avec({numerotation: 'pages'}, texte)
    page(1).has_text('Un paragraphe qui contient une cible.')
    page(1).has_text("Et puis une autre dans le même paragraphe.")
    page(2).has_text("Un autre paragraphe qui contient la référence (page 1) à cette cible.")
    page(2).has_text("Et la référence à cette page 1.")
    mini_success "Les références avec cibles placées avant les apples sont bien traitées"

    page(3).has_text("Cette page présente la référence avant.")
    page(5).has_text("Le texte avant (page 3) doit être placé ici.")
    mini_success "Les références avec cibles placée après appels sont bien traitée."

    # page(5).has_text(["Ce paragraphe contient une référence croisée vers la page 2 de","Le Livre croisé."])
    [
      "Ce paragraphe contient une référence croisée vers la page 2 de", 
      "Le Livre croisé",
      "Ce paragraphe contient une référence croisée vers la page 2 de Le Livre croisé."
    ].each do |segment|
      assert_match(segment, page(5).text)
      # BIZARREMENT, ne fonctionne pas avec has_text même en
      # donnant les deux textes séparés (le titre séparé de la phrase)
    end
    mini_success "Les références avec cibles croisées sont bien, traitées."

    # TODO
    # mini_success "Les références avant cibles croisées manquantes sont bien traitées."
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

  def test_affichage_bibliographie
    skip "Test de l'affichage des bibliographies"
    # TODO : penser à mettre des pages dans le désordre, par 
    # exemple pour les références croisées (je pense que ça n'est
    # possible que dans ce cas). C'est-à-dire que la liste des
    # pages/paragraphes seraient dans le désordre (p.e. 1,12,3,2)
    # et il faudrait faire attention à ce qu'elle soit toujours
    # classée
    # TODO : s'assurer qu'on a bien : les informations sur 
    # l'élément bibliographique et ses références dans le texte,
    # ses pages ou ses paragraphes (les pages ou les paragraphes
    # où on en parle)
  end

private

  def page(x)
    pdf.page(x)
  end

end #/class GeneratedBookTestor
