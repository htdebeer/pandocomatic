#!/usr/bin/env ruby

current_dst = $stdin.read
current_dst_dir = File.dirname current_dst
current_dst_filename = File.basename current_dst

renamed_dst = File.join(current_dst_dir, "RENAMED-#{current_dst_filename}")

puts renamed_dst
