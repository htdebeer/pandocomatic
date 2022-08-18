# frozen_string_literal: true

#--
# Copyright 2022, Huub de Beer <Huub@heerdebeer.org>
#
# This file is part of pandocomatic.
#
# Pandocomatic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at you1r
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
  # A pandocomatic template
  class Template
    attr_reader :name, :path

    # The name of the 'extends' section in a template
    EXTENDS = 'extends'

    # The name of the 'glob' section in a template
    GLOB = 'glob'

    # The name of the 'setup' section in a template
    SETUP = 'setup'

    # The name of the 'preprocessors' section in a template
    PREPROCESSORS = 'preprocessors'

    # The name of the 'metadata' section in a template
    METADATA = 'metadata'

    # The name of the 'pandoc' section in a template
    PANDOC = 'pandoc'

    # The name of the 'postprocessors' section in a template
    POSTPROCESSORS = 'postprocessors'

    # The name of the 'cleanup' section in a template
    CLEANUP = 'cleanup'

    # List of the sections a template can contain
    SECTIONS = [EXTENDS, GLOB, SETUP, PREPROCESSORS, METADATA, PANDOC, POSTPROCESSORS, CLEANUP].freeze

    # Create a new template based on a template hash
    #
    # @param name [String] this template's name
    # @param template_hash [Hash] hash representing template
    def initialize(name, template_hash = {}, path = nil)
      @name = name
      @path = path

      @data = {
        EXTENDS => [],
        GLOB => [],
        SETUP => [],
        PREPROCESSORS => [],
        METADATA => {},
        PANDOC => {},
        POSTPROCESSORS => [],
        CLEANUP => []
      }

      @data.merge! template_hash
    end

    # Deep copy template
    #
    # @param template [Template] the template to copy
    # @return [Template] a deep copy of the input template
    def self.clone(template)
      Template.new(template.name, Marshal.load(Marshal.dump(template.to_h)), template.path)
    end

    # Is this an internal template?
    #
    # @return [Bool]
    def internal?
      @path.nil?
    end

    # Is this an external template?
    #
    # @return [Bool]
    def external?
      !internal?
    end

    # Does this template have a 'extends' section?
    #
    # @return [Bool]
    def extends?
      section?(EXTENDS)
    end

    # List of template names that this template extends
    #
    # @return [Array<String>]
    def extends
      to_extend = section(EXTENDS)
      to_extend = [to_extend] if to_extend.is_a? String
      to_extend
    end

    # Does this template have a 'glob' section?
    #
    # @return [Bool]
    def glob?
      section?(GLOB)
    end

    # Get the list with glob patterns for this template
    #
    # @return [Array<String>]
    def glob
      section(GLOB)
    end

    # Does this template have a 'setup' section?
    #
    # @return [Bool]
    def setup?
      section?(SETUP)
    end

    # Get the list of setup scripts for this template
    #
    # @return [Array<String>]
    def setup
      section(SETUP)
    end

    # Does this template have a 'preprocessors' section?
    #
    # @return [Bool]
    def preprocessors?
      section?(PREPROCESSORS)
    end

    # Get the list of preprocessors scripts for this template
    #
    # @return [Array<String>]
    def preprocessors
      section(PREPROCESSORS)
    end

    # Does this template have a 'metadata' section?
    #
    # @return [Bool]
    def metadata?
      section?(METADATA)
    end

    # Get the metadata key-value pairs for this template
    #
    # @return [Hash]
    def metadata
      section(METADATA, {})
    end

    # Does this template have a 'pandoc' section?
    #
    # @return [Bool]
    def pandoc?
      section?(PANDOC)
    end

    # Get the pandoc configuration for this template
    #
    # @return [Hash]
    def pandoc
      section(PANDOC, {})
    end

    # Does this template have a 'postprocessors' section?
    #
    # @return [Bool]
    def postprocessors?
      section?(POSTPROCESSORS)
    end

    # Get the list of postprocessor scripts for this template
    #
    # @return [Array<String>]
    def postprocessors
      section(POSTPROCESSORS)
    end

    # Does this template have a 'cleanup' section?
    #
    # @return [Bool]
    def cleanup?
      section?(CLEANUP)
    end

    # Get the list of cleanup scripts for this template
    #
    # @return [Array<String>]
    def cleanup
      section(CLEANUP)
    end

    # Merge another template into this one.
    #
    # @param other [Template] other template to merge into this one.
    def merge!(other)
      SECTIONS.each do |section_name|
        current_section = section(section_name)
        other_section = other.send section_name
        extended_section = Configuration.extend_value other_section, current_section

        if extended_section.nil?
          @data.delete section_name
        else
          @data[section_name] = extended_section
        end
      end
    end

    # Create Hash representation of this template
    #
    # @return [Hash]
    def to_h
      @data
    end

    private

    def section?(name)
      @data[name] and !@data[name].empty?
    end

    def section(name, default = [])
      @data[name] or default
    end
  end
end
