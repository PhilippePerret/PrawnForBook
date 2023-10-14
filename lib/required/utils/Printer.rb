#
# Class Prawn4book::Printer
# -------------------------
# Cf. le manuel
# 
module Prawn4book
class Printer

  # --- CLASS Prawn4book::Printer --- #

  class << self

    # -- Registration --

    # Enregistrer un Printer
    # 
    def register(printer, name)
      printer.is_a?(Printer) || raise("Il faut fournir un Printer en premier argument !")
      @printers ||= {}
      if @printers[name]
        raise "Le printer de nom #{name.inspect} existe déjà !"
      end
      @printers.merge!(name => printer)
    end

    # Récupérer un Printer registré
    # 
    def get(name)
      @printers ||= {}
      @printers[name] || raise("Le printer #{name.inspect} est inconnu.")
    end

    # -- Définition des fontes --

    def valueFonte
      @value_fonte ||= Fonte.default
    end
    def valueFonte=(value)
      @value_fonte = value
    end
    def labelFonte
      @label_fonte ||= Fonte.default
    end
    def labelFonte=(value)
      @label_fonte = value
    end
    def titleFonte
      @title_fonte ||= Fonte.new(name:'Helvetica', size:13, style: :bold)
    end
    def titleFonte=(value)
      @title_fonte = value
    end
  end #/<< self


  # --- INSTANCE Prawn4book::Printer --- #

  attr_reader :pdf, :options

  def initialize(pdf, **options)
    @pdf      = pdf
    @options  = defaultize_options(options)
  end

  # -- Helpers de lignes --

  # Ligne pour un titre
  def title(titre, **suboptions)
    me = self
    myclass = me.class
    titleFonte = suboptions[:font] || myclass.titleFonte
    pdf.update do
      move_down(20)
      font(titleFonte) do
        move_cursor_to_next_reference_line
        leading = leading_for(titleFonte, line_height)
        text(titre, **{inline_format: true})
      end
    end
  end
  alias :titre :title

  # Ligne de base avec puce (item de liste)
  # 
  def bx(content, **suboptions)
    me = my = self
    myclass = my.class
    # -- Fonte à utiliser --
    if suboptions[:size]
      fonte = suboptions[:font] || Fonte.dup(valueFonte) || Fonte.dup_default
      # -- Modification de la taille de la police --
      fonte.size = suboptions[:size]
    else
      fonte = suboptions[:font] || valueFonte || Fonte.default
    end
    puce = get_bullet_from(suboptions[:bullet])
    pdf.update do
      start_new_page if cursor < 20
      move_cursor_to_next_reference_line
      float do
        font(fonte) do
          if puce.is_a?(Proc) # quand image
            puce.call
          else
            text(puce, **{inline_format: true})
          end
        end
      end
      span(bounds.width - my.bulcol_width, position: my.bulcol_width) do
        font(fonte) do 
          leading = leading_for(fonte, line_height)
          text(content, **{inline_format:true, leading: leading})
        end
      end
    end    
  end
  alias :bxx    :bx
  alias :bxxx   :bx
  alias :bxxx   :bx
  alias :bxxxx  :bx

  # Ligne de base indentée sans puce (item de liste)
  # 
  def _x(content, **suboptions)
    bx(content, suboptions.merge(bullet: ' '))
  end
  alias :_xx    :_x
  alias :_xxx   :_x
  alias :_xxx   :_x
  alias :_xxxx  :_x

  # Ligne de base avec libellé et valeur (sans puce)
  # 
  def _x_x(values, **suboptions)
    bx_x(values, suboptions.merge!(bullet:' ' ))
  end
  def bx_x(values, **suboptions)
    values.is_a?(Array) || raise("On doit donner un Array à Printer#_x_x")
    label, value = values
    me = my = self
    myclass = me.class
    # - Police à utiliser -
    fontValue = suboptions[:value_fonte] || options[:value_fonte] || valueFonte
    fontLabel = suboptions[:label_fonte] || options[:label_fonte] || labelFonte
    # - Inscription -
    # TODO: En fait, il faudrait regarder quelle est la plus longue
    # valeur, entre le label et le value, et mettre la plus courte
    # dans le float.

    puce = get_bullet_from(suboptions[:bullet])

    pdf.update do
      # -- On se place sur la prochaine ligne de référence --
      move_cursor_to_next_reference_line
      # -- On mémorise la position actuelle du curseur --
      current_cursor = cursor.freeze
      
      # -- Dans tous les cas, on écrit la puce, même si elle est vide
      float do
        if puce.is_a?(Proc) # image
          puce.call
        else
          text(puce, **{inline_format: true})
        end
      end

      # -- LE LABEL (en prenant sa hauteur) --
      label_height = nil
      span(my.labcol_width, position: my.bulcol_width) do
        font(fontLabel) do
          leading = leading_for(fontLabel, line_height)
          text(label, **{inline_format:true, leading: leading})
          label_height = height_of(label, **{inline_format:true, leading:leading})
        end
      end

      # -- LA VALEUR (en prenant sa hauteur) --
      move_cursor_to(current_cursor)
      value_height = nil
      span(bounds.width - (my.labcol_width+my.bulcol_width), position: my.labcol_width + my.bulcol_width) do
        font(fontValue) do
          leading = leading_for(fontValue, line_height)
          text(value, **{inline_format:true, leading: leading})
          value_height = height_of(value, **{inline_format:true, leading:leading})
        end
      end

      # -- On se déplace au plus bas --
      height = [label_height,value_height].max
      move_cursor_to(current_cursor - height)

    end#/pdf.update
  end
  #/ bx_x

  def separator(**params)
    # -- Defaultize parameters --
    params.key?(:color)     || params.merge!(color: '555555')
    params.key?(:thickness) || params.merge!(thickness: 0.3)
    if params.key?(:width)
      w = params[:width]
      if w.is_a?(String) && w.end_with?('%')
        w = (w[0...-1].to_f / 100).to_f * pdf.bounds.width
      end
      if w.is_a?(Numeric)
        lf = (pdf.bounds.width - w) / 2
        params.merge!({right: lf + w})
        params.merge!(left: lf) unless params[:left]
      else
        raise "Je ne sais pas comment traiter la largeur #{w.inspect}. Il faut soit un nombre (<= #{pdf.bounds.width}) soit un pourcentage (<= '100%')."
      end
    else
      params.merge!(right: pdf.bounds.width)
      params.merge!(left: 0) unless params.key?(:left)
    end
    # -- Draw the separator --
    pdf.update do
      # -- Récupération des valeurs actuelles --
      context_color     = stroke_color
      context_thickness = self.line_width
      # -- Affectation des nouvelles valeurs --
      self.line_width = params[:thickness]
      stroke_color params[:color]
      # -- Dessin de la ligne --
      move_down(line_height / 3)
      stroke do 
        horizontal_line(params[:left], params[:right])
      end
      move_down(2 * line_height / 3)
      # -- Réaffection des anciennes valeurs --
      stroke_color(context_color)
      self.line_width(context_thickness)
    end
  end


  # -- Données métriques --

  def bulcol_width
    @bulcol_width ||= options[:tabs][0]
  end

  def labcol_width
    @labcol_width ||= options[:tabs][1]
  end

  # -- Data --

  # Retourne la largeur de la colonne d'index +idx+
  def tab(idx)
    options[:tabs][idx]
  end

  # @return [Numeric] La largeur de la colonne d'index +idx+ 
  # (0-start)
  def col_width(idx)
    options[:tabs][idx]    
  end

  def titleFonte
    @titleFonte || self.class.titleFonte
  end
  def labelFonte
    @labelFonte || self.class.labelFonte
  end
  def valueFonte
    @valueFonte || self.class.valueFonte
  end

  # @return La puce à utiliser
  def bullet
    options[:bullet]
  end

  # -- Pour chaque option une méthode de définition --

  # Définition des tab stops. On peut les définir soit avec une liste
  # qui définit chaque valeur : [20, 50, 200]
  # Soit avec un Hash qui ne définit que certaines colonnes :
  # {1 => 150, 3 => 20}
  # (noter qu'en clé, c'est l'indice 1-start de la colonne) 
  def tabs=(values)
    if values.is_a?(Hash)
      values.each do |col, width|
        options[:tabs][col - 1] = width
      end
    else
      options.merge!(tabs: values)
    end
  end

  def setup=(value)
    options.merge!(setup: value)
  end

  def titleFonte=(value); @titleFonte = value end
  def labelFonte=(value); @labelFonte = value end
  def valueFonte=(value); @valueFonte = value end

  def book
    pdf.pdfbook
  end

  private

    def get_bullet_from(value)
      case value
      when NilClass, :hyphen, :tiret then '–'
      when :square  then '■'
      when :bullet  then '●'
      when :losange then '<font name="PictoPhil">L</font>'
      when :empty_losange then '<font name="PictoPhil">M</font>'
      when :finger  then '☞'
      else
        if value.match?(/(png|jpg|jpeg|tiff|svg)$/i.freeze)
          # - Une image personnalisée -
          img_path = book.existing_path(value)
          Proc.new do 
            pdf.image(img_path, **{width: col_width(0) - 2})
          end
        else
          # - tel quel -
          value
        end
      end      
    end

    def defaultize_options(opts)
      # -- Taille de police --
      opts.key?(:title_size) || opts.merge!(title_size: 13)

      # -- Puce à utiliser --
      opts.merge!(:bullet => get_bullet_from(opts[:bullet]))

      # -- Colonnes virtuelles --
      bcolwidth = 10
      demi = ((pdf.bounds.width - bcolwidth).to_f / 2).round(2)
      opts.key?(:tabs) || opts.merge!(tabs: [bcolwidth, demi, demi])
      tabs = opts[:tabs]
      tabs[0] ||= bcolwidth
      cw = 0
      nilcol = nil
      tabs.each_with_index do |c, idx|
        if c.nil?
          if nilcol.nil?
            # On mémorise la colonne nil
            nilcol = idx.freeze
          else
            raise "Il ne devrait y avoir qu'une seule colonne non définie en largeur…"
          end
        else 
          # On ajoute à la largeur totale définie
          cw += c
        end
      end
      reste = (pdf.bounds.width - cw).round
      reste >= 0 || raise("La largeur des colonnes virtuelles définies est trop large (max: #{pdf.bounds.width}, actuelle: #{cw})")
      if nilcol
        # -- On affecte la valeur de la colonne nil
        tabs[nilcol] = reste
      end

      opts.merge!(tabs: tabs)
      
      return opts
    end

end #/class Printer
end #/module Prawn4book
