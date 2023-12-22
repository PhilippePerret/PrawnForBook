Prawn4book::Manual::Feature.new do

  titre "Formateurs"


  description <<~EOT
    En mode expert, on a un accès complet à toutes les possibilités qu’offrent _PFB_, c’est-à-dire, n’ayant pas peur de le dire, *un monde infini, sans limite*.
    Pour se faciliter la vie, certaines méthodes propres permettent une implémentation plus rapide. C’est le cas de la méthode `Printer#pretty_render` qui, comme son nom l’indique, permet d’obtenir un bon rendu dans le livre sans effort (et, notamment, un traitement du texte sur les lignes de référence — cf. [[page__page__|comportement/align_on_reference_lines]])
    Voici un code exemple :
    ~~~ruby
    # Par exemple dans ./formater.rb
    def mon_helper(pdf)

      # On définit une fonte particulière
      mafonte = Prawn4book::Fonte.new(name:'Arial', size:8, \
        style: :normal)

      # On écrit le texte voulu dans le document.
      Printer.pretty_render(
        pdf:      pdf, 
        fonte:    mafonte, 
        text:     "Mon texte qui sera bien disposé [etc.]",
        options:  {left: 40, right: 80},
        owner:    nil,
      )
    end
    ~~~
    EOT

  texte <<~EOT
    Ci-dessous, je vais appeler la méthode `mon_helper` définie ci-dessus avec le code :
    {-}`\\#\\{-mon_helper(pdf)}`^^.
    \#{-mon_helper(pdf)}
    ^^ Le "-" devant l’appel de la méthode permet de n’imprimer aucun retour de méthode. Rappel : sinon, c’est toujours le retour de l’appel qui est imprimé.
    EOT


end

module Prawn4book
class PdfBook::NTextParagraph
  def mon_helper(pdf)

    # On définit une fonte particulière
    mafonte = Prawn4book::Fonte.new(name:'Arial', size:8, \
      style: :normal)

    str = "Mon texte qui sera bien disposé sur les "+
        "lignes de référence malgré sa taille plus petite "+
        "que le texte normal de ce mode d’emploi. C’est une police "+
        "Arial, de taille 8, qui va se placer à 40 points de la " +
        "marge gauche et à 80 points de la marge droite, car "+
        "le :left des options a été mis à 40 et le :right a été "+
        "mis à 80. Ça permet d’avoir un texte qui se place où on "+
        "veut dans la page, plus serré que les marges."

    # On écrit le texte voulu dans le document.
    Printer.pretty_render(
      pdf: pdf, 
      fonte:mafonte, 
      text: str,
      options: {left: 40, right: 80},
      owner:nil,
    )
  end

end #/class
end #/module
