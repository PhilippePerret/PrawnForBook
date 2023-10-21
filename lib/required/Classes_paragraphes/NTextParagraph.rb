require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  THIEF_LINE_LENGTH = 7

  attr_reader :text
  attr_reader :raw_text
  attr_reader :numero

  def initialize(book:, raw_text:, pindex:)
    super(book, pindex)
    @type = 'paragraph'
    @raw_text = raw_text
    #
    # On regarde tout de suite la nature du paragraphe (item
    # de liste ? citation ? etc. pour pouvoir faire un pré-traitement
    # de son texte et pré-définir ses styles)
    pre_parse_text_paragraph
  end

  ##
  # Pré-parsing du paragraphe à l'instanciation
  # Permet de définir sa nature, par exemple citation ou item de
  # liste
  # 
  def pre_parse_text_paragraph


    # TODO : Voir et remettre ce qui est nécessaire
    return



    @is_citation    = raw_text.match?(REG_CITATION)
    @is_list_item   = raw_text.match?(REG_LIST_ITEM)
    # En cas de citation ou d'item de liste, on retire la marque
    # de début du paragraphe ("> " ou "* ")
    @text = raw_text[1..-1].strip if citation? || list_item?

    recup = {}
    tx = NTextParagraph.__get_class_tags_in(raw_text, recup)
    self.class_tags = recup[:class_tags]
    @text = tx
    
    # 
    # Pré-définition des styles en fonction de la nature du paragra-
    # phe de texte
    # 
    if citation?
      @text = "<i>#{@text}</i>"
      add_style({font_size: font_size + 1, margin_left: 1.cm, margin_right: 1.cm, margin_top: 0.5.cm, margin_bottom: 0.5.cm, no_num:true})
    elsif list_item?
      add_style({margin_left:3.mm, no_num: true, cursor_positionned: true})
    elsif table_line?
      # rien à faire
    elsif tagged_line?
      # rien à faire
    end

  end #/pre_parse_text_paragraph

  REG_CITATION    = /^> .+$/.freeze
  REG_LIST_ITEM   = /^\* .+$/.freeze

  
  # --- Printing Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # @note
  #   C'est vraiment cette méthode qui écrit un paragraphe texte,
  #   en plaçant le curseur, en réglant les propriétés, etc.
  # 
  def print(pdf)

    puts "-> print de NTextParagraph".jaune

    #
    # Pour repartir du texte initial, même lorsqu'un second tour est
    # nécessaire pour traiter les références croisées.
    # 
    # @exemple
    #   Par exemple, si le paragraphe est un item de liste, il 
    #   commence par '* '. Mais au préformatage, ce '* ' est retiré
    #   de @text. La deuxième fois qu'on traite l'impression, on se
    #   retrouve(rait) donc avec un @text qui ne commencerait plus 
    #   par '* ' et qui ne serait donc plus un item de liste…
    # 
    @text = raw_text.dup

    puts "  @text = #{@text.inspect}".jaune

    #
    # Quelques traitements communs, comme la retenue du numéro de
    # la page ou le préformatage pour les éléments textuels.
    # 
    super

    # spy "text au début de print (paragraphe) : #{text.inspect}".orange
    
    #
    # Si le paragraphe possède son propre builder, on utilise ce
    # dernier pour le construire et on s'en retourne.
    # Un paragraphe possède son propre builder lorsqu'il est stylé
    # (précédé de "<style>::") et qu'il existe une méthode pour
    # construire ce style dans formater.rb de nom
    #     build_<style>_paragraph
    # 
    return own_builder(pdf) if own_builder?

    #
    # Le texte a pu être déjà écrit par les formateurs personnalisés
    # Dans ce cas, on écrit le numéro du paragraphe si nécessaire et
    # on s'en retourne.
    # 
    # @note
    #   Si le paragraphe doit être numéroté, il faut que la méthode
    #   de formatage elle-même s'en occupe (celle qui met le texte
    #   à nil si c'est le cas, parce qu'elle s'en occupe)
    # 
    if @text.nil? || @text == ""
      return 
    end

    mg_left   = margin_left
    mg_bot    = margin_bottom  || nil # ...
    mg_right  = margin_right
    no_num    = style[:no_num] || false
    cursor_positionned = style[:cursor_positionned] || false

    #
    # Pour invoquer cette instance dans le pdf.update
    # 
    par = self

    #
    # Préformatage par nature de paragraphe
    # 
    # Typiquement, c'est ici qu'on ajoute un "- " au début des items
    # de liste (encore le cas ?)
    # 
    formate_per_nature(pdf)

    # 
    # FONTE (name, taille et style)
    # 
    pdf.update do
      begin
        spy "Application de la fonte : #{Fonte.default_fonte.inspect}"
        font(Fonte.default_fonte)
      rescue Prawn::Errors::UnknownFont
        spy "--- fonte inconnue ---"
        spy "Fontes : #{book.recipe.get(:fonts).inspect}"
        raise
      end
    end

      
    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    begin
      pdf.update do


        par_options = {
          inline_format:true, 
          overflow: :truncate, 
          single_line:true, 
          dry_run:true, 
          width: bounds.width, # modifiable
          align: :justify
        }.freeze


        # Pile pour mettre les lignes à écrire du paragraphe
        # 
        # Les lignes ne seront placées qu'à la fin, une fois que l'on
        # sait s'il y a des orphelines, des veuves, des lignes de
        # voleur et des paragraphes à conserver ensemble
        # 
        paragraphe_stack = [] # pour mettre les box avant de les rendre
      
        # Tant qu'il reste du texte, on boucle pour faire des lignes
        str = par.text.dup
        while str.length > 0

          # Il faudra mettre la ligne sur la prochaine page s'il ne
          # reste pas assez de place
          # 
          this_line_on_next_page = cursor - line_height < 0
          if this_line_on_next_page
            puts "La ligne #{str.inspect} sur la page suivante"
          end
          
          # Fabrication du text-box
          # ------------------------
          # C'est une méthode que j'ai surclassée pour qu'elle 
          # puisse fonctionner avec :dry_run et en même temps retour-
          # ner l'excédant de texte et le box.
          # 
          #   Le :dry_run à true empêche d'écrire le paragraphe
          # 
          # +rest+ contient le texte restant (Array) ou une liste
          # null
          # +box+ est 
          rest, box = text_box(str, **par_options.merge(at: [0, cursor]))

          #
          # S'il reste quelque chose, mais que c'est trop court, il faut
          # jouer sur le kerning du texte courant pour faire remonter le
          # texte ou faire descendre un mot
          # @note TODO Il faut pouvoir régler la longueur de mot minimum
          # 
          has_thief_line = rest.count > 0 && rest.first[:text].length <= THIEF_LINE_LENGTH
          if has_thief_line
            treate_thief_line_in(pdf, stf, **par_options)
          end

          has_no_rest = rest.count == 0


          if this_line_on_next_page || cursor == bounds.height
            #
            # Si le curseur est trop bas
            # 

            this_line_is_last_line = has_no_rest

            #
            # Si c'est la dernière ligne, pour qu'elle ne soit pas
            # veuve, il faut récupérer la dernière du stack pour l'ajouter
            # ensuite.
            # @note : il y a encore un problème ici (ou pour l'orpheline)
            # 
            if this_line_is_last_line && paragraphe_stack.count > 0

              start_new_page
              lines_down(1)

              dernier = paragraphe_stack.pop
              dernier.instance_variable_set('@at', [0, bounds.height])
              lines_kept = [dernier]
              box.instance_variable_set('@at', [0, bounds.height - line_height])
            
            else
            
              lines_kept = []
            
            end

            while rbox = paragraphe_stack.shift
              # Je place un 'move_down' pour la suite, mais le rbox se
              # placerait bien de toutes façons puisqu'il contient son
              # @at qui définit sa position.
              rbox.render 
              move_down(line_height)
            end

            # 
            # On met les/la ligne(s) éventuellement récupérée(s) pour ne
            # pas avoir de veuve
            # 
            paragraphe_stack += lines_kept

          else
            #
            # Passage à la ligne suivante
            # 
            move_down(line_height) # Sans rien toucher d'autre, ça doit être une ligne de référence
          
          end

          if cursor < 0
            start_new_page
            move_to_line(1)
          end        
        
          # 
          # On met la ligne (c'est forcément une ligne) dans le tampon
          # du paragraphe.
          # 
          # La ligne de voleur a été éventuellement traitée avant.
          # 
          paragraphe_stack << box

          break if has_no_rest

          str = rest[0][:text]

        end
        # /loop tant qu'il reste du texte (while str.length > 0)

        # options.merge!(indent_paragraphs: textIndent) if textIndent

        # 
        # On peut écrire les lignes du paragraphe
        # 
        puts "  #{paragraphe_stack.count} lignes à écrire".bleu
        # sleep 2
        while rbox = paragraphe_stack.shift
          rbox.render
          move_down(line_height) # voir la note plus haut
        end


      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise FatalPrawnForBookError.new(100, {
        text:text.inspect, 
        err: e.message, 
        backtrace:(debug? ? e.backtrace.join("\n") : '')
      })
    end

    # 
    # On prend la dernière page du paragraphe, c'est toujours celle
    # sur laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

  end

  # 
  # Pour calculer le character spacing, on fonctionne ne plus en
  # plus fin : dès qu'un c-s fait supprimer la ligne de voleurs
  # on prend le précédent et on affine avec une division plus
  # fine
  def treate_thief_line_in(pdf, rest, **options)
    cs = nil # character-spacing
    snap = 0.1
    last_cs = 0
    while snap > 0.000001
      cs = last_cs
      rest = [1]
      while rest.count > 0
        cs += snap
        rest, box = pdf.text_box(str, **par_options.merge(at:[0,cursor], kerning:true, character_spacing: -cs))
        break if rest.count == 0
        last_cs = cs.dup
      end
      snap = snap / 10 # cran : 0.001 -> 0.0001
    end
    return cs
  end


  def indent
    @indent ||= book.recipe.text_indent
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.end_with?('=')
      prop_name = method_name.to_s[0..-2].to_sym
      if self.instance_variables.include?(prop_name)
        self.instance_variable_set(prop_name, args)
      else
        puts "instances_variables : #{self.instance_variables.inspect}"
        PrawnView.add_error_on_property(prop_name)
        raise "Le paragraphe ne connait pas la propriété #{prop_name.inspect}."
      end
    else
      raise FatalPrawnForBookError.new(200, **{mname: method_name})
    end
  end

  def own_builder?
    return false if class_tags.nil?
    class_tags.each do |tag|
      if self.respond_to?("build_#{tag}_paragraph".to_sym)
        @own_builder_method = "build_#{tag}_paragraph".to_sym
        return true
      end
    end
    return false
  end

  # Constructeur propre
  # TODO : Comme c'est une méthode utilisateur, il faut la protéger
  def own_builder(pdf)
    send(@own_builder_method, self, pdf)
  end

  # --- Predicate Methods ---

  def paragraph?; true end

  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?

  def citation?     ; @is_citation      end
  def table_line?   ; @is_table_line    end
  def tagged_line?  ; @is_tagged_line   end
  def list_item?    ; @is_list_item     end
  attr_accessor :is_list_item

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
