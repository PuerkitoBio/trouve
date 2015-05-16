class Trouve::Worker
    def self.work(ch: Channel(String), out, stop: Channel(Bool))
        loop do
            case Channel.select(ch, stop)
            when ch
                out.send(ch.receive)
            else
                return
            end
        end
    end
end
