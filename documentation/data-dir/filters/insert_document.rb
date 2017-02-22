#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "Para" do |paragraph|
    if paragraph.inner_markdown.lines.length == 1
      command, path = paragraph.inner_markdown.strip.split " "
      if command == "::paru::insert"
        markdown = File.read path.gsub(/\\_/, "_")
        paragraph.outer_markdown = markdown
      end
    end
  end
end

