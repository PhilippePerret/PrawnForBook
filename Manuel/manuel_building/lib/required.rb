
require_relative 'constants'
require_relative 'Feature'
require_relative 'RealBook'

if debug?
  spy(:off)
else
  def spy(*args); end
end
