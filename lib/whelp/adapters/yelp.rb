require 'oauth'
require 'json'
require 'active_support/core_ext'

module Whelp
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
      attr_reader :body,:content

      def initialize( content=nil )
        @content ||= content || NullObject.new
        @body    ||= @content.body
      end

      def all
        @all ||= JSON.parse( body )
      end

      def instantiate!

        #region = results['region']

        #define keys as constants
        #separate metadata
        #instantiate businesses, e.g. results.businesses returns [ business, business, business ]

        #instantiated results are results.region, results.total (just an integer), results.businesses

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