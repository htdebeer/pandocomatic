#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  metadata.delete "pandocomatic" if metadata.has_key? "pandocomatic"
  metadata.delete "fileinfo" if metadata.has_key? "fileinfo"
end
