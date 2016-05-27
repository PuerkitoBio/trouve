require "option_parser"
require "../*"

module Trouve
  VERSION = "0.0.1"
end

before, after = 0, 0

opts = OptionParser.parse! do |opts|
  opts.banner = "Usage: #{PROGRAM_NAME} [OPTION]... PATTERN [FILES OR DIRECTORIES]

Search for PATTERN in each file in the tree rooted at the current
directory or in the specified FILES or DIRECTORIES."

  opts.on("-h", "--help", "print this help menu") do
    puts opts
  end
  opts.on("-B NUM", "--before", "contextual lines before the match") do |val|
    before = val.to_i
  end
  opts.on("-A NUM", "--after", "contextual lines after the match") do |val|
    after = val.to_i
  end
  opts.on("-C NUM", "--context", "contextual lines before and after the match") do |val|
    after = before = val.to_i
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
job.after = after
job.before = before

job.run
