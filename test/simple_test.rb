#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/pandocomatic/pandocomatic'

Pandocomatic::Pandocomatic.run '-i files/src/hello.md -o hello2.html'
