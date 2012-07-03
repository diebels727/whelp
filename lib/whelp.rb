require "whelp/version"
require 'whelp/adapters'
require 'whelp/railtie' if defined?(Rails)

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
      class << self
        define_method(:whelpable?) { true }
      end
    end

  end

  module InstanceMethods

    def adapter
      @adapter ||= self.class.adapter
    end

    def whelp_for(*args,&block)
      adapter.search(*args,&block)
    end

    def results
      adapter.results
    end

    def whelpable?
      self.class.whelpable?
    end

  end

end



