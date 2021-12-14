# frozen_string_literal: true

require_relative "../suite_test"

class SchemaTest < SuiteTest
  def setup
    OnPage::Api.reset_request_counter
  end

  def test_project_information_memoize_result
    skip("not yet implemented")
  end

  def test_project_information_forced_reload
    skip("not yet implemented")
  end
end
