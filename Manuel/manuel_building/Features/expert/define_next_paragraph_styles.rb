Prawn4book::Manual::Feature.new do

  titre "Définir le style du paragraphe suivant"


  description <<~EOT
    Dans les formateurs et autres parseurs, on peut définir le style (*les styles*) du paragraphe suivant à l’aide de la méthode :
    (( line ))
    ~~~ruby
    Prawn4book::PdfBook::AnyParagraph
       .next_paragraph_styles(\<{styles}>)
    ~~~
    (( line ))
    Par exemple, si le paragraphe suivant ne doit pas avoir d’indentation, on utilisera dans la méthode de formatage :
    (( line ))
    ~~~ruby
    def formate_personnel(str, context)
      context[:pdf].update do
        text ...
        update_current_line
      end
      Prawn4book::PdfBook::AnyParagraph
        .next_paragraph_styles(indent: 0)
    end
    ~~~
    (( line ))
    EOT

end
