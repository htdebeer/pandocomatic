#!/usr/bin/env ruby
require "paru/filter"

current_chapter = 0
current_section = 0
current_figure = 0

Paru::Filter.run do
    with "Header" do |header|
        if header.level == 1 
            current_chapter += 1
            current_figure = 0
            current_section = 0

            header.inner_markdown = "Chapter #{current_chapter}. #{header.inner_markdown}"
        end

        if header.level == 2
          current_section += 1
          header.inner_markdown = 
            "#{current_chapter}.#{current_section} #{header.inner_markdown}"
        end
    end

    with "Header + Image" do |image|
        current_figure += 1
        image.inner_markdown = 
          "Figure #{current_chapter}.#{current_figure} #{image.inner_markdown}"
    end
end
