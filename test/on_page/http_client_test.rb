# frozen_string_literal: true

require "test_helper"
require "ostruct"
require "minitest/mock"

class HttpClientTest < Minitest::Test
  FakeHttpResponse = Struct.new(:body, :class)

  def test_response_handler_process_blank_responses
    response_handler = OnPage::Api::JSONResponseHandler.new
    http_mock = FakeHttpResponse.new(nil, Net::HTTPSuccess)
    outcome = response_handler.call(http_mock)
    assert outcome.failed?
    assert_nil outcome.result
    http_mock = FakeHttpResponse.new("", Net::HTTPSuccess)
    outcome = response_handler.call(http_mock)
    assert outcome.failed?
    assert_nil outcome.result
    http_mock = FakeHttpResponse.new("null", Net::HTTPSuccess)
    outcome = response_handler.call(http_mock)
    assert outcome.failed?
    assert_nil outcome.result
    http_mock = FakeHttpResponse.new('"null"', Net::HTTPSuccess)
    outcome = response_handler.call(http_mock)
    assert outcome.failed?
    assert_nil outcome.result
  end

  def test_response_handler_process_messages
    body = <<~TEXT
      {
        "message": "Richiesta non valida"
      }
    TEXT
    http_mock = FakeHttpResponse.new(body, Net::HTTPUnprocessableEntity)

    response_handler = OnPage::Api::JSONResponseHandler.new
    outcome = response_handler.call(http_mock)
    assert outcome.failed?
    assert_equal outcome.error_messages, "Richiesta non valida"
  end

  def test_wraps_exceptions
    skip("not yet implemented")
  end
end
