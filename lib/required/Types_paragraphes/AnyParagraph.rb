module Prawn4book
class PdfBook
class AnyParagraph

  attr_reader :pdfbook

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  def formated_text(pdf, str = nil)
    str ||= text
    # 
    # Traitement des codes ruby 
    # 
    str = str.gsub(/#\{(.+?)\}/) do
      code = $1.freeze
      methode = nil
      if code.match?(REG_HELPER_METHOD)
        # C'est peut-être une méthode d'helpers qui est appelée
        methode = code.match(REG_HELPER_METHOD)[1].to_sym
      end
      if methode && pdfbook.pdfhelpers && pdfbook.pdfhelpers.respond_to?(methode)
        # 
        # Une méthode helper propre au livre ou à la collection
        # 
        pdfbook.pdfhelpers.instance_eval(code)
      else
        #
        # Un code général
        # 
        eval(code)
      end
    end

    # 
    # Traitement des mots indexé
    # 
    if str.match?('index:') || str.match?('index\(')
      str = str.gsub(/index:(.+?)(\b)/) do
        dmot = {mot: $1.freeze, page: first_page, paragraph:numero}
        pdfbook.page_index.add(dmot)
        dmot[:mot] + $2
      end
      str = str.gsub(/index\((.+?)\)/) do
        mot, canon = $1.freeze.split('|')
        dmot = {mot: mot, canon: canon, page: first_page, paragraph: numero}
        pdfbook.page_index.add(dmot)
        dmot[:mot]
      end
    end

    #
    # Traitement des marques bibliograghiques (if any)
    # 
    if Bibliography.any?
      str = str.gsub(Bibliography.reg_occurrences) do
        bib_tag = $1.freeze
        item_id, item_titre = $2.freeze.split('|')
        item_id = item_id.to_sym
        ibib = Bibliography.add_occurrence_to(bib_tag, item_id, {page: first_page, paragraph: numero})
        item_titre || ibib.items[item_id].title
      end
    end

    #
    # Traitement des références
    # 
    if str.match?('\(\( \(')
      str = str.gsub(REG_REFERENCE) do
        ref_id = $1.freeze
        pdfbook.table_references.add(ref_id, {page:first_page, paragraph:numero})
        ''
      end
    end
    # Appels de référence
    if str.match?('\(\( \->\(')
      str = str.gsub(REG_APPEL_REFERENCE) do
        pdfbook.table_references.get($1.freeze)
      end
    end

    return str
  end #/formated_text

  def titre?; false end

REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/

REG_REFERENCE       = /\(\( \((.+?)\) \)\)/
REG_APPEL_REFERENCE = /\(\( +\->\((.+?)\) +\)\)/

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
