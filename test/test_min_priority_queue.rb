require_relative '../lib/min_priority_queue'
require 'test/unit'

class TestMinPriorityQueue < Test::Unit::TestCase
  def test_empty
    q = MinPriorityQueue.new
    assert_equal(nil, q.extract_min)
  end

  def test_abcs
    q = MinPriorityQueue.new
    q.add_with_priority('c', 2)
    q.add_with_priority('b', 1)
    q.add_with_priority('d', 3)
    q.add_with_priority('a', 0)
    assert_equal('a', q.extract_min)
    assert_equal('b', q.extract_min)
    assert_equal('c', q.extract_min)
    assert_equal('d', q.extract_min)
    assert_equal(nil, q.extract_min)
  end

  def test_interleaved
    q = MinPriorityQueue.new
    q.add_with_priority('a', 0)
    assert_equal('a', q.extract_min)
    q.add_with_priority('d', 3)
    q.add_with_priority('b', 1)
    q.add_with_priority('c', 2)
    assert_equal('b', q.extract_min)
    assert_equal('c', q.extract_min)
    assert_equal('d', q.extract_min)
    assert_equal(nil, q.extract_min)
  end

  def test_decrease_priority
    q = MinPriorityQueue.new
    q.add_with_priority('a', 2)
    q.add_with_priority('b', 1)
    q.add_with_priority('c', 2)
    q.decrease_priority('a', 0)
    assert_equal('a', q.extract_min)
    assert_equal('b', q.extract_min)
    assert_equal('c', q.extract_min)
    assert_equal(nil, q.extract_min)
  end
end
