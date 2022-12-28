module Prawn4book

# --- Toutes les données permettant de renseigner les recettes
# --- 
# --- Sert autant aux templates qu'à l'assistant
# ---

# Pour le menu principal qui présente toutes les données à définir
# pour choisir celle qu'on veut faire maintenant.
CHOIX_DATA2DEFINE = [
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:book_data])     , value: :book_data},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:fonts])         , value: :fonts},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:book_format])   , value: :book_format},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:titles])        , value: :titles},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:wanted_pages])  , value: :wanted_pages},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:book_infos])    , value: :infos},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:recipe_options]), value: :options},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:headers_and_footers]), value: :headers_and_footers},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:biblios]), value: :biblios},
  {name:PROMPTS[:finir]+" (#{TERMS[:other_default_values]})"  , value: :finir}
]
DATA2DEFINE_VALUE_TO_INDEX = {}
CHOIX_DATA2DEFINE.each_with_index do |dvalue, idx|
  DATA2DEFINE_VALUE_TO_INDEX.merge!(dvalue[:value] => idx)
end

RECIPE_VALUES_FOR_WANTED_PAGES = [
  {k: :pagegarde, q:'Dois-je laisser une page de garde ?', df:true, t: :yes},
  {k: :fauxtitre, q:'Dois-je imprimer la page de faux titre (titre seul) ?', df:true, t: :yes},
  {k: :pagetitre, q:'Dois-je imprimer la page de titre (titre et infos) ?', df:true, t: :yes},
  {k: :pageinfos, q:'Dois-je imprimer la page d’informations (fin du livre) ?', df:true, t: :yes},
]

RECIPE_VALUES_FOR_OPTIONS = [
  {k: :numparag, q:'Dois-je numéroter les paragraphes ?', df:false, t: :yes},
  {k: :numpage, q:'Pagination avec :', df: 'num_page', t: :select, values:[{name:'numéro page', value:'num_page'},{name:'numéros paragraphes', value:'num_parag'}]},
]

end # module Prawn4book
