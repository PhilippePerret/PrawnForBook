module Prawn4book
class PdfBook
class NTextParagraph

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def self.get_next_numero
    @@last_numero ||= 0
    @@last_numero += 1
  end

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  def initialize(data)
    @data   = data.merge!(type: 'paragraph')
    @numero = self.class.get_next_numero
  end

  # --- Helper Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # 
  def print(pdf, cursor_on_refgrid)
    
    parag = self

    pdf.update do

      # 
      # Indication de la première page du paragraphe
      # 
      parag.first_page = page_number

      if paragraph_number? 
        numero = parag.number.to_s

        # 
        # On place le numéro de paragraphe
        # 
        font "Bangla", size: 7
        # 
        # Taille du numéro si c'est en belle page, pour calcul du 
        # positionnement exactement
        # 
        # Calcul de la position du numéro de paragraphe en fonction du
        # fait qu'on se trouve sur une page gauche ou une page droite
        # 
        span_pos_num = 
          if belle_page?
            wspan = width_of(numero)
            bounds.right + (parag_number_width - wspan)
          else
            - parag_number_width
          end

        @span_number_width ||= 1.cm

        move_cursor_to cursor_on_refgrid - 1
        span(@span_number_width, position: span_pos_num) do
          text "#{numero}", color: '777777'
        end
      end #/end if paragraph_number?

      move_cursor_to cursor_on_refgrid

      # puts "cursor avant écriture paragraphe = #{cursor}"

      final_str = "#{parag.text}"
      final_str = add_cursor_position(final_str) if add_cursor_position?

      font "Garamond", size: 11, font_style: :normal
      # 
      # Le paragraphe va-t-il passer à la page suivante ?
      # (pour pouvoir calculer son numéro de dernière page)
      # 
      final_str_height = height_of(final_str)
      chevauchement = cursor - final_str_height < 0

      # 
      # Écriture du paragraphe
      # 
      begin
        text final_str, 
          align: :justify, 
          size: 11, 
          font_style: :normal, 
          inline_format: true
      rescue Exception => e
        puts "Problème avec le paragraphe #{final_str.inspect}".rouge
        exit
      end
      # 
      # On prend la dernière page du paragraphe, c'est celle sur 
      # laquelle on se trouve maintenant
      # 
      parag.last_page = page_number # + (chevauchement ? 1 : 0)

      # debug rapport
      # puts "Parag ##{parag.numero.to_s.ljust(2)} first: #{parag.first_page.to_s.ljust(2)} last: #{parag.last_page.to_s.ljust(2)}"

    end
  end

  # def margin_bottom; 0  end
  def margin_bottom; 1  end
  def margin_top; nil end

  # --- Predicate Methods ---

  def paragraph?; true end

  # --- Data Methods ---

  def text  ; @text ||= data[:text]||data[:raw_line] end
  def text=(value)
    @text = value
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
