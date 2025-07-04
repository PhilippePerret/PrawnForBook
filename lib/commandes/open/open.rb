module Prawn4book
    
  # @runner
  class Command
    def proceed; Prawn4book.open_something end
  end #/Command


  def self.open_something
    case CLI.components[0]
    when NilClass # => le livre (pdf, txt, etc.)
      case choisir_quoi_ouvrir
      when NilClass         then return
      when :book            then open_pdf_book
      when :folder          then open_book_folder(false)
      when :ffolder         then open_book_folder(true)
      when :cfolder         then open_collection(false)
      when :cffolder        then open_collection(true)
      when :package         then open_sublime_text_package
      when :pfb_manual      then open_manual_prawn_for_book
      when :folder_manuel   then open_manual_folder
      when :auto_manual     then open_auto_manual
      when :auto_manual_bat then open_auto_manual_bat
      when :prawn_manual    then open_prawn_manual
      when :prawntbl_manual then open_prawn_table_manual
      end
    when 'manuel'
      open_manual_prawn_for_book
    when 'book'
      PdfBook.current.open_book
    when 'package-st'
      open_sublime_text_package
    else
      raise PFBFatalError.new(300, {ca:CLI.components[0].inspect})
    end
  end

  def self.open_book_folder(in_finder)
    book = PdfBook.ensure_current || return
    if in_finder
      `open -a Finder "#{book.folder}"`
    else
      `code "#{book.folder}"` # VSCode
      # `subl -n "#{book.folder}"` # Sublime Text
    end
  end

  def self.open_pdf_book
    book = PdfBook.ensure_current || return
    book.open_book
  end

  def self.open_collection(in_finder)
    book = PdfBook.ensure_current || return
    book.in_collection? || begin
      raise PFBFatalError.new(10, {title:File.basename(book.folder)})
    end
    if in_finder
      `open -a Finder "#{book.collection.folder}"`  
    else
      `code "#{book.collection.folder}"` # VSCode
      # `subl -n "#{book.collection.folder}"` # Sublime Text
    end
  end

  def self.open_manual_prawn_for_book
    if edition?
      `open -a Typora "#{USER_MANUAL_MD_PATH}"`
    else
      # `open -a Preview "#{USER_MANUAL_PATH}"`
      `open "#{USER_MANUAL_PATH}"`
    end
  end

  def self.open_prawn_manual
    `open "#{PRAWN_MANUEL_PATH}"`
  end

  def self.open_auto_manual
    `open "#{APP_FOLDER}/Manuel/MANUEL_BUILDING/book.pdf"`
  end

  def self.open_auto_manual_bat
    `open "#{APP_FOLDER}/Manuel/MANUEL_BUILDING/book_bat.pdf"`
  end

  def self.open_manual_folder
    `open -a "Finder" "#{APP_FOLDER}/Manuel/MANUEL_BUILDING"`
  end

  def self.open_prawn_table_manual
    `open #{PRAWN_TABLE_MANUAL}`
  end

  def self.open_sublime_text_package
    `subl "#{PACKAGE_SUBLIME_TEXT}"`
  end

  def self.choisir_quoi_ouvrir
    clear
    choices = [
      {name:TERMS[:curbook_pdf],        value: :book},
      {name:TERMS[:curbook_in_ide],     value: :folder},
      {name:TERMS[:curbook_in_finder],  value: :ffolder},
      {name:TERMS[:coll_in_ide],        value: :cfolder},
      {name:TERMS[:coll_in_finder],     value: :cffolder},
      {name:TERMS[:package_subtext],    value: :package},
      {name:TERMS[:manual_pfb],         value: :pfb_manual},
      {name:TERMS[:auto_manual],        value: :auto_manual},
      {name:TERMS[:auto_manual_bat],    value: :auto_manual_bat},
      {name:TERMS[:manual_prawn],       value: :prawn_manual},
      {name:TERMS[:manual_prawn_table], value: :prawntbl_manual},
      {name:TERMS[:folder_manuel]     , value: :folder_manuel}
    ]
    precfile = File.join(__dir__, '.precedences')
    choix = precedencize(choices, precfile) do |q|
      q.question PROMPTS[:Open_]
      q.add_choice_cancel(:up, {value: :cancel, name: PROMPTS[:cancel]})    
    end
  end

  def self.edition?
    CLI.option(:dev) || CLI.option(:edition)
  end

PACKAGE_SUBLIME_TEXT = File.join(Dir.home,'Library','Application Support','Sublime Text','Packages','Prawn4Book')

end #/ module Prawn4book
