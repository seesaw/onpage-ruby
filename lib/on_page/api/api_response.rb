# frozen_string_literal: true

require "ostruct"

module OnPage
  module Api
    # API response as json as value object(s) of the given class
    class ApiResponse
      attr_reader :errors, :result

      def initialize(result = nil)
        @errors = []
        @result = result
      end

      def failed?
        !@errors.empty?
      end

      def error_messages
        @errors.join(",")
      end

      def add_error(text)
        @errors << text
      end
    end
  end
end
