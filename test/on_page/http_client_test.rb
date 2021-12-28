# frozen_string_literal: true

require_relative "../suite_test"
require "ostruct"
require "minitest/mock"

class HttpClientTest < SuiteTest
  def setup
    response_handler = OnPage::Api::JSONResponseHandler.new
    @uri = URI("http://www.example.net/")
    @client = OnPage::Api::HttpClient.new.uri(@uri).response_handler(response_handler)
  end

  def test_wraps_network_exceptions
    stub_request(:post, "www.example.net").to_timeout
    error = assert_raises(OnPage::ApiError) do
      @client.post
    end
    assert_equal "execution expired", error.message
  end

  def test_wraps_generic_exceptions
    stub_request(:post, "www.example.net").to_raise("error message")
    error = assert_raises(OnPage::ApiError) do
      @client.get
    end
    assert_equal "error message", error.message
  end

  def test_set_configured_timeouts
    with_env(
      "ONPAGE_READ_TIMEOUT" => "3_000_000",
      "ONPAGE_CONNECT_TIMEOUT" => "5_000_000"
    ) do
      # FIXME: wasn't able to find a cleaner way to test it :-(
      options = @client.send(:http_call_options, @uri)
      assert_equal 5_000_000, options[:open_timeout]
      assert_equal 3_000_000, options[:read_timeout]
    end
  end
end
