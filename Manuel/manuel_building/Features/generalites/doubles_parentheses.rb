Prawn4book::Manual::Feature.new do

  subtitle "Signe distinctif"


  str = <<~EOT
    Le *signe distinctif* de _PFB_, utilisé pour tous les codes, est la double parenthèses :
    \\(( line ))
    (( {align: :center} ))
    `\\(( . . . ))`
    \\(( line ))
    Dès qu’un code doit être ajouté au texte, c’est souvent ce signe qui est utilisé. Vous pouvez le voir pour ce propre texte, où des `\\(( line \\))` ont été utilisés pour sauter des lignes et un `\\(( {align: :center} \\))` a été employé pour mettre le paragraphe suivant à la ligne.
    Noter qu’il est impératif de laisser une espace à l’intérieur des parenthèses, de chaque côté. Dans le cas contraire, le code ne serait pas vu.
    > Si vous utilisez [[-annexe/package_sublime_text]], vous verrez le code se mettre en couleur, ce qui vous assurera que vous avez la bonne expression.
    EOT

  sample_texte(str, "Description précédente obtenue à l’aide de :")
  description(str.gsub('\\\\','_DBLPAREN_').gsub('\\','').gsub('_DBLPAREN_','\\\\'))
  texte(:none)

end
