require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTable < AnyParagraph

  attr_accessor :page_numero
  attr_reader :data

  attr_reader :numero
  alias :number :numero

  attr_reader :pdf
  attr_reader :book

  def initialize(pdfbook, data)
    super(pdfbook)
    @book = pdfbook
    @numero = AnyParagraph.get_next_numero
    @data = data.merge!(type: 'table')
  end


  # --- Printing Methods ---

  def print(pdf)
    @pdf = pdf

    #
    # Check value. Ici, on va calculer les valeurs implicites
    # 
    # Les "valeurs" implicites, ce sont les valeurs non fournies.
    # Par exemple, si on a une table à 3 colonnes mais que dans
    # column_widths on n'en définit que 2 (où qu'une des valeurs est
    # nil) alors on calcule la valeur manquante
    # 
    calc_implicite_values(pdf)

    # 
    # Application de la fonte par défaut
    # (utile par exemple si la table est placée après un titre)
    # 
    pdf.font(Fonte.default_fonte)

    pdf.move_down(pdf.line_height)
    pdf.move_cursor_to_next_reference_line

    #
    # Écriture du numéro du paragraphe
    # 
    print_paragraph_number(pdf) if pdfbook.recipe.paragraph_number?


    begin
      if code_block.nil?
        # puts "lines = #{lines.inspect}"
        pdf.table(lines, table_style)
      else
        pdf.table(lines, table_style, &code_block)
      end
    rescue Prawn::Errors::CannotFit => e
      puts "
      Problème de taille avec la table (elle est certainement trop 
      grande ou la taille des colonnes produisent une taille trop 
      grande.
      Peut-être aussi le contenu des cellules est-il trop grand par
      rapport à leur taille.
      (#{e.message})".rouge
      exit
    end

    pdf.move_down(2 * pdf.line_height)
  end

  # --- Predicate Methods ---

  def paragraph?; false end
  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?
  def titre?    ; false  end

  # Mis en test pour le moment, pour quand on utilise la méthode
  # #formate_all sur le contenu des cellules, qui travaille normale-
  # ment avec une instance paragraphe qui définit cette valeur.
  def list_item?; false end

  # --- Volatile Data Methods ---

  def code_block        ; @code_block       end
  def code_block=(val)  ; @code_block = val  end
  alias :block_code= :code_block=
  alias :blockcode=  :code_block=

  ##
  # Nombre de colonnes (pour vérifications des valeurs implicites)
  # 
  # Cette valeurs est soit donnée explicitement, soit compté en
  # fonction des données de la première ligne.
  def col_count
    @col_count ||= begin
      lines[0].count
    end
  end

  ##
  # Les lignes préparées pour Prawn::Table
  # 
  def lines
    @lines ||= begin
      # 
      # Si la deuxième ligne ne contient que '-', ':' et '|', c'est
      # une ligne qui définit l'alignement dans les colonnes
      # 
      if raw_lines[1] && raw_lines[1].match?(/^[ \-\:\|]+$/)
        raw_lines.shift()
        raw_lines.shift()
      end
      raw_lines.map do |rawline|
        rawline.strip[1...-1].split(/(?!\\)\|/).map do |cell|
          # 
          # Évaluation, si la cellule contient une table
          # 
          cstrip = cell.strip
          if cstrip.start_with?('{') && cstrip.end_with?('}')
            rationalise_pourcentages_in(eval(cstrip))
          elsif cstrip.match?(REG_IMAGE_IN_CELL)
            # 
            # Traitement d'une image
            # 
            found = cstrip.match(REG_IMAGE_IN_CELL)
            _  = found[1]
            image_style = found[2]
            image_style = "{#{image_style}}" unless image_style.start_with?('{')
            image_style = rationalise_pourcentages_in(eval(image_style))
          else
            # 
            # Traitement d'un "simple" texte
            # 
            treate_simple_text(cstrip)
          end
        end
      end
    end
  end
  def lines=(value); @lines = value end

  ##
  # Calcule les valeurs implicites permettant de styliser la table
  # 
  # Les "valeurs implicites" sont des valeurs qui ne sont pas fournies
  # ou qui sont définies de façon générales. Par exemple, une table
  # à trois colonnes peut définir la largeur de seulement 2 colonnes.
  # Il faut donc calculer la valeur de la troisième.
  # 
  def calc_implicite_values(pdf)
    # exit
    return if table_style.nil?
    if table_style.key?(:column_widths) && table_style[:column_widths].is_a?(Array)
      if table_style[:column_widths].count < col_count
        table_style[:column_widths] << nil
      end
      table_style[:column_widths].each_with_index do |wcol, idx|
        # rappel : ici, il n'existe plus de valeurs en pourcentage
        if wcol.nil?
          # Une colonne non définie (note : il ne doit y en avoir
          # qu'une seule)
          # 
          # Largeur de table prise en compte
          # @note
          #   Quand une colonne n'est pas définie et que la largeur
          #   de la table n'est pas définie explicitement, on prend
          #   la largeur totale par défaut.
          # 
          table_width = table_style[:width] || pdf.bounds.width
          reste = table_width - table_style[:column_widths].compact.sum
          table_style[:column_widths][idx] = reste
        end
      end
    end
  end

  def table_style
    @table_style ||= begin
      st = table_definition ? rationalise_pourcentages_in(table_definition) : {}
      st.key?(:cell_style) || st.merge!(cell_style: {})
      st[:cell_style].merge!(inline_format: true)
      [:borders, :border_width].each do |cell_prop|
        if st.key?(cell_prop)
          st[:cell_style].merge!(cell_prop => st.delete(cell_prop))
        end
      end
      st
    end
  end

  # @return [Hash] Table des styles définis (note: c'est une valeur
  # que Prawn-Table peut appréhender — même si calc_implicite_values
  # doit encore faire son travail dessus) c'est-à-dire qu'on y a
  # retirer les propriétés propres à Prawn-for-book à commencer par :
  #   :table_class    Une classe de table définie dans le formateur
  #   :col_count      Le nombre explicite de colonnes.
  # 
  # @note
  #   Pour utiliser ces définitions, utiliser plutôt #style, qui 
  #   contient la même chose mais avec des valeurs rationnelles (pas
  #   de pourcentages)
  # 
  def table_definition
    @table_definition ||= begin
      if pfbcode && pfbcode.parag_style
        ps = pfbcode.parag_style
        if ps.key?(:table_class)
          # 
          # Le code définit un style de table
          # On l'appelle pour qu'il retourne la table de style
          # et qu'il puisse modifier les rangées si nécessaire.
          #
          ps = traite_table_class(ps.delete(:table_class))
          ps = nil unless ps.is_a?(Hash)
        end
        if ps && ps.key?(:col_count)
          @col_count = ps.delete(:col_count)
        end
        ps
      end
    end
  end

  ##
  # Si le pfbcode précédent la table définit :table_class, c'est
  # la class de la table qui doit lui être appliquée. On vérifie
  # d'abord qu'elle soit bien définie puis on l'invoque.
  def traite_table_class(table_class)
    if self.class.respond_to?(table_class)
      begin
        if self.class.method(table_class).arity == 1
          self.class.send(table_class, self)
        elsif self.class.method(table_class).arity == 2
          self.class.send(table_class, self, pdf)
        else
          raise "La méthode #{table_class.inspect} doit accepter un argument, l'instance NTable de la table."
        end
      rescue Psych::SyntaxError => e
        puts "\n\nUne erreur est survenue au cours du parsing du fichier YAML (vers le paragraphe #{numero}) :\n#{e.message}".rouge
        exit
      end
    else
      raise "La méthode de table #{table_class.inspect} doit être définie dans le module TableFormaterModule du fichier formater.rb (de la collection ou du livre)."
    end
  end

  def text
    @text ||= begin
      raw_lines.join("\n")
    end
  end

  # --- Data Methods ---

  def raw_lines  ; @raw_lines   ||= data[:lines]   end

  ##
  # Méthode qui reçoit une table avec des valeurs pouvant définir
  # un pourcentage (p.e. {width:'100%'}) et remplaçant ce pourcentage
  # par une valeur réelle (en ps-point) bonne à traiter par Prawn.
  # 
  # @note
  #   Pour le moment, on ne sait traiter que les valeurs horizontales
  # @note
  #   Traite aussi les textes définis dans des :content
  # @return [Hash] La table corrigée
  def rationalise_pourcentages_in(hash)
    return if hash.nil?
    unless hash.respond_to?(:each)
      raise "hash ne répond pas à each : #{hash.inspect}"
      return hash
    end
    return value_rationalized(hash)
  end

  def value_rationalized(value)
    case value
    when String
      if value.end_with?('%') && value[0...-1].strip.numeric?
        value = value[0...-1].strip.to_f
        page_width * value / 100
      else
        value
      end
    when Hash
      value.each do |k, v|
        v = (k == :content) ? v : value_rationalized(v)
        value.merge!(k => v)
      end
      #
      # Si la table contient :content, il faut parser et formater
      # le texte.
      # Mais la table définit peut-être d'autres valeurs, comme la
      # police ou la taille. Il faut indiquer à :pdf que ce sont les
      # valeurs courantes, mais seulement localement.
      # 
      if value.key?(:content)
        #
        # On prend les options :pdf courante (pour les remettre ensuite)
        # 
        current_pdf_options = pdf.current_options.dup
        #
        # On définit les options provisoires
        # 
        context.merge!(font_size: value[:size]) if value.key?(:size)
        context.merge!(font_name: value[:font]) if value.key?(:font)
        context.merge!(font_style: value[:font_style]) if value.key?(:font_style)
        value.merge!(content: treate_simple_text(value[:content]))
      end
      value
    when Array      
      value.map do |svalue|
        value_rationalized(svalue)
      end
    else # par exemple float ou integer, ou nil
      value
    end
  end

  ##
  # Méthode qui traite complètement, en profondeur et à tous les 
  # niveau, le texte de cellule +str+
  # 
  def treate_simple_text(str)
    str = self.class.__parse(str, context)
    return str
  end

  def context
    # @context ||= {paragraph: self, pdf: pdf}.merge(table_definition)
    @context ||= {paragraph: self}.merge(table_definition||{})
  end

  def page_width
    @page_width ||= pdf.bounds.width.freeze
  end


REG_IMAGE_IN_CELL = /^IMAGE\[(.+?)(?:\|(.+?))\]$/

end #/class NTable
end #/class PdfBook
end #/module Prawn4book