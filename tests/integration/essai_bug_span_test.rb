#
# Test pour essayer de voir si le span bug
# 
require 'prawn'


LOREM_IPSUM = <<~EOT
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit id leo faucibus sodales. Nulla fermentum id erat eu convallis. Duis euismod diam dolor, ut egestas dolor interdum porttitor. Cras sed nisl dolor. Donec at magna scelerisque, feugiat eros id, tincidunt lorem. In laoreet felis eu ornare tristique. Quisque id egestas ante. Sed vitae suscipit justo, ac pharetra magna. Quisque convallis malesuada lectus. Curabitur nec lectus urna. Ut fermentum vel sapien vitae convallis. Curabitur sed lectus varius, imperdiet dolor sed, convallis quam. Suspendisse malesuada neque sit amet libero malesuada faucibus. Aenean tristique elit a ornare blandit.
  Nunc quis porta mauris. Praesent placerat mollis ex, id lobortis mi facilisis eget. Nunc vitae lacus ullamcorper, accumsan eros vitae, interdum est. Sed vitae ex eget mi lobortis posuere quis at nisl. Vivamus sed urna in felis luctus dignissim id eget leo. Donec vitae dignissim augue. Nunc nec lobortis erat, in euismod metus. Ut in finibus quam. Quisque sit amet cursus orci. Nunc hendrerit, leo sit amet pellentesque sollicitudin, est sem euismod dui, quis maximus purus justo quis quam. Donec et tortor sem. In finibus venenatis facilisis. Ut sed cursus augue. Morbi euismod lectus vel mi semper fermentum. Phasellus non velit in eros malesuada.
  EOT

Prawn::Document.generate('mondoc.pdf') do |pdf|

  pdf.on_page_create do
    pdf.text "C'EST ICI"
    pdf.move_cursor_to(200)
    pdf.text "C'EST LA"
  end

  pdf.text "Premier texte à #{pdf.cursor}"

  pdf.move_cursor_to(100)

  options = {document: pdf, at:[0, pdf.cursor]}

  pdf.span(pdf.bounds.width - 40, position: 40) do
    # Pour calculer la taille que ça fait
    # essai = Prawn::Text::Box.new(LOREM_IPSUM, options)
    # # essai = Prawn::Text::Formatted::Box.new(array_of_texts, options)
    # essai.render(dry_run: true)
    # puts "Ça fait #{essai.height}"
  end

  exceed = pdf.text_box(LOREM_IPSUM, **{overflow: :truncate, width: pdf.bounds_width - 40, at:[40, pdf.cursor]})
  puts "Non imprimé: #{exceed}"

  # 
  # Faire un essai autrement : comme pour l'écriture normale, je 
  # crois, c'est-à-dire qu'on met dans un text box pour voir si ça
  # va dépasser. Si c'est le cas, on récupère l'excédent et on passe
  # à l'autre page.
  # Mais que faire si on a largement la place ? On ne peut pas faire
  # un text-box qui va jusqu'en bas.
  # 
  # En fait, on fait un text-box sans hauteur, avec le overflow à
  # truncate et on regarde ce qui reste.

  pdf.start_new_page

  pdf.text "Le cursor est à #{pdf.cursor}."

end
