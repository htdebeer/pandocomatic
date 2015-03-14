require '../lib/pandocomatic/pandocomatic'
require '../lib/pandocomatic/configuration'
require '../lib/pandocomatic/dir_converter.rb'
require '../lib/pandocomatic/file_converter.rb'
require '../lib/pandocomatic/pandoc_metadata.rb'

src_tree = '/home/ht/test/src'
dst_tree = '/home/ht/test/www'
config = Pandocomatic::Configuration.new

dc = Pandocomatic::DirConverter.new src_tree, dst_tree, config
dc.convert

#src_file = '/home/ht/test/src/index.markdown'
#dst_file = '/home/ht/test/testfile.html'
#m = Pandocomatic::PandocMetadata.load_file src_file

#fc = Pandocomatic::FileConverter.new.convert src_file, dst_file, config

