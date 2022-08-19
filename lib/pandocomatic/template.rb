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

    # For each section in a template, generate methods to check if the section
    # exists and to get that section's content.
    SECTIONS.each do |sec|
      define_method(sec.downcase.to_sym) do
        section sec
      end

      define_method("#{sec.downcase}?".to_sym) do
        section? sec
      end
    end

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

    # List of template names that this template extends.
    #
    # @return [Array<String>]
    def extends
      # Overwriting automatically generated method with more specific
      # behavior
      to_extend = section(EXTENDS)
      to_extend = [to_extend] if to_extend.is_a? String
      to_extend
    end

    # Merge another template into this one.
    #
    # @param other [Template] other template to merge into this one.
    def merge!(other)
      SECTIONS.each do |section_name|
        current_section = section(section_name)
        other_section = other.send section_name
        extended_section = Template.extend_value other_section, current_section

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

    # rubocop:disable Metrics

    # Extend the current value with the parent value. Depending on the
    # value and type of the current and parent values, the extension
    # differs.
    #
    # For simple values, the current value takes precedence over the
    # parent value
    #
    # For Hash values, each parent value's property is extended as well
    #
    # For Arrays, the current overwrites and adds to parent value's items
    # unless the current value is a Hash with a 'remove' and 'add'
    # property. Then the 'add' items are added to the parent value and the
    # 'remove' items are removed from the parent value.
    #
    # @param current [Object] the current value
    # @param parent [Object] the parent value the current might extend
    # @return [Object] the extended value
    def self.extend_value(current, parent)
      if parent.nil?
        # If no parent value is specified, the current takes
        # precedence
        current
      elsif current.nil?
        nil
      # Current nil removes value of parent; follows YAML spec.
      # Note. take care to actually remove this value from a
      # Hash. (Like it is done in the next case)
      else
        case parent
        when Hash
          if current.is_a? Hash
            # Mixin current and parent values
            parent.each_pair do |property, value|
              if current.key? property
                extended_value = extend_value(current[property], value)
                if extended_value.nil?
                  current.delete property
                else
                  current[property] = extended_value
                end
              else
                current[property] = value
              end
            end
          end
          current
        when Array
          case current
          when Hash
            if current.key? 'remove'
              to_remove = current['remove']

              if to_remove.is_a? Array
                parent.delete_if { |v| current['remove'].include? v }
              else
                parent.delete to_remove
              end
            end

            if current.key? 'add'
              to_add = current['add']

              if to_add.is_a? Array
                parent = current['add'].concat(parent).uniq
              else
                parent.push(to_add).uniq
              end
            end

            parent
          when Array
            # Just combine parent and current arrays, current
            # values take precedence
            current.concat(parent).uniq
          else
            # Unknown what to do, assuming current should take
            # precedence
            current
          end
        else
          # Simple values: current replaces parent
          current
        end
      end
    end

    # rubocop:enable Metrics

    private

    def section?(name)
      @data[name] and !@data[name].empty?
    end

    def section(name, default = [])
      @data[name] or default
    end
  end
end
