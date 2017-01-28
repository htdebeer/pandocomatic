#!/usr/bin/env ruby
require 'date'

# Set some metadata properties in a postprocessor is as easy as copying the
# stdin to stdout and then printing a yaml metadata block with the properties
# and their values:

puts $stdin.read
puts "---"
puts "date: #{Date.today.to_s}"
puts "..."
