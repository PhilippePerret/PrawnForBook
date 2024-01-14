Prawn4book::Manual::Feature.new do

  titre "Correspondances linguistiques"


  locale_terms_file = File.join(LOCALISATION_FOLDER,'properties.yaml')
  locale_terms = YAML.safe_load(File.read(locale_terms_file))

  locale_terms = locale_terms.sort{|a,b| a[1] <=> b[1] }.map do |en, lo|
    "| #{lo} | #{en} |"
  end.join("\n")

  description <<~EOT
    Cette section présente la correspondance entre tous les termes dans votre langue (#{Prawn4book::TERMS[:lang]}) et les termes anglais utilisés dans _PFB_.
    (( line ))
    (( {align: :center} ))
    #{locale_terms}
    |/|
    EOT


end
