Prawn4book::Manual::Feature.new do

  titre "Premiers pas"

  description <<~EOT
    Dans ce tutoriel, nous allons concevoir notre premier livre publiable qui contiendra tout ce qu’il faut savoir sur _PFB_ pour pouvoir démarrer et se débrouiller. À l’issue de ce tutoriel, vous serez en possession d’un fichier PDF que vous pourrez publier facilement. Si vous êtes inscrit au programme KDP d’Amazon (cf. [[annexe/kdp_amazon]]), vous pourrez même aussitôt en demander des épreuves papier.
    Dans cette première partie, nous allons installer la base de notre livre. Cette base consiste à créer un nouveau dossier sur votre ordinateur (*les opérations seront détaillées ci-dessous, pour le moment, vous pouvez ne faire que lire*) dans lequel nous créerons les deux fichiers de base de l’application, le fichier `texte.pfb.md` pour mettre le texte et le fichier `recipe.yaml` pour définir la recette de ce livre.
    (( line ))
    À VOUS DE JOUER !
    (( line ))
    * Ouvrez une fenêtre de Terminal (sur Mac/Unix) ou une Console (sur Windows) dans le dossier dans lequel vous voulez créer votre livre, par exemple le dossier "`Documents`" (*sur MacOS, control-cliquez sur le dossier `Documents` dans le Finder et choisissez l’item du menu contextuel qui s’appelle quelque chose comme "Nouveau terminal au dossier"*). 
    * Que vous soyez sur MacOS, Windows ou Unix, pour simplifier, nous appellerons toujours cette fenêtre la *console*.
    * Tapez dans cette console la commande :<br>`> pfb init`<br> … qui permet d’initier un nouveau livre dans le dossier courant.
    * À titre indicatif, *pfb* sont simplement les trois premières lettres de _PFB_.
    * L’application vous demande de définir le nom du dossier de votre livre. Vous pouvez lui donner le nom du livre ou tout autre valeur significative. Nous l’appellerons "Nouveau livre".
    * PFB vous demande de confirmer le chemin d’accès, il suffit de presser la touche Entrée sans rien écrire. Si vous n’êtes pas d’accord avec le lieu, il suffit de taper "n" et de recommencer.
    * PFB vous présente alors une liste d’opérations avec le titre "DONNÉES DE LA RECETTE". C’est un assistant qui vous aide dans la conception de votre livre.
    * Nous n’allons pas utiliser d’assistant, aussi vous pouvez choisir l’item "Finir" en cliquant tout de suite sur la touche Entrée.
    * Comme vous pouvez le constater, PFB construit deux fichiers, l’un pour le texte, l’autre pour la recette, comme nous en avons parlé.
    * PFB vous demande ensuite le titre du livre, vous pouvez entrer "Mon premier livre" ou tout autre titre, puis presser la touche Entrée.
    * PFB finalise alors le dossier en créant quelques fichiers supplémentaires.
    * Elle vous présente ensuite une aide concernant les commandes essentielles. Vous pourrez afficher une liste plus complète dès que vous en avez besoin avec la commande "`> pfb aide`" (*essayez justement cette commande dès à présent*).
    (( line ))
    BRAVO ! Vous venez de créer votre premier dossier de livre _PFB_ !
    (( line ))
    Nous devons maintenant *rejoindre* notre nouveau dossier pour y travailler notre livre. Soit vous ouvrez une nouvelle console dans le dossier du livre comme nous l’avons fait tout à l’heure, soit, dans la console actuelle, vous tapez…<br>`> cd "Nouveau livre"`<br>… pour rejoindre ce dossier (*dans le cas où vous l’ignoreriez, "`cd`" est une commande générale qui n’est pas propre à PFB et qui permet de rejoindre un dossier sur votre ordinateur*).
    Revenons à votre bureau (votre *Finder* sur MacOS) pour voir ce que contient votre dossier livre.
    Il contient plusieurs fichiers qui nous permettrons en temps voulu de formater le livre et d’effectuer certaines opérations très pratiques.
    Pour le moment, nous devons seulement nous concentrer sur les fichiers "`texte.pfb.md`" et "`recipe.yaml`". Ce sont les deux fichiers que nous allons commencé à éditer.

    #### Attention à l’édition !

    Pour modifier les fichiers de PFB, vous allez utiliser un *IDE*, c’est-à-dire un *environnement de développement intégré*, c’est-à-dire, pour faire simple, un éditeur qui ne va rien ajouter en douce à votre fichier, qui va le laisser tel que vous l’avez écrit, sans code caché.
    En contrepartie, cet IDE, si vous désirez l’exploiter, vous proposera des outils très intéressants, qui vous deviendront bientôt indispensables, pour rédiger votre livre et le mettre en forme comme vous le voulez. Par exemple, il utilisera la *coloration syntaxique* qui vous permet d’y voir très clair dans vos fichiers, en mettant les différents éléments en couleur (pour PFB par exemple, vous pourrez voir le texte du livre proprement dit en noir et les autres éléments dans une autre couleur).
    Nous utilisons pour ce faire l’application "`Sublime Text`" mais vous pouvez utiliser n’importe quel autre IDE. Ils sont très simples d’accès et d’utilisation : vous ouvrez votre fichier dans cet IDE (par le menu "Ouvrir", ou en glissant le fichier sur l’application), vous tapez votre texte, ou votre code, vous enregistrez, et c’est tout.

    #### Nom de l’auteur et début de texte

    Nous allons commencer justement à éditer nos deux fichiers principaux pour définir l’auteur(e) du livre et commencer à lui coller du contenu.
    * Ouvrez le fichier "`recipe.yaml`" dans votre IDE (que nous apppellerons simplement *éditeur* par la suite).
    Astuce : plutôt que d’avoir à ouvrir vos fichiers un par un pour pouvoir les éditer, le plus simple est d’ouvrir tout le dossier du livre dans l’IDE, et de choisir, toujours dans l’IDE, le fichier à voir et modifier.
    * Donnez votre nom à la propriété "`author` ("auteur") de la section `book_data`" ("données du livre") de votre fichier. Votre fichier devrait ressembler à quelque chose comme :
    {-}`---`
    {-}`app_name: Prawn-For-Book`
    {-}`app_version: #{Prawn4book::VERSION}`
    {-}`created_at: '#{Time.now.strftime("%Y-%m-%d")}'`
    {-}`#\\<book_data>`^^
    {-}`book_data:`
    {-}`  titre: Mon premier livre`
    {-}`  author: "John DOE"`
    {-}`---`
    {-}`#\\</book_data>`

    ^^ Notez que toutes les lignes de ce fichier qui commencent par "`#`" sont justes des *commentaires* pour vous repérer et laisser des notes.




    EOT

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  # texte <<~EOT
  #   Texte à interpréter, si 'sample_texte' ne peut pas l'être.
  #   EOT

  # recipe <<~EOT #, "Autre entête"
  #   ---
  #     # ...
  #   EOT

  # init_recipe([:custom_cached_var_key])

end
