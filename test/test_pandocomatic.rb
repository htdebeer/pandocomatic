require '../lib/pandocomatic/configuration.rb'
require '../lib/pandocomatic/dir_converter.rb'
require '../lib/pandocomatic/file_converter.rb'
require '../lib/pandocomatic/pandoc_metadata.rb'

require 'yaml'

src_tree = '/home/ht/Test/pandocomatic/src'
dst_tree = '/home/ht/Test/pandocomatic/www'
config = Pandocomatic::Configuration.new '/home/ht/Test/pandocomatic/pandocomatic.yaml'

dc = Pandocomatic::DirConverter.new src_tree, dst_tree, config
dc.convert

#src_file = '/home/ht/Test/pandocomatic/src/index.markdown'
#dst_file = '/home/ht/Test/pandocomatic/www/index.html'
#m = Pandocomatic::PandocMetadata.load_file src_file

#fc = Pandocomatic::FileConverter.new.convert src_file, dst_file, config

