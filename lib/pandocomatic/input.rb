# frozen_string_literal: true

#--
# Copyright 2019 Huub de Beer <Huub@heerdebeer.org>
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
  require_relative 'configuration'

  # Generic class to handle input files and directories in a general manner.
  class Input
    attr_reader :errors

    # Create a new Input
    #
    # @param input [String[]] a list of input files
    def initialize(input)
      @input_files = input
      @errors = []
    end

    # The absolute path to this Input
    #
    # @return String
    def absolute_path
      File.absolute_path @input_files.first
    end

    # The base name of this Input
    #
    # @return String
    def base
      File.basename @input_files.first
    end

    # The name of this input
    #
    # @return String
    def name
      @input_files.first
    end

    # Is this input a directory?
    #
    # @return Boolean
    def directory?
      File.directory? @input_files.first
    end

    # Does this input have encountered any errors?
    #
    # @return Boolean
    def errors?
      !@errors.empty?
    end

    # A string representation of this Input
    #
    # @return String
    def to_s
      name
    end
  end
end
