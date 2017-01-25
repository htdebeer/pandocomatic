#!/usr/bin/env ruby
require_relative '../lib/pandocomatic/pandocomatic.rb'

Pandocomatic::Pandocomatic.run '-i files/src/hello.md -o hello2.html'
