require 'minitest_helper'

class TestOCInterval < Minitest::Test
  def setup
    @interval = Ranger::OCInterval.new(1, 3)
  end

  def test_cover?
    refute @interval.cover?(1)
    assert @interval.cover?(2)
    assert @interval.cover?(3)
    refute @interval.cover?(4)
  end
end
