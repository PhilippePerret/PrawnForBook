Prawn4book::Manual::Feature.new do

  titre "Référence à un paragraphe"

  description <<~EOT
    Il peut arriver qu’on ait besoin de faire référence à un paragraphe spécial au cours du formatage du texte.
    Pour ce faire, en *mode expert*, on peut utiliser la méthode ruby `#reference` des paragraphes.
    Par exemple :
    (( line ))
    ```ruby
    def methode_formatage(str, context)
      paragraph = context[:paragraph]
    end
    ```
    (( line ))
    Si on veut juste le numéro de la page ou du paragraphe (sans préfixe), on ajouter `false` ("faux" en anglais)
    Par exemple :
    (( line ))
    ```ruby
    def methode_formatage(str, context)
      paragraph = context[:paragraph]
      "{str} est situé à la page {paragraph.reference\\(false)}."
    end
    ```
    (( line ))
    EOT

  # description <<~EOT
  #   Il peut arriver qu’on ait besoin de faire référence à un paragraphe spécial au cours du formatage du texte.
  #   Pour ce faire, en *mode expert*, on peut utiliser la méthode ruby `#reference` des paragraphes.
  #   Par exemple :
  #   (( line ))
  #   ```ruby
  #   def methode_formatage(str, context)
  #     paragraph = context[:paragraph]
  #     "\\\#{str} se trouve sur la \\\#{paragraph.reference}."
  #   end
  #   ```
  #   (( line ))
  #   Si on veut juste le numéro de la page ou du paragraphe (sans préfixe), on ajouter `false` ("faux" en anglais)
  #   Par exemple :
  #   (( line ))
  #   ```ruby
  #   def methode_formatage(str, context)
  #     paragraph = context[:paragraph]
  #     "\\\#{str} est situé à la page \\\#{paragraph.reference\\(false)}."
  #   end
  #   ```
  #   (( line ))
  #   EOT

  # sample_texte <<~EOT
  #   Ce paragraphe est situé à \\\#\\{self.reference}.
  #   EOT

  # texte(:as_sample)
end
