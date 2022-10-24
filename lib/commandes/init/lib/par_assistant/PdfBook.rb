module Prawn4book
class PdfBook

  # --- CLASSE ---
  class << self
    def cfolder
      @@cfolder ||= File.expand_path('.')
    end
  end #/ class << self

  # --- INSTANCE --- #

  def text_path
    @text_path ||= File.join(folder, "texte#{File.extname(original_text_path)}")
  end

  def original_text_path
    @original_text_path ||= data[:text_path]
  end

end #/class PdfBook
end #/module Prawn4book
