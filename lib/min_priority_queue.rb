class MinPriorityQueue
  def initialize
    @elements = []
  end

  def add_with_priority(item, priority)
    @elements << [item, priority]

    index = @elements.size - 1
    up_heap(index)
  end

  def decrease_priority(item, priority)
    index = @elements.find_index { |i, p| i == item }
    return if index.nil?
    @elements[index] = [item, priority]
    up_heap(index)
  end

  def extract_min
    ret = @elements.shift
    return nil if ret.nil?
    return ret[0] if @elements.empty?

    # move last element to the root node
    @elements.unshift(@elements.pop)
    down_heap(0)

    ret[0]
  end

  private

  def up_heap(index)
    loop do
      return if index == 0
      parent_index = (index - 1) / 2
      parent_item, parent_priority = @elements[parent_index]
      item, priority = @elements[index]
      return if parent_priority <= priority
      swap(index, parent_index)
      index = parent_index
    end
  end

  def down_heap(index)
    left_child_index = 2 * index + 1
    right_child_index = 2 * index + 2

    if left_child_index < @elements.size
      if right_child_index < @elements.size
        left_child_item, left_child_priority = @elements[left_child_index]
        right_child_item, right_child_priority = @elements[right_child_index]

        smaller_child_index = left_child_priority < right_child_priority ? left_child_index : right_child_index
      else
        smaller_child_index = left_child_index
      end

      item, priority = @elements[index]
      child_item, child_priority = @elements[smaller_child_index]
      return if priority <= child_priority

      swap(index, smaller_child_index)

      down_heap(smaller_child_index)
    end
  end

  def swap(i1, i2)
    @elements[i1], @elements[i2] = @elements[i2], @elements[i1]
  end

  def check_heap_property(parent_index)
    left_child_index = 2 * parent_index + 1
    right_child_index = 2 * parent_index + 2

    parent_item, parent_priority = @elements[parent_index]

    if left_child_index < @elements.size
      left_item, left_priority = @elements[left_child_index]
      raise "parent and child are not ordered: parent priority is #{parent_priority} and left priority is #{left_priority}" if parent_priority > left_priority
      check_heap_property(left_child_index)
    end

    if right_child_index < @elements.size
      right_item, right_priority = @elements[right_child_index]
      raise "parent and child are not ordered: parent priority is #{parent_priority} and right priority is #{right_priority}" if parent_priority > right_priority
      check_heap_property(right_child_index)
    end
  end
end
