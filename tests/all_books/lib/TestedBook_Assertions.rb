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
    textes.each do |texte|
      assert_match texte, whole_string
    end
  end

  def should_have_page_count(nombre)
    assert_equal nombre, pager.pages.size, "Le livre devrait avoir #{nombre} page(s). Il en a #{pager.pages.size}."
  end

end #/class TestedBook
