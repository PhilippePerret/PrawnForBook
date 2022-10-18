module Prawn4book
class PdfHelpers

  # --- CLASSE ---
  class << self

    ##
    # Charge les méthodes d'instance (helpers) définis pour la
    # collection et pour le livre et instancie ce qui deviendra
    # @pdfhelpers dans pdfbook
    # 
    def create_instance(pdfbook, pdf)
      # 
      # Charger les modules et les évaluer dans l'instance
      # 
      helpers_files(pdfbook).each { |m| require m }
      inst = PdfHelpers.new(pdfbook, pdf)
      inst.extend PrawnHelpersMethods
      return inst
    end

    def helpers_files(pdfbook)
      files = [
        File.join(pdfbook.folder,'helper.rb'),
        File.join(pdfbook.folder,'helpers.rb'),
      ]
      if pdfbook.collection
        files += [
          File.join(pdfbook.collection.folder,'helper.rb'),
          File.join(pdfbook.collection.folder,'helpers.rb'),
        ]
      end

      files.select { |fpath| File.exist?(fpath) }
    end

    def modules_helpers?(pdfbook)
      helpers_files(pdfbook).any?
    end

  end #/ << self


  # --- INSTANCE ---

  attr_reader :pdfbook, :pdf

  def initialize(pdfbook, pdf)
    @pdfbook = pdfbook
    @pdf     = pdf
  end


end #/class PdfHelpers
end #/module Prawn4book
