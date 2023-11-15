Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce doigt tendu"

  puce    = :finger
  vadjust = 1
  size    = 20
  left    = 6.5

  recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: #{puce.inspect}
          size: #{size}
          vadjust: #{vadjust}
          left: #{left}mm
    #</book_format>
    YAML

  init_recipe([:format_text])

  _ps = vadjust > 1 ? 's' : ''
  
  sample_texte <<~EOT
    * Ceci est une puce `#{puce.inspect}` de #{size} points, remontée de #{vadjust} point#{_ps}, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
