# frozen_string_literal: true

require 'minitest/reporters'
OPTIONS = {
  color: true
}.freeze
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::DefaultReporter.new(OPTIONS)
]
