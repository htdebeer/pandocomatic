require '../lib/pandocomatic/configuration.rb'
require '../lib/pandocomatic/dir_converter.rb'
require '../lib/pandocomatic/file_converter.rb'
require '../lib/pandocomatic/pandoc_metadata.rb'

require 'yaml'

src_tree = '/home/ht/test/src'
dst_tree = '/home/ht/test/www'
config = Pandocomatic::Configuration.new  YAML.load_file('/home/ht/test/pandocomatic.yaml')

puts config.to_s

dc = Pandocomatic::DirConverter.new src_tree, dst_tree, config
dc.convert

#src_file = '/home/ht/test/src/index.markdown'
#dst_file = '/home/ht/test/testfile.html'
#m = Pandocomatic::PandocMetadata.load_file src_file

#fc = Pandocomatic::FileConverter.new.convert src_file, dst_file, config

