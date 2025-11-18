# frozen_string_literal: true

#--
# Copyright 2014-2024, Huub de Beer <Huub@heerdebeer.org>
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
  require 'paru'
  require 'yaml'

  require_relative 'error/pandoc_metadata_error'
  require_relative 'pandocomatic_yaml'

  # Regular expression to find the start of metadata blocks in a string.
  BLOCK_START = /^---[ \t]*$/

  # Regular expression to find metadata blocks in a string. This regular
  # expression does interfere with pandoc's horizontal line syntax when using
  # three dashes for horizontal lines. Therefore, use four or more dashes in
  # your pandoc documents.
  METADATA_BLOCK = /^---[ \t]*(\r\n|\r|\n)(.+?)^(?:---|\.\.\.)[ \t]*(\r\n|\r|\n)/m

  # PandocMetadata represents the metadata with pandoc options set in
  # templates and input files.
  class PandocMetadata < Hash
    # Extract the YAML metadata from an input string
    #
    # @param input [String] the input string
    # @return [String] the YAML data embedded in the input string
    def self.pandoc2yaml(input)
      extract_metadata(input).first
    end

    # Create an empty metadata object with only the source format set.
    #
    # @param src_format [String] the source format
    # @param ignore_pandocomatic [Boolean] when true, ignore pandocomatic
    # configuration in YAML metadata blocks
    # @return [PandocMetadata[ empty metadata with only pandoc's source format
    # set.
    def self.empty(src_format, ignore_pandocomatic: false)
      metadata = PandocMetadata.new
      metadata['pandocomatic_'] = { 'pandoc' => { 'from' => src_format } } unless ignore_pandocomatic
      metadata
    end

    # Collect the metadata embedded in the src file and create a new
    # PandocMetadata instance
    #
    # @param src [String] the path to the file to load metadata from
    # @return [PandocMetadata] the metadata in the source file, or an empty
    #   one if no such metadata is contained in the source file.
    def self.load_file(src, ignore_pandocomatic: false)
      self.load File.read(src), path: src, ignore_pandocomatic:
    end

    # Collect the metadata embedded in the src file and create a new
    # PandocMetadata instance
    #
    # @param input [String] the string to load the metadata from
    # @param path [String|Nil] the path to the source of the input, if any
    # @param ignore_pandocomatic [Boolean] when true, ignore pandocomatic
    # configuration in YAML metadata blocks
    # @return [PandocMetadata] the metadata in the source file, or an empty
    #   one if no such metadata is contained in the source file.
    #
    # @raise [PandocomaticError] when the pandoc metadata cannot be
    # extracted.
    def self.load(input, path: nil, ignore_pandocomatic: false)
      yaml, pandocomatic_blocks = extract_metadata(input, path)

      if yaml.empty?
        PandocMetadata.new
      else
        metadata = PandocMetadata.new PandocomaticYAML.load(yaml, path), unique: pandocomatic_blocks <= 1
        metadata.delete('pandocomatic') if ignore_pandocomatic
        metadata.delete('pandocomatic_') if ignore_pandocomatic
        metadata
      end
    end

    # Creat e new PandocMetadata object based on the properties contained
    # in a Hash
    #
    # @param hash [Hash] initial properties for this new PandocMetadata
    #   object
    # @param unique [Boolean = true] the pandocomatic property did occur
    # at most once.
    # @return [PandocMetadata]
    def initialize(hash = {}, unique: true)
      super()
      merge! hash
      @unique = unique
    end

    # Did the metadata contain multiple pandocomatic blocks?
    #
    # @return [Boolean] True if at most one pandocomatic block was present
    # in the metadata
    def unique?
      @unique
    end

    # Does this PandocMetadata object use a template?
    #
    # @return [Boolean] true if it has a key 'use-template' among the
    #   pandocomatic template properties.
    def template?
      pandocomatic? and pandocomatic.key? 'use-template' and !pandocomatic['use-template'].empty?
    end

    # Get all the templates of this PandocMetadata oject
    #
    # @return [Array] an array of templates used in this PandocMetadata
    #   object
    def templates
      if template?
        if pandocomatic['use-template'].is_a? Array
          pandocomatic['use-template']
        else
          [pandocomatic['use-template']]
        end
      else
        ['']
      end
    end

    # Get the used template's name
    #
    # @return [String] the name of the template used, if any, "" otherwise.
    def template_name
      if template?
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
    def pandocomatic?
      config = nil
      if key?('pandocomatic') || key?('pandocomatic_')
        config = self['pandocomatic'] if key? 'pandocomatic'
        config = self['pandocomatic_'] if key? 'pandocomatic_'
      end
      config.is_a? Hash
    end

    # Get the pandoc options for this PandocMetadata object
    #
    # @return [Hash] the pandoc options if there are any, an empty Hash
    #   otherwise.
    def pandoc_options
      if pandoc_options?
        pandocomatic['pandoc']
      else
        {}
      end
    end

    # Get the pandocomatic property of this PandocMetadata object
    #
    # @return [Hash] the pandocomatic property as a Hash, if any, an empty
    #   Hash otherwise.
    def pandocomatic
      return self['pandocomatic'] if key? 'pandocomatic'

      self['pandocomatic_'] if key? 'pandocomatic_'
    end

    # Does this PandocMetadata object has a pandoc options property?
    #
    # @return [Boolean] True if there is a pandoc options property in this
    #   PandocMetadata object. False otherwise.
    def pandoc_options?
      pandocomatic? and pandocomatic.key? 'pandoc' and !pandocomatic['pandoc'].nil?
    end

    # Extract the metadata from an input file
    #
    # @param input [String] the string to extract metadata from
    # @return [Array] The return value is an array with the following two
    # values:
    #
    # 1. The extracted metadata as a YAML string
    # 2. The number of times the pandocomatic properties did occur in the
    #    input.
    #
    # If more than one pandocomatic property is contained in the input,
    # all but the first are discarded and are not present in the
    # extracted metadata YAML string.
    #
    # @raise [PandocomaticError] when pandoc metadata cannot be extracted.
    private_class_method def self.extract_metadata(input, path = nil)
      metadata_blocks = MetadataBlockList.new input, path

      ["#{YAML.dump(metadata_blocks.full)}...", metadata_blocks.count_pandocomatic_blocks]
    end

    # List of YAML metadata blocks present in some input source file
    class MetadataBlockList
      def initialize(input, path)
        blocks = extract_blocks input, path
        if blocks.any? { |b| !b.is_a? Hash }
          raise PandocMetadataError.new :found_horizontal_lines_with_three_dashes, nil, path
        end

        @metadata_blocks = blocks
      end

      # Count the number of metadata blocks with a "pandocomatic_" property.
      def count_pandocomatic_blocks
        @metadata_blocks.count do |block|
          block.key? 'pandocomatic_' or block.key? 'pandocomatic'
        end
      end

      # Combine all metadata blocks into a single metadata block
      # @return [Hash]
      def full
        # According to the pandoc manual: "A document may contain multiple
        # metadata blocks. The metadata fields will be combined through a
        # left-biased union: if two metadata blocks attempt to set the
        # same field, the value from the first block will be taken."
        #
        # Here we do the same
        @metadata_blocks
          .reverse
          .reduce({}) { |metadata, block| metadata.merge!(block) }
      end

      private

      def extract_blocks(input, path)
        starts = input.scan(BLOCK_START)

        if starts.empty?
          # No YAML metadata blocks expected
          return []
        end

        # Expect YAML metadata blocks
        input
          .scan(METADATA_BLOCK)
          .map { |match| PandocomaticYAML.load "---#{match.join}...", path }
          .select { |block| !block.nil? and !block.empty? }
      rescue StandardError => e
        raise PandocMetadataError.new :expected_to_find_YAML_metadata_blocks, e, path
      end
    end

    private_constant :MetadataBlockList
  end
end
