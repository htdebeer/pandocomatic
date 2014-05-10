require_relative '../lib/pandocomatic/pandoc/pandoc'

p = Pandocomatic::Pandoc::Pandoc.new

doc = "some text **vet** \n\n more text\n\n-----\n\n# head"
puts p.read(doc)
