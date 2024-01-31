#
# MODULE Prawn4book::Occurrences
# ------------------------------
# Module inauguré pour traiter les occurrences, dans les bibliogra-
# phies et autres index de façon soignée, en pouvant définir des
# fontes pour les canons (ou donnée bibliographiques) et surtout les
# occurrences en fonction de leur poids.
# 
module Prawn4book
module Occurrences
  def self.as_formatted(data, occurrences)
    return Occurrences.new(data).formatted_occurrences(occurrences)
  end

  class Occurrences
    def initialize(data = {})
      # Le texte principal
      @text = data[:text]
      # Les fontes en fonction du poids
      @fonte          = data[:fonte]        || Prawn4book::Fonte.default
      @normal_fonte   = data[:fonte_normal] || Prawn4book::Fonte.default
      @main_fonte     = data[:fonte_main]   || @normal_fonte
      @minor_fonte    = data[:fonte_minor]  || @normal_fonte
      # - La clé de référence -
      # (pour la pagination à utiliser)
      @key_ref        = data[:key_ref] || :page
    end
    # @main
    # 
    # @params [Array<Hash>] occs
    #     Liste des occurrences. Une table où chaque élément doit
    #     contenir :poids ou :weight (le poids), :page (le numéro de
    #     page), :paragraph (numéro de paragraphe) ou :hybrid (format
    #     de référence hybrid, avec la page et le paragraphe)
    #     La donnée peut contenir :count qui définit le nombre
    #     d’occurrences dans la référence précise
    # 
    def formatted_occurrences(occs)
      segments = [
        fonte_data.merge(text: "#{@text} : ")
      ]
      occs.each do |hocc|
        poids = hocc[:poids] || hocc[:weight] || :normal
        ref   = hocc[@key_ref].to_s
        font_data = send("#{poids}_fonte_data".to_sym) # p.e. main_fonte_data
        segments << font_data.merge(text: ref)
        if hocc.key?(:count)
          segments << hash_count(hocc[:count], poids)  
        end
        segments << hash_virgule
      end
      # 1) On retire le dernier pour mettre un point
      segments.pop
      segments << hash_point
      # 2) s’il y a plus de deux éléments, on ajoute "et" au lieu 
      # de la dernière virgule
      # segments[-3] = hash_et if segments.count > 3

      return segments
    end

    # - Données des fontes en fonction du poids -
    # 
    def main_fonte_data
      @main_fonte_data ||= {
        font:   @main_fonte.name, 
        size:   @main_fonte.size, 
        styles: @main_fonte.styles, 
        color:  @main_fonte.color
      }.freeze
    end
    def normal_fonte_data
      @normal_fonte_data ||= {
        font:   @normal_fonte.name, 
        size:   @normal_fonte.size, 
        styles: @normal_fonte.styles, 
        color:  @normal_fonte.color
      }.freeze
    end
    def minor_fonte_data
      @minor_fonte_data ||= {
        font:   @minor_fonte.name, 
        size:   @minor_fonte.size, 
        styles: @minor_fonte.styles, 
        color:  @minor_fonte.color
      }.freeze
    end

    def fonte_data
      @fonte_data ||= {
        font:   @fonte.name,
        size:   @fonte.size,
        styles: @fonte.styles,
        color:  @fonte.color
      }.freeze
    end

    def count_fonte_data
      @count_fonte_data ||= begin
        fsize = fonte_data[:size] - 1
        fsize -= 3 if fsize > 12
        fonte_data.merge(size:fsize).freeze
      end
    end

    # - Hash des données pour le nombre de fois -

    def hash_count(count, poids)
      count_fonte_data.merge(text: " (x#{count})")
    end

    # - Hash de données pour les séparateurs -

    def hash_virgule
      @hash_virgule ||= fonte_data.merge(text:', ')
    end
    def hash_et
      @hash_et ||= fonte_data.merge(text:' et ')
    end
    def hash_point
      @hash_point ||= fonte_data.merge(text:'.')
    end


    # - Tailles en fonction du poids -

    def sizes_per_weight
      @sizes_per_weight ||= {
        main:   @main_fonte.size - 1,
        normal: @normal_fonte.size - 1,
        minor:  @minor_fonte.size - 1
      }
    end

  end
end #/module Occurrences
end #/module Prawn4book
