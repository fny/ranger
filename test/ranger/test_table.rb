require 'minitest_helper'
require 'ranger/table'
require 'pry'
class TestTable < Minitest::Test

  #          1...2 2...3 y
  #   1...2  a     b
  #   2...3  c     d
  #   x
  def test_initialize_by_range
    table = Ranger::Table.new(
      1...2 => {
        1...2 => :a,
        2...3 => :b
      },
      2...3 => {
        1...2 =>  :c,
        2...3 =>  :d
      }
    )

    assert_equal nil, table[0, 0]
    assert_equal :a,  table[1, 1]
    assert_equal :a,  table[1.1, 1.1]
    assert_equal :b,  table[1.1, 2.1]
    assert_equal :c,  table[2.1, 1.1]
    assert_equal :d,  table[2.1, 2.1]
    assert_equal nil, table[3, 3]
  end

  def test_initialize_by_in_interval
    table = Ranger::Table.new(
        Ranger::Interval(:c, 1, 2, :o) => {
        Ranger::Interval(:c, 1, 2, :o) => :a,
        Ranger::Interval(:c, 2, 3, :o) => :b
      },
      [:c, 2, 3, :o] => {
        Ranger::Interval(:c, 1, 2, :o) =>  :c,
        Ranger::Interval(:c, 2, 3, :o) =>  :d
      }
    )

    assert_equal nil, table[0, 0]
    assert_equal :a,  table[1, 1]
    assert_equal :a,  table[1.1, 1.1]
    assert_equal :b,  table[1.1, 2.1]
    assert_equal :c,  table[2.1, 1.1]
    assert_equal :d,  table[2.1, 2.1]
    assert_equal nil, table[3, 3]
  end

  def test_initialize_by_array_shorthand
    table = Ranger::Table.new(
      [:c, 1, 2, :o] => {
        [:c, 1, 2, :o] => :a,
        [:c, 2, 3, :o] => :b
      },
      [:c, 2, 3, :o] => {
        [:c, 1, 2, :o] =>  :c,
        [:c, 2, 3, :o] =>  :d
      }
    )

    assert_equal nil, table[0, 0]
    assert_equal :a,  table[1, 1]
    assert_equal :a,  table[1.1, 1.1]
    assert_equal :b,  table[1.1, 2.1]
    assert_equal :c,  table[2.1, 1.1]
    assert_equal :d,  table[2.1, 2.1]
    assert_equal nil, table[3, 3]
  end

  # def test_shorthand
  #   Ranger::Table.shorthand(
  #     [ :closed, :open, {
  #         1 => [
  #           :closed, :open, {
  #             1 =>
  #           }]
  #         2 => :b,
  #         3 => nil
  #       }
  #     ]

  #   )
  # end
end
