module Prawn4book
class PrawnView

  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end


  def top_mg; @top_mg ||= config[:top_margin] || DEFAULT_TOP_MARGIN end
  def bot_mg
    @bot_mg ||= begin
      (config[:bottom_margin] || DEFAULT_BOTTOM_MARGIN) + 20
    end
  end
  def ext_mg
    @ext_mg ||= begin
      lm = config[:left_margin] || DEFAULT_LEFT_MARGIN
      lm += parag_number_width if paragraph_number?
      lm
    end
  end
  def int_mg
    @int_mg ||= begin
      rm = config[:right_margin] || DEFAULT_RIGHT_MARGIN
      rm += parag_number_width if paragraph_number?
      rm
    end
  end

end #/class PrawnView
end #/module Prawn4book
