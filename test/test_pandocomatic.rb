require '../lib/pandocomatic/pandocomatic'

p = Pandocomatic::Pandocomatic.new '/home/ht/test/src', '/home/ht/test/www'

p.generate
