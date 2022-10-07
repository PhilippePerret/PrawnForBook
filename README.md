# Dossier PRAWN

Ce dossier doit permettre de tester l'utilisation du gem `prawn` pour produire les PDFs de la collection Narration

Synopsis
--------

On partirait d'un document texte simple, avec un balisage minimaliste (où, par exemple, les mots à indexer seraient entre `:mot|canon:`). L'inspiration serait Markdown.

Ce document serait parsé et analysé. Par exemple, tous les paragraphes seraient numérotés et mis en forme.

On produit un document YAML qui permettrait de donner des indications de mis en forme sur chaque paragraphe.

On produirait le document PDF final, à remettre à l'imprimeur (KDP pour le moment).

### Pour en faire un alias

~~~bash

ln -s /Users/philippeperret/Programmes/Prawn4book/prawn4book.rb /usr/local/bin/prawn-for-book

~~~
