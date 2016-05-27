require "colorize"

abstract class Trouve::Formatter
  abstract def format(m : Match)
end

class Trouve::StdFormatter < Trouve::Formatter
  @has_previous = false

  def format(m : Match)
    return if m.line_nums.size == 0

    STDOUT << "\n" if @has_previous
    @has_previous = true

    with_color.green.push(STDOUT) do |io|
      io << m.filename << "\n"
    end

    match_line = m.line_nums.shift
    m.buffers.each do |data|
      line_num, buf = data
      buf.each do |line|
        with_color.yellow.push(STDOUT) do |io|
          io << line_num
        end
        if line_num == match_line
          STDOUT << ":#{line}"
        else
          STDOUT << "-#{line}"
        end
        if line_num >= match_line && m.line_nums.size > 0
          match_line = m.line_nums.shift
        end
        line_num += 1
      end
    end
  end
end
