=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/bibliographies_test.rb

=end
require 'test_helper'
require_relative 'generated_book/required'
class GeneratedBookTestor < Minitest::Test

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
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

  def test_biblio_without_biblio
    return if focus?
    resume "
    Si l'on demande d'imprimer une bibliographie qui n'existe pas,
    une erreur est levée.
    "
    __make_livres_biblio
    __pour_tester_livre({}, "(( biblio(unknown) ))", **{noop:true})
    err = assert_raises { book.build }
    assert_match("La bibliographie d'identifiant 'unknown' est inconnue", err.message)
  end


  def test_biblio_without_items
    return if focus?
    resume "
    Une bibliographie sans item ne s'inscrit pas dans le livre.
    "
    __make_livres_biblio

    # On fait des fiches 
    biblio = Factory::Bibliography.new(book, 'unknown', 'biblios/unknown')
    biblio.make_items_with_props([:title, :auteur, :date])

    texte = "C'est le premier paragraphe d'un livre qui doit tester le fait qu'une bibliographie bien définie dans la recette, mais qui ne contient pas d'items, ne sera pas affichée.\n(( new_page ))\n(( biblio(unknown) ))"
    unknown_title = "Les Grands Inconnus"
    __pour_tester_livre(data_for_biblios({title: unknown_title}),texte)
    book.build

    # puts "page(2) = #{page(2).text.inspect}"
    # page(2).not.has_text(unknown_title) # POURQUOI ÇA NE FONCTIONNE PAS ?????
    refute_match(unknown_title, page(2).text)
  end



  def test_biblio_with_items
    # return if focus?
    resume "
    Une bibliographie avec des items s'inscrit à l'endroit voulu.
    "
    __make_livres_biblio
    # On fait des fiches 
    biblio = Factory::Bibliography.new(book, 'unknown', 'biblios/unknown')
    fiches = biblio.make_items_with_props([:title, :auteur, :date])
    
    texte = <<~TEXT
    C'est le premier paragraphe d'un livre qui doit tester le fait qu'une bibliographie bien définie dans la recette, qui ne contient des items, est affichée.
    On trouve ça dans unknown(#{fiches[4][:id]}).
    (( new_page ))
    Un premier paragraphe de la page 2. On y fait référence à unknown(#{fiches[0][:id]}|Ma Première fiche) et également à unknown(#{fiches[2][:id]}).
    (( new_page ))
    Ce paragraphe de la page 3 contient une deuxième référence à la fiche 2 (unknown(#{fiches[2][:id]}))

    (( new_page ))

    (( biblio(unknown) ))
    TEXT

    # puts "Le texte : #{texte.inspect}"

    unknown_title = "Les Grands Inconnus"
    __pour_tester_livre(data_for_biblios({title: unknown_title}),texte)
    book.build

    page(5).has_text(unknown_title)
    page(5).has_text([fiches[4][:title], fiches[0][:title], fiches[2][:title]])
    mini_success "On trouve tous les titres utilisés dans la liste bibliographique."
    
    [
      fiches[4][:title], fiches[0][:title], fiches[2][:title]
    ].each do |title|
      page(5).has_text(title, **{count: 1})
    end
    mini_success "On ne trouve chaque titre qu'une seule fois"

    page(2).has_text("Ma Première fiche")
    page(2).not.has_text(fiches[0][:title])
    mini_success "Le texte de substitution a bien été utilisé à la place du title."

    skip "Vérifier l'alignement"
    mini_success "Les écritures des items sont alignés à la grille de référence."
  end


  private

    def page(x)
      pdf.page(x)
    end

    def __pour_tester_livre(props, texte, **options)
      props = {
        book_title: "Essai livre"
      }.merge(props)
      # ===> FABRICATION DU LIVRE <===
      recipe = Factory::Recipe.new(book.folder)
      recipe.build_with(**props)
      book.build_text(texte)
      book.build unless options[:noop]
    end

    def data_for_biblios(data = {})
      {
        bibliographies:{
          biblios: {
            unknown: {
              title: data[:title],
              path: 'biblios/unknown'
            }
          }
        }
      }    
    end

    # Pour faire des livres utilisables comme références croisées
    def __make_livres_biblio
      biblio = Factory::Bibliography.new(book, 'livre', 'biblios/livres')
      biblio.add_item({
        id: 'livre1', 
        title: "Le Livre croisé", 
        refs_path: 'livres/livre1/references.yaml',
        auteur: "John DOE",
        isbn: "125-45698-5-65",
      })
      biblio.add_item({
        id:'livre2', title: 'La Belle Époque', refs_path:'livres/livre2/references.yaml',
        auteur:'Jane DOE'
      })
      # - On fait le fichier de références livres 1 -
      pth_refs = File.join(book.folder,'livres','livre1','references.yaml')
      mkdir(File.dirname(pth_refs))
      File.write(pth_refs, {cible1: {page:2, paragraph:12}}.to_yaml)
      # - On fait le fichier de références livre 2 -
      pth_refs = File.join(book.folder,'livres','livre2','references.yaml')
      mkdir(File.dirname(pth_refs))
      File.write(pth_refs, {
        cible1: {page:2, paragraph:12},
        cible2: {page:4, paragraphe:52},
      }.to_yaml)
    end

end #/class GeneratedBookTestor
