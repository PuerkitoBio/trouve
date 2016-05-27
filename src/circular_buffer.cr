class Trouve::CircularBuffer(T)
  include Enumerable(T)

  def initialize(@capacity : Int32 = 3)
    @container = Array(T).new(@capacity)
    @insert_at = 0
  end

  def self.new(ary : Array(T))
    buf = CircularBuffer.new(ary.size)
    ary.each { |e| buf << e }
    buf
  end

  def <<(value : T)
    push(value)
  end

  def each
    index = 0
    index = @insert_at if size == @capacity
    @container.size.times do |i|
      yield @container[index]
      index += 1
      index = 0 if index >= @container.size
    end
    self
  end

  def expand(add_n : Int)
    return self if add_n <= 0

    new_container = Array(T).new(@capacity + add_n)
    each { |e| new_container << e }
    @insert_at = new_container.size
    @capacity += add_n
    @container = new_container
    self
  end

  def size
    @container.size
  end

  def push(value : T)
    if @insert_at >= @container.size
      @container << value
    else
      @container[@insert_at] = value
    end
    @insert_at += 1
    @insert_at = 0 if @insert_at >= @capacity
    self
  end
end
