class Trouve::Job
    WORKERS = 10
    MAX_LINE_LENGTH = 256

    # TODO : implement those... (also, inc/exc dirs, regex patterns)
    property :pattern, :dir, :max_matches, :include_files, :exclude_files
    property :after, :before

    def initialize(@pattern: (String | Regex), @dir = "." : String)
        @max_matches = 0
        @after, @before = 0, 0
    end

    def run()
        # start the workers
        ch = Channel(String).new
        stop = Channel(Bool).new
        matches = Channel(Match).new
        # TODO : start Formatter's thread to process matches
        f = Formatter.new(matches, stop)
        spawn f.run()
        WORKERS.times do |i|
            spawn process_files(ch, stop, matches)
        end

        process_dir(@dir, ch)

        (WORKERS + 1).times do |i|
            stop.send true
        end
    end

    private def process_dir(dir, sendch: Channel(String))
        # TODO: on dir entry, parse ignore files

        Dir.foreach(dir) do |entry|
            # ignore entries starting with a dot
            next if entry.starts_with?('.')

            entry_path = File.join(dir, entry)
            if File.directory?(entry_path)
                # recursively process directories
                process_dir(entry_path, sendch)
                next
            end
            sendch.send entry_path
        end
    end

    private def process_files(ch: Channel(String), stop: Channel(Bool), 
                             matches: Channel(Match))
        loop do
            case Channel.select(ch, stop)
            when ch
                filename = ch.receive
                begin
                    m = find_in_file(filename)
                rescue ex: InvalidByteSequenceError
                    # presumably a binary file
                    # TODO : detect binary or not using first few bytes
                    # maybe https://mimesniff.spec.whatwg.org/ ?
                rescue ex: Exception
                    m = Match.new(filename, ex.message)
                end
                matches.send m if m
            else
                stop.receive
                break
            end
        end
    end

    private def find_in_file(filename: String)
        line_num = 0
        matches = 0
        buffer = CircularBuffer(String).new(@before + @after + 1)
        add_in = -1
        match = Match.new(filename)

        File.each_line(filename) do |line|
            line_num += 1
            add_in -= 1 if add_in > 0

            is_match = 
                case pat = @pattern
                when String
                    line.includes?(pat)
                else
                    line =~ pat
                end

            if is_match
                match.line_nums << line_num
                add_in = @after
                matches += 1
            end

            if add_in == 0
                match.buffers << {line_num - buffer.length, buffer.to_a}
                add_in = -1
            end

            break if @max_matches > 0 && matches >= @max_matches
        end
    end
end
