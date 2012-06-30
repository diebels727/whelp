require "whelp/version"
require 'whelp/adapters'

class Array

  def extract_options!
    pop if last.is_a? Hash
  end

end

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

class Object
  include Whelp

  def whelpable?
    false
  end

end
