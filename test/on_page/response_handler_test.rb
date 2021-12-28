# frozen_string_literal: true

require "test_helper"
require "ostruct"
require "minitest/mock"

class ResponseHandlerTest < Minitest::Test
  MockHttpResponse = Struct.new(:body, :class)

  def test_response_handler_process_nil_responses
    response_handler = OnPage::Api::JSONResponseHandler.new
    http_response = MockHttpResponse.new(nil, Net::HTTPSuccess)
    outcome = response_handler.call(http_response)
    assert outcome.failed?
    assert_nil outcome.result
  end

  def test_response_handler_process_empty_responses
    response_handler = OnPage::Api::JSONResponseHandler.new
    http_response = MockHttpResponse.new("", Net::HTTPSuccess)
    outcome = response_handler.call(http_response)
    assert outcome.failed?
    assert_nil outcome.result
  end

  def test_response_handler_process_json_null_responses
    response_handler = OnPage::Api::JSONResponseHandler.new
    http_response = MockHttpResponse.new("null", Net::HTTPSuccess)
    outcome = response_handler.call(http_response)
    assert outcome.failed?
    assert_nil outcome.result
  end

  def test_response_handler_process_stringyfied_null_responses
    response_handler = OnPage::Api::JSONResponseHandler.new
    http_response = MockHttpResponse.new('"null"', Net::HTTPSuccess)
    outcome = response_handler.call(http_response)
    assert outcome.failed?
    assert_nil outcome.result
  end

  def test_response_handler_process_messages
    body = <<~TEXT
      {
        "message": "Richiesta non valida"
      }
    TEXT
    http_response = MockHttpResponse.new(body, Net::HTTPUnprocessableEntity)

    response_handler = OnPage::Api::JSONResponseHandler.new
    outcome = response_handler.call(http_response)
    assert outcome.failed?
    assert_equal "Richiesta non valida", outcome.error_messages
  end
end
