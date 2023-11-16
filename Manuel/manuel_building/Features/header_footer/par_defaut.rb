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
    * **Portion**. Nous appelons "portion" l’un des trois tiers de page qui constituent une *entête* ou un *pied de page*. On trouve la *portion gauche*, la *portion droite* et la *portion centrale*.
    * **Disposition**. Une *disposition* décrit le contenu des pieds et page et entête d’une ou plusieurs pages. Cela revient à définir quel *headfooter* les pages utilisent en entête et quel *headfooter* elles utilisent en pied de page. Puisque nous sommes en page double (page droite et page gauche), il y a 4 *headfooters* à définir par disposition (cf. plus bas). 
    * **Headfooter**. Un *headfooter* décrit le contenu exact des trois portions qui constituent une *entête* ou un *pied de page* mais qui peuvent s’utiliser indifféremment pour l’un ou pour l’autre. Un *headfooter* peut même être utilisé en même temps en pied de page et en entête.
    
    ##### Trois portions de page

    Un *entête* ou un *pied de page* est un espace de page qui contient trois portions, trois tiers de page, une portion gauche, une portion droite et une portion centrale. On répartie les éléments dans ces trois portions. Les trois portions peuvent être différentes entre page gauche et page droite.

    ##### Les éléments

    Les éléments qui peuvent être utilisés dans les entêtes et les pieds de page sont illimités en mode expert ([[expert/header_footer]]). Pour le commun des mortels, ils se limitent — ce qui est déjà largement suffisant — aux titres courants jusqu’au niveau 3, au numéro de la page ainsi qu’au nombre total de page.

    ##### Définition des entêtes et pieds de page

    Les *entêtes* et *pieds de page*, comme pour le reste, se définissent dans [[-recette/grand_titre]] du livre ou de la collection, dans une section qui s’appelle, on ne s’en étonnera pas : `headers_footers`.
    (( line ))
    Pour les définir, on définit en fait des entités qui s’appellent des `headfooter`s, spécifiant le contenu des trois portions dont nous avons parlé plus haut, et qu’on peut utiliser indifféremment comme entête ou comme pied de page, en page droite ou page gauche. On utilise ensuite ces *headfooters* pour créer des *dispositions* d’entête ou de pied de page. Il y a en quatre par disposition :
    * le *headfooter* de l’entête de page gauche,
    * le *headfooter* de l’entête de page droite (qui peut être le même, bien entendu),
    * le *headfooter* du pied de page gauche (par défaut, il contient le numéro de page dans sa portion gauche),
    * le *headfooter* du pied de page droite (par défaut, il contient le numéro de page dans sa portion droite).
    On peut définir autant de *dispositions* que l’on veut, même s’il est conseillé, toujours, de rester le plus sobre possible. On peut se contenter, pour un résultat optimum, d’une *disposition* pour le corps du livre, son contenu principal, et une *disposition* pour les annexes si elles existent.

    ##### Ajustement

    Noter bien que l’*ajustement vertical* effectué avec `header_vadjust` et `footer_vadjust` fonctionne différemment. Dans les deux cas, il définit l’éloignement *par rapport au texte principal de la page*. Ainsi, pour `header_vadjust` (l’entête), une valeur positive fera monter les portions alors que pour `footer_vadjust` (le pied de page), une valeur positive les fera descendre.

    ##### Fontes

    Bien qu’on puisse définir les polices très précisément pour chaque élément, il est conseillé de ne pas trop les différencier. La sobriété est toujours bonne conseillère, en matière de mise en page.
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
            # Définition de l’headfooter HD22
            left: <contenu portion gauche>
            center: <contenu portion centrale>
            right: <contenu portion droite>

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
            lp_header:  <id headfooter entête page gauche>
            lp_footer:  <id headfooter pied page gauche>
            rp_header:  <id headfooter entête page droite>
            rp_footer:  <id headfooter pied page droite>
            header_vadjust: <ajustement vertical entête>
            footer_vadjust: <ajustement vertical pied>
            header_hadjust: <ajustement horizontal entete>
            footer_vadjust: <ajustement vertical pied>

      EOT

    recipe <<~YAML
    ---
    headers_footers:
      # Fonte générale pour tous les pieds et page et entêtes
      font: "<name>/<style>/<size>"
      headfooters:
        HF01:
          # Fonte générale pour ce headfooter
          font: "<name>/<style>/<size>"
          # Contenu du tiers gauche
          left: "-NUM"
          # Fonte particulière pour le tiers gauche (si ≠)
          left_font: "<name>/<style>/<size>"
          # Contenu du tiers central
          center: null
          # Contenu du tiers droit
          right: "TIT1"
          # Fonte particulière du tiers droit (si ≠)
          right_font: "<name>/<style>/<size>"
        HF02:
          # Fonte générale pour ce headfooter
          font: "<name>/<style>/<size>"

          left: "-NUM"
          center: null
          right: "v2.3"
        HF03:
          left: "TIT2"
          center: null
          right: "NUM-"
        HF04:
          left: null
          center: "#{Time.now.strftime('%d-%m-%Y')}"
          right: "NUM-"

      dispositions:
        - name: "Sur cette page"
          lp_header: HF01
          lp_footer: HF02
          rp_header: HF03
          rp_footer: HF04
          first_page: \#{pdf.number_page - 1}
          last_page: \#{pdf.number_page + 1}
      YAML
end
