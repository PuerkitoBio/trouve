class Trouve::CircularBuffer(T)
    include Enumerable

    @insert_at = 0

    def initialize(@capacity = 3: Int)
        @container = Array(T).new(@capacity)
    end

    def self.new(ary: Array(T))
        buf = CircularBuffer.new(ary.length)
        ary.each { |e| buf << e }
        buf
    end

    def <<(value: T)
        push(value)
    end

    def length
        @container.length
    end

    def push(value: T)
        if @insert_at >= @container.length
            @container << value
        else
            @container[@insert_at] = value
        end
        @insert_at += 1
        @insert_at = 0 if @insert_at >= @capacity
    end

    def each
        index = @insert_at
        @container.length.times do |i|
            yield @container[index]
            index += 1
            index = 0 if index >= @container.length
        end
    end
end
