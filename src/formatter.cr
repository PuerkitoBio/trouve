abstract class Trouve::Formatter
    abstract def format(m: Matcher)
end

class Trouve::StdFormatter < Trouve::Formatter
    @has_previous = false

    def format(m: Matcher)
        return if m.line_nums.length == 0

        STDOUT.puts "" if @has_previous
        @has_previous = true

        STDOUT.puts "\033[1;32m#{m.filename}\033[0m" 
        match_line = m.line_nums.shift
        m.buffers.each do |data|
            line_num, buf = data
            buf.each do |line|
                if line_num == match_line
                    STDOUT.puts "\033[1;33m#{line_num}\033[0m:#{line}"
                else
                    STDOUT.puts "\033[1;33m#{line_num}\033[0m-#{line}"
                end
                if line_num >= match_line && m.line_nums.length > 0
                    match_line = m.line_nums.shift
                end
                line_num += 1
            end
        end
    end
end
