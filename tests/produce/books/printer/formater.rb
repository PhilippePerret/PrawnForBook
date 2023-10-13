module Prawn4book
  def self.printer_with_label_and_value(pdf)
    printer = Printer.new(pdf)
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
    pr.tabs = {1 => 250}
    pr.bx_x(["Le label", "la valeur"])

    return nil
  end
end

