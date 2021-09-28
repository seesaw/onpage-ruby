# frozen_string_literal: true

require "test_helper"

class Onpage::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Onpage::Client::VERSION
  end

  def _test_it_does_something_useful
    assert false
  end
end
