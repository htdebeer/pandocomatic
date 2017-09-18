#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "CodeBlock" do |code_block|
    command, path, *classes = code_block.string.strip.split " "
    if command == "::paru::insert"
        # prepend a space for each line to prevent pandocomatic to interpret
        # YAML code blocks as pandoc YAML metadata
        code_lines = File.readlines path.gsub(/\\_/, "_")
        code_block.string = code_lines.map {|l| " " + l}.join()
        classes.each {|c| code_block.attr.classes.push c}
    end
  end
end
