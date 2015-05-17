class Trouve::CircularBuffer(T)
    include Enumerable

    getter :length
    @length :: Int32

    @start, @end = 0, 0

    def initialize(@length = 3: Int)
        @container = Array(T).new(@length)
    end

    def self.new(ary: Array(T))
        buf = CircularBuffer.new(ary.length)
        ary.each { |e| buf << e }
        buf
    end

    def self.new(length, &block: Int32 -> T)
        buf = CircularBuffer.new(length)
        length.times do |i|
            buf << yield i
        end
        buf
    end

    def <<(value: T)
        push(value)
    end

    def push(value: T)
    end

    def each
        index = @start
    end
end
