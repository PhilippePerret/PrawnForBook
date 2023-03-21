module TableFormaterModule


  def formated_with_bloc(ntable)
    ntable.code_block = Proc.new do 
      cells.padding = 40
      cells.align   = :right
      cells.valign  = :center
      cells.width   = 100
      column(1).font_style = :bold
      column(1).size = 30
      column(1).width = 200 # redéfinition
      column(1).align = :left # redéfinition
    end
  end

end
