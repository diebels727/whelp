require 'whelp'
require 'rails'
require 'whelp/railties/active_record'

module Whelp
  class Railtie < Rails::Railtie
    initializer 'whelp.initialize' do
      ActiveSupport.on_load(:active_record) do
        include Whelp
        self.extend Whelp::Railties::ActiveRecord
      end
    end
  end


end