# =begin

#   class Prawn4book::HeadersFooters::Headfooter
#   --------------------------------------------
#   En tant que classe, elle consigne les données des headfooters
#   En tant qu'instance, c'est la classe abstraite des classes filles
#   Header(s) et Footer(s).

# =end
# module Prawn4book
# class HeadersFooters
# class Headfooter
# ###################       CLASSE      ###################
# class << self
#   ##
#   # @return [Hash] la table de donnée du headfooter d'identifiant
#   # +hf_id+
#   # 
#   # @note
#   #   - "hf" pour "headfoot" et "id" pour "identifiant". Il s'agit donc
#   #     de l'identifiant du "headfoot" qui définit l'entête et le 
#   #     pied de page.
#   #   - Comme l'utilisateur peut les définir à la main, on s'assure de
#   #     pouvoir les trouver, avec l'identifiant symbolique ou string
#   # 
#   def get(hf_id)
#     data[hf_id.to_s] || data[hf_id.to_sym] || raise("L'headfooter d'identifiant #{hf_id.inspect} est inconnu…")
#   end
#   # Les données des headfooters (telles qu'elles sont définies
#   # dans la propriété :headers_footers de la recette du livre)
#   def data=(value)  ; @data = value   end
#   def data          ; @data           end
# end #/ << self

# ################### INSTANCE (Abstract Class)   ###################
#   attr_reader :data

#   # @prop [Disposition] La disposition qui utilise ce headfooter
#   attr_reader :disposition

#   # @props Le livre et le pdf (hérités de la disposition)
#   attr_reader :book, :pdf

#   def initialize(disposition, data)
#     @data         = data
#     @disposition  = disposition
#     # - raccourcis -
#     @book         = disposition.book
#     @pdf          = disposition.pdf
#   end

#   ##
#   # Construction de l'headfooter
#   # 
#   def build
#     # 
#     # @note
#     #   ni @name ni @id ne semblent définis, ici
#     # 
#     spy "-> Construction de l'headfooter <<#{name}>> (ID #{id})".jaune
#     build_even_pages if pd_left || pd_right || pd_center
#     build_odd_pages  if pg_left || pg_right || pg_center
#     spy "<- /fin construction headfooter ID #{id}".jaune
#   end

#   ##
#   # Construction de l'headfooter sur les pages paires
#   #
#   def build_even_pages
#     build_pages(:even)
#   end
#   ##
#   # Construction de l'headfooter sur les pages impaires
#   # 
#   def build_odd_pages
#     build_pages(:odd)
#   end

#   # Construction des headers-footers des pages +side+
#   # 
#   # @param [Symbol] side Soit :even soit :odd
#   def build_pages(side)
#     spy "   * Construction pages #{side.inspect}".jaune
#     pdf.repeat(side, **{dynamic: true}) do
#       numero = pdf.page_number
#       #
#       # Si la page courante ne se trouve pas dans le rang des pages
#       # concernées par l'head-foot, on passe à la suivante.
#       # 
#       next unless page_in_range?(numero)

#       #
#       # Si la page se trouve dans les pages à exclure
#       next if book.pages[numero].no_pagination?

#       #
#       # Sinon, on prend les données de la page
#       # 
#       bpage = get_data_page(numero)  # instance BookData
#       if bpage
#         #
#         # Définition de la méthode à utiliser en fonction du côté
#         # de la page (even ou odd). "procedure_[even|odd]_page" va
#         # retourner une procédure pour écrire ce qu'il faut là où il
#         # le faut.
#         # 
#         # @noter que c'est une méthode qu'on appelle pour définir
#         # cette méthode.
#         # 
#         procedure = self.send("procedure_#{side}_page".to_sym)
#         #
#         # Appel de la méthode avec les données de la page courante
#         # pour écrire ce qu'il faut sur cette page précisément.
#         # 
#         procedure.call(bpage)
#         spy "Page #{numero} traitée".vert
#         # puts "Page #{numero} traitée".vert
#       else
#         # add_erreur("Impossible d'obtenir la page ##{numero.inspect}… Je ne peux pas traiter ses headers/footers.")
#         # spy "Minor error : impossible d'obtenir la page #{numero.inspect}… Je ne peux pas traiter ses headers/footers.".orange
#         # Il ne s'agit plus d'une erreur maintenant, mais d'une page
#         # qui est "sautée" parce qu'elle n'a pas de contenu et ne doit
#         # donc pas être entêtée.
#       end
#     end
#   end

#   def procedure_even_page
#     @procedure_even_page ||= procedure_any_page(pg_left, pg_center, pg_right, :even)
#   end
#   def procedure_odd_page
#     @procedure_odd_page ||=  procedure_any_page(pd_left, pd_center, pd_right, :odd)
#   end

#   # Fabrication de la procédure d'écriture de l'entête et du pied
#   # de page qui sera appliqué à chaque page.
#   # 
#   def procedure_any_page(dleft, dcenter, dright, side)
#     # 
#     # Procédure (vide) pour mettre les autres code
#     # 
#     proce = Proc.new { |bpage| bpage }
#     # 
#     # On ajoute tous les tiers nécessaires
#     # 
#     # @rappel
#     #   Une entête et un pied de page sont définis par leur tiers,
#     #   à gauche, à droite et au centre de la page.
#     # 

#     #
#     # La dimension par défaut est toujours d'un tiers
#     # 
#     w = tiers

#     if dleft
#       #
#       # Si l'entête ou le pied de page définit une partie à gauche
#       # 
#       dleft.merge!(align: :left) unless dleft.key?(:align)
#       #
#       # Affinement de la taille en fonction de la présence des autres
#       # éléments
#       # 
#       w += tiers unless dcenter
#       w += tiers unless dright
#       dleft.merge!(width: w)
#       #
#       # Procédure de construction de ce tiers en particulier
#       # 
#       procleft = Proc.new { |bpage|
#         build_tiers(bpage, [0, top], dleft)
#       }
#       proce = (proce << procleft)
#     end

#     if dcenter
#       #
#       # Si l'entête ou le pied de page définit une partie centrale
#       # 
#       dcenter.merge!(align: :center) unless dcenter.key?(:align)
#       #
#       # Décalage à gauche du tiers (pour être au centre s'il y a 
#       # d'autres tiers)
#       # 
#       lf  = dleft ? tiers : 0
#       #
#       # Affinement de la taille suivant la présence des autres tiers
#       # 
#       w  += tiers unless dleft
#       w  += tiers unless dright
#       dcenter.merge!(width: w)
#       #
#       # Finalisation de la procédure et ajout à la procédure générale
#       # 
#       proccenter = Proc.new { |bpage|
#         build_tiers(bpage, [lf, top], dcenter)
#       }
#       proce = (proce << proccenter)
#     end
#     if dright
#       # 
#       # Si l'entête ou le pied de page définit une partie à droite
#       # 
#       dright.merge!(align: :right) unless dright.key?(:align)
#       #
#       # On affine la largeur en fonction de la présence ou non des
#       # autres tiers
#       # 
#       w   = (dcenter ? dleft ? 1 : 2 : dleft ? 2 : 3) * tiers
#       dright.merge!(width: w)
#       #
#       # On affine la position à gauche en fonction des autres tiers
#       # 
#       lf  = (dcenter||dleft ? dcenter ? 2 : 1 : 0) * tiers
#       #
#       # Fabrication du bout de procédure et ajout à la procédure
#       # principale.
#       # 
#       procright = Proc.new { |bpage|
#         build_tiers(bpage, [lf, top], dright)
#       }
#       proce = (proce << procright)
#     end
#     proce
#   end

#   ##
#   # === Écriture du tiers +dtiers+ de l'entête
#   #     ou du pied de page dans la page +bpage ===
#   # 
#   # @return [BookPage] La page (pour l'addition des procédures)
#   # 
#   # @param bpage [Prawn4book::HeadersFooters::BookPage]
#   # 
#   #   Instance de page du livre.
#   # 
#   # @param at [Paire]
#   # 
#   #   Position du tiers
#   # 
#   # @param dtiers [Hash]  
#   # 
#   #   Données du tiers, à commencer par {:content}
#   # 
#   def build_tiers(bpage, at, dtiers)
#     if at == [0,0]
#       # at[1] = -15
#     end
#     props = common_tiers_props.merge({
#       at:         at, 
#       align:      dtiers[:align], 
#       width:      dtiers[:width]},
#       overflow:   :expand,
#       height:     20
#       )
#     # 
#     # Le contenu textuel
#     # ------------------
#     # Il dépend de sa classe.
#     # 
#     # @note
#     #   Lorsque dtiers[:content] est un symbol, c'est une méthode
#     #   de la page (BookPage) qui sera appelée pour retourner le
#     #   contenu. 
#     #   C'est le cas typique pour un numéro de page : 
#     #   dtiers[:content] est alors égal à :numéro, c'est donc la 
#     #   méthode BookPage#numero qui est appelée.
#     # 
#     content = 
#         case dtiers[:content]
#         when String       then get_content_as_custom_text(dtiers[:content])
#         when Numeric      then dtiers[:content].to_s
#         when Symbol
#           # p.e. :numero
#           bpage.send(dtiers[:content])
#         when Proc, Method then dtiers[:content].call(bpage)
#         end.to_s # peut être vide
#     content = 
#         case dtiers[:casse]
#         when :all_caps then content.upcase 
#         when :all_min  then content.downcase
#         else content
#         end
#     # 
#     # Fonte à appliquer
#     # 
#     lafonte = fonte(dtiers)
#     #
#     # Alignement du contenu
#     # 
#     props_text = {align: props.delete(:align)}
#     #
#     # Écriture proprement dite
#     # 
#     # puts "content : #{content}".bleu
#     pdf.update do
#       font(lafonte) do
#         # bounding_box(at, **{width:props.delete(:width), height:})
#         bounding_box( props.delete(:at), **props) do
#           text(content, **props_text)
#         end
#       end
#     end
#     # 
#     # On retourne la page pour l'addition des procédures
#     # 
#     return bpage
#   end

#   ## 
#   # Si le texte personnalisé contient du code ou des variables, il
#   # faut l'estimer.
#   # 
#   # @return [String] Le texte à écrire dans le headfooter
#   # 
#   # @param [String] str Le texte original tel que défini dans la recette
#   # 
#   def get_content_as_custom_text(str)
#     if str.match?(/#\{/)
#       return eval('"' + str + '"')
#     else
#       str
#     end
#   end

#   def common_tiers_props
#     @common_tiers_props ||= begin
#       spy "#{'Calcul de la hauteur'.jaune} : #{height.inspect}".bleu
#       {height: height, size: font_size}
#     end
#   end

#   # @prop [Float] Taille d'un tiers de page (en points-post-script)
#   # 
#   def tiers
#     @tiers ||= (pdf.bounds.width.to_f / 3).round(6)
#   end

#   # Définition de la fonte à utiliser
#   # 
#   # Soit elle est définie explicitement par ce headfoot, soit elle
#   # est prise dans la recette
#   # 
#   def fonte(dtiers = {})
#     fontnstyle = dtiers[:font_n_style] || book.recipe.pagination_font_n_style
#     fname, fstyle = fontnstyle.split('/')
#     fstyle = fstyle.to_sym
#     Fonte.new(name:fname, style:fstyle, size:font_size)
#   end

#   # @return Taille de la fonte pour ce head-foot
#   def font_size(dtiers = {})
#     dtiers[:size] || @font_size ||= book.recipe.pagination_font_size
#   end

# private

#   # @eturn [Boolean] true si la page de numéro +num+ est dans le
#   # rang des pages à prendre
#   # @note
#   #   Cela dépend de la disposition
#   def page_in_range?(num)
#     return num >= disposition.first_page && num <= disposition.last_page
#   end

#   # - Data Methods -

#   # @return [Integer] La hauteur du pied de page ou de l'entête en
#   # fonction du contenu des tiers. On prend le tiers le plus grand.
#   def height
#     @height ||= begin
#       max_height = 0
#       [ 
#         :pg_left, :pg_center, :pg_right, 
#         :pd_left, :pd_center, :pd_right
#       ].each do |tiers|
#         dtiers = self.send(tiers)
#         next if dtiers.nil?
#         tiers_height = get_height_of_tiers(dtiers)
#         max_height = tiers_height if tiers_height > max_height
#       end
#       max_height.ceil
#     end
#   end

#   def get_height_of_tiers(dtiers)
#     pdf.font(fonte(dtiers)) do
#       return pdf.height_of("MAXq")
#     end
#   end

#   # @return [Hash] La table des données de la page de numéro 
#   # +page_num+
#   # 
#   def get_data_page(page_num)
#     disposition.data_pages[page_num]
#   end

#   # - Data -

#   def id            ; @id           ||= data[:id]           end
#   def name          ; @name         ||= data[:name]         end
#   def font_n_style  ; @font_n_style ||= data[:font_n_style] end
#   def font          ; @font         ||= data[:font]         end
#   def size          ; @size         ||= data[:size]         end
#   # - page gauche (pg_) -
#   def pg_left       ; @pg_left      ||= data[:pg_left]      end
#   def pg_right      ; @pg_right     ||= data[:pg_right]     end
#   def pg_center     ; @pg_center    ||= data[:pg_center]    end
#   # - page droite (pd_) -
#   def pd_left       ; @pd_left      ||= data[:pd_left]      end
#   def pd_right      ; @pd_right     ||= data[:pd_right]     end
#   def pd_center     ; @pd_center    ||= data[:pd_center]    end

# end #/class Headfooter
# end #/class HeadersFooters
# end #/module Prawn4book
