module Prawn4book
class PrawnView

  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end

  def top_mg; @top_mg ||= config[:top_margin] end
  def bot_mg; @bot_mg ||= config[:bot_margin] + 20 end
  def ext_mg; @ext_mg ||= config[:ext_margin] end
  def int_mg; @int_mg ||= config[:int_margin] end

end #/class PrawnView
end #/module Prawn4book
