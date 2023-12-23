module Prawn4book
  
  class CalcError < StandardError; end

  # @runner
  class Command
    def proceed; Prawn4book.calc end
  end #/Command

  ERRCALC = {
    text_width_to_big: "La largeur de texte (%s) doit être inférieure à la largeur de page (%s).".freeze,
    text_height_to_big: "La hauteur de texte (%s) doit être inférieure à la hauteur de page (%s).".freeze,
    header_height_to_big: "La hauteur de l’entête (%s) doit être inférieure à la hauteur de page (%s).".freeze,
    footer_height_to_big: "La hauteur du pied de page (%s) doit être inférieure à la hauteur de page (%s).".freeze,
  }

  class << self

    # Unité à utiliser
    attr_reader :unit

    def calc
      book = PdfBook.ensure_current || return
      case CLI.components[0]
      when NilClass # => le livre (pdf, txt, etc.)
        case choisir_quoi_calculer
        when NilClass         then return
        when :int_margin      then calc_thing(:int_margin)
        when :margins         then calc_thing(:margins)
        when :cover           then calc_thing(:cover)
        end
      when 'marge_int', 'int_marge'
        calc_thing(:int_margin)
      when 'marges', 'margins' then
        calc_thing(:margins)
      when 'cover', 'couverture' then
        calc_thing(:cover)
      else
        raise PFBFatalError.new(301, {ca:CLI.components[0].inspect})
      end
    end

    def calc_thing(thing)
      @unit = choisir_unite
      clear
      puts "#{PROMPTS[:Calc_]} #{TERMS[thing]}".jaune
      puts "#{PROMPTS[:Unit]} : #{TERMS[unit]} (#{unit})".jaune
      puts "Page : #{page_width} #{unit} x #{page_height} #{unit}".jaune
      require_relative "calc/calc_#{thing}"
      proceed_calc
    end

    def choisir_quoi_calculer
      clear
      choices = [
        {name:TERMS[:margins],        value: :margins},
        {name:TERMS[:int_margin],     value: :int_margin},
        {name:TERMS[:cover],          value: :cover},
      ]
      precfile = File.join(__dir__, '.precedences')
      choix = precedencize(choices, precfile) do |q|
        q.question PROMPTS[:Calc_]
        q.add_choice_cancel(:up, {value: :cancel, name: PROMPTS[:cancel]})    
      end
    end

    def choisir_unite
      choices = [
        {name:TERMS[:in],       value: :in},
        {name:TERMS[:mm],       value: :mm},
        {name:TERMS[:cm],       value: :cm},
        {name:TERMS[:pt],       value: :pt},
      ]
      precfile = File.join(__dir__, '.precs_unit')
      choix = precedencize(choices, precfile) do |q|
        q.question PROMPTS[:Unit]
        q.add_choice_cancel(:up, {value: :cancel, name: PROMPTS[:cancel]})    
      end
    end

    def book
      @book ||= PdfBook.current
    end

    private

      # --- Helper Methods ---

      def unit_str
        @unit_str ||= TERMS[unit]
      end

      def page_width_str; "#{page_width.round(2)} #{unit}" end
      def page_height_str; "#{page_height.round(2)} #{unit}" end

      # --- Data Methods ---

      # Largeur de page
      def page_width
        page_size[0]
      end
      def page_height
        page_size[1]
      end
      def page_size
        @page_size ||= begin
          if unit != :pt
            conv_method = "pt2#{unit}".to_sym
            book.recipe.page_size.map {|n| n.send(conv_method)}
          else
            book.recipe.page_size
          end
        end
      end

      # Pour demander le nombre de pages
      def ask_for_page_count
        nb = Q.ask("#{PROMPTS[:Page_count]}#{TYPO[:colon]}".jaune) || return
        nb.to_i
      end

  end #/<< self
end #/ module Prawn4book
