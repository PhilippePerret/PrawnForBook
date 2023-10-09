#
# Test pour essayer de voir si le span bug
# 
require 'prawn'

Prawn::Fonts::AFM.hide_m17n_warning = true

LOREM_IPSUM = <<~EOT
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit id leo faucibus sodales. Nulla fermentum id erat eu convallis. Duis euismod diam dolor, ut egestas dolor interdum porttitor. Cras sed nisl dolor. Donec at magna scelerisque, feugiat eros id, tincidunt lorem. In laoreet felis eu ornare tristique. Quisque id egestas ante. Sed vitae suscipit justo, ac pharetra magna. Quisque convallis malesuada lectus. Curabitur nec lectus urna. Ut fermentum vel sapien vitae convallis. Curabitur sed lectus varius, imperdiet dolor sed, convallis quam. Suspendisse malesuada neque sit amet libero malesuada faucibus. Aenean tristique elit a ornare blandit.
  Nunc quis porta mauris. Praesent placerat mollis ex, id lobortis mi facilisis eget. Nunc vitae lacus ullamcorper, accumsan eros vitae, interdum est. Sed vitae ex eget mi lobortis posuere quis at nisl. Vivamus sed urna in felis luctus dignissim id eget leo. Donec vitae dignissim augue. Nunc nec lobortis erat, in euismod metus. Ut in finibus quam. Quisque sit amet cursus orci. Nunc hendrerit, leo sit amet pellentesque sollicitudin, est sem euismod dui, quis maximus purus justo quis quam. Donec et tortor sem. In finibus venenatis facilisis. Ut sed cursus augue. Morbi euismod lectus vel mi semper fermentum. Phasellus non velit in eros malesuada.
  EOT

line_height = 14
fsize       = 15

Prawn::Document.generate('mondoc.pdf', **{
  page_size:'A5'
}) do |pdf|


  # pdf.start_new_page

  # 
  # On dessine des lignes de repère
  # 
  pdf.stroke_color 51, 0, 0, 3  # bleu ciel
  pdf.fill_color 51, 0, 0, 3    # bleu ciel
  pdf.line_width(0.1)
  h = pdf.bounds.top.dup - (fsize - 3)
  while true
    pdf.stroke_horizontal_line(-100, pdf.bounds.width + 100, at: h)
    h -= line_height
    break if h < 0
  end
  pdf.stroke_color  0, 0, 0, 100
  pdf.fill_color    0, 0, 0, 100

  options = {size:fsize}
  leading = line_height - pdf.height_of('H', **options)
  options.merge!(leading: leading)


  pdf.text "Texte à #{pdf.cursor.round(2)} de hauteur #{pdf.height_of('H', **options)}\nUn autre\nEt encore un autre beaucoup plus long pour qu'il puisse passer à la ligne et puis il faudrait qu'il passe une deuxième fois pour bien voir ce que ça raconte au niveau des lignes de référence.",
  **options
end
