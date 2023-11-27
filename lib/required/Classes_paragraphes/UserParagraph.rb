require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class UserParagraph < AnyParagraph

  # Quand l'utilisateur utilise la méthode Printer.pretty_render
  # sans fournir de propriétaire (:owner), un propriétaire de cette
  # classe est aussitôt créé pour permettre les opérations de base
  # sur les héritiers de AnyParagraph.
  # 
  # Amélioration : le texte est parsé avec la même méthode que le
  # texte normal pour définir ce que c’est. Ça produit la propriété
  # @tparagraph

  # L’instance [NTextParagraph|NTitre|NTable etc.] du paragraphe de
  # l’utilisateur.
  attr_reader :regular_paragraph

  def initialize(pdf, text, options)
    super(PdfBook.current, nil)
    @type     = 'user'
    @pdf      = pdf
    @book     = pdf.book
    @text     = text
    @options  = options
    @index    = UserParagraph.next_index
    parse_as_regular_paragraph
  end

  def parse_as_regular_paragraph

    if UserParagraph.current_table
      if text.match?(AnyParagraph::REG_END_TABLE)
        # Ce paragraphe est autre chose qu’un élément de la table.
        # On doit imprimer UserParagraph.current_table
        # print UserParagraph.current_table
        UserParagraph.current_table = nil
      elsif text.match?(AnyParagraph::REG_TABLE)
        UserParagraph.current_table.add_line(text.strip)
        @print_it = false
        return
      end
    end

    if UserParagraph.current_comment
      if text.match?(AnyParagraph::REG_END_COMMENT)
        UserParagraph.current_comment.add(text[0...-3].strip)
        UserParagraph.current_comment = nil
        @print_it = false
      else
        # Suite du commentaire
        UserParagraph.current_comment.add(text)
        @print_it = false
      end
      return
    end

    @regular_paragraph = AnyParagraph.instance_type_from_string(@pdf, text, @index)
    # Par défaut, il faut l’imprimer
    @print_it = true

    # Je fais la suite pour le moment, mais on ne s’en sert pas 
    # vraiment pour le moment (c’est tiré de book.inject)
    if @regular_paragraph.is_a?(NTable)
      UserParagraph.current_table = @regular_paragraph
    elsif @regular_paragraph.is_a?(Empty_paragraph) && @regular_paragraph.comment?
      UserParagraph.current_comment = @regular_paragraph
      @print_it = false
    end

    # 
    # TODO: Peut-être qu’il faudra aussi faire quelque chose comme :
    # (c’est ce qu’on trouve dans book.inject)
    # Mais il faudra faire attention à ce que les index ne s’emmêlent
    # pas les crayons. Car pour rappel, ces index doivent permettre 
    # de localiser rapidement un texte dans un fichier, pour trouver
    # et corriger une erreur. Il faut aussi s’assurer, pour que les
    # index soient bons, que l’instanciation de ces paragraphes user
    # se fassent bien dans le flux général du parsing du texte, ce 
    # qui n’est pas toujours évident si, par exemple, on écrit quel-
    # que chose sur une page particulière (cas qui ne s’est pas en-
    # core posé concrètement).
    # 
    # @regular_paragraph.abs_index = @book.paragraphes.count
    # @book.paragraphes << @regular_paragraph

  end

  # --- Predicate Methods ---


  # Return true si le paragraphe doit être imprimé. C’est-à-dire s’il
  # n’est pas un élément de table ou de commentaire (pour le moment,
  # mais ensuite il faudra voir les pdfcode qui ne sont pas étudiés
  # pour le moment)
  def printed?
    @print_it === true
  end

  def paragraph?; true end
  def title?; regular_paragraph.titre? end
  def table?; regular_paragraph.table? end
    
  class << self

    attr_accessor :current_table
    attr_accessor :current_comment

    # @return [Integer] L’index suivant pour un paragraphe utilisa-
    # teur.
    # (ne sert à rien pour le moment, mais il faudra voir ensuite)
    def next_index
      @last_index ||= 0
      @last_index += 1
    end

  end #/<< self UserParagraph
end #/class UserParagraph
end #/class PdfBook
end #/module Prawn4book
