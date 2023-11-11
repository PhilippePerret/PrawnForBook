require_relative 'lib/required'
module Prawn4book

  FEATURES_TO_PAGE = {}

  def self.consigne_page_feature(fname, page_title, page_number)
    FEATURES_TO_PAGE.merge!(fname => {title:page_title, page:page_number})    
  end
  # = main =
  # 
  # Construction des features dans le livre
  def self.build_features(pdf, book)

    # Ordre d'affichage des fonctionnalités
    require_relative 'Features/_FEATURE_LIST_'
    # => FEATURE_LIST

    if first_turn?

      FEATURE_LIST.each do |fname|
        next if fname.start_with?('#')
        fpath = File.join(FEATURES_FOLDER, "#{fname}.rb")
        if File.exist?(fpath)
          # puts "Traitement de #{fname.inspect}".bleu
          # 
          PFBError.context = "Chargement de la feature #{fname}"
          load fpath
          Manual::Feature.last.filename = fname
          PFBError.context = "Première impression de la feature #{fname}"
          Manual::Feature.last.print_with(pdf, book)
        else
          add_erreur "Le fichier feature #{fname.inspect} est à écrire.".orange
        end
      end


    else

      # = Deuxième Tour =
      
      Manual::Feature.each do |feature|
        PFBError.context = "Seconde impression de la feature #{feature.filename}"
        feature.print_with(pdf, book)
      end

    end
    
    PFBError.context = nil
  
  end

end #/module Prawn4book

module Prawn4book
class Feature 



  # On écrit le code en caractère courrier blanc sur du noir
  def print_code
    my = self
    pdf.update do
      move_to_next_line
      text("<em><color rgb='999999'>À écrire dans le fichier texte :</color></em>", **{inline_format: true})
      top_rect = cursor
      move_to_next_line
      font('Numito', **{size: 13, style: :light})
      rest, box = text_box(my.code, **{dry_run:true, at:[0, cursor], width: bounds.width})
      stroke do
        fill_color   'F5FFF5'
        fill_rounded_rectangle [-20, top_rect], bounds.width + 40, box.height + 2 * line_height, 5
      end
      fill_color   '000000'
      box.render
      move_down(box.height + 2 * line_height)
    end
  end


  def produce_rendu(book)
    pdf.update do
      font(Fonte.default_fonte)
      move_to_next_line
      text("<em><color rgb='999999'>Rendu dans le PDF :</color></em>", **{inline_format: true})
    end
    pdf.move_to_next_line
    pdf.move_to_next_line
    code.split("\n").each_with_index do |line, idx|
      book.inject(@pdf, line.strip, idx, self)
    end
  end


private

  def options_text
    @options_text ||= options_communes.merge({

    }).freeze
  end
  def fonte_text
    @fonte_text ||= Fonte.default_fonte
  end

  def options_code
    @options_code ||= options_communes.merge({
      font_name: 'Courrier',
    }).freeze
  end
  def fonte_code
    @fonte_code ||= Fonte.default_fonte
  end

  def options_rendu
    @options_rendu ||= options_communes.merge({
        
    }).freeze
  end
  def fonte_rendu
    @fonte_rendu ||= Fonte.default_fonte
  end

  def options_communes
    @options_communes ||= {      
      inline_format: true,
      align: :justify,
    }.freeze
  end
end #/class Feature
end #/module Prawn4book
