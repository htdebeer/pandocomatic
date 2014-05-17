#!/usr/bin/env ruby
require_relative '../lib/pandocomatic/pandoc'

# run it on input file or stdin

Pandocomatic::Pandoc.new do
  from :markdown
  to :html
end
