require 'oauth'
require 'json'
require 'active_support/core_ext'

module Whelp
  module Utilities
    class Kernel
      def self.const_exists?( name )
        const_get( name.capitalize )
        true
      rescue
        false
      end
    end


    class ClassFactory

      def self.create(*args,&block)
        name = args.shift || ''
        name = name.to_s
        attribute_pairs = args.pop || {}
        attributes = attribute_pairs.keys
        attributes = attributes.map &:to_sym
        values     = attribute_pairs.values

        if !Kernel.const_exists?(name)
          Object.const_set(name.capitalize,Struct.new(*attributes))
        end

        object = Kernel.const_get name.capitalize

        object.new *values
      end

    end

  end

  module Adapters
    class Query

      class << self
        ['term','location','limit'].each do |method|
          define_method method do |val|
            @query << "#{method}=#{val}"
          end
        end
      end

      def self.build(&block)
        @query = []
        instance_eval &block
        @query = @query.join('&')
        @query.gsub!(' ','%20')
      end

    end

    class NullObject

      def stubs
        [:body]
      end

      [:nil?,:blank?,:empty?].each do |method|
        define_method(method) { true }
      end

      [:present?,:any?].each do |method|
        define_method(method) { false }
      end

      def method_missing(*args,&block)
        stubs.include?(args.first) && return
        super
      end

    end

    class Result
      include Utilities

      attr_reader :body,:content,:region,:total,:businesses

      def initialize( content=nil )
        @content ||= content || NullObject.new
        @body    ||= @content.body
      end

      def all
        @all ||= JSON.parse( body )
      end

      def instantiate_results!
        @region = ClassFactory.create 'region',all['region']
        @total  = all['total']
        @businesses = all['businesses'].map { |business| ClassFactory.create 'business',business }
      end

    end

    class Yelp
      def initialize(*args)
        @block_of_caller = args.last
        instance_eval &@block_of_caller
      end

      def version(number=nil)
        @version ||= 2
      end

      def api_host
        'api.yelp.com'
      end

      def consumer
        @consumer ||= OAuth::Consumer.new(configuration[:consumer_key],configuration[:consumer_secret], {:site => "http://#{api_host}"})
      end

      def access_token
        @access_token ||= OAuth::AccessToken.new(consumer,configuration[:token],configuration[:token_secret])
      end

      def configuration(options=nil)
        @configuration ||= options
      end

      def path
        '/v2/search?'
      end

      def search(*args,&block)
        query = block_given? ? Query.build(&block) : args.first || ''
        @content = access_token.get( path << query )
      end

      def results
        @results ||= Result.new(@content)
      end

    end
  end
end