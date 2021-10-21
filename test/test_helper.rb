# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "on_page"

require "minitest/autorun"
require "minitest/color"

require "vcr"

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "test/cassettes"
  c.default_cassette_options = {
    match_requests_on: %i[method uri body]
  }

  # use real token to record new tests
  c.filter_sensitive_data("COMPANY_NAME") { "company_name" }
  c.filter_sensitive_data("API_TOKEN") { "api_token" }
end
