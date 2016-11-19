require "minitest/reporters"
OPTIONS = {
  :color => true
}
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::DefaultReporter.new(OPTIONS)
]
