#!/usr/bin/env ruby
# Set some metadata properties in a postprocessor is as easy as copying the
# stdin to stdout and then printing a yaml metadata block with the properties
# and their values. For testing purposes I just print a date here, but
# normally you would use something like Date.today.to_s instead.

puts $stdin.read
puts "---"
puts "date: 2017-01-28"
puts "..."
