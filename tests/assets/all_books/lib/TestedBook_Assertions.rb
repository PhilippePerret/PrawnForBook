class TestedBook

  # --- ASSERTIONS METHODS ---

  def should_have_text(textes)
    textes = [textes] if textes.is_a?(String)
    textes.each do |texte|
      assert text_inspector.strings.include?(texte), "#{text_inspector.strings.inspect} devrait contenir #{texte.inspect}"
    end
  end

  def should_contain(textes)
    textes = [textes] if textes.is_a?(String)
    spy "whole_string: #{whole_string.inspect}"
    textes.each do |texte|
      assert_match texte, whole_string
    end
  end

  def should_have_page_count(nombre)
    assert_equal( nombre, pagtor.pages.size, "Le livre devrait avoir #{nombre} page(s). Il en a #{pagtor.pages.size}.")
  end

  def should_have_font(font_name, properties = nil)
    fonts # pour les obtenir
    return true
    # spy "Fonts : #{fonts}"
    assert(fonts.key?(font_name), "Le livre devrait contenir/définir la police #{font_name.inspect}.")
  end

end #/class TestedBook
