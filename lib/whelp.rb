require "whelp/version"
require 'whelp/adapters'

module Whelp

  def self.included(*args)
    base = args.first
    base.extend ClassMethods
  end

  module ClassMethods

    attr_reader :adapter

    def whelpable(adapter,&block)
      include InstanceMethods
      @adapter = Adapter.build adapter,block
    end

    def whelpable?
      true
    end

  end

  module InstanceMethods

    def adapter
      @adapter ||= self.class.adapter
    end

    def search(*args,&block)
      adapter.search(*args,&block)
    end

    def results
      adapter.results
    end

    def whelpable?
      true
    end

  end



end

#Need to extend via Railtie
class Object
  include Whelp

  def whelpable?
    false
  end

end
