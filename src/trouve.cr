require "./trouve/*"
require "option_parser"
require "./*"

opts = OptionParser.parse! do |opts|
    opts.banner = "Usage: #{PROGRAM_NAME} [OPTION]... PATTERN [FILES OR DIRECTORIES]

Search for PATTERN in each file in the tree rooted at the current
directory or in the specified FILES or DIRECTORIES."

    opts.on("-h", "--help", "print this help menu") do
        puts opts
    end
end

case ARGV.length
when 0
    puts "missing pattern\n\n#{opts}" 
    exit(1)
when 1
    job = Trouve::Job.new(ARGV[0])
else
    job = Trouve::Job.new(ARGV[0], ARGV[1])
end

job.run
