# frozen_string_literal: true

require_relative "api/http_client"
require_relative "api/criteria"
require_relative "schema"
require_relative "thing"
require_relative "request_counter"
require "uri"

module OnPage
  # OnPage::FieldNotFound
  class FieldNotFound < StandardError; end

  # OnPage::ApiError
  class ApiError < StandardError; end

  # OnPage::Api
  module Api
    extend self

    def project_information
      http_client
        .uri(view_endpoint_url("schema"))
        .response_handler(OnPage::Api::JSONResponseHandler.new(Schema))
        .get
    end

    def query(criteria)
      http_client
        .uri(view_endpoint_url("things"))
        .criteria(criteria)
        .response_handler(OnPage::Api::JSONResponseHandler.new(Thing))
        .get
    end

    def storage_link(token, name = nil)
      url = URI.join storage_api_url, token
      url.query = "name=#{name}" unless name.nil?
      url
    end

    def inc_request_counter
      request_counter.inc!
    end

    def request_count
      request_counter.counter
    end

    def reset_request_counter
      request_counter.reset!
    end

    private

    def base_url
      URI("https://#{OnPage.configuration.company}.onpage.it/")
    end

    def api_url
      URI.join base_url, "api/"
    end

    def view_api_url
      URI.join api_url, "view/", "#{OnPage.configuration.api_token}/"
    end

    def storage_api_url
      URI.join api_url, "storage/"
    end

    def view_endpoint_url(action)
      URI.join view_api_url, action
    end

    def request_counter
      @request_counter ||= RequestCounter.new
    end

    def http_client
      HttpClient.new
                .connect_timeout(OnPage.configuration.connect_timeout)
                .read_timeout(OnPage.configuration.read_timeout)
      #         .request_handler_class(OnPage::Api::JSONRequestHandler)
    end
  end
end
