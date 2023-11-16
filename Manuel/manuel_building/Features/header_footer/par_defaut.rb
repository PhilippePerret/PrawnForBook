Prawn4book::Manual::Feature.new do

  titre "Description"


  description <<~EOT
    Comme pour les autres éléments, on pourra laisser les **entêtes** et **pieds de page** par défaut, ce qui signifiera n’afficher que les numéro de pages — sur les pages adéquates —, ou au contraire on pourra définir des entêtes et pieds de page complexes et adaptés au contenu pour une navigation optimum.
    (( line ))
    Comme pour les autres éléments de _PFB_, les entêtes et pieds de page par défaut sont conçus pour être directement "professionnels". C’est-à-dire que la numérotation est intelligente, elle ne numérote pas bêtement toutes les pages de la première à la dernière. Seules sont numérotées les pages qui le sont dans un livre imprimé. Sont soigneusement évitées les pages vides, les pages de titre ou les pages spéciales comme [[-pages_speciales/table_des_matieres]] ou [[-pages_speciales/page_infos]].
    (( line ))
    Les pages suivantes font définir les différents entête et pieds de page que l’on peut définir, en présentant dans la page le code utilisé et le résultat dans les entêtes et/ou les pieds de page.

    ##### Lexique

    Comme pour les autres parties, nous définissons ici le lexique des termes qui seront rigoureusement utilisés dans cette partie.

    * **Entête**. C’est la partie, en haut de page, au-dessus du texte principal de la page, qui contient le plus souvent le titre courant, qui permet de naviguer plus facilement dans les chapitres du livre.
    * **Header**. *Entête*, en anglais.
    * **Pied de page**. C’est la partie, en bas de page, sous le texte principal de la page, qui contient le plus souvent le *numéro de page*.
    * **Footer**. *Pied de page*, anglais.
    * **Portion**. Nous appelons "portion" l’un des trois tiers de page qui constituent une *entête* ou un *pied de page*. On trouve la *portion interne* (près de la reliure), la *portion externe* (près de l’extérieur du livre) et la *portion centrale*.
    * **Disposition**. Une *disposition* décrit le contenu des pieds et page et entête d’une ou plusieurs page. Cela revient à définir quel *headfooter* les pages utilisent en entête et quel *headfooter* elles utilisent en pied de page.
    * **Headfooter**. Un *headfooter* décrit le contenu exact des trois portions qui constituent une *entête* ou un *pied de page* mais qui peuvent s’utiliser indifféremment pour l’un ou pour l’autre. Un *headfooter* peut même être utilisé en même temps en pied de page et en entête.
    
    ##### Trois portions de page

    Un *entête* ou un *pied de page* est un espace de page qui contient trois portions, trois tiers de page, une portion externe (à gauche pour la page gauche, à droite pour la page droite), une portion interne et une portion centrale. On répartie les éléments dans ces trois portions.

    ##### Les éléments

    Les éléments qui peuvent être utilisés dans les entêtes et les pieds de page sont illimités en mode expert ([[expert/header_footer]]). Pour le commun des mortels, ils se limitent — ce qui est déjà largement suffisant — aux titres courants jusqu’au niveau 3, au numéro de la page ainsi qu’au nombre total de page.

    ##### Définition des entêtes et pieds de page

    Les *entêtes* et *pieds de page*, comme pour le reste, se définissent dans [[-recette/grand_titre]] du livre ou de la collection, dans une section qui s’appelle, on ne s’en étonnera pas : `headers_footers`.
    (( line ))
    Ce qu’il faut comprendre, c’est que pour les définir, on définit en fait des entités qui s’appellent des `headfooter`s, spécifiant le contenu des trois portions, et qu’on peut utiliser indifféremment comme entête ou comme pied de page. On utilise ensuite ces *headfooters* pour créer des *dispositions* d’entête ou de pied de page.
    On peut définir autant de *dispositions* que l’on veut, même s’il est conseillé, toujours, de rester le plus sobre possible. On peut se contenter, pour un résultat optimum, d’une *disposition* pour le corps du livre, son contenu principal, et une *disposition* pour les annexes si elles existent.

    ##### Ajustement

    Noter bien que l’*ajustement vertical* effectué avec `vadjust` fonctionne différemment pour les entêtes et pour les pieds de page. Dans les deux cas, il définit l’éloignement par rapport au texte principal de la page. Ainsi, pour une entête, une valeur positive fera monter les portions alors que pour un pied de page, une valeur positive les fera descendre.
    EOT


    sample_recipe <<~EOT
      ---
      # .\\..
      headers_footers:
        headfooters:
          # Définitions des "headfooters"

          # Un headfooter d’identifiant HD22. Cet identifiant
          # permet d’y faire référence dans la disposition
          HD22:
            # Définition de l’headfooter

          AutreHD:
            # Définition de l’autre headfooter

          H23D:
            # Définition de l’headfooter H23D
        
        dispositions:
          # Définitions des différentes dispositions en
          # fonction des pages

          - name: "Nom humain juste pour mémoire"
            first_page: <première page>
            last_page:  <dernière page>
            header:     <id de l’headfooter pour l’entête>
            footer:     <id headfooter pour pied de page>
            vadjust:    <ajustement vertical>
            hadjust:    <ajusement horizontal>


      EOT
end
