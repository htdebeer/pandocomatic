#!/usr/bin/env ruby
require 'yaml'
require 'pandocomatic/pandoc_metadata'

input = $stdin.read
puts input

metadata = YAML.load Pandocomatic::PandocMetadata.pandoc2yaml(input)
if metadata['fileinfo'] and metadata['fileinfo']['path'] then
    path = metadata['fileinfo']['path']
    site_menu = {'site-menu' => []}
    uppath = '/'
    File.dirname(path).split('/')[1..-1].each do |updir|
        uppath += "#{updir}/"
        item = {
            'name' => updir.split('_').join(' '),
            'url' => uppath
        }
        site_menu['site-menu'].push item
    end
    puts YAML.dump(site_menu)
    puts "..."
end
