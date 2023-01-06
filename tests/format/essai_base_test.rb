require 'test_helper'

class PrawnTestDeBase < Minitest::Test

  def show_methods_of(instance, instance_name)
    methodes = instance.class.instance_methods(false)
    methodes.each do |methode|
      if methode.to_s.end_with?('=') || methode.to_s.start_with?('set_')
        puts "#{instance_name}.#{methode}"
      else
        begin
          puts "#{instance_name}.#{methode} = #{instance.send(methode).inspect}"
        rescue Exception => e
          puts "Problème avec : #{methode.inspect} : #{e.message}".rouge
        end
      end
    end    
  end

  def test_pour_essai_simple
    actual = 2 + 2
    expect = 4
    assert_equal expect, actual
  end

  def test_liste_des_methodes_de_pdf_reader
    
    lepath  = "./tests/test.pdf"
    letexte = "Bonjour tout le monde !"
    pdf = Prawn::Document.generate(lepath) do
      text letexte
    end

    inspector = PDF::Reader.new(lepath)

    puts "\n\nMÉTHODES DE L'INSTANCE `PDF::Reader'".bleu
    show_methods_of(inspector, 'PDF::Reader.new(path)')
    puts "\n\nMÉTHODES D'UNE PAGE DE L'INSTANCE `PDF::Reader'".bleu
    first_page = inspector.pages[0]
    show_methods_of(first_page, 'PDF::Reader.new(path).pages[0]')

  end

  def test_contenu_pdf
    skip "Passer l'essai avec PDF::Inspector"
    letexte = "Bonjour tout le monde !"
    pdf = Prawn::Document.generate("./tests/test.pdf") do
      text letexte
    end

    pdfile = File.new("./tests/test.pdf")
    inspector = PDF::Inspector

    text_verifier = verifieur = inspector::Text.analyze(pdfile)

    # Les méthodes
    show_methods_of(verifieur, 'PDF::Inspector::Text.analyze(...)')


    properties = verifieur.instance_variables

    properties.each do |property|
      next if property.to_s.end_with?('=')
      next if property == :@state
      begin
        puts "PDF::Inspector::Text.analyze(...)#{property} = #{verifieur.instance_variable_get(property).inspect}"
      rescue Exception => e
        puts "Problème avec : #{property.inspect} : #{e.message}".rouge
      end
    end

    textes = text_verifier.strings
    nombre_de_textes = textes.count

    assert_equal 1, nombre_de_textes, "Il ne devrait y avoir qu'un seul texte."
    assert_equal letexte, textes[0], "Le texte devrait être « #{letexte} », or c'est « #{textes.first} »"

    analfile = PDF::Inspector::Text.analyze(pdfile)
    puts "analyze_file methods : #{analfile.class.instance_methods(false)}"
    puts "analyze_file variables : #{analfile.instance_variables}"
    puts "character spacing: #{analfile.character_spacing}"



  end

end #/Minitest
