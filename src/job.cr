class Trouve::Job
    WORKERS = 10

    # TODO : implement those... (also, inc/exc dirs, regex patterns)
    property :pattern, :dir, :max_matches, :include_files, :exclude_files

    def initialize(@pattern: (String | Regex), @dir = "." : String)
        @max_matches = 0
    end

    def run()
        # start the workers
        ch = Channel(String).new
        stop = Channel(Bool).new
        WORKERS.times do |i|
            spawn process_files(ch, stop)
        end

        process_dir(@dir, ch)

        WORKERS.times do |i|
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

    private def process_files(ch: Channel(String), stop: Channel(Bool))
        loop do
            case Channel.select(ch, stop)
            when ch
                find_in_file(ch.receive)
            else
                stop.receive
                break
            end
        end
    end

    private def find_in_file(filename: String)
        line_num = 0
        matches = 0
        File.each_line(filename) do |line|
            line_num += 1
            case pat = @pattern
            when String
                if line.includes?(pat)
                    puts "> #{filename}:#{line_num}: #{line}" 
                    matches += 1
                end
            else
                if line =~ pat
                    puts "> #{filename}:#{line_num}: #{line}"
                    matches += 1
                end
            end
            break if @max_matches > 0 && matches >= @max_matches
        end
    end
end
