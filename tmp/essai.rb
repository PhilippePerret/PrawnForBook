#!/usr/bin/env ruby -wU
# 
# 
module MonModuleClass
  def methode_module_class
    puts "Je suis la méthode de classe définie dans le module"
    if self.respond_to?(:methode_added_by_module)
      self.methode_added_by_module
    end
  end
end

module MonModule
def methode_module_instance
  puts "Je suis la méthode d'instance définie dans le module"
end
end


class MaClass
  extend MonModuleClass
  include MonModule

  def ou
    self.class.methode_module_class
    methode_module_instance
  end

end #/ class MaClass

inst = MaClass.new
inst.ou
