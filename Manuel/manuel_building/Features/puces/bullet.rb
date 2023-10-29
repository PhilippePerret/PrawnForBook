Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce ronde"

  puce    = :bullet
  vadjust = 1
  size    = 20

  sample_recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: #{puce.inspect}
          size: #{size}
          vadjust: #{vadjust}
    #</book_format>
    YAML

  recipe({
    format_text: {
      puce: {
        text: puce, size: size, vadjust:vadjust, hadjust: 0, left: '4mm'
      }
    }
  })

  _ps = vadjust > 1 ? 's' : ''
  
  sample_texte <<~EOT
    * Ceci est une puce `#{puce.inspect}` de #{size} points, remontée de #{vadjust} point#{_ps}, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
