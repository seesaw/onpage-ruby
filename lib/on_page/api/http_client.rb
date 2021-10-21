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
        @connect_timeout = 1000
        @read_timeout = 2000
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

      def connect_timeout(connect_timeout)
        @connect_timeout = connect_timeout
        self
      end

      def read_timeout(read_timeout)
        @read_timeout = read_timeout
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

      def do_call
        raise ArgumentError, "You must specify a URL" if @uri.nil?
        raise ArgumentError, "You must specify a response handler" if @response_handler.nil?

        # raise ArgumentError, "You must specify a body handler class" if @request_handler_class.nil?

        body_handler = @request_handler_class.new(@criteria)

        outcome = begin
          OnPage::Api.inc_request_counter
          http_response = Net::HTTP.post(@uri, body_handler.body, body_handler.headers)

          @response_handler.call(http_response)
        rescue StandardError => e
          puts e.full_message
          raise OnPage::ApiError, e.message
        end

        raise OnPage::ApiError, outcome.error_messages if outcome.failed?

        outcome.result
      end
    end
  end
end
