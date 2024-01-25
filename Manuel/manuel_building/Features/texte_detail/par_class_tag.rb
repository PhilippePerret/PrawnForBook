Prawn4book::Manual::Feature.new do

  titre "Stylisation par *class-tag*"


  description <<~EOT
    Une autre manière de styliser du texte, qui demande plus de compétence mais pas forcément le [[niveau expert|expert/mode_expert]] consiste à utiliser ce qu’on appelles les *class-tag* dans _PFB_ ou les *classes-balises* en français.
    Elle consiste à ranger en quelque sorte tous les attributs d’un paragrpahe sous un nom et d’utiliser ce nom devant le paragraphe pour lui affecter tous les attributs.
    On peut voir cela comme les *styles* des *feuilles de styles* dans un traitement de texte classique. "Classe", ici, est synonyme de "Style".
    On crée par exemple le *style* **citation** et on l’affecte au paragraphe contenant une citation :
    (( line ))
    ~~~
    Le paragraphe au-dessus de la citation.
    citation::Rien ne sert de courir, il faut partir à temps.
    Le paragraphe en dessous de la citation.
    ~~~
    (( line ))
    Le code ci-dessus pourra produire par exemple :
    Le paragraphe au-dessus de la citation.
    citation::Rien ne sert de courir, il faut partir à temps.
    Le paragraphe en dessous de la citation.
    (( line ))
    Pour produire ce résultat, dans le fichier ruby `formater.rb`, j’ai implémenté le code suivant, qui ne demande pas une grande expertise malgré son apparence (en tout cas si vous n’avez jamais vu une ligne de code avant aujourd’hui) :
    (( line ))
    ~~~ruby
    1   # Dans ./formater.rb
    2 
    3   module ParserFormaterClass
    4     def formate_citation\\(str, context)
    5       pr = context[:paragraph]
    6       pr.align = :center
    7       pr.lines_before = 4
    8       pr.lines_after  = 4
    9       pr.margin_left  = 6.cm
    10      pr.margin_right = 6.cm
    11      "<i>\\\#{str.upcase}</i>"
    12    end
    13  end
    ~~~
    (( line ))
    Expliquons les lignes de ce petit code…
    **Ligne 1**, c’est un simple commentaire ruby, qui ne produit rien, il commence par un signe dièse et donne une indication. Ici, il nous dit juste qu’il faut mettre le code dans le (ou "un") fichier de nom `formater.rb` qui doit se trouver à la racine de votre collection ou de votre livre.
    **Ligne 2**, une ligne vide.
    **Ligne 3**, on *ouvre* le module `ParserFormaterClass`. C’est un simple conteneur, on va mettre dedans toutes nos méthodes de *class-tags*.
    **Ligne 4**, on définit la *méthode* (ou la *fonction*) qui va gérer notre *class-tag*. Puisque le *class-tag* s’appelle `citation`, notre méthode s’appelle obligatoirement `formate_citation`. On dit qu’on la définit grâce au `def` (pour *define*, "définir" en anglais) juste devant.
    On trouve ensuite entre parenthèses les deux *paramètres* de cette méthode. Le premier est `str`, c’est en fait le texte qui suit la *class-tag* et les deux double-points dans notre texte. Dans notre exemple, `str` contient "Rien ne sert de courir, il faut partir à temps.".
    Noter que vous pouvez nommer ce paramètre comme vous voulez. Vous pouvez remplacer ce `str` par `texte` ou `barnabe` par exemple, c’est la même chose. La méthode a juste besoin de savoir comment s’appellera son premier paramètre.
    Le second paramètre, `context`, est un peu plus compliqué. Nous l’expliqueront en détail dans le [[mode export|expert/_titre_section_]], pour le moment, souvenez-vous simplement qu’il contient une propriété important, `:paragraph`, qui est le paragraphe contenant la citation. C’est lui que nous allons modifier pour obtenir l’aspect que nous voulons.
    Tout ce qui suit l’ouverture de la méthode avec `def` concerne le traitement de notre texte, jusqu’au `end` de la ligne 12 (l’indentation nous permet de bien lire le code).
    **Ligne 5**, nous récupérons le paragraphe dans le contexte et le mettons dans une variable appelée `pr`. C’est juste pour que ce soit plus simple à manipuler, pour ne pas avoir à répéter `context[:paragraph]` à toutes les lignes.
    Ici aussi, nous l’avons appelé `pr` mais nous aurions pu choisir n’importe quoi d’autre, comme `par` ou `parag`.
    Le seul nom qu’elle ne peut pas avoir, c’est le nom du premier paramètre de la méthode, dans lequel cas elle l’écraserait…
    Maintenant que nous avons récupéré le paragraphe, nous allons le traiter pour l’apparence que nous désirons.
    **Ligne 6**, nous indiquons que nous voulons que le paragraphe soit *centré*.
    **Ligne 7**, nous indiquons que nous voulons laisser 4 lignes vides avant.
    **Ligne 8**, nous indiquons que nous voulons 4 lignes vides après la citation.
    **Ligne 9** et **Ligne 10**, nous indiquons que nous voulons une marge à gauche et à droite de 6 centimètres.
    Enfin, **ligne 11**, nous préparons le texte à renvoyer, celui qui sera écrit, en le formatant. Nous le mettons en capitales avec la méthode ruby `upcase` (`str.upcase` qui doit devenir `barnabe.upcase` si vous avez changé le nom du paramètre).
    Et nous le mettons en italique grâce aux balises HTML "`\\<i>..\\.\\</i>`".
    Nous avons fait un traitement de `str` un peu compliqué ici pour vous montrer ce qu’on peut faire, mais la plupart du temps, vous aurez juste à écrire `str` en fin de méthode pour que le texte soit retourné (n’oubliez pas de toujours le mettre, sinon c’est autre chose qui serait retourné).
    **<color rgb="FF0000">Rappelez-vous bien</color> : c’est toujours ce qui est à la fin de la méthode qui est retourné pour être marqué dans le document.** Cette dernière ligne est donc très importante.
    **Ligne 12**, nous *fermons* la méthode `formate_citation`.
    **Ligne 13**, nous *fermons* le module `ParserFormaterClass`.
      (( line ))
    Maintenant, chaque fois que vous aurez une citation, vous pourrez la faire précéder de "`citation::`" et elle sera automatiquememnt formatée selon vos désirs. Comme ci-dessous.
    citation::Mieux vaut savoir ce que l’on fait !

    #### Propriétés utilisables dans les *class-tags*

    Les *propriétés de paragraphe* que l’on peut utiliser dans les méthodes de *class-tags* sont les mêmes que celles qu’on peut utiliser dans la [[texte_detail/inline_styling]]. Reportez-vous à cette partie pour en retrouver la liste complète.
    EOT

end

module ParserFormaterClass
  def formate_citation(str, context)
    pr = context[:paragraph]
    pr.align = :center
    pr.lines_before = 4
    pr.lines_after  = 4
    pr.margin_left  = 6.cm
    pr.margin_right = 6.cm
    "<i>#{str.upcase}</i>"
  end
end
