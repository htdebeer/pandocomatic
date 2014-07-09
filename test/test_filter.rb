
require_relative '../lib/pandocomatic/pandoc/filter'

pf = Pandocomatic::Pandoc::Filter.new do |ast|
  ast
end

puts pf.run "**meh**"
