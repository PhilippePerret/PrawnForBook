Prawn4book::Manual::Feature.new do

  titre "Numérotation des paragraphes"

  description <<~EOT
    Une des fonctionnalités puissante de _PFB_ est la capacité de numéroter les paragraphes d’un texte. Cela se révèle très pratique lorsqu’on doit faire référence à des paragraphes précis, par exemple lorsque l’analyse d’un récit ou dans un ouvrage technique.
    Pour ce faire, il suffit d’indiquer la pagination voulue, `parags` ou `hybrid`, dans la recette du livre (ou de la collection).

    #### Numérotation continue

    La valeur `parags` attribue à chaque paragraphe du texte un numéro unique qui s’incrémente de paragraphe en paragraphe et de feuillets en feuillets.
    Ce format devient vite "encombrant" dans les textes qui contiennent plus d’un millier de paragraphe.

    #### Numérotation hybride

    La numérotation *hybride* (`hybrid`) convient parfaitement aux longs textes contenant des centaines de paragraphe. Elle correspond à l’indication de la page suivi de l’indication du paragraphe dans la double page, en sachant qu’à chaque nouvelle double page (en partant de la page gauche) on reprend la numérotation des paragraphes à 1.
    Ainsi, l’indication de pagination "12-5" signifie qu’il s’agit du 5e paragraphe de la page 12.

    #### Format de la numérotation du paragraphe

    Comme tout autre élément de _PFB_, on peut en garder les valeurs par défaut, qui sont déjà tout à fait adaptées au livre, ou on peut les définir très précisément, dans les moindres détails.

    EOT

  real_recipe <<~YAML
    ---
    book_format:
      page:
        pagination: hybrid
    YAML

  new_page_before(:texte)

  # Ci-dessous, on dispose les pages comme dans le livre, avec la
  # première page à droite, la deuxième page à gauche plus bas et la
  # troisième page sous la première.
  texte <<~EOT
    (( fausse_page ))
    Les pages d’un livre dont les paragraphes sont numérotés ressemblent aux pages ci-dessous.
    Remarquez comment la numérotation recommence à la page 2 (sur la double page 2-3 donc) et comment elle se poursuit sur la page 3.
    Notez également la référence qui est fait, dans le paragraphe 6 de la page 3, à une référence du paragraphe 5 de la page 2 ("p. 2 § 5").
    Pour savoir comment modifier le format de cette référence voir [[pagination/types_numerotation]].
    (( move_to_line(25) ))
    ![page-2](width:"100%")
    (( new_page ))
    ![page-1](width:"100%")
    ![page-3](width:"100%")
    EOT


  real_text <<~EOT
    Cillum aliquip in cupidatat in cillum sit nisi anim pariatur sint voluptate ea laboris esse sint cillum dolore ea nulla non commodo quis adipisicing. Officia cillum eiusmod in incididunt consequat in voluptate veniam ut in dolore laboris consectetur ullamco proident voluptate amet esse ut anim exercitation esse non in magna consequat fugiat. Do dolore minim qui dolore minim enim laboris exercitation ex veniam duis commodo consectetur velit sed consequat esse velit.
    Ut in officia esse ad cupidatat in duis fugiat duis ut velit fugiat enim proident irure commodo occaecat reprehenderit duis duis voluptate proident tempor qui id do adipisicing dolore adipisicing irure cupidatat dolore laborum anim ea aliqua.
    Eiusmod laborum consectetur est sunt laboris officia mollit quis ad mollit incididunt commodo occaecat magna officia fugiat velit cillum est culpa ut minim.
    Lorem ipsum excepteur amet qui labore ut elit ea adipisicing enim dolore voluptate ut dolor enim et magna commodo deserunt reprehenderit in excepteur enim dolor amet.
    Aliquip deserunt consequat irure minim tempor in laboris sint nisi nulla officia cillum sint dolore dolore do consectetur exercitation aliquip enim incididunt minim cillum quis dolore consectetur voluptate fugiat cupidatat deserunt eiusmod dolor in.
    Deserunt voluptate aute consectetur eiusmod dolor in amet cupidatat sint eiusmod commodo excepteur sit ullamco occaecat commodo minim ad veniam labore.
    Nulla irure sunt irure consectetur labore irure culpa deserunt occaecat ut aliqua ullamco aliquip et aute veniam ut dolore tempor.
    (( <-(BAD_REFERENCE) ))
    Dolor labore consectetur REFERENCE<-(REFERENCE) ut veniam nostrud ut dolore commodo proident laboris nostrud anim quis ex amet proident pariatur do incididunt excepteur eiusmod aliquip ullamco officia consequat ex exercitation ea cupidatat ea ut consequat pariatur do dolor id.
    Dolore reprehenderit sit nostrud voluptate dolore ex consectetur dolore voluptate tempor magna proident est in qui sint tempor dolor non occaecat velit (cf. ->(REFERENCE)). 
    Lorem ipsum id commodo tempor laboris reprehenderit dolore tempor velit elit adipisicing qui sed elit in eiusmod proident id consequat voluptate amet voluptate cupidatat aute aliquip commodo adipisicing eu in anim quis id deserunt.
    EOT

end
