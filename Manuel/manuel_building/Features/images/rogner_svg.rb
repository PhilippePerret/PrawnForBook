Prawn4book::Manual::Feature.new do

  titre "Rogner une image SVG"

  description <<~EOT
    Il est fort possible qu’en produisant une image SVG, et en l’insérant dans le livre, elle laisse voir trop de blanc autour d’elle, comme dans le premier exemple donné ci-après. Pour palier ce problème, il faut "rogner" cette image SVG. Mais *rogner* une image SVG ne se fait pas aussi facilement qu’avec une image d’un format non vectoriel (JPG, PNG, etc.). Il faut pour ce faire utiliser, après avoir chargé la commande `inkscape` dans votre ordinateur, le code suivant :
    (( line ))
    (( {align: :center} ))
     `inkscape -l -D -o image-rogned.svg image.svg` 

    EOT

  new_page_before(:texte)

  texte <<~EOT
    Image non rognée :
    ![exemples/rogned_non.svg](width:200, name: "Image non rognée")
    *(note : la page vide précédente est occupée par le blanc de l’image rognée)*
    La même image, rognée cette fois :
    ![exemples/rogned.svg](width:200, name: "Image rognée")
    Amet exercitation ut dolore in in nulla adipisicing laborum.
    EOT

end
