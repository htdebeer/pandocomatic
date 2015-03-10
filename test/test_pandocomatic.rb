require '../lib/pandocomatic/pandocomatic'
require '../lib/pandocomatic/configuration'

c = Pandocomatic::Configuration.new
Pandocomatic::Pandocomatic.generate '/home/ht/test/src', '/home/ht/test/www', c
