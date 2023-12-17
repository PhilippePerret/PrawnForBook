require 'iconv'
module Prawn4book
class ManuelSearcher

  MANUEL_TEXT_PATH  = "#{APP_FOLDER}/Manuel/manuel_building/only_text.txt"

  # Longueur à prendre autour (avant et après) le texte trouvé
  CONTEXT_LENGTH    = 200

class << self


  def search(expression)
    expression = 
      if expression.start_with?('/') && expression.end_with?('/')  
        # - Recherche régulière -
        Regexp.new(expression[1..-2])
      else
        # - Recherche explicite -
        Regexp.new(Regexp.escape(expression))
      end
    proceed_search(expression)
  end

  def proceed_search(expression)
    founds = []
    whole_code.scan(expression) do |found|
      if found.is_a?(Array)
        puts "found array : #{found.freeze}"
        found = found[0] 
      end
      founds << [ found, $~.offset(0)[0] ]
    end
    puts "Recherche de #{expression.inspect}\n".jaune
    if founds.any?
      clear
      whole_text_len = whole_code.length
      reg_page = /\-\-\-\-\-\-PAGE \#?([0-9]+)\-\-\-\-\-\-/.freeze
      puts "Recherche de #{expression.inspect}\n".jaune
      founds.each_with_index do |pair, idx|
        found, offset = pair
        # --- Recherche de la page ---
        start_offset = offset.dup
        page_number = nil
        while page_number.nil?
          txt = whole_code[start_offset..offset]
          if (pn = txt.match(reg_page))
            page_number = pn[1].to_i
          end
          start_offset -= 20 
        end
        # --- Inscription du résultat ---
        puts "\n[#{idx+1}](#{offset}) --- Page #{page_number} ---".bleu
        from_car = offset - CONTEXT_LENGTH
        from_car = 0 if from_car < 0
        before_txt = whole_code[from_car...offset]
        before_txt = "[…] #{before_txt}" unless from_car == 0
        to_car   = offset + CONTEXT_LENGTH
        after_txt = whole_code[offset+found.length..to_car]
        after_txt = "#{after_txt} […]" unless to_car + 1 >= whole_text_len
        puts before_txt + found.bleu + after_txt
      end
      s = founds.count > 1 ? 's' : ''
      puts "\n#{founds.count} élément#{s} trouvé#{s}".bleu
    else
      # - Aucun trouvé -
      puts "Aucun élément trouvé"
    end
  end


  def whole_code
    @whole_code ||= begin
      # File.read(MANUEL_TEXT_PATH)
      # txt = File.read(MANUEL_TEXT_PATH, encoding:'utf-8')
      # s = open(MANUEL_TEXT_PATH, "r:ISO-8859-1:UTF-8") { |io| io.read }
      # open(MANUEL_TEXT_PATH, "r:UTF-8:ISO-8859-1") { |io| io.read } # => error
      # s
      txt = File.read(MANUEL_TEXT_PATH)
      # Iconv.iconv('utf-8', 'iso8859-1', txt).join('')
    end
  end

end #/<< self
end #/class ManuelSearcher
end #/module Prawn4book
