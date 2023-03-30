module TableFormaterModule

  def filtering(ntable)


    ntable.blockcode = Proc.new do

      # columns(0..-1).rows(0..-1)
      cells.filter do |cell|
        cell.content.start_with?('X')
      end.background_color = 'DAF7A6'

      # 
      # Filtre personnel
      # 
      bads  = Prawn::Table::Cells.new
      goods = Prawn::Table::Cells.new
      columns(0..-1).rows(0..-1).each do |cell|
        next unless cell.content.numeric?
        if cell.content.to_i > 25
          goods << cell
          # cell.background_color  = '00FF00'
        else
          bads << cell
          # cell.background_color = 'FF0000'
        end
      end

      goods.background_color = 'FF0000'
      bads.background_color  = '00FF00'

    end

    # Aucun style retourné    
    return nil
  end

end #/TableFormaterModule
