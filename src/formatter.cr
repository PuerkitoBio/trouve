class Trouve::Formatter
    def self.run(matches: Channel(Match), stop: Channel(Bool))
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
