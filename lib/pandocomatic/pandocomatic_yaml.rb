# frozen_string_literal: true

#--
# Copyright 2022 Huub de Beer <Huub@heerdebeer.org>
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
  require 'date'
  require 'yaml'

  require_relative './error/template_error'

  # PandocomaticYAML is a wrapper around ruby's YAML library that replaces
  # occurrences of "$(X)$" in the YAML by the value of the evironment variable
  # X. If variable X cannot be found, an exception is thrown.
  module PandocomaticYAML
    # List of classes that are permitted in YAML
    PERMITTED_YAML_CLASSES = [Date].freeze

    # Regular expression representing environment variables in templates
    VAR_PATTERN = /\$\((?<var>[a-zA-Z_][a-zA-Z0-9_]*)\)\$/.freeze

    # Load a string, substitute any variables, and parse as YAML.
    #
    # @param str [String] String to parse as YAML
    # @param path [Path|Nil] Path of the source of the string, if any
    # @return [Hash]
    # @raise [TemplateError] when environment variable does not exist.
    def self.load(str, path = nil)
      YAML.safe_load substitute_variables(str, path), permitted_classes: PERMITTED_YAML_CLASSES
    end

    # Load a text file, substitute any variables, and parse as YAML.
    #
    # @param path [String] Path to text file to parse as YAML
    # @return [Hash]
    # @raise [TemplateError] when environment variable does not exist.
    def self.load_file(path)
      self.load File.read(path), path
    end

    # Substitute all environment variables in the str with the values of the
    # corresponding environment variables.
    #
    # @raise [TemplateError] when environment variable does not exist.
    private_class_method def self.substitute_variables(str, path = nil)
      str.gsub(VAR_PATTERN) do |_match|
        key = Regexp.last_match(1)

        raise TemplateError.new :environment_variable_does_not_exist, { key: key, path: path } unless ENV.key? key

        ENV[key]
      end
    end
  end
end
