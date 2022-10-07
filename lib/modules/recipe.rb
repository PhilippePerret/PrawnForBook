module Prawn4book
class PdfBook

  def self.define_first_recipe

    # 
    # Confirmer le dossier
    # 
    Q.yes?("Initier le nouveau livre dans le dossier courant ?\n(#{cfolder})".jaune) || return

    # 
    # Questions à poser
    # 
    data = [
      {q: "Titre du livre"          , id:'titre'   , v: nil},
      {q: "Auteur du livre"         , id:'auteur'  ,v: nil},
      {q: "Identifiant (seulement lettres et '_')"  , id:'id'  , v: nil},
      {q: "Dossier où placer le dossier du livre"   , id:'main_folder'  , v: cfolder},
      {q: "Texte initial (chemin)", id:'text_path', v:nil}
    ]
    # 
    # Autres données
    data += [
      {q: "Dimensions", id:'dim', type:'list', values: DIM_VALUES},
      {q: 'Marges en mm (Haute, Intérieure, Basse, Extérieure)', id: 'marges', v: nil},
      {q: 'Interligne', id:'interligne', v:18},
      {q: "Paragraphes numérotés ?", id:'opt_para_num', type:'bool'},
      {q: "Polices utilisées (vous pourrez les définir plus tard)", id:'fonts'},
      {q: 'Numéroter les pages avec : ', id:'num_page', values: NUMPAGES_VALUES},
    ]

    #
    # On demande les valeurs
    # 
    data.each do |dproperty|
      question = dproperty[:q].jaune
      vdefaut  = dproperty[:v]
      case dproperty[:type]
      when 'bool'
        dproperty.merge!(v: Q.yes?(question))
      when 'list'
        dproperty.merge!(v: Q.select(question, dproperty[:values], default:vdefaut))
      else
        dproperty.merge!(v: Q.ask(question, default:vdefaut))
      end
    end

    #
    # On fait une table de données
    # 
    cdata = {}
    data.each do |dproperty|
      cdata.merge!( dproperty[:id].to_sym => dproperty[:v])
    end

    # 
    # On peut enregitrer le livre
    # 
    PdfBook.new.create_recipe(cdata)

  end

  def self.cfolder
    @@cfolder ||= File.expand_path('.')
  end


  # --- INSTANCE ---

  def create_recipe(data)

    #
    # Check des valeurs
    # 
    check_creation_data(data)

    # 
    # Création du dossier
    # 
    @folder = File.join(data[:main_folder], data[:id])
    mkdir(@folder)
    
    # 
    # Création du fichier
    # 
    @recipe_path = File.join(folder, 'recipe.yaml')
    File.write(recipe_path, data.to_yaml)

    #
    # On dépose le texte dans le dossier
    # 
    FileUtils.cp(data[:text_path], text_path)

    puts "Dossier du livre créé avec succès.".vert
    puts "Placez-vous dans ce dossier puis jouer ".jaune
    puts "la commande 'prawn-for-book build' pour ".jaune
    puts "produire la première version du livre.".jaune
  end

  def text_path
    @text_path ||= File.join(folder, "texte#{File.extname(original_text_path)}")
  end

  def original_text_path
    @original_text_path ||= data[:text_path]
  end


  private


    ##
    # Méthode qui check les données
    # 
    #
    # Vérifications à faire
    # 
    # - non existence du dossier
    # - existence du fichier texte
    # - conformité de l'identifiant
    # 
    def check_creation_data(cdata)
      @data = cdata
      cdata[:titre]  || raise("Le titre est requis")
      cdata[:titre].length < 50 || raise("Le titre est trop long")
      cdata[:titre].length > 2 || raise("Le titre est trop court")
      cdata[:auteur] || raise("L'auteur du livre est requis")
      cdata[:id]     || raise("L'identifiant du livre est requis")
      cdata[:id].gsub(/[a-z0-9_]/i,'') == '' || raise("L'identifiant n'est pas valide (que des lettres et '_')")
      not(File.exist?(folder)) || raise("Le dossier de ce livre existe déjà… Je ne le touche pas.")
      cdata[:text_path] || raise("Le chemin d'accès au texte doit être défini.")
      File.exist?(cdata[:text_path]) || raise("Le fichier texte est introuvable (in #{cdata[:text_path]})")
      # --- autres valeurs ---
      marges_ok?(cdata)

    end

    def marges_ok?(cdata)
      cdata[:marges] || raise("Il faut définir les marges du livre")
      marges = cdata[:marges].split(',').map { |n| n.to_i }
      marges.count == 4 || raise("4 marges doivent être définies")
      marges.each { |mg| mg.between?(5,50) || raise("Les marges doivent mesurer entre 5 et 50 mm !")} 
    end

DIM_VALUES = [
  {name:'12,7 cm x 20,32 cm (5 x 8 po)' , value:'127x203.2'   },
  {name:'21 x 29.7 (A4)'                , value:'210x297'     },
  {name:'15,24 x 22,86 (6 x 9 po)'      , value:'152.4x228.6' },
  {name:'14.85 x 21 (A5)'               , value:'148.5x210'   },

]

NUMPAGES_VALUES = [
  {name: 'Ne pas numéroter les pages' , value: false          },
  {name: 'Numéro simple'              , value: 'simple'        },
  {name: 'Numéro avec nombre total'   , value: 'num_et_nombre' },
  {name: 'Numéro de paragraphes'      , value: 'num_parags'    }
]
end #/class PdfBook
end #/module Prawn4book
