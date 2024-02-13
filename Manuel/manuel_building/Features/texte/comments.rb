Prawn4book::Manual::Feature.new do

  titre "Commentaires"


  description <<~EOT
    Les commentaires dans _PFB_ ne correspondent pas aux commentaires dans le format Markdown ("`\\<!-- commentaire markdown --\\>`")
    Dans _PFB_, on met des commentaires dans le texte en utilisant la marque "`[#] `" placée en début de ligne. Par exemple :
    (( line ))
    ```
    \\[#] Cette ligne ne sera pas traitée.
    ```
    (( line ))
    Pour mettre tout un bloc en commentaire, on utilise la marque "`[#`" pour commencer et la marque "`#]`" pour terminer.
    Par exemple :
    (( line ))
    ```
    Un paragraphe qui sera gravé.
    \\[#
    Un bloc qui ne sera pas gravé.
    Avec plusieurs lignes.
    \\#]
    Ce paragraphe sera gravé.

    EOT
end
