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

    # PandocMetadata represents the metadata with pandoc options set in
    # templates and input files.
    class PandocMetadata < Hash

        # Extract the metadata from an input file
        #
        # @param input_document [String] a path to an input file
        # @return [String] the input document's metadata in the YAML format.
        def self.extract_metadata input_document
            begin
                pandoc2yaml File.read(input_document)
            rescue StandardError => e
                raise IOError.new(:error_opening_file, e, input_document)
            end
        end

        # Extract the YAML metadata from an input string
        #
        # @param input [String] the input string
        # @return [String] the YAML data embedded in the input string
        def self.pandoc2yaml(input)
            mined_metadata = input.scan(/^---[ \t]*(\r\n|\r|\n)(.+?)^(?:---|\.\.\.)[ \t]*(\r\n|\r|\n)/m)
            
            mined_metadata
                .flatten
                .map{|yaml| yaml.strip}
                .join("\n")
        end

        # Collect the metadata embedded in the src file and create a new
        # PandocMetadata instance
        #
        # @param src [String] the path to the file to load metadata from
        # @return [PandocMetadata] the metadata in the source file, or an empty
        #   one if no such metadata is contained in the source file.
        def self.load_file src
            yaml_metadata = extract_metadata src

            if yaml_metadata.empty? then
                return PandocMetadata.new
            else
                return PandocMetadata.new YAML.load(yaml_metadata)
            end
        end

        # Creat e new PandocMetadata object based on the properties contained
        # in a Hash
        #
        # @param hash [Hash] initial properties for this new PandocMetadata
        #   object
        # @return [PandocMetadata] 
        def initialize hash = {}
            super
            merge! hash
        end

        # Does this PandocMetadata object use a template?
        #
        # @return [Boolean] true if it has a key 'use-template' among the
        #   pandocomatic template properties.
        def has_template?()
            has_pandocomatic? and pandocomatic.has_key? 'use-template' and not pandocomatic['use-template'].empty?
        end

        # Get all the templates of this PandocMetadata oject
        #
        # @return [Array] an array of templates used in this PandocMetadata
        #   object
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

        # Get the used template's name
        #
        # @return [String] the name of the template used, if any, "" otherwise.
        def template_name()
            if has_template? then
                pandocomatic['use-template']
            else
                ''
            end
        end
        
        # Does this PandocMetadata object have a pandocomatic property?
        #
        # @return [Boolean] True if this PandocMetadata object has a Hash
        # property named "pandocomatic_". False otherwise.
        #
        # Note. For backward compatibility with older versions of
        # pandocomatic, properties named "pandocomatic" (without the trailing
        # underscore) are also accepted.
        def has_pandocomatic?()
            config = nil
            if has_key? 'pandocomatic' or has_key? 'pandocomatic_'
                config = self['pandocomatic'] if has_key? 'pandocomatic'
                config = self['pandocomatic_'] if has_key? 'pandocomatic_'
            end
            config.is_a? Hash
        end

        # Get the pandoc options for this PandocMetadata object
        #
        # @return [Hash] the pandoc options if there are any, an empty Hash
        #   otherwise.
        def pandoc_options()
            if has_pandoc_options? then
                pandocomatic['pandoc']
            else
                {}
            end
        end

        # Get the pandocomatic property of this PandocMetadata object
        #
        # @return [Hash] the pandocomatic property as a Hash, if any, an empty
        #   Hash otherwise.
        def pandocomatic()
            return self['pandocomatic'] if has_key? 'pandocomatic'
            return self['pandocomatic_'] if has_key? 'pandocomatic_'
        end

        # Does this PandocMetadata object has a pandoc options property?
        #
        # @return [Boolean] True if there is a pandoc options property in this
        #   PandocMetadata object. False otherwise.
        def has_pandoc_options?()
            has_pandocomatic? and pandocomatic.has_key? 'pandoc'
        end

    end

end
