Prawn4book::Manual::Feature.new do

  is_real_book


  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce doigt tendu noir"

  puce    = :black_finger
  vadjust = 1
  size    = 20
  left    = 7

  real_recipe <<~YAML
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
  
  real_texte <<~EOT
    * Ceci est une puce `#{puce.inspect}` de #{size} points, remontée de #{vadjust} point#{_ps}, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
