#!/usr/bin/env ruby
require 'paru/filter'

# Just a simple converter: only need about 4 or 5 at the moment
def integer_to_roman(n)
  case n
  when 1 then 'I'
  when 2 then 'II'
  when 3 then 'III'
  when 4 then 'IV'
  when 5 then 'V'
  when 6 then 'VI'
  end
end

current_part = 0
current_chapter = 0
current_section = 0
current_figure = 0

Paru::Filter.run do
  with 'Header' do |header|
    if header.level == 1
      current_part += 1
      current_figure = 0
      current_section = 0

      header.inner_markdown =
        "Part #{integer_to_roman current_part}. #{header.inner_markdown}"
    end

    if header.level == 2
      current_chapter += 1
      current_figure = 0
      current_section = 0

      header.inner_markdown =
        "Chapter #{current_chapter}. #{header.inner_markdown}"
    end

    if header.level == 3
      current_section += 1
      header.inner_markdown =
        "#{current_chapter}.#{current_section} #{header.inner_markdown}"
    end
  end

  with 'Header + Image' do |image|
    current_figure += 1
    image.inner_markdown =
      "Figure #{current_chapter}.#{current_figure} #{image.inner_markdown}"
  end
end
