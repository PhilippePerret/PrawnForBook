require_relative 'lib/required'
module Prawn4book

  FEATURES_TO_PAGE = {}

  # On consigne cette fonctionnalité (son fichier)
  # 
  # @note
  #   On le fait à son instanciation, alors que sa page n’est pas 
  #   encore définie. Cette page sera définie pendant le premier
  #   tour
  def self.consigne_page_feature(fname, page_title)
    # puts "Consignation de #{fname.inspect} (#{page_title})".jaune
    FEATURES_TO_PAGE.merge!(fname => {title:page_title, page_number:nil})    
  end
  # = main =
  # 
  # Construction des features dans le livre
  def self.build_features(pdf, book)

    # Ordre d'affichage des fonctionnalités
    require_relative 'Features/_FEATURE_LIST_'
    # => FEATURE_LIST

    if first_turn?

      puts "Chargement des features…".bleu
      all_features = FEATURE_LIST.map do |fname|
        next if fname.start_with?('#')
        fpath = File.join(FEATURES_FOLDER, "#{fname}.rb")
        dname = File.basename(fname)
        if File.exist?(fpath)
          PFBError.context = "Chargement de la feature #{fname}"
          # --- Chargement du fichier ---
          STDOUT.write "\rChargement de #{dname}…#{' '*20}".bleu
          load fpath
          # On prend l’instance
          feat = Manual::Feature.last
          # On indique le nom/chemin relatif
          feat.filename = fname
          feat.filepath = fpath
          # Pour les liens de type [[path/feature]], on mémorise la page
          # courante avec le fichier (plus tard dans le flux du 
          # programme, on règlera aussi le numéro de page)
          consigne_page_feature(fname, feat.feature_title)
          # --- Un real-book ---
          if feat.real_book?
            begin
              feat.produce_real_book
            rescue Exception => e
              puts "# Problème à la production du real book de #{fname} : #{e.message}".rouge
              puts "Backtrace:".rouge
              puts e.backtrace.join("\n").orange
              exit 13
            end
            begin
              feat.traite_texte_for_real_book
            rescue Exception => e
              puts "# Problème en traitant le texte du real book de #{fname} : #{e.message}".rouge
              puts "Backtrace:".rouge
              puts e.backtrace.join("\n").orange
              exit 14
            end
          end
          # --- Pour map ---
          feat
        else
          add_erreur "Le fichier feature #{fname.inspect} est à écrire.".orange
          nil
        end
      end.compact

      clear

      # --- On attend que toutes les images soient prêtes ---
      RealBook.wait_for_images_ready || begin
        raise "Impossible de produire les images des real-books."
      end

      all_features.each do |feat|
        msg = "Première impression feature ’#{feat.filename}’"
        logif msg
        PFBError.context = msg
        feat.print_with(pdf, book)
      end


    else

      # = Deuxième Tour =
      
      Manual::Feature.each do |feature|
        PFBError.context = "Seconde impression feature #{feature.filename}"
        feature.print_with(pdf, book)
      end

    end
    
    PFBError.context = nil
  
  end


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

class Bibliography

  # Pour montrer comment avoir une méthode de transformation d’une
  # propriété d’un item de bibliographie dans :format
  def transforme_nom(str)
    "<font size=\"20\"><color rgb=\"059950\">#{str}</color></font>"
  end

end #/class Bibliography

end #/module Prawn4book


module CustomIndexModule
  def index_article(id, output, **context)
    output || id
  end

  def index_film(id, output, **context)
    output || id
  end

  def index_costum(id, output, **context)
    output || id
  end


end
