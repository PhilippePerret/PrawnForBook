D'abord une table où la dernière largeur de colonne n'est pas définie, avec une largeur totale définie.

(( {width: '50%', column_widths: [40,40]} ))
| A1 | B1 | C1 |
| A2 | B2 | C2 |

La même table, mais sans largeur définie. Dans ce cas, c'est la page complète qui est utilisée.
(( {column_widths: [40,40]} ))
| A1 | B1 | C1 |
| A2 | B2 | C2 |

Ensuite une table où c'est la deuxième colonne qui n'est pas définie, mais la troisième si. Dans ce cas-là, on met la valeur nil.
(( {width: '75%', column_widths: [40, nil, 40]} ))
| A1 | B1 | C1 |
| A2 | B2 | C2 |

Idem, sans précision de largeur (la page complète doit être utilisée)
(( {column_widths: [40, nil, 40]} ))
| A1 | B1 | C1 |
| A2 | B2 | C2 |

Une table plus complexe, avec un colspan pour mettre le trouble dans le comptage des colonnes.

(( {col_count: 3, column_widths: [30, nil, 30]} ))
| {content:"Une longue ligne comme un titre", colspan: 3, align: :center} |
| A1 | B1 | C1 |
| A2 | B2 | C2 |
