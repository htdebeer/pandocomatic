require_relative '../lib/pandocomatic/pandocomatic'

Pandocomatic::Pandocomatic.run('-d data-dir -c blog.yaml -i src/blog -o /home/huub/test-blog')
