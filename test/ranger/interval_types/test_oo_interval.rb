require 'minitest_helper'

class TestOOInterval < Minitest::Test
  def setup
    @interval = Ranger::OOInterval.new(1, 3)
  end

  def test_cover?
    refute @interval.cover?(1)
    assert @interval.cover?(2)
    refute @interval.cover?(3)
  end
end
