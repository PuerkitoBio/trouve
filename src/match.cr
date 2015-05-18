struct Trouve::Match
    @filename :: String
    @line_nums :: Array(Int32)
    @buffers :: Array(Tuple(Int32, Array(String)))
    @error :: String

    property :filename, :line_nums, :buffers, :error

    def initialize(@filename)
        @line_nums = Array(Int32).new
        @buffers = Array(Tuple(Int32, Array(String))).new
        @error = ""
    end

    def initialize(@filename, @error)
        @line_nums = Array(Int32).new
        @buffers = Array(Tuple(Int32, Array(String))).new
    end
end
