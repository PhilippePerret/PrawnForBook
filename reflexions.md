Pour essayer de trouver la méthode ultime qui écrit dans le document


`draw_text` appelle `draw_text!(text, options)`

`draw_text!` appelle `add_text_content(text, x, y, options)`

> `add_text_content` est une méthode de `PDF::Core::Renderer` (il faut intercepter le code avant)

`text` utilise `formatted_text`

`formatted_text` appelle :
* `draw_indented_formatted_line`
* `draw_remaining_formatted_text_on_new_pages`

`draw_intended_formatted_line` appelle `fill_formatted_text_box`
`draw_remaining_formatted_text_on_new_pages` aussi

`fill_formatted_text_box` utilise `Text::Formatted::Box#render`

`text_box` utilise :
* Text::Formatted::Box#render
* Text::Box#render

`formatted_text_box` utilise
* Text::Formatted::Box#render

L'écriture dans une table se sert de 
* `Prawn::Text::Formatted::Box` (quand il y a du inline_format)
* `Prawn::Text::Box`

## Moralité :

À part `draw_text` et `draw_text!` qui appellent directement le cœur de `PDF`, toutes les autres méthodes se servent d'une instance `Prawn::Text::Box` ou `Prawn::Text::Formated::Box` pour écrire dans le document.
