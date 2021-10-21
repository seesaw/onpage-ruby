# frozen_string_literal: true

require "test_helper"

class SchemaTest < Minitest::Test
  def setup
    OnPage.configure do |config|
      config.company = "company_name"
      config.api_token = "api_token"
    end
    OnPage::Api.reset_request_counter
  end

  def test_project_information_memoize_result
    skip("not yet implemented")
  end

  def test_project_information_forced_reload
    skip("not yet implemented")
  end
end
