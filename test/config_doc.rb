#!/usr/bin/env ruby
require_relative '../lib/pandocomatic/pandoc'

p Pandocomatic::Pandoc.new do
  from :markdown
  to :html
end.convert 'documents/test0.markdown', 
  'documents/test1.markdown'

