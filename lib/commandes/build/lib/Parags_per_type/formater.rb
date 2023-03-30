=begin

Module rassemblant toutes les méthodes qui permettent de formater
les textes (sauf, bien entendu, le formateurs définis pour le livre
ou la collection dans helpers.rb et formaters.rb)

Pourquoi "bien entendu" ci-dessus ????
Ça serait pourtant ici que ça serait le mieux.

=end
module Prawn4book
class PdfBook
class AnyParagraph

  # [String] Le texte final, tel qu'il est vraiment écrit par 
  # pdf.
  attr_reader :final_text
  
  # [Hash] Table des spécifications finales pour l'impression du
  # paragraphe (quel qu'il soit)
  attr_reader :final_specs

  # = main =
  #
  # Préformatage du texte
  # 
  # Une des différences avec le formatage final, par exemple, c'est
  # que ce préformatage se fait avant la construction par les propres
  # builders
  # 
  # C'est @text lui-même qui est modifié
  # 
  # @note
  #   - la méthode preformatage est "détachée" car pour les tables,
  #     par exemple, c'est chaque ligne de texte qui doit être 
  #     formatée séparéement.
  # 
  def preformate_text(pdf)

    detecte_et_traite_nature_paragraphe

    @text = preformatage(text, pdf)

  end

  ##
  # On doit détecter la nature de certains paragraphes avant le
  # formatage pour éviter certains problème. Typiquement, si un
  # paragraphe est un item de liste et qu'il contient un texte en 
  # italique, il peut ressembler à :
  #   * un item de *liste* avec italique
  # Mais s'il est formaté tel quel, alors la portion "* un item de "
  # va être considérée comme en italique.
  # Il faut donc :
  #   - détecter qu'il s'agit un item de liste (self.list_item?)
  #   - retirer la marque de début dans @text
  # On peut ensuite le formater comme convenu
  def detecte_et_traite_nature_paragraphe
    @is_list_item = paragraph? && text.match?(REG_LIST_ITEM)
    if list_item?
      @text = text[1..-1].strip
    end
  end
  REG_LIST_ITEM = /^\* (.*)$/

  def preformatage(str, pdf)
    # 
    # Traitement des codes ruby 
    # 
    # (ce sont tous les codes qui sont mis dans #{...})
    # 
    str = __traite_codes_ruby_in(str)
    # spy "str après code ruby : #{text.inspect}".orange

    # 
    # Traitement des formats inline markdown 
    # (les étoiles, tirets plats, etc.)
    # 
    # Ne sont pas traités ici les listes (qui demande un traitement
    # au moment de l'impression) ou les blocs de notes
    # 
    str = __traite_format_markdown_inline(str)
    # spy "str après format markdown inline : #{text.inspect}".orange
    
    return str
  end

  # = main =
  #
  # Méthode principale qui va produire le texte final qui sera vraiment
  # écrit dans le livre (@final_text).
  # 
  def formate_final_text(pdf)
    @final_specs  = {}
    @final_text   = formate_text(pdf, self.text)
  end

  def formate_text(pdf, str)
    spy "str initial : #{str.inspect}".orange

    if list_item?
      str = formate_as_list_item(pdf, str)
    elsif str.start_with?('> ')
      str = formate_as_citation(pdf, str)
    end
    
    return str
  end

  def formate_as_list_item(pdf, str)
    str = text
    pdf.update do 
      move_cursor_to_next_reference_line
      float { text '– ' }
    end
    final_specs.merge!({mg_left:0.3.cm, no_num: true, cursor_positionned: true})
    return str
  end

  def formate_as_citation(pdf, str)
    str = "<em>#{str[2..-1].strip}</em>"
    final_specs.merge!({size: font_size(pdf) + 2, mg_left: 1.cm, mg_right: 1.cm, mg_top: 0.5.cm, mg_bot: 0.5.cm, no_num:true})
    return str
  end

  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  # + ça permet d'envoyer n'importe quel texte, comme celui provenant
  #   d'un code à évaluer ou d'un tableau (pour le moment, il semble
  #   que les tables ne passent pas par là, peut-être parce qu'elles
  #   sont transformées en lignes et écrites séparément)
  def formated_text(pdf, str = nil)

    raise "Doit devenir obsolète ?"
    # 

    # Soit on utilise le texte +str+ transmis, soit on prend le
    # text du paragraphe.
    # 
    str ||= text

    # spy "str initial : #{str.inspect}".orange

    # 
    # Traitement des marques de formatage spéciales
    # (par exemple 'perso(Selma)' dans la collection narration)
    # TODO C'est traité quelque part, mais il faut tout rassembler
    # ici

    # # 
    # # Traitement des codes ruby 
    # # 
    # str = __traite_codes_ruby_in(str)
    # # spy "str après code ruby : #{str.inspect}".orange

    # 
    # Traitement des mots indexé
    #
    if str.match?('index:') || str.match?('index\(')
      str = __traite_mots_indexed_in(str)
      # spy "str après recherche index : #{str.inspect}".orange
    end

    #
    # Traitement des marques bibliograghiques
    # 
    if Bibliography.any?
      str = __traite_termes_bibliographiques_in(str)
      # spy "str après recherche biblio : #{str.inspect}".orange
    end

    #
    # Traitement des références (appels et cibles)
    # 
    str = __traite_references_in(str)

    # 
    # Traitement du pseudo-format markdown
    # 
    # ATTENTION : cet traitement peut retourner deux éléments
    # 
    str = __traite_pseudo_markdown_format(str, pdf)

    # S'il le faut (options), ajouter la position du curseur en
    # début de paragraphe.
    if paragraph? && add_cursor_position?
      if str.is_a?(Array)
        str[0] = pdf.add_cursor_position(str[0])
      else
        str = pdf.add_cursor_position(str) 
      end
    end

    return str
  end #/formated_text

  ##
  # Pour le debuggage on peut vouloir ajouter la valeur du curseur
  # en début de texte du paragraphe. Pour ce faire, on ajouter
  # l'option '--cursor' à la ligne de commande
  # @rappel
  #   Le "curseur", c'est la hauteur vertical du prochain texte
  #   écrit avec 'pdf.text'
  # 
  # @return [Boolean] true s'il faut ajouter la valeur du curseur
  def self.add_cursor_position?
    :TRUE == @@addcurspos ||= true_or_false(CLI.option(:cursor))
  end
  def add_cursor_position?
    self.class.add_cursor_position?
  end


private

  # 
  # Traitement des codes ruby, qui se présentent dans le texte par
  # « #{...} »
  # Le code à l'intérieur des accolades peut être du code à interpréter
  # tel quel (un opération par exemple, ou une date) ou alors une
  # méthode personnalisée définie dans les helpers.
  # 
  # @return [String] Le texte formaté
  # 
  REG_CODE_RUBY = /#\{(.+?)\}/.freeze
  def __traite_codes_ruby_in(str)
    str.gsub(REG_CODE_RUBY) do
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
  end
  REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/


  def __traite_format_markdown_inline(str)
    # 
    # Les gras ('**')
    # 
    str = __traite_bold(str)
    # 
    # Les italiques
    # 
    str = __traite_italic(str)
    # 
    # Les soulignés
    # 
    str = __traite_underline(str)
    #
    # Les exposants
    # 
    str = __traite_superscript(str)

    return str
  end

  def __traite_bold(str)
    str = str.gsub(REG_BOLD) do
      txt = $1.freeze
      SPAN_BOLD % txt 
    end
  end
  REG_BOLD      = /\*\*(.+?)\*\*/.freeze
  SPAN_BOLD     = "<b>%s<b>".freeze

  def __traite_italic(str)
    return str unless str.match?('\*')
    str .gsub(REG_ETOILE, 'mmSTARmm'.freeze)
        .gsub(REG_ITALIC, SPAN_ITALIC)
        .gsub(REG_START,  '*'.freeze)
  end
  REG_ETOILE    = /\\\*/.freeze
  REG_ITALIC    = /\*(.+?)\*/.freeze
  SPAN_ITALIC   = '<em>\1</em>'.freeze
  REG_START     = /mmSTARmm/.freeze

  def __traite_underline(str)
    return str unless str.match?('_')
    str .gsub(REG_TIRET_PLAT, 'mmTIRETmmPLATmm'.freeze)
        .gsub(REG_UNDERLINE, SPAN_UNDERLINE)
        .gsub(REG_PLAT_TIRET, '_'.freeze)
  end
  REG_TIRET_PLAT = /\\_/.freeze
  REG_UNDERLINE = /__(.+?)__/.freeze
  SPAN_UNDERLINE = '<u>\1</u>'.freeze
  REG_PLAT_TIRET = /mmTIRETmmPLATmm/.freeze

  def __traite_superscript(str)
    str = str.gsub(REG_EXPOSANT) do
      lettre = $1.freeze
      expo   = $2.freeze
      SPAN_EXPOSANT % [lettre, expo]
    end
  end
  REG_EXPOSANT = /([0-9XVIC])\^(er|re|e)/.freeze
  SPAN_EXPOSANT = '%s<sup>%s</sup>'.freeze


end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
