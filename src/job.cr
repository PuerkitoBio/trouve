class Trouve::Job
  WORKERS       = 128
  MAX_LINE_SIZE = 256

  # TODO : implement those... (also, inc/exc dirs)
  # property :include_files, :exclude_files, :include_dirs, :exclude_dirs
  property :pattern, :dir, :max_matches, :after, :before, :formatter

  def initialize(@pattern : (String | Regex), @dir : String = ".", @formatter : Formatter = StdFormatter.new)
    @max_matches = 0
    @after, @before = 0, 0
  end

  def run
    # start the workers
    ch = Channel(String).new
    stop = Channel(Bool).new
    stop_matches = Channel(Bool).new
    matches = Channel(Match).new(WORKERS)

    spawn process_matches(matches, stop_matches)
    WORKERS.times do |i|
      spawn process_files(ch, stop, matches)
    end

    process_dir(@dir, ch)

    WORKERS.times do |i|
      stop.send true
    end
    stop_matches.send true
  end

  private def process_matches(matches : Channel(Match), stop : Channel(Bool))
    receive_or_stop(matches, stop) do |value|
      @formatter.format(value)
    end
  end

  private def process_dir(dir, sendch : Channel(String))
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

  private def process_files(ch : Channel(String), stop : Channel(Bool),
                            matches : Channel(Match))
    receive_or_stop(ch, stop) do |filename|
      begin
        m = find_in_file(filename)
      rescue ex : InvalidByteSequenceError
        # presumably a binary file
        # TODO : detect binary or not using first few bytes
        # maybe https://mimesniff.spec.whatwg.org/ ?
      rescue ex : Exception
        m = Match.new(filename, ex.message)
      end
      matches.send m if m
    end
  end

  private def find_in_file(filename : String)
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
        if add_in >= 0
          # was already in a match - expand the buffer to @after
          # lines + the new match line
          buffer.expand(@after + 1)
        end
        add_in = @after
        matches += 1
      end
      line = line[0, MAX_LINE_SIZE] if line.size > MAX_LINE_SIZE
      buffer << line

      if add_in == 0
        match.buffers << {line_num - buffer.size + 1, buffer.to_a}
        add_in = -1
      end

      break if @max_matches > 0 && matches >= @max_matches
    end
    if add_in >= 0
      match.buffers << {line_num - buffer.size + 1, buffer.to_a}
    end
    match
  end

  private def receive_or_stop(in_channel, stop_channel)
    loop do
      channel, value = Channel.select(in_channel.receive_op, stop_channel.receive_op)
      case channel
      when 0
        yield value.as(typeof(in_channel.receive))
      else
        break
      end
    end
  end
end
