# frozen_string_literal: true

require "net/http"
require "json"
require_relative "json_response_handler"
require_relative "api_response"

module OnPage
  module Api
    # Handle a JSON request, filling the body from the criterion
    class JSONRequestHandler
      attr_reader :criteria

      def initialize(criteria = {})
        @criteria = criteria
      end

      # Returns the body String for the request
      #
      # @return [String] The body as a String
      def body
        @criteria&.empty? ? nil : JSON.fast_generate(@criteria.to_h)
      end

      def type
        :json
      end

      # Sets any headers necessary for the body to be processed.
      def headers
        { "Content-Type": "application/json" }
      end
    end

    # OnPage::Api::HttpClient
    class HttpClient
      def initialize
        @criteria = {}
        @response_handler = nil
        @request_handler_class = JSONRequestHandler
      end

      def get
        @criteria.merge! _method: "get"
        do_call
      end

      def post
        do_call
      end

      def uri(uri)
        @uri = uri.dup
        self
      end

      def criteria(criteria)
        @criteria.merge! criteria.to_h if criteria
        self
      end

      def response_handler(response_handler)
        @response_handler = response_handler
        self
      end

      # def request_handler_class(klass)
      #   @request_handler_class = klass
      #   self
      # end

      private

      def http_call_options(uri)
        options = {
          use_ssl: uri.instance_of?(URI::HTTPS)
        }
        config = OnPage.configuration
        options[:read_timeout] = config.read_timeout if config.read_timeout
        options[:open_timeout] = config.connect_timeout if config.connect_timeout
        options
      end

      def do_call
        raise ArgumentError, "You must specify a URL" if @uri.nil?
        raise ArgumentError, "You must specify a response handler" if @response_handler.nil?

        # raise ArgumentError, "You must specify a body handler class" if @request_handler_class.nil?

        http_response = begin
          OnPage::Api.inc_request_counter
          Net::HTTP.start(@uri.host, @uri.port, http_call_options(@uri)) do |http|
            body_handler = @request_handler_class.new(@criteria)
            http.request_post(@uri.path, body_handler.body, body_handler.headers)
          end
        rescue StandardError => e
          raise OnPage::ApiError, e.message
        end

        outcome = @response_handler.call(http_response)
        raise OnPage::ApiError, outcome.error_messages if outcome.failed?

        outcome.result
      end
    end
  end
end
