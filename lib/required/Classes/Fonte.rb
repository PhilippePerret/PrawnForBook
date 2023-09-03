=begin

  Class Prawn4book::Fonte
  -----------------------
  Pour la gestion facile des fontes dans l'application.

  Permet de centraliser tout ce qui concerne les fontes.

  Avoir des instances permet de faire 'fonte.font', 'fonte.size', 
  etc.

=end
module Prawn4book
class Fonte
####################       CLASSE      ###################
class << self

  public

  # @return [Prawn4book::Fonte] L'instance fonte pour le niveau
  # de titre +level+
  def title(level)
    self.send("title#{level}".to_sym)
  end
  alias :titre :title

  # @return [Prawn4book::Fonte] Les instances fonte pour les titres
  # des différents niveau, soit définis dans la recette du livre
  # courant (livre ou collection) soit par défaut.
  # 
  # @api public
  def title1 ; @title1 ||= titre_default(1, 24.5) end
  alias :titre1 :title1
  def title2 ; @title2 ||= titre_default(2, 22.5) end
  alias :titre2 :title2
  def title3 ; @title3 ||= titre_default(3, 20.5) end
  alias :titre3 :title3
  def title4 ; @title4 ||= titre_default(4, 18.5) end
  alias :titre4 :title4
  def title5 ; @title5 ||= titre_default(5, 16.5) end
  alias :titre5 :title5
  def title6 ; @title6 ||= titre_default(6, 14.5) end
  alias :titre6 :title6
  def title7 ; @title7 ||= titre_default(7, 12.5) end
  alias :titre7 :title7

  # @return [Prawn4book::Fonte] l'instance fonte par défaut ultime,
  # c'est-à-dire qu'elle existe toujours. 
  # 
  # @note
  #   Soit elle retourne la première fonte définie dans la recette
  #   Soit elle retourne la première fonte par défaut de Prawn
  # 
  # @api public
  def default_fonte
    @default_fonte ||= begin
      if book && recipe.default_font_and_style
        font_name, font_style = recipe.default_font_and_style.split('/')
        font_style = font_style.to_sym
        new(font_name, **{style: font_style, size:default_size})
      elsif book && recipe.fonts_data && not(recipe.fonts_data.empty?)
        datafirst = recipe.fonts_data.values.first
          new(recipe.fonts_data.keys.first.to_s, **{style: datafirst.keys.first, size: default_size})
      else
        default_fonte_times
      end
    end
  end

  def default_size
    @default_size ||= begin
      if book && recipe.default_font_size
        recipe.default_font_size
      else
        11
      end
    end
  end

  def default_fonte_times
    @default_fonte_times ||= new("Times-Roman", **{size: default_size, style: :roman})
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
        new(font_name, data_font) 
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


  # @return [Prawn4book::Fonte] Instance pour un titre de niveau
  # +level+ dont la taille sera mise à +size+ si le titre n'est pas
  # défini dans la recette du livre ou de la collection.
  # 
  # @api private
  def titre_default(level, size)
    key_level = "level#{level}".to_sym
    font_name, font_style, font_size =
      if book && recipe.titles_data && (df = recipe.titles_data[key_level])
        # spy "df (data titre level #{level}) : #{df.inspect}".orange
        # 
        # Si le style n'est pas défini, on prend le premier existant
        # 
        df[:style] || get_style_default_for_font(df[:font])
        # 
        # Array des données retourné
        # 
        [df[:font], df[:style], (df[:size]||size)]
      else
        ["Helvetica", :bold, size]
      end
    new(font_name, **{style:font_style, size:font_size})
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

attr_reader :name, :style, :size
attr_reader :hname

public

def initialize(font_name, data)
  @data   = data
  @name   = font_name
  @style  = data[:style]
  @style = @style.to_sym unless @style.nil?
  @size   = data[:size]
  @hname  = data[:hname] # a human name
end

def inspect
  @inspect ||= begin
    d = [name]
    d << style if style
    d << "#{size}pt"  if size
    d.join('/')
  end
end

# @return [Hash] la table des valeurs pour le second argument de
# Prawn::Document#font
def params
  @params ||= {style: style, size: size}
end
end #/class Fonte
end #/module Prawn4book
