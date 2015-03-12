require 'yaml'

require '../lib/pandocomatic/pandocomatic'
require '../lib/pandocomatic/configuration'

c = Pandocomatic::Configuration.new
Pandocomatic.generate '/home/ht/test/src', '/home/ht/test/www', c

m = Pandocomatic.pandoc2yaml '/home/ht/test/src/index.markdown'
h = YAML.load m
puts h
