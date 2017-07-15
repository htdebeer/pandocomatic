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
  require 'paru'

  require_relative './error/pandoc_error.rb'
  require_relative './error/io_error.rb'

  class PandocMetadata < Hash

    def self.extract_metadata input_document
      begin
        pandoc2yaml File.read(input_document)
      rescue StandardError => e
        raise IOError.new(:error_opening_file, e, input_document)
      end
    end

    def self.pandoc2yaml(input)
      input
        .scan(/^---[ \t]*\n(.+?)^(?:---|\.\.\.)[ \t]*\n/m)
        .flatten
        .map{|yaml| yaml.strip}
        .join("\n")
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

    def has_template?()
      has_pandocomatic? and pandocomatic.has_key? 'use-template' and not pandocomatic['use-template'].empty?
    end

    def templates() 
        if has_template?
            if pandocomatic['use-template'].is_a? Array
                pandocomatic['use-template']
            else
                [pandocomatic['use-template']]
            end
        else
            [""]
        end
    end

    def template_name()
      if has_template? then
        pandocomatic['use-template']
      else
        ''
      end
    end

    # TODO: allow a pandoc block outside a pandocomatic block to make
    # pandocomatic work like paru's do-pandoc.rb.

    def has_pandoc_options?()
      has_pandocomatic? and pandocomatic.has_key? 'pandoc'
    end

    def pandoc_options()
      if has_pandoc_options? then
        pandocomatic['pandoc']
      else
        {}
      end
    end

    def has_pandocomatic?()
      config = nil
      if has_key? 'pandocomatic' or has_key? 'pandocomatic_'
        config = self['pandocomatic'] if has_key? 'pandocomatic'
        config = self['pandocomatic_'] if has_key? 'pandocomatic_'
      end
      config.is_a? Hash
    end

    def pandocomatic()
      return self['pandocomatic'] if has_key? 'pandocomatic'
      return self['pandocomatic_'] if has_key? 'pandocomatic_'
    end

  end

end
