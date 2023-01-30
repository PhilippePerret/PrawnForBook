=begin

  Grand commande permettant de gérer les bibliographies.

=end
module Prawn4book

class Command
  def proceed
    clear
    # 
    # On s'assure qu'il y a bien un livre courant
    # 
    book = Prawn4book::PdfBook.ensure_current || return
    # 
    # On prend ce qui est défini dans la ligne de commande.
    # 
    biblio_id, subcommand = CLI.components # non utilisé pour le moment
    # 
    # Choisir l'action à accomplir
    action = precedencize(choices_actions, __dir__) do |q|
      q.question PROMPTS[:Action_to_run]
      q.add_choice_cancel
    end
    action || return

    # 
    # On requiert tout ce qui concerne les bibliographies
    # 
    require 'lib/pages/bibliographies'
    # 
    # On exécute l'action désirée
    # 
    case action
    when 'create_biblio' then biblio = Prawn4book::Bibliography.assiste_creation(book)
      
    end

    # 
    # Dans tous les cas, il faut avoir une bibliographie, en choisir
    # une ou en construire une nouvelle
    # 
    # [Prawn4book::Bibliography]
    biblio ||= Bibliography.choose_or_create(book) || return

    case action
    when 'create_bibitem'
      Bibliography::BibItem.assiste_creation(book, biblio)
    when 'edit_biblio'
      puts "Je dois apprendre à éditer une bibliographie".jaune
    when 'edit_bibitem'
      puts "Je dois apprendre à éditer un item de bibliographie".jaune
    when 'choose_bibitem'
      puts "Je dois apprendre à proposer de choisir un item de bibliographie".jaune
    end

  end
  # /proceed

  def choices_actions
    [
      {name: (PROMPTS[:creer_une] % TERMS[:bibliography]) , value: 'create_biblio'},
      {name: (PROMPTS[:creer_un] % TERMS[:biblio_item])   , value: 'create_bibitem'},
      {name: (PROMPTS[:edit_une] % TERMS[:bibliography])  , value: 'edit_biblio'},
      {name: (PROMPTS[:edit_un] % TERMS[:biblio_item])    , value: 'edit_bibitem'},
      {name: (PROMPTS[:choose_un] % TERMS[:biblio_item])  , value: 'choose_bibitem'},
    ]
  end
end #/Command
end #/ module Prawn4book
