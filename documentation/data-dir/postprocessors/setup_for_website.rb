#!/usr/bin/env ruby

puts $stdin.read
puts "\n"
puts '---'
puts 'pandocomatic_:'
puts '    pandoc:'
puts '        filter:'
puts "        - './documentation/data-dir/filters/number_all_the_things.rb'"
puts '...'
