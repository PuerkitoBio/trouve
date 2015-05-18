class Trouve::Formatter
    def initialize(@matches: Channel(Match), @stop: Channel(Bool))
    end

    def run()
        puts "Started"
        loop do
            Scheduler.yield
            case Channel.select(@matches, @stop)
            when @matches
                m = @matches.receive
                if m.error != ""
                    STDERR.puts "#{m.filename}: error: #{m.error}"
                else
                    STDOUT.puts "#{m.filename}: #{m.line_nums.length} matches"
                end
            else
                puts " Got stop"
                @stop.receive
                break
            end
        end
    end
end
