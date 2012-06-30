require 'whelp/adapters/yelp'

module Whelp
  class Adapter
    def self.build(name,block_of_caller)
      adapter_class = eval('Whelp::Adapters::' << name.to_s.capitalize)
      adapter_class.new( block_of_caller )
    end
  end
end