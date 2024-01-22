=begin

  Class Prawn4book::Fonte
  -----------------------
  Pour la gestion facile des fontes dans l'application.

  Permet de centraliser tout ce qui concerne les fontes.

  Avoir des instances permet de faire 'fonte.name', 'fonte.size', 
  etc. et surtout de ne pas avoir à détailler chaque fois le nom,
  le style, la taille et même le leading de chaque fonte.


  Class Prawn4book::FonteGetter
  -----------------------------
  En bas de ce module. Pour récupérer une fonte dans une table.

=end
module Prawn4book
class Fonte

####################       INSTANCE      ###################

attr_reader :name, :style, :size, :color
attr_reader :hname

public

def initialize(name:, style:, size:, hname: nil, color: nil)
  @name   = name
  @style  = style.to_sym
  @size   = size
  @hname  = hname # a human name
  @color  = color || '000000'
  Fonte.add_by_name(self) if hname != ''
  @leadings = {}
end

def reset
  @leadings = {}
end

# La fonte comme table de ses valeurs
def values
  {
    name:   self.name,
    style:  self.style,
    size:   self.size,
    color:  self.color
  }
end

# Retourne les données pour la donnée :styles utilisée par exemple
# dans formatted_text
# 
def styles
  @styles ||= begin
    ary = []
    if italic? || bold?
      ary << :italic if italic?
      ary << :bold   if bold?
    else
      ary << style
    end
    ary
  end
end

# -- Predicate Methods --

def italic?
  style.to_s.match?(/italic/i)
end

def bold?
  style.to_s.match?(/bold/i)
end

# -- Méthodes pour forcer des changements --

def name=(value)
  @name = value
  reset
end
def size=(value)
  @size = value
  reset
end
def style=(value)
  @style = value
  reset
end
def color=(value)
  @color = value
  reset
end
def hname=(value)
  @hname = value
  reset
end

# Leading à utiliser en fonction de la hauteur de ligne courante. 
# Sans argument, on retourne le leading qui a dû être calculé avant. 
# Avec les arguments, on le calcule.
# 
# @note
#   On pourrait aussi n'envoyer que +pdf+ et récupérer son 
#   @line_height, mais je préfère quand même garder la possibilité
#   qu'on puisse calculer une valeur sans que ce soit la valeur 
#   appliquée, par exemple pour faire un calcul en dehors de la 
#   config courante.
# 
def leading(pdf = nil, lineheight = nil)
  return @leadings[LINE_HEIGHT] if pdf.nil? && lineheight.nil?
  lineheight ||= pdf.line_height  || raise(PrawnFatalError.new(ERRORS[:building][:require_line_height]))
  @leadings[lineheight] ||= begin
    # — Leading inconnu, on le calcule -
    pdf || raise(PFBFatalError.new(650, {name:name, pms: params.inspect}))
    lineheight - pdf.real_height_of('Xp', **{font:self.name, size:self.size, style:self.style})
  end
end

# Pour comparer deux fontes
def !=(of)
  self.name != of.name || self.style != of.style || self.size != of.size
end

def inspect
  @inspect ||= begin
    d = []
    d << hname || '<sans nom>'
    d << name.inspect
    d << style.inspect
    d << size.inspect
    d << color.inspect
    d.join('/')
  end
end

# @return [Hash] la table des valeurs pour le second argument de
# Prawn::Document#font
def params
  @params ||= {style: style, size: size}
end
alias :options :params


private

  def book
    @book ||= PdfBook.current
  end



####################       CLASSE      ###################
class << self

  public

  # La fonte courante (c'est toujours dans Prawn::View::font qu'elle
  # est définie)
  attr_accessor :current
  
  # Fonte [Prawn4book::Fonte] par défaut, définie par la recette
  # du livre.
  # Pour pouvoir utiliser n'importe où : <<< Fonte.default >>>
  # 
  # Elle est définie au début de la construction du livre.
  # 
  attr_accessor :default


  # Pour récupérer une fonte dans une table de valeur quelconque
  # 
  # @usages
  # 
  #     Fonte.get_in(<table>).or_default
  # 
  #     Fonte.get_in(<table>).or(<fonte alternative>)
  # 
  # @note
  #   Toutes les méthodes de fonte doivent maintenant utiliser cette
  #   méthode pour définir la fonte. En "font-string" :
  #   "name/style/size/couleur"
  # 
  # @param table [Hash|Nil]
  #   La table qui peut contenir :font définie en tant que string
  #   contenant "name/style/taille/couleur" ou simple nom de font
  #   si table définit :size (ou :font_size), :style (ou :font_style)
  #   :color (ou :font_color)
  # 
  # @param default_values [Hash]
  #   Table pouvant définir :name, :style, :size, :color qui seront
  #   les valeurs de remplacement en cas d’absence d’une valeur. Par
  #   exemple, si table[:font] est définie comme "Courier//12", le
  #   style est la couleur ne sont donc pas définis.
  #   Si default_values = {style: :italic}, alors la fonte sera mise
  #   à {name: ’Courier’, size: 12, style: :italic, color: ’000000’}
  #   (la couleur n’étant pas définie, on prend la couleur par 
  #   défaut)
  # 
  # @return
  #   Une instance FonteGetter dont on va appeler la propriété 
  #   @font si on veut simplement la fonte ou nil si elle n’existe
  #   pas ou la méthode #or_default si on veut la police par défaut
  #   à utiliser (en sachant que ça n’est pas forcément la police
  #   par défaut si des valeurs par défaut ont été envoyées)
  # 
  def get_in(table, default_values = {})
    FonteGetter.new(table || {}, default_values)
  end

  # @return la fonte dont les données sont +dfont+
  # 
  # @param dfont [Hash]
  #   @option :name   [String]  Nom de la fonte
  #   @option :style  |Symbol]  Style de la fonte (tel que défini dans la recette)
  #   @option :size   [Numeric] Taille de la fonte (chaque taille possède sa propre instance)
  #   @option :color  [String]  La couleur
  # 
  # @param return_default [Book]
  #   Si true, on retourne une fonte par défaut en cas de fonte 
  #   introuvable, sinon, on retourne nil (la méthode fournira alors
  #   sa propre méthode par défaut)
  # 
  def get_or_instanciate(dfont, return_default = true)

    @fonts ||= {}

    # - Clé de consignation de la fonte -
    key_font = "#{dfont[:name]}:#{dfont[:style]}:#{dfont[:size]}:#{dfont[:color]}"

    return @fonts[key_font] if @fonts.key?(key_font) || not(return_default)

    #
    # La fonte n'existe pas encore, il faut l'instancier et la
    # consigner.
    # 

    # Les données doivent être valides
    dfont.key?(:size)  || begin
      # add_erreur(PFBError[651] % {dfont: dfont, prop: 'size'})
      dfont.merge!(size: current.size)
    end
    dfont.key?(:style) || begin
      # add_erreur(PFBError[651] % {dfont: dfont, prop: 'style'})
      dfont.merge!(style: current.style)
    end

    # - Clé de consignation de la fonte -
    # (il faut la refaire avec les données peut-être modifiées)
    key_font = "#{dfont[:name]}:#{dfont[:style]}:#{dfont[:size]}:#{dfont[:color]}"

    thefont = new(dfont)
    @fonts.merge!(key_font => thefont)

    return thefont
  end

  # Retourne la police de nom humain +hname+
  # 
  def get_by_name(hname)
    @fonts_by_name[hname]
  end

  def add_by_name(fonte)
    @fonts_by_name ||= {}
    @fonts_by_name.merge!(fonte.hname => fonte)
  end

  # Pour retourner une copie de la fonte par défaut (pour ne pas la
  # toucher)
  def dup_default
    new(name:default.name, size:default.size, style:default.style, color: default.color.dup)
  end

  # Pour dupliquer une police quelconque
  # 
  def dup(fonte)
    new(name:fonte.name.dup, size:fonte.size.dup, style: fonte.style.dup, color: default.color.dup)
  end

  # [Prawn4book::Fonte] Fonte pour du code
  # 
  def code_fonte
    @code_fonte ||= Fonte.new(name:'Courier', style: :regular, size: 12, hname: 'Code Fonte')  
  end

  # @return [Prawn4book::Fonte] l'instance fonte par défaut ultime,
  # c'est-à-dire qu'elle existe toujours. 
  # 
  # @note
  #   - Soit elle retourne la première fonte définie dans la recette
  #     Soit elle retourne la première fonte par défaut de Prawn
  #   - Pour obtenir tout de suite une duplication de cette fonte,
  #     utiliser la méthode ::dup_default
  # 
  # @api public
  def default_fonte
    default
  end

  def default_size
    @default_size ||= begin
      if book
        recipe.default_font.size
      else
        11
      end
    end
  end

  def default_fonte_times
    @default_fonte_times ||= new("Times-Roman", **{size: default_size, style: :roman, color: '000000'})
  end

  # @return [Array<Hash>] La liste des Q-choices pour pouvoir choisir
  # une police associée à un style dans la liste des polices accessibles 
  # (polices définies par la recette et polices par défaut.
  # 
  # @param [Hash] data_choix Les données du choix telles que définies dans les data absolues
  # 
  def as_choices(data_choix)
    prop =  if data_choix.key?(:prop)
              data_choix[:prop]
            elsif data_choix.key?(:simple_key)
              data_choix[:simple_key].split('-').last
            else
              nil
            end
    if prop.to_s.match?(/font_a?nd?_style/)
      # 
      # On doit retourner les paires font/style existant
      # 
      all_fonts_data.map do |font_name, data_font|
        data_font.map do |style, stylepath|
          {name: "#{font_name}/#{style}", value: "#{font_name}/#{style}"}
        end
      end.flatten
    else
      # 
      # On ne doit retourner que la liste des fontes
      #
      all_fonts_data.map do |font_name, data_font|
        {name:font_name, value: font_name}
      end
    end
  end

  # @return la liste des fontes définies
  # 
  # @note
  #   Attention, cette méthode a été "bricolée" en vitesse pour
  #   faire passer l'option -display_grid qui sinon foire
  # 
  def fontes
    @fontes ||= begin
      all_fonts_data.map do |font_name, data_font|
        new(name:font_name, size:data_font[:size], style: data_font[:style]) 
      end
    end
  end

  # @return [Array<Array>] Liste des données des fontes avec les 
  # éléments qui contiennent en premier item le nom de la fonte
  # (par exemple 'Numito') et en second item ses données 
  def all_fonts_data
    @all_fonts_data ||= begin
      recipe.fonts_data.merge(DEFAUT_FONTS)
    end
  end

  # @prop [Prawn4book::PdfBook] Instance du livre courant
  # 
  # @api private
  def book
    @book ||= begin
      Prawn4book::PdfBook.current? && Prawn4book::PdfBook.ensure_current
    end
  end

  # --- Private Methods ---

  private

  # - raccourci -
  def recipe
    @recipe ||= book.recipe
  end


  # Pour les tests
  def reset
    (1..7).each do |niveau|
      self.instance_variable_set("@title#{niveau}", nil)
    end
    @book   = nil
    @recipe = nil
    @default_fonte_times = nil
    @default_fonte = nil
    @default_size  = nil
  end

  def get_style_default_for_font(font_name)
    if book && recipe.fonts_data && recipe.fonts_data.key?(font_name.to_sym)
      recipe.fonts_data[font_name.to_sym].keys.first
    elsif DEFAUT_FONTS.key?(font_name.to_s)
      DEFAUT_FONTS[font_name.to_s].keys.first
    else
      raise "Je ne connais la fonte #{font_name.inspect} ni dans le livre ni dans #{DEFAUT_FONTS.inspect}"
    end || :normal

  end

end #/<< self Fonte
###################       INSTANCE      ###################

end #/class Fonte


#############################################################
# 
# Class FonteGetter
# 
# La classe qui permet d’obtenir une fonte à partir des données
# fonte fournies, quelles qu’elles soient.
# 
class FonteGetter
  attr_reader :table, :default_values
  attr_reader :font
  def initialize(table, default_values)
    table = {font: table} if table.is_a?(String)
    @table = table
    @default_values = default_values
    # On recherche la fonte dans la table fournie
    search_font
  end
  def or_default
    font || Fonte.default
  end
  def or(alt_font)
    font || alt_font
  end
  def search_font
    @font = nil # @semantic
    data_font = table[:font]||table[:fonte]
    nom, style, taille, couleur = [nil, nil, nil, nil]
    # Pour mettre les valeurs qui seraient exprimées en supplément,
    # par valeur explicite (size: 12 par exemple)
    spec_name, spec_style, spec_size, spec_color = [nil, nil, nil, nil]
    if data_font.is_a?(String)
      if data_font.match?('/')
        nom, style, taille, couleur = data_font.split('/').map { |v| v.empty? ? nil : v }
        taille = taille && taille.to_pps
      else
        nom = data_font
      end
    else
      # Old fashion
      if table[:font_name]
        spec_name = table[:font_name]
      end
      if table[:size] || table[:font_size]
        spec_size = (table[:size] || table[:font_size]).to_pps
      end
      if table[:style] || table[:font_style]
        spec_style = table[:style] || table[:font_style]
      end
      if table[:color] || table[:font_color]
        spec_color = table[:color] || table[:font_color]
      end
    end
    # On comble les manques avec les valeurs par défaut
    nom     ||= spec_name  || default_name
    taille  ||= spec_size  || default_size
    style   ||= spec_style || default_style
    couleur ||= spec_color || default_color
    # Si rien n’est défini, on renonce
    return nil if nom.nil? && style.nil? && taille.nil? && couleur.nil?
    # On instancie la fonte
    @font = Fonte.get_or_instanciate(name:nom, style:style, size:taille, color:couleur)
  end

  def default_name
    default_values[:name] || Fonte.default.name
  end
  def default_size
    default_values[:size] || Fonte.default.size
  end
  def default_style
    default_values[:style] || Fonte.default.style
  end
  def default_color
    default_values[:color] || Fonte.default.color
  end
end #/FonteGetter


end #/module Prawn4book
