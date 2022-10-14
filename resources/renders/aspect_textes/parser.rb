module ParserParagraphModule
  class << self
    def init_parser
    end

    ##
    # Méthode appelée en fin de construction du livre
    # pour écrire un rapport
    def report
      puts "Fin d'opération.".jaune
    end

  end #/self



  def __paragraph_parser(paragraphe)

  end

  #
  # Instancier le parseur au chargement du module
  # 
  init_parser
end


module PrawnCustomBuilderModule # ce nom est absolument à respecter

  # def round(val)
  #   r = val.round(2)
  #   r.end_with?('.0') ? val.to_i.to_s : r
  # end

  # def text_info(pdf, prev_cursor = nil)
  #   c = cursor.freeze
  #   t = "à #{round(c)}"
  #   t = "#{t} [+ #{round(prev_cursor - c)}" if prev_cursor
  #   return t
  # end

  # 
  # Ici doit être défini les choses à faire avec les informations
  # qui ont été parsées
  #
  def __custom_builder(pdf)


    essai_extensions_prawn_document(pdf)



    pdf.instance_eval do

      def text_info(pdf, prev_cursor = nil)
        c = cursor.freeze
        t = "à #{round(c)}"
        t = "#{t} [+ #{round(prev_cursor - c)}" if prev_cursor
        return t
      end

      def write_with_info(methode = :text, texte = nil, args = {})
        if methode.is_a?(String)
          args = texte || {}
          texte = methode
          methode = :text
        end
        c = cursor.freeze
        c_round = round(c)
        self.send(methode, "[#{round(c)}] #{texte}", args)
        nc = cursor.freeze
        text_box "[+ #{round(c - nc)}]", at:[bounds.right - 50, c], align: :right, width:50
      end


      start_new_page

      # --- Début des essais ---

      font 'Garamond', size:11

      c = cursor
      text "default_leading = #{default_leading} #{text_info(self)}"

      write_with_info("Une ligne en size 11")
      font 'Garamond', size: 12
      write_with_info("Une ligne en size 12")
      font 'Garamond', size: 11
      write_with_info("Une ligne assez longue pour qu'elle tienne sur plusieurs lignes pour voir ce qu'elle va faire come ça. Il faut vraiment qu'elle tiennen sur au moins trois lignes.")
      fill_color 'DD0000'
      stroke_color '00DD00'
      write_with_info("Cette ligne se trouve", {mode: :stroke})
      stroke_color 'FFFFFF'
      fill_color '000000'

      # -----

      font "Garamond", size: 11
      default_leading 0
      
      c1 = cursor.freeze      


      start_new_page


      font "Garamond", size: 11
      default_leading 0

      c7 = cursor.freeze
      text "AVEC UN DEFAULT_LEADING DE 0 (Garamond, 11) [#{c7.round(2)}]"

      move_down(10)
      c8 = cursor.freeze
      text "move_down(10) [#{c8.round(2)} +#{(c7 - c8).round(2)}]"

      c1 = cursor.freeze
      text = "Ligne à #{cursor}" 
      taille = height_of("Ligne").round(2)
      text "#{text} de taille #{taille}"
      c2 = cursor.freeze
      text "Ligne à #{cursor} [+#{(c1 - c2).round(2)}]"

      move_down(10)

      c3 = cursor.freeze
      text = "Ligne à #{c3.round(2)}"
      font 'Garamond', size: 20
      taille = height_of(text).round(2)
      text "#{text} size:20, taille = #{taille}", size: 20
      c4 = cursor.freeze
      text "Ligne à #{cursor.round(2)} [+#{(c3-c4).round(2)}]"

      move_down(10)

      c5 = cursor.freeze
      text "Ligne size 20 à #{cursor.round(2)}", size: 20
      c6 = cursor.freeze
      text "Ligne size 20 à #{cursor.round(2)} [+#{(c5-c6).round(2)}]", size: 20

      # -----

      move_down(10)

      font "Garamond", size: 11
      default_leading -2

      text "AVEC UN DEFAULT_LEADING DE -2 (Garamond, 11)"

      c1 = cursor.freeze
      text = "Ligne à #{cursor}" 
      taille = height_of("Ligne").round(2)
      text "#{text} de taille #{taille}"
      c2 = cursor.freeze
      text "Ligne à #{cursor} [+#{(c1 - c2).round(2)}]"

      move_down(10)


      c3 = cursor.freeze
      text = "Ligne à #{c3.round(2)}"
      font 'Garamond', size: 20
      taille = height_of(text).round(2)
      text "#{text} size:20, taille = #{taille}", size: 20
      c4 = cursor.freeze
      text "Ligne à #{cursor.round(2)} [+#{(c3-c4).round(2)}]"

      move_down(10)

      c5 = cursor.freeze
      text "Ligne size 20 à #{cursor.round(2)}", size: 20
      c6 = cursor.freeze
      text "Ligne size 20 à #{cursor.round(2)} [+#{(c5-c6).round(2)}]", size: 20


    
    end # instance pdf



    return

    grand_titre_index = Prawn4book::PdfBook::NTitre.new(
      text: "Index", level: 1)
    pdf.insert(grand_titre_index)
    pdf.font 'Garamond', font_style: :normal
    ParserParagraphModule.table_mots.each do |imot, destinations|
      # puts "Traitement index de : #{imot.inspect}"
      # pdf.formatted_text [
      #   {text: imot.mot, size: 10},
      #   {text: destinations.map{|d|d[:parag_num].to_s}.join(', '), size: 8 }
      # ]
      pdf.text_box "#{imot.mot} ".ljust(100,'.'), size:10, at:[0, pdf.cursor], width: 100, overflow: :truncate
      pdf.text destinations.map{|d|d[:parag_num].to_s}.join(', '), size: 8
    end

    grand_titre_filmo = Prawn4book::PdfBook::NTitre.new(
      text: "Liste des films", level: 1)
    pdf.insert(grand_titre_filmo)
    pdf.font 'Garamond', font_style: :normal
    ParserParagraphModule.table_films.each do |ifilm, destinations|
      pdf.formatted_text [
        {text: ifilm.titre, size: 10},
        {text: destinations.map{|d|d[:parag_num].to_s}.join(', '), size:8}
      ]
    end

  end


  ##
  # Pour essayer les méthode ajoutées
  # 
  # GRILLE DE RÉFÉRENCE
  # Prefix : refgrid_
  # Par exemple : refgrid_hline = hauteur de ligne (interligne) de la grille de référence
  # 
  def essai_extensions_prawn_document(pdf)

    long_texte  = "Un texte assez long. " * 20
    texte_moyen = "Un texte plutôt moyen. " * 10
    
    pdf.instance_eval do 

      start_new_page

      font 'Garamond', size:11

      h = height_of("A")
      text "Hauteur de A size:11 lead:0 : #{h}"

      h = height_of("A", leading: -1)
      text "Hauteur de A size:11 lead:-1 : #{h}"

      h = height_of("A", leading: -1.5)
      text "Hauteur de A size:11 lead:-1.5 : #{h}"

      start_new_page

      text "Recherche progressive du leading, centième par centième."
      text "Cette recherche permet de trouver la valeur leading qui est nécessaire pour que les lignes du texte courant soient sur les lignes de références."
      lead = font2leading('Garamond', 11, 12)
      font 'Garamond', size:11
      text "Hauteur de A size:11 leading: #{lead} pour faire 12"
      text "Démonstration sur un long texte :"
      text "----------"
      c = cursor.freeze
      text "[#{round(c)}] #{long_texte}", leading: lead
      c2 = cursor.freeze
      text "[#{round(c2)}] +#{round(c - c2)}"
      text "----------"

      font_size = 18
      lead = font2leading('Garamond', font_size, 12)
      font 'Garamond', size:11
      text "Hauteur de A size:font_size leading:#{round(lead)} pour faire 12"
      text "Démonstration sur un long texte :"
      text "----------"
      font 'Garamond', size:font_size
      c1 = cursor.freeze
      text "[#{round(c1)}] #{texte_moyen}", leading: lead
      c2 = cursor.freeze
      text "[#{round(c2)}] +#{round(c1 - c2)}"
      font 'Garamond', size:11
      text "----------"



      h = height_of("A", size:14)
      text "Hauteur de A size:14 = #{h}"


      start_new_page

      font "Nunito", size: 20
      text "Essai des fontes"

      move_down(10)
      mafont = font('Garamond', size:11)
      # text "La baseline : #{mafont.methods.inspect}"
      text "Garamond 11 ascender: #{mafont.ascender} / descender: #{mafont.descender} / height: #{mafont.height} / x_height: #{mafont.x_height}"

      move_down(10)
      mafont = font('Garamond', size:13)
      text "Garamond 13 ascender: #{mafont.ascender} / descender: #{mafont.descender} / height: #{mafont.height} / x_height: #{mafont.x_height}"
      
      move_down(10)
      mafont = font('Garamond', size:11, default_leading:0)
      # text "La baseline : #{mafont.methods.inspect}"
      text "Garamond 11 default_leading:0 / ascender: #{mafont.ascender} / descender: #{mafont.descender} / height: #{mafont.height} / x_height: #{mafont.x_height}"

      move_down(10)
      mafont = font('Garamond', size:11, default_leading:1)
      text "Garamond 11 default_leading:1 / ascender: #{mafont.ascender} / descender: #{mafont.descender} / height: #{mafont.height} / x_height: #{mafont.x_height}"

      move_down(10)
      mafont = font('Garamond', size:11, default_leading:-1)
      text "Garamond 11 default_leading:-1 / ascender: #{mafont.ascender} / descender: #{mafont.descender} / height: #{mafont.height} / x_height: #{mafont.x_height}"

      hline = 12
      rapport = mafont.height / hline # p.e. 13.2 / 12 => 1.1 
      #  Ou 12 / 13.2 => 0.9
      c1 = cursor.freeze
      text "[#{round(c1)}] #{long_texte}", leading:-0.909, size:11
      c2 = cursor.freeze
      text "[#{round(c2)}] [+ #{round(c1 - c2)}]"



      start_new_page

      font "Nunito", size: 20
      text "Essais du leading"

      font 'Garamond', size: 11

      c1 = round(cursor.freeze)
      hauteur = height_of("[#{c1}] Leading: 0 / #{long_texte}", leading: 0)
      hline = height_of("A", leading: 0)
      text "[#{c1}] Leading: 0 / HLine: #{hline} / H: #{hauteur} #{long_texte}", leading: 0

      c3 = round(cursor.freeze)
      hauteur = height_of("[#{c1}] Leading: 0 / #{long_texte}", leading: -0.5)
      hline = height_of("A", leading: -0.5)
      text "[#{c3}] Leading: -0.5 / HLine: #{hline} / H: #{hauteur} #{long_texte}", leading: -0.5

      c4 = round(cursor.freeze)
      hauteur = height_of("[#{c1}] Leading: 0 / #{long_texte}", leading: -1.5)
      hline = height_of("A", leading: -1.5)
      text "[#{c4}] Leading: -1.5 / HLine: #{hline} / H: #{hauteur} #{long_texte}", leading: -1.5

      c2 = round(cursor.freeze)
      hauteur = height_of("[#{c2} Leading: 4 / #{long_texte}", leading: 4)
      hline = height_of("A", leading: 4)
      text "[#{c2} Leading: 4 / HLine: #{hline} / H: #{hauteur} / #{long_texte}", leading: 4


      start_new_page

      # line_height retourne la hauteur de ligne
      c1 = cursor.freeze
      text "[#{round(c1)}] Font:#{default_font} - Size:#{default_font_size} — LineHeight: #{line_height} – Baseline:#{baseline_height}"

      # next_baseline Permet de passer à la ligne de référence 
      # suivante
      next_baseline

      c2 = cursor.freeze
      text "[#{round(c2)}] Sur la ligne de référence [+#{round(c1 - c2)}]"

      # next_baseline(x) permet de passer à la xe ligne de référence
      # suivante
      next_baseline(4)

      c3 = cursor.freeze
      text "[#{round(c3)}] Sur la 4e ligne de référence [+#{round(c2 - c3)}]"
    end

  end

end #/module

