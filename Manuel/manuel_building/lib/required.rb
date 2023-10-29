
require_relative 'constants'
require_relative 'Feature'

if debug?
  spy(:off)
else
  def spy(*args); end
end
