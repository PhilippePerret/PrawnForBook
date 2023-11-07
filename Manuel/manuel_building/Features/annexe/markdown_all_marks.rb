Prawn4book::Manual::Feature.new do

  titre "Marques markdown"

  description <<~EOT
    <-(all_markdown)
    Vous trouverez ci-dessous toutes les marques Markdown utilisables.
    EOT

  sample_texte <<~EOT
    La table ci-dessous a été construite aussi en markdown, en utilisant le format : 
    \\| CA1 | CA2 | CA3 | CA4 \\|
    \\| CB1 | CB2 | CB3 | CB4 \\|
    \\|/|
    Vous pouvez trouver toutes les informations sur l'utilisation des tables à la page ->(tables).
    EOT

  texte <<~EOT
    (( {width: "100%", col_count:3, cell_style:{border_width:[0.1, 0]}} ))
    | italique    | \\*...\\*         | *texte en italique*   |
    | gras        | \\*\\*...\\*\\*   | **texte en gras**     |
    | souligné    | \\__...\\__       | __texte souligné__    |
    | exposants   | 1\\^er            | 1^er                  |
    |        | 1\\^re            | 1^re                  |
    |        | 2\\^e             | 2^e                   |
    |        | X\\^e             | X^e                   |
    |/|
    EOT

end
