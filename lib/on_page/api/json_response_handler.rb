# frozen_string_literal: true

require_relative "api_response"

module OnPage
  module Api
    # Interprets api success/failure API response as json, filling a ApiResponse object with the results
    class JSONResponseHandler
      attr_reader :klass

      def initialize(klass = nil)
        @klass = klass
      end

      def call(http_response)
        content = json_body_content(http_response)
        if http_response.is_a?(Net::HTTPSuccess)
          success_response(content)
        else
          failure_response(content)
        end
      end

      private

      def json_body_content(http_response)
        return nil unless http_response && !http_response.body.nil? && !http_response.body.empty?

        data = JSON.parse(http_response.body)
        data&.empty? ? nil : data
      end

      def success_response(content)
        outcome = if content.instance_of? Array
                    content.map { |thing| @klass.new(thing) }
                  else
                    content.nil? ? nil : @klass.new(content)
                  end
        ApiResponse.new(outcome)
      end

      def failure_response(content)
        response = ApiResponse.new # ApiResponse.new(OpenStruct.new(content))
        response.add_error extract_error_message(content)
        response
      end

      def extract_error_message(content)
        error_text = nil
        error_text = content.fetch("message") if content.instance_of? Hash
        error_text || "unexpected error"
      end
    end
  end
end
