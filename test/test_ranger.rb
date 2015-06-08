require 'minitest_helper'

class TestRanger < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ranger::VERSION
  end
end
