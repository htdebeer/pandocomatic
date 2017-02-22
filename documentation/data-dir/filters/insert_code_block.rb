#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "CodeBlock" do |code_block|
    command, path, *classes = code_block.string.strip.split " "
    if command == "::paru::insert"
      code_block.string = File.read path.gsub(/\\_/, "_")
      classes.each {|c| code_block.attr.classes.push c}
    end
  end
end
