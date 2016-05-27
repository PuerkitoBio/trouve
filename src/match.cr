struct Trouve::Match
  property :filename, :line_nums, :buffers, :error

  def initialize(@filename : String)
    @line_nums = Array(Int32).new
    @buffers = Array(Tuple(Int32, Array(String))).new
    @error = ""
  end

  def initialize(@filename : String, @error : String?)
    @line_nums = Array(Int32).new
    @buffers = Array(Tuple(Int32, Array(String))).new
  end
end
