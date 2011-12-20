RMAGICK_BYPASS_VERSION_TEST = true

class Array
  def randomize!
    srand(length)
    for i in 0...length
      r = Kernel::rand(length - i)
      self[length - i - 1], self[r] = self[r], self[length - i - 1]
    end
    self    
  end
  
  def shuffle(length)
    srand
    shuffledArray = Array.new(self)
    for i in 0...length
      r = Kernel::rand(length - i)
      shuffledArray[length - i - 1], shuffledArray[r] = shuffledArray[r], shuffledArray[length - i - 1]
    end
    shuffledArray
  end
  
  def shuffle!(length)
    srand
    for i in 0...length
      r = Kernel::rand(length - i)
      self[length - i - 1], self[r] = self[r], self[length - i - 1]
    end
    self
  end
  
  def rsend(baseobj)
    inject(baseobj) { |n, value| n.send(value) }
  end
  
  def random_element
    srand
    a, i = [], Kernel::rand(length)
    each_index { |j| a.push(self[j]) if j != i}
    [self[i], a]
  end  
end

class Object
  def rsend(*args, &block)
    obj = self
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b)
    end
    obj
  end
  
  alias_method :__rsend__, :rsend  
end

class Fixnum
  def random_numbers(max_number)
    srand
    numbers = []
    while numbers.length != self
        rand_num = Kernel::rand(max_number)
        numbers |= [rand_num] if rand_num != 0
    end    
    numbers
  end  
end


module Enumerable
  def find_by_index
    for i in 0 ... size
      return i if yield self[i]
    end
    nil
  end
end
