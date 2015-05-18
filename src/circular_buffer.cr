class Trouve::CircularBuffer(T)
    include Enumerable

    def initialize(@capacity = 3: Int)
        @container = Array(T).new(@capacity)
        @insert_at = 0
    end

    def self.new(ary: Array(T))
        buf = CircularBuffer.new(ary.length)
        ary.each { |e| buf << e }
        buf
    end

    def <<(value: T)
        push(value)
    end

    def each
        index = 0
        index = @insert_at if length == @capacity
        @container.length.times do |i|
            yield @container[index]
            index += 1
            index = 0 if index >= @container.length
        end
        self
    end

    def expand(add_n: Int)
        new_container = Array(T).new(@capacity + add_n)
        each { |e| new_container << e }
        @insert_at = new_container.length
        @capacity += add_n
        @container = new_container
        self
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
        self
    end
end
