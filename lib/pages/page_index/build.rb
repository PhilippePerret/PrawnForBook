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
      pdf.move_to_next_line
      txt = INDEX.key?(canon.downcase.to_sym) ? INDEX[canon.downcase.to_sym] : canon
      pdf.formatted_text [
        {text: txt, font: canon_fonte.name, size: canon_fonte.size, styles: canon_fonte.styles, color: canon_fonte.color},
        {text: " : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}", font: number_fonte.name, size: number_fonte.size, styles: number_fonte.styles, color: number_fonte.color}
      ]
    end
    spy "<- /construction de l'index".jaune
  end

  def canon_fonte
    @canon_fonte ||= recipe.index_canon_fonte
  end
  def number_fonte
    @number_fonte ||= recipe.index_number_fonte
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
