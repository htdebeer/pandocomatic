#--
# Copyright 2014, 2015, 2016, 2017, Huub de Beer <Huub@heerdebeer.org>
# 
# This file is part of pandocomatic.
# 
# Pandocomatic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
# 
# Pandocomatic is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with pandocomatic.  If not, see <http://www.gnu.org/licenses/>.
#++
module Pandocomatic

  require 'json'
  require 'yaml'
  require 'paru/pandoc'

  require_relative './error/pandoc_error.rb'

  class PandocMetadata < Hash
  
    # Paru converters:
    # Note. When converting metadata back to the pandoc markdown format, you have
    # to use the option 'standalone', otherwise the metadata is skipped
    PANDOC_2_JSON = Paru::Pandoc.new {from 'markdown'; to 'json'}
    JSON_2_PANDOC = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}

    # When converting a pandoc document to JSON, or vice versa, the JSON object
    # has the following three properties:
    VERSION = 'pandoc-api-version'
    META = 'meta'
    BLOCKS = 'blocks'

    def self.extract_metadata input_document
      yaml = ""
      begin
        json = JSON.parse(PANDOC_2_JSON << File.read(input_document))

        version, metadata = json.values_at(VERSION, META)

        if not metadata.empty? then
          metadata_document = {
            VERSION => version, 
            META => metadata, 
            BLOCKS => []
          }

          yaml = JSON_2_PANDOC << JSON.generate(metadata_document)
        end
      rescue Paru::Error => e
        raise PandocError.new(:error_running_pandoc, e, input_document)
      rescue StandardError => e
        raise IOError.new(:error_opening_file, e, input_document)
      end

      yaml
    end

    # Collect the metadata embedded in the src file
    def self.load_file src
      yaml_metadata = extract_metadata src
      if yaml_metadata.empty? then
        return PandocMetadata.new
      else
        return PandocMetadata.new YAML.load(yaml_metadata)
      end
    end
    
    def initialize hash = {}
      super
      merge! hash
    end

    def has_template?
      self['pandocomatic'] and self['pandocomatic']['use-template'] and 
          not self['pandocomatic']['use-template'].empty?
    end

    def template_name
      if has_template? then
        self['pandocomatic']['use-template']
      else
        ''
      end
    end

    # TODO: allow a pandoc block outside a pandocomatic block to make
    # pandocomatic work like paru's do-pandoc.rb.

    def has_pandoc_options?
      self['pandocomatic'] and self['pandocomatic']['pandoc']
    end

    def pandoc_options
      if has_pandoc_options? then
        self['pandocomatic']['pandoc']
      else
        {}
      end
    end

  end

end
