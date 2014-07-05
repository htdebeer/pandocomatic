# First step in constructing the statig site generator (ssg) of pandocomatic
# is creating a mirroring application. This application copies all files,
# except those starting with a period, from a source directory to a target
# directory. Symbolic links are either copied or treated as directories,
# respectively when they's links to a subtree of source or not.

require 'optparse'
require 'ostruct'
require 'fileutils'
require_relative 'mirror'

options = OpenStruct.new
options.source = "."
options.target = ""
options.verbose = false

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: mirror.rb [options]"
  opts.separator ""
  opts.separator "Options:"

  opts.on("-s", "--source [PATH]", "Source directory to mirror, default is current directory") do |path|
    path = options.source = File.absolute_path(path || '.')
    # Check source: does it exist, is it a directory, is it readable
    abort "Source does not exist" unless File.exist? path 
    abort "Source is not a directory" unless File.directory? path 
    abort "Source is not readable" unless File.readable? path
  end

  opts.on("-t", "--target PATH", "Target directory to write mirror of source to") do |path|
    path = options.target = File.absolute_path path
    # Check target: does it exist, is it a directory, is it writable
    if File.exist? path
      abort "Target does not exist" unless File.exist? path
      abort "Target is not a directory" unless File.directory? path
      abort "Target is not writable" unless File.writable? path
    else
      abort "Cannot create target directory" unless File.writable? Dir.pwd
    end
  end

  opts.on("-v", "--verbose", "Verbosely mirror source to target") do |verbose|
    options.verbose = verbose
  end

  opts.on("-h", "--help",  "Display this message") do
    puts opts
    exit
  end

end

option_parser.parse ARGV

Mirror.new(options.source, options.target).run
