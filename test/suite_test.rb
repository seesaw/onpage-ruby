# frozen_string_literal: true

require "test_helper"
require "anyway/testing/helpers"
require "minitest/hooks"

class SuiteTest < Minitest::Test
  include Anyway::Testing::Helpers
  include Minitest::Hooks

  def around_all
    with_env(
      "ONPAGE_API_TOKEN" => "api_token",
      "ONPAGE_COMPANY" => "company_name"
    ) do
      super
    end
  end
end
