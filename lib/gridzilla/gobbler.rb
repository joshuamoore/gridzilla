module Gridzilla
  class Gobbler < BlankSlate
    def method_missing(meth_name, *args, &block)
      self
    end
  end
end
