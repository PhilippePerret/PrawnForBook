module PrawnHelpersMethods

  def display_lines_references
    h = pdf.bounds.top
    lr = []
    while h > 0
      lr << round(h)
      h -= pdf.line_height
    end
    "line_height:#{pdf.line_height} | " + lr.join(', ') 
  end

end #/module PrawnHelpersMethods
