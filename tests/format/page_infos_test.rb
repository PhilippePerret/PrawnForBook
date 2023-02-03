require 'test_helper'
require_relative 'generated_book/required'

class PageInfosTest < Minitest::Test

  def setup
    super
    @book = nil # utile ?
  end

  def teardown
    super
  end

  # Pour se concentrer sur un test en particulier
  # Utiliser 'return if focus?' en début des tests sauf celui qu'on
  # travaille.
  def focus?
    # true
    false # pour jouer tous les tests
  end

  # Le livre généré (spécial pour les tests)
  # @note
  #   On s'assure qu'il n'existe pas physiquement à l'instanciation 
  def book
    @book ||= begin
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

  # Le checker du livre
  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  ##
  # @return [Hash] Les données de base qui permettent de produire
  # le livre et particulièrement la page d'informations à la fin
  # du livre.
  # @note
  #   Ici, la table contient toutes les données utiles, il faut donc
  #   en retirer ou les modifier pour tester 
  # 
  def data_recipe
    {
      # -- Données pour infos
      page_infos:           true,
      concepteur:           'Phil Perret',
      concepteur_mail:      'phil@chez.lui',
      metteur_en_page:      'Cédric de Montdénard',
      metteur_en_page_mail: 'cedric@mondenard.com',
      couverture:           'Agnès Brossard',
      couverture_mail:      'agnes.brossard@chez.elle',
      correctrice:          'Marion Michel',
      correctrice_mail:     'marion.michel@gaim.com',
      font_label_infos:     :'Helvetica',
      style_label_infos:    :regular,
      size_label_infos:     10,
      color_label_infos:    '555555',
      font_infos:           :'Times-Roman',
      size_infos:           11,
      disposition_infos:    'distribute',
      depot_legal:          "3e trimestre #{Time.now.year}",
      imprimerie:           "Les Impressions d'Augias",
      imprimerie_ville:     'Aubagne',
      publisher_name:       "Icare éditions",
      publisher_contact:    'contact@icare-editions.fr',
      publisher_mail:       'infos@icare-editions.fr',
      publisher_siret:      '0123456987',
      publisher_url:        'https://www.icare-edition.fr',
      # --/ données pour infos --
      book_titre:           "Le Livre des infos",
      book_auteur:          'Marion Michel',
      isbn:                 '215-8-52698-65-3',
      page_de_titre:        false,
      height:               500,
      margin_top:           20,
      margin_bottom:        20,
      line_height:          23,
      page_de_garde:        false,
      faux_titre:           false,
    }    
  end


  def build_without_all_infos(data_for_recipe)
    book.recipe.build_with(data_for_recipe)
    book.build_text("Un livre pour tester la page des informations")
    err = assert_raises { book.build }
    return err    
  end

  def test_raise_without_all_infos
    return if focus?
    resume "
    Si toutes les informations nécessaires n'ont pas été données
    pour produire la page d'infos dont l'impression est demandée, 
    Prawn-for-book génère une erreur et ne construit pas le livre.
    "

    action "J'oublie de donner la maison d'édition"
    dr = data_recipe.dup
    dr.merge!(publisher_name: nil)
    err = build_without_all_infos(dr)
    assert_match(/Impossible de produire la page d'informations/, err.message)
    assert_match(/Est requis : la maison d'édition/, err.message)
    refute(File.exist?(book.book_path), "Le livre ne devrait pas avoir été produit.")
    mini_success "L'erreur a bien été générée et le livre n'a pas été produit."

    @book = nil
    action "J'oublie de donner le concepteur rédacteur"
    dr = data_recipe.dup
    dr.merge!(concepteur: nil)
    err = build_without_all_infos(dr)
    assert_match(/Impossible de produire la page d'informations/, err.message)
    assert_match(/Est requis : le concepteur\/rédacteur/, err.message)
    refute(File.exist?(book.book_path))
    mini_success "L'erreur a bien été générée et le livre n'a pas été produit."

    @book = nil
    action "J'oublie de donner la correctrice et l'imprimerie"
    dr = data_recipe.dup
    dr.merge!(correctrice: nil, imprimerie: nil)
    err = build_without_all_infos(dr)
    assert_match(/Impossible de produire la page d'informations/, err.message)
    assert_match(/Sont requis : la correctrice et l\'imprimerie/, err.message)
    refute(File.exist?(book.book_path))
    mini_success "L'erreur a bien été générée et le livre n'a pas été produit."

  end


  def test_page_produite_avec_bonnes_informations_distributed
    return if focus?
    resume "
    Avec les bonnes informations, la page d'information est produite
    avec succès avec une disposition distribuée.
    "
    # ===> TEST <===
    dr = data_recipe.dup.merge(disposition: 'distribute')
    book.recipe.build_with(dr)
    book.build_text("Un livre avec page d'infos, les informations sont distribuées dans la page.")
    book.build

    # --- Vérifications ---
    page = pdf.page(3)
    [:concepteur, :isbn, :publisher_url, :publisher_siret, :publisher_mail,
      :publisher_contact, :publisher_name, :imprimerie_ville, :imprimerie,
      :depot_legal, :correctrice_mail, :correctrice, :couverture_mail,
      :couverture, :metteur_en_page_mail, :metteur_en_page, 
      :concepteur_mail, :concepteur
    ].each do |prop|
      page.has_text(data_recipe[prop])
    end
  end

  def test_page_produite_avec_bonnes_informations_at_bottom
    return if focus?
    resume "
    Avec les bonnes informations, la page d'information est produite
    avec succès avec une disposition en BAS DE PAGE.
    "
    # ===> TEST <===
    dr = data_recipe.dup.merge(disposition: 'bottom')
    book.recipe.build_with(dr)
    book.build_text("Un livre avec page d'infos, les informations sont rassemblées en bas de page.")
    book.build

    # --- Vérifications ---
    page = pdf.page(3)
    [:isbn, :publisher_url, :publisher_siret, :publisher_mail,
      :publisher_contact, :publisher_name, :imprimerie_ville, :imprimerie,
      :depot_legal, :correctrice_mail, :correctrice, :couverture_mail,
      :couverture, :metteur_en_page_mail, :metteur_en_page, 
      :concepteur_mail, :concepteur
    ].each do |prop|
      page.has_text(data_recipe[prop])
    end
    page.has_text(dr[:publisher_name]).below(250)
    page.has_text("Conception & rédaction : #{dr[:concepteur]}")
    page.has_text("Mise en page : #{dr[:metteur_en_page]} (#{dr[:metteur_en_page_mail]})")
    page.has_text("Correction & relecture : #{dr[:correctrice]} (#{dr[:correctrice_mail]})")
    page.has_text("Imprimé par : #{dr[:imprimerie]} (#{dr[:imprimerie_ville]})")
  end

  def test_page_produite_avec_bonnes_informations_at_top
    return if focus?
    resume "
    Avec les bonnes informations, la page d'information est produite
    avec succès avec une disposition des informations en HAUT DE PAGE.
    "
    # ===> TEST <===
    dr = data_recipe.dup.merge(disposition: 'top')
    book.recipe.build_with(dr)
    book.build_text("Un livre avec page d'infos, les informations sont rassemblées en bas de page.")
    book.build

    # --- Vérifications ---
    page = pdf.page(3)
    [:isbn, :publisher_url, :publisher_siret, :publisher_mail,
      :publisher_contact, :publisher_name, :imprimerie_ville, :imprimerie,
      :depot_legal, :correctrice_mail, :correctrice, :couverture_mail,
      :couverture, :metteur_en_page_mail, :metteur_en_page, 
      :concepteur_mail, :concepteur
    ].each do |prop|
      page.has_text(data_recipe[prop])
    end
    page.has_text(dr[:publisher_name]).above(250)
    page.has_text("Conception & rédaction : #{dr[:concepteur]}")
    page.has_text("Mise en page : #{dr[:metteur_en_page]} (#{dr[:metteur_en_page_mail]})")
    page.has_text("Correction & relecture : #{dr[:correctrice]} (#{dr[:correctrice_mail]})")
    page.has_text("Imprimé par : #{dr[:imprimerie]} (#{dr[:imprimerie_ville]})")
  end

  def test_page_produite_avec_bonnes_informations_minimales
    return if focus?
    resume "
    Avec les informations minimales, la page d'information est produite
    avec succès en bas de page.
    "
    # ===> TEST <===
    not_data = {
      isbn: nil, 
      publisher_siret:nil, publisher_mail:nil, publisher_contact:nil,
      imprimerie_ville:nil, couverture_mail: nil,
      metteur_en_page_mail:nil, concepteur_mail:nil, depot_legal:nil,
    }
    dr = data_recipe.dup.merge(not_data)
    book.recipe.build_with(dr)
    book.build_text("Un livre avec page d'infos, les informations sont rassemblées en bas de page.")
    book.build

    # --- Vérifications ---
    page = pdf.page(3)
    [:concepteur, :publisher_url,
      :publisher_name, :imprimerie, :correctrice_mail, :correctrice,
      :couverture, :metteur_en_page, :concepteur
    ].each do |prop|
      page.has_text(data_recipe[prop])
    end
    not_data.each do |prop, null|
      page.not.has_text(data_recipe[prop])
    end
  end



end #/class PageInfosTest
