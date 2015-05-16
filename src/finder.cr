class Trouve::Finder
    def initialize(@pattern: (String|Regex), @max_matches = 0)
    end

    def find(io: IO)
        line_num = 0
        matches = 0
        io.each_line do |line|
            case pat = @pattern
            when String
                if line.includes? pat
                    yield line_num, line 
                    matches += 1
                end
            when Regex
                if line =~ pat
                    yield line_num, line 
                    matches += 1
                end
            end
            break if @max_matches > 0 && matches >= @max_matches
            line_num += 1
        end
    end
end
