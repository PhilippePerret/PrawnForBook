require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTable < AnyParagraph

  attr_accessor :page_numero
  attr_reader :data

  attr_reader :pdf

  def initialize(pdfbook, data)
    super(pdfbook)
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

    pdf.move_down(pdf.line_height)
    pdf.move_cursor_to_next_reference_line

    args = [lines]
    args << style unless style.nil?

    if code_block.nil?
      pdf.table(*args)
    else
      pdf.table(*args, &code_block)
    end

    # if style.nil?
    #   pdf.table(lines)
    # else
    #   pdf.table(lines, **style)
    # end

    pdf.move_down(2 * pdf.line_height)
  end

  # --- Predicate Methods ---

  def paragraph?; false end
  def sometext? ; true  end
  def titre?    ; false  end

  # --- Volatile Data Methods ---

  def code_block        ; @code_block       end
  def code_block=(val)  ; @code_block = val  end

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
      if raw_lines[1].match?(/^[ \-\:\|]+$/)
        entete = raw_lines.shift()
        aligns = raw_lines.shift()
      end
      raw_lines.map do |rawline|
        dline = rawline.strip[1...-1].split('|').map do |cell|
          # 
          # Évaluation, si la cellule contient une table
          # 
          cstrip = cell.strip
          if cstrip.start_with?('{') && cstrip.end_with?('}')
            rationalise_pourcentages_in(eval(cstrip))
          elsif cstrip.match?(REG_IMAGE_IN_CELL)
            found = cstrip.match(REG_IMAGE_IN_CELL)
            image_path  = found[1]
            image_style = found[2]
            image_style = "{#{image_style}}" unless image_style.start_with?('{')
            image_style = rationalise_pourcentages_in(eval(image_style))
          else
            cell
          end
        end
      end
    end
  end

  def calc_implicite_values(pdf)
    puts "style = #{style.inspect}".bleu
    # exit
    return if style.nil?
    if style.key?(:column_widths) && style[:column_widths].is_a?(Array)
      if style[:column_widths].count < col_count
        style[:column_widths] << nil
      end
      style[:column_widths].each_with_index do |wcol, idx|
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
          table_width = style[:width] || pdf.bounds.width
          reste = table_width - style[:column_widths].compact.sum
          style[:column_widths][idx] = reste
        end
      end
    end
  end

  def style
    @style ||= begin
      if pfbcode
        # S'il y a un pfbcode, il peut définir le style de la table
        # de façon explicite ou par un nom de class (méthode de 
        # formatage dans formater.rb)
        rationalise_pourcentages_in(parag_style)
      else
        nil
      end
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
  def parag_style
    @parag_style ||= begin
      ps = pfbcode.parag_style
      if ps.key?(:col_count)
        @col_count = ps.delete(:col_count)
      end
      if ps.key?(:table_class)
        # 
        # Le code définit un style de table
        # On l'appelle pour qu'il retourne la table de style
        # et qu'il puisse modifier les rangées si nécessaire.
        #
        traite_table_class(ps.delete(:table_class))
      end
      ps
    end
  end

  ##
  # Si le pfbcode précédent la table définit :table_class, c'est
  # la class de la table qui doit lui être appliquée. On vérifie
  # d'abord qu'elle soit bien définie puis on l'invoque.
  def traite_table_class(table_class)
    if self.class.respond_to?(table_class)
      if self.class.method(table_class).arity == 1
        self.class.send(table_class, self)
      else
        raise "La méthode #{table_class.inspect} doit accepter un argument, l'instance NTable de la table."
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
  # 
  # @return [Hash] La table corrigée
  def rationalise_pourcentages_in(hash)
    return if hash.nil?
    unless hash.respond_to?(:each)
      raise "hash ne répond pas à each : #{hash.inspect}"
      return hash
    end
    hash.each do |key, value|
      hash.merge!(key => value_rationalized(value))
    end
    return hash
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
        value.merge!(k => value_rationalized(v))
      end
    when Array      
      value.map do |svalue|
        value_rationalized(svalue)
      end
    else # par exemple float ou integer, ou nil
      value
    end
  end

  def page_width
    @page_width ||= pdf.bounds.width.freeze
  end


REG_IMAGE_IN_CELL = /^IMAGE\[(.+?)(?:\|(.+?))\]$/

end #/class NTable
end #/class PdfBook
end #/module Prawn4book
