module Prawn4book
class Pages
  PAGE_FAKED_LENGTH = 500000
class Bibliography

  # = main =
  #
  # Méthode principale construisant la/les page/s de bibliographie
  # 
  def build(pdf)
    # 
    # Si aucun item n'a été collecté, on n'inscrit pas cette
    # bibliographie
    # 
    if empty?
      spy "Aucun item bibliographique pour #{biblio.title.inspect}".orange
      add_notice(MESSAGES[:biblio][:no_occurrence] % [biblio.title])
      return
    end
    #
    # Méthode formatage à utiliser pour les items de bibliographie
    # 
    # Soit :
    #   - la méthode propre définie dans un module de formatage
    #   - le format `format’ défini dans la recette
    #   - le format par défaut (seulement le titre et les références)
    # 
    item_formatage_method = 
      if biblio.custom_formating_method_for_biblio?
        biblio.method(biblio.custom_format_method_for_biblio)
      elsif biblio.has_format?
        biblio.define_formated_format
        biblio.method(:formate_item_by_format)
      else
        Prawn4book::Bibliography.method(:default_formate_method)
      end

    #
    # Si une méthode est à appeler avant de commencer, il faut
    # l'appeler
    # 
    if biblio.method_pre_building
      biblio.send(biblio.method_pre_building)
    end

    # 
    # Inscription du TITRE DE LA BIBLIOGRAPHIE
    # 
    ititre = PdfBook::NTitre.new(book:book, titre:biblio.title, level:biblio.title_level, pindex: nil)
    ititre.print(pdf)
    # 
    # Application de la fonte
    # 
    bib_font  = Fonte.new(name:font_name, size:font_size, style: font_style)
    pdf.font(bib_font)
    # - Calcul du leading à utiliser -
    leading   = bib_font.leading(pdf, pdf.line_height)
    # 
    # Les options à appliquer
    # 
    options = {inline_format: true, leading: leading}
    #
    # Page de départ
    # 
    page_number_at_start = pdf.page_number
    if book.pages[page_number_at_start].nil?
      # puts "La page du lexique n'est pas connue.".rouge
      book.add_page(page_number_at_start) # impossible, normalement
    end
    if book.pages[page_number_at_start][:content_length] == 0
      # On met toujours une valeur, car si le texte est écrit 
      # directement dans le livre, on ne peut pas connaitre la
      # longueur de texte ajouté.
      # -- valeur fictive --
      book.pages[page_number_at_start][:content_length] = PAGE_FAKED_LENGTH
    end
    if book.pages[page_number_at_start][:first_par].nil?
      book.pages[page_number_at_start][:first_par] = 1
    end
    # 
    # On écrit tous les items de cette bibliographie
    # 
    biblio.items.values.sort_by do |bibitem|
      # - Classement des items -
      bibitem.keysort
    end.each do |bibitem|
      ##############################
      ###                        ###
      ### - Écriture des items - ###
      ###                        ###
      ##############################
      pdf.move_to_next_line
      # str = Prawn4book::Bibliography.send(formate_method, bibitem)
      begin
        #
        # C'est peut-être une méthode utilisateur qui est utilisée
        # ici, il faut donc s'attendre au pire. On la protège.
        # 
        str = item_formatage_method.call(bibitem, pdf)
        # La méthode peut retourner nil si le code a été écrit 
        # directement dans le document pdf.
      rescue Exception => e
        raise PFBFatalError.new(740, **{method: "#{item_formatage_method.name}", err: e.message, err_class: "#{e.class}"})
      end
      unless str.nil?
        #
        # Si le texte n'a pas été écrit directement dans le 
        # livre
        # 
        pdf.text(str, **options)
        if  book.pages[page_number_at_start][:content_length] == PAGE_FAKED_LENGTH
          # -- valeur fictive retirée --
          book.pages[page_number_at_start][:content_length] = 0
        end
        book.pages[page_number_at_start].add_content_length(str.length)
        pdf.move_down(4)
      end
    end
  end

end #/class Bibliography
end #/class Pages

class Bibliography

  # Affichage par défaut de l’item dans la liste
  # des sources en fin d’ouvrage
  # 
  def self.default_formate_method(bibitem, pdf)
    spy "Je dois imprimer l'item #{bibitem.title} avec la méthode par défaut des bibliographies.".jaune
    "#{bibitem.title} : #{bibitem.occurrences_pretty_list}."
  end

  # Affichage de l’item dans la liste des sources bibliographiques
  # quand la propriété `format’ est définie.
  def formate_item_by_format(bibitem, pdf)
    fmt_data = Marshal.load(Marshal.dump(bibitem.data))
    # Formatage des propriétés
    # (voir plus bas pour +uk+, en [1])
    @format_methods_per_key.each do |uk, duk|
      prop = duk[:prop]
      meth = duk[:method]
      valu = fmt_data[prop]
      valu = send(meth, valu) unless meth.nil?
      fmt_data.merge!(uk => valu)
    end

    @formated_format % fmt_data.merge(pages: bibitem.occurrences_pretty_list)
  end

  # Prend la donnée `format’ de la bibliographie si elle est définie
  # et la transforme en un texte template 
  def formated_format
    @formated_format
  end
  def define_formated_format
    # Pour mettre les méthodes qu’il faudra utiliser suivant les
    # propriété de l’item bibliographiques. Par exemple, si on a
    # la définition `%{title|all_caps}’ dans :format, la donnée
    # :title devra passer par la méthode `all_caps’ avant d’être 
    # inscrite.
    # => @format_methods_per_key
    keys  = {}
    # [1] Pour indicer les propriétés
    # Pourquoi ? Parce que si une propriété était utilisée une seule
    # fois (par exemple une année 'year'), alors on pourrait simple-
    # ment enregistrer dans la table +keys+ la correspondance entre
    # la propriété (pe +year+) et la méthode (pe. +age+). Et au moment
    # du traitement de la propriété +year+ on a ferait passer par la
    # méthode +age+. Mais il peut arriver qu’une même propriété soit 
    # utilisée deux fois. Par exemple, on peut voir afficher l’année
    # de naissance de quelqu’un et aussi son âge. Pour les deux valeurs
    # c’est la propriété +year+ qui est utilisée.
    # On doit alors pouvoir utiliser `%{year}’ pour afficher l’année
    # de naissance et `%{year|age}’ pour afficher l’âge de la person-
    # ne. Mais si on a `keys = {year: method(age)}’, les deux marques
    # seront remplacées par l’âge.
    # Pour palier ce problème, on consigne dans +keys+ en indiçant les
    # les propriétés, et en mémorisant la propriété de référence et
    # la méthode à utiliser. Ce qui donnera dans le cas présent :
    # keys = {
    #   'year1' => {prop: :year, method: nil},
    #   'year2' => {prop: :year, method: :age}
    # }
    # Et bien sûr, dans le texte du format final, on trouvera :
    #   "... %{year1} — %{year2} ..."
    # qui affichera :
    #   "... 1999 — 24 ans ..."
    # 
    iprop = 0
    fmt = self.format.gsub(REG_BIBITEM_PROP_DEFINITION) do
      prop = $1.to_sym.freeze
      uniq_prop = "#{prop}#{iprop += 1}".to_sym # [1]
      meth = $2.to_sym.freeze
      keys.merge!(uniq_prop => {prop: prop, method: meth}) # [1]
      "%{#{uniq_prop}}" # [1]
    end
    # Si le format ne définit pas `pages` on l’ajoute à la fin
    # Noter que suivant la pagination, ça peut être autre chose
    unless keys.key?(:pages)
      fmt << " : %{pages}."
    end
    @format_methods_per_key = keys
    @formated_format = fmt
  end

  REG_BIBITEM_PROP_DEFINITION = /\%\{([a-zA-Z_0-9\-]+?)(?:\|(.+?))?\}/

  # Toutes les méthodes de formatages communes
  # (on peut en définir d’autres en mode expert)

  def all_caps(str)
    str.upcase
  end

  def person(ary)
    ary = [ary] if ary.is_a?(String)
    ary.map do |p|
      if p.start_with?('=')
        p[1..-1]
      else
        p.titleize
      end
    end.pretty_join
  end
  alias :as_person :person

  def age(annee)
    "#{Time.now.year - annee} ans"
  end

  def minute_to_horloge(minutes)
    horloge(minutes * 60)
  end
  def horloge(secondes)
    secondes.to_i.s2h
  end
end #/class Bibliography
end #/module Prawn4book
