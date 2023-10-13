#
# Class Prawn4book::Printer
# -------------------------
# Cf. le manuel
# 
module Prawn4book
class Printer

  class << self
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
    fonte   = suboptions[:font] || Fonte.dup_default
    if suboptions[:size]
      # -- Modification de la taille de la police --
      fonte.size = suboptions[:size]
    end
    puce = get_bullet_from(suboptions[:bullet])
    pdf.update do
      start_new_page if cursor < 20
      move_cursor_to_next_reference_line
      float do
        font(fonte) do
          text(puce, **{inline_format: true})
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
    fontValue   = suboptions[:value_fonte] || options[:value_fonte] || myclass.valueFonte
    labelFonte  = suboptions[:label_fonte] || options[:label_fonte] || myclass.labelFonte
    # - Inscription -
    # TODO: En fait, il faudrait regarder quelle est la plus longue
    # valeur, entre le label et le value, et mettre la plus courte
    # dans le float.


    puce = get_bullet_from(suboptions[:bullet])
    procBullet = Proc.new do |pdf|
      pdf.text(puce, **{inline_format: true})
    end

    procValue = Proc.new do |pdf|
      pdf.span(pdf.bounds.width - (my.labcol_width+my.bulcol_width), position: my.labcol_width + my.bulcol_width) do
        pdf.font(fontValue) do
          leading = pdf.leading_for(fontValue, pdf.line_height)
          pdf.text(value, **{inline_format:true, leading: leading})
        end
      end
    end

    procLabel = Proc.new do |pdf|
      pdf.span(my.labcol_width, position: my.bulcol_width) do
        pdf.font(labelFonte) do
          leading = pdf.leading_for(labelFonte, pdf.line_height)
          pdf.text(label, **{inline_format:true, leading: leading})
        end
      end
    end

    pdf.update do
      move_cursor_to_next_reference_line
      current_cursor = cursor.freeze
      # if label.length > value.length
        # - Quand le label est plus long que la valeur -
        # float { procBullet.call(self); procValue.call(self) }
        procBullet.call(self)
        move_cursor_to(current_cursor)
        procValue.call(self)
        move_cursor_to(current_cursor)
        procLabel.call(self)
      # else
      #   procBullet.call(self); procLabel.call(self) }
      #   procValue.call(self)
      # end
    end
  end

  def separator
    pdf.move_down(pdf.line_height) # tout simplement
  end


  # -- Données métriques --

  def bulcol_width
    @bulcol_width ||= options[:tabs][0]
  end

  def labcol_width
    @labcol_width ||= options[:tabs][1]
  end

  # -- Data --

  # @return La puce à utiliser
  def bullet
    options[:bullet]
  end

  # -- Pour chaque option une méthode de définition --

  # Définition des tab stops. On peut les définir soit avec une liste
  # qui définit chaque valeur : [20, 50, 200]
  # Soit avec un Hash qui ne définit que certaines colonnes :
  # {1 => 150, 3 => 20}
  def tabs=(values)
    if values.is_a?(Hash)
      values.each do |col, width|
        options[:tabs][col] = width
      end
    else
      options.merge!(tabs: values)
    end
  end

  def setup=(value)
    options.merge!(setup: value)
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
      else value
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
