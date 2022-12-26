=begin
  
  Requis par toutes les pages, avant de charger leurs modules

=end

require_folder(File.join(__dir__,'special_pages_abstract'))

def require_page(page_name)
  require_folder(File.join(__dir__, page_name))
end
