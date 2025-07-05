module CustomIndexModule

  # def index_lettre(lettre, output, context)
  #   return lettre
  # end

end

module PrawnHelpersMethods
  def lettre(params, context)
    name, lettre = params
    return (name + ' = <font name="PictoPhil" size="16">' + lettre + '</font>')
  end
end