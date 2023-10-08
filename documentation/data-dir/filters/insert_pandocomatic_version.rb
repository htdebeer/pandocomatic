#!/usr/bin/env ruby
# A filter to insert paru's version. All occurrences of
# '::paru::version' are replaced by paru's version.
require_relative '../../../lib/pandocomatic/pandocomatic'
require 'paru/filter'

# Get pandocomatic's version
def version(str)
  str.gsub '::pandocomatic::version', Pandocomatic::VERSION.join('.')
end

Paru::Filter.run do
  with 'Str' do |str|
    str.string = version(str.string)
  end

  with 'CodeBlock' do |code|
    code.string = version(code.string)
  end

  with 'Link' do |link|
    link.target.url = version(link.target.url)
    link.target.title = version(link.target.title)
  end
end
