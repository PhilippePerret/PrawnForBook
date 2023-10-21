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

    @pdf = pdf

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

    no_num    = style[:no_num] || false

    #
    # Pour invoquer cette instance dans le pdf.update
    # 
    par = my = self

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
        if current_fonte && Fonte.default_fonte != current_fonte
          spy "Application de la fonte : #{Fonte.default_fonte.inspect}"
          font(Fonte.default_fonte)
        end
      rescue Prawn::Errors::UnknownFont
        spy "--- fonte inconnue ---"
        spy "Fontes : #{book.recipe.get(:fonts).inspect}"
        raise
      end
    end

    spy "Écriture de « #{text} »"
      
    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    # 
    # Principe :
    # 
    # On établit d'abord la liste des lignes qu'on aura à écrire, en
    # résolvant les lignes de voleur (il ne doit plus y en avoir).
    # 
    # Ensuite, une fois qu'on a toutes les lignes (sous forme de box),
    # on peut les écrire.
    # 
    begin
      pdf.update do

        # Pile pour mettre les lignes à écrire du paragraphe
        # 
        # Les lignes ne seront placées qu'à la fin, une fois que l'on
        # sait s'il y a des orphelines, des veuves, des lignes de
        # voleur et des paragraphes à conserver ensemble
        # 
        paragraphe_stack = [] # pour mettre les box avant de les rendre
      
        # Tant qu'il reste du texte, on boucle pour faire toutes les
        # lignes (box) du paragraphe.
        str = par.text.dup
        while str.length > 0
          
          # Fabrication du text-box
          # ------------------------
          # text_box est une méthode surclassée pour qu'elle fonc-
          # tionne avec :dry_run (donc qu'elle n'imprime pas le para-
          # graphe et qu'elle retourne en même temps l'excédant, dé-
          # signé par +rest+ ci-dessous le box [Text::Formatted::Box
          # ou Text::Box s'il n'y a pas de formatage.
          # 
          # +rest+  [Array<Hash>] Le texte restant ou une liste vide.
          # +box+   [Text::Formatted::Box|Text::Box]
          # 
          # @note
          # 
          #   On se place toujours tout en haut de la page pour 
          #   qu'aucun calcul de passage à la page suivante ne vienne
          #   perturber la vérification. Noter que quel que soit la 
          #   longueur du paragraphe, il sera traité en entier puis-
          #   qu'on fonctionne toujours ligne à ligne ici.
          # 
          rest, box = text_box(str, **par.dry_options)

          # spy "rest = #{rest.inspect}"

          #
          # S'il reste quelque chose, mais que c'est trop court, il faut
          # jouer sur le kerning du texte courant pour faire remonter le
          # texte ou faire descendre un mot.
          # 
          # Donc, ici, on va calculer le character_spacing nécessaire,
          # et on va corriger +box+ pour qu'il intègre le reste. Après
          # cette opération, +rest+ doit être vide.
          # 
          # @note TODO Il faut pouvoir régler la longueur de mot minimum
          #   C'est-à-dire la valeur du THIEF_LINE_LENGTH ci-dessous
          #   et il faut pouvoir le modifier à la volée dans le texte
          # 
          has_thief_line = rest.count > 0 && rest.first[:text].length <= THIEF_LINE_LENGTH
          if has_thief_line
            cs = treate_thief_line_in(pdf, stf, **par.dry_options)
            rest, box = text_box(
              str, 
              **par.dry_options.merge(kerning:true, character_spacing:-cs)
            )
            rest.count == 0 || raise("Il ne devrait rester plus rien.")
          end

          has_no_rest = rest.count == 0

          # 
          # On met toujours la ligne (c'est forcément une ligne) dans 
          # le tampon de ligne du paragraphe.
          # 
          paragraphe_stack << box

          break if has_no_rest

          str = rest[0][:text]

        end
        # /loop tant qu'il reste du texte (while str.length > 0)


        # À partir d'ici, on a dans le tampon de lignes toutes les
        # lignes du paragraphe à écrire.
        spy "Nombre lignes-box à écrire : #{paragraphe_stack.count}"

        # Faut-il passer à la page suivante pour écrire le premier
        # paragraphe ?
        first_line_on_next_page = cursor - line_height < 0

        start_new_page if first_line_on_next_page

        # On boucle sur toutes les lignes pour les écrire
        # À chaque ligne écrite il faut déplacer le curseur sur la 
        # ligne suivante.
        # 
        # is_first_line pour savoir si c'est la première et gérer les
        # orphelines.
        is_first_line = true
        while boxline = paragraphe_stack.shift

          # Nombre de lignes restantes
          nombre_restantes = paragraphe_stack.count

          is_penultimate_line = nombre_restantes == 1

          if is_first_line && (nombre_restantes > 0) &&  cursor - 2 * line_height < 0
            # => Orpheline
            # => Passer tout de suite à la page suivante
            start_new_page
          elsif is_penultimate_line && cursor - 2 * line_height < 0
            # => La suivante serait une Veuve
            # => Passer tout de suite à la page suivante pour que
            #    la ligne suivante ne soit pas seule.
            start_new_page
          end
          boxline.at = [0, cursor] # TODO: CE "0" EST À RÉGLER

          ##############################
          ### IMPRESSION DE LA LIGNE ###
          ##############################
          boxline.render

          # -- On se place sur la ligne suivante --
          move_to_next_line

          is_first_line = false
        end

      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise FatalPrawnForBookError.new(100, {
        text:raw_text.inspect, 
        err: e.message, 
        backtrace:(debug? ? e.backtrace.join("\n") : '')
      })
    end

    # 
    # On prend la dernière page du paragraphe, c'est toujours celle
    # sur laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

  end #/print

  def dry_options
    @dry_options ||= {
      inline_format:true, 
      overflow: :truncate, 
      single_line:true, 
      dry_run:true,
      at:    [margin_left, @pdf.bounds.height],
      width: width || @pdf.bounds.width,
      align: :justify
    }.freeze
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
