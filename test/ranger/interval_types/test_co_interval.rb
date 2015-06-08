require 'minitest_helper'

class TestCOInterval < Minitest::Test
  def setup
    @interval = Ranger::COInterval.new(1, 3)
  end

  def test_cover?
    refute @interval.cover?(0)
    assert @interval.cover?(1)
    assert @interval.cover?(2)
    refute @interval.cover?(3)
  end
end
