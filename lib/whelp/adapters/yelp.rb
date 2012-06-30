require 'oauth'
require 'json'

module Whelp
  module Adapters
    class Query

      class << self
        ['term','location'].each do |method|
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
        @results = access_token.get( path << query )
      end

      def results
        @results = JSON.parse( @results.body )
      end

    end
  end
end