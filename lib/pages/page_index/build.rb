module Prawn4book
class Pages
class PageIndex

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    spy "-> Construction de la page d'index".jaune
    # 
    # S'il n'y a aucun mot indexé, on s'en retourne tout de suite
    # 
    return if table_index.empty?
    # 
    # La clé à utiliser pour la page ou le paragraphe
    #   - page        On utilise le numéro de page
    #   - paragraph   On utilise le numéro de paragraphe
    #   - hybrid      On utilise un numéro "page-paragraphe"
    # 
    key_num = recipe.references_key
    # 
    # Le titre de la page d'index
    # 
    titre = PdfBook::NTitre.new(book:pdfbook, titre:"Index", level:1, pindex: 0)
    titre.print(pdf)

    # 
    # Boucle sur la table des index 
    # 
    table_index.sort_by do |canon, dcanon|
      # 
      # Classement des canons dans l'ordre
      # 
      dcanon[:canon_for_sort]
    end.each do |canon, dcanon|
      # 
      # Regrouper les index qui ont la même page (si numérotation
      # par page) ou le même paragraphe (si numérotation par 
      # paragraphe).
      # ATTENTION : pour le moment, ça modifie la propriété :items 
      # du canon.
      new_items = []
      table_ref = {} # pour ranger par page/paragraphe
      dcanon[:items].each do |dmot|
        ref = dmot[key_num]
        table_ref.merge!(ref => 0) unless table_ref.key?(ref)
        table_ref[ref] += 1
      end
      new_items = table_ref.map do |ref, nombre_fois|
        if nombre_fois > 1
          {key_num => "#{ref} (x #{nombre_fois})"}
        else
          {key_num => ref}
        end
      end
      dcanon.merge!(items: new_items)
    end.each do |canon, dcanon|
      pdf.font(canon_fonte)
      # pdf.move_to_next_line
      txt = INDEX.key?(canon.downcase.to_sym) ? INDEX[canon.downcase.to_sym] : canon
      segments = [
        {text: "#{txt} : ", font: canon_fonte.name, size: canon_fonte.size, styles: canon_fonte.styles, color: canon_fonte.color},
      ]
      # - Ajout de chaque occurrence -
      dcanon[:items].map do |dmot|
        font_data = 
          case dmot[:poids]
          when :main  then number_main_fonte_data
          when :minor then number_minor_fonte_data
          else number_fonte_data
          end
        segments << dmot[:font_data].merge!(text: dmot[key_num].to_s)
      end
      # -- Gravure du canon et ses références --
      # Note : ça passe automatiquement à la ligne, ne rien faire.
      pdf.formatted_text(segments)
    end
    spy "<- /construction de l'index".jaune
  end

  def number_fonte_data
    @number_fonte_data ||= begin
      {
        font:   number_fonte.name, 
        size:   number_fonte.size, 
        styles: number_fonte.styles, 
        color:  number_fonte.color
      }.freeze
    end
  end

  def number_main_fonte_data
    @number_main_fonte_data ||= begin
      {
        font:   number_main_fonte.name, 
        size:   number_main_fonte.size, 
        styles: number_main_fonte.styles, 
        color:  number_main_fonte.color
      }.freeze
    end
  end

  def number_minor_fonte_data
    @number_minor_fonte_data ||= begin
      {
        font:   number_minor_fonte.name, 
        size:   number_minor_fonte.size, 
        styles: number_minor_fonte.styles, 
        color:  number_minor_fonte.color
      }.freeze
    end
  end

  def canon_fonte
    @canon_fonte ||= recipe.index_canon_fonte
  end
  def number_fonte
    @number_fonte ||= recipe.index_number_fonte
  end
  def number_main_fonte
    @number_main_fonte ||= Fonte.get_in(recipe_data[:number][:main]).or(number_fonte)
  end
  def number_minor_fonte
    @number_minor_fonte ||= Fonte.get_in(recipe_data[:number][:minor]).or(number_fonte)
  end

  def recipe_data
    @recipe_data ||= recipe.page_index
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
