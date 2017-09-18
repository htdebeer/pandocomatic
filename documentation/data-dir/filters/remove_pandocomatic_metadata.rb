#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  metadata.delete "pandocomatic" if metadata.has_key? "pandocomatic"
  metadata.delete "pandocomatic_" if metadata.has_key? "pandocomatic_"
  metadata.delete "pandocomatic-fileinfo" if metadata.has_key? "pandocomatic-fileinfo"
end
