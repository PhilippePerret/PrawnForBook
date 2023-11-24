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
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:inserted_pages]), value: :inserted_pages},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:publisher])    , value: :publisher},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:book_infos])    , value: :credits_page},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:headers_and_footers]), value: :headers_and_footers},
  {name:(PROMPTS[:recipe][:data_for] % TERMS[:biblios]), value: :biblios},
]
DATA2DEFINE_VALUE_TO_INDEX = {}
CHOIX_DATA2DEFINE.each_with_index do |dvalue, idx|
  DATA2DEFINE_VALUE_TO_INDEX.merge!(dvalue[:value] => idx)
end

end # module Prawn4book
