module Prawn4book
  def self.printer_with_label_and_value(pdf)

    # Un printer spécial que je ne fais que registrer
    pr = Printer.new(pdf, {numerotation: false})
    pr.valueFonte = Fonte.new(name:'Arial', style: :italic, size:40)
    pr.labelFonte = Fonte.new(name:'Avenir', style: :regular, size:30)
    Printer.register(pr, 'gros_tableau')



    printer = Printer.new(pdf)
    # -- Ça doit générer une erreur, si j'essaie d'enregistrer avec
    #    le même nom --
    begin
      Printer.register(printer, 'gros_tableau')
      raise "J'aurais dû lever une erreur puisque ce printer existe déjà."
    rescue Exception => e
      # OK
    end

    printer.title("Le grand titre d'imprimerie")
    printer.bx("Un premier item")
    printer.bx("Et un second item")
    printer.bx("Et un troisième item avec un losange vide", **{bullet: :empty_losange})
    printer.bx("Un quatrième item avec un losange plein", **{bullet: :losange})
    printer._x("Juste un texte décalé à droite qui va tenir normalement sur plusieurs lignes pour voir surtout si le leading est appliqué, car ce texte sera en tout petit, en réglant le paramètre :size dans les options que j'envoie à la méthode du printer", **{size:8})


    pr = Printer.new(pdf)
    pr.title("Une table de valeurs")
    pr.bx_x(["Le label", "la valeur"])
    pr.bx_x(["Un label avec puce suffisamment long pour qu'il passe à la ligne.", "Une valeur suffisamment longue pour qu'elle passe elle aussi à la ligne."])
    pr.separator
    pr._x_x(["Un label sans puce suffisamment long pour qu'il passe à la ligne.", "Une valeur suffisamment longue pour qu'elle passe elle aussi à la ligne."])
    pr.bx_x(["Le label", "la valeur"])
    pr.separator(width:'50%', thickness: 12, color: 'EEEEEE')
    pr.bx("Une puce totalement personnalisée, c'est une image en fait.", {bullet:"images/bullet.png"})
    pr.separator(width:'50%', thickness: 12, color: 'FF0000', left: 5)
    pr.separator(width: 50)

    pdf.start_new_page

    pr = Printer.new(pdf)
    pr.title("Printer avec d'autres fontes customisées")


    pr = Printer.new(pdf, **{numerotation: false})
    pr.titre("Printer pour correction des textes")
    pr._x("*(Les paragraphes de ce printer ne sont pas numérotés)*")
    pr._x_x(["4 + 4 font", "\#{4 + 4}"])
    pr._x_x(["Italique MD", "*Italic*"])
    pr._x_x(["Gras MD", "**bold**"])
    pr._x_x(["Souligné MD", "__Underline__"])

    imprime_gros_tableau

    return nil
  end

  # Pour récupérer un printer registré
  # 
  def self.imprime_gros_tableau
    pr = Printer.get('gros_tableau')
    pr.titre("Un Printer registré")
    pr._x_x(["Produit", "BON"])
    pr._x_x(["Réservé", "BAD"])
  end
end

