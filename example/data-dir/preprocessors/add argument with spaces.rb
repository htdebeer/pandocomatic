#!/usr/bin/env ruby
# Set some metadata properties in a postprocessor is as easy as copying the
# stdin to stdout and then printing a yaml metadata block with the properties
# and their values. For testing purposes I just add the arguments to the
# script as an array to the metadata, which are then printed by a pandoc
# template.

puts $stdin.read
puts ''
puts '---'
puts "arguments_with_spaces: [#{ARGV.map { |a| "'#{a}'" }.join(', ')}]"
puts '...'
