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
  require 'tempfile'
  require_relative 'input'

  # A specific Input class to handle multiple input files
  class MultipleFilesInput < Input
    # Create a new MultipleFilesInput. As a side-effect a temporary file
    # is created as well containing the content of all the files in input.
    #
    # @param input [String[]] a list with input files
    def initialize(input, config)
      super(input)
      @config = config
      create_temp_file
    end

    # The name of this input
    #
    # @return String
    def name
      @tmp_file.path
    end

    # Is this input a directory? A MultipleFilesInput cannot be a
    # directory
    #
    # @return Boolean
    def directory?
      false
    end

    # Destroy the temporary file created for this MultipleFilesInput
    def destroy!
      return if @tmp_file.nil?

      @tmp_file.close
      @tmp_file.unlink
    end

    # A string representation of this Input
    #
    # @return String
    def to_s
      input_string = @input_files.first
      previous_dir = File.dirname @input_files.first
      @input_files.slice(1..-1).each do |f|
        current_dir = File.dirname f
        if current_dir == previous_dir
          input_string += " + #{File.basename f}"
        else
          previous_dir = current_dir
          input_string += " + #{f}"
        end
      end

      input_string
    end

    private

    # rubocop:disable Metrics/AbcSize

    def create_temp_file
      # Concatenate all input files into one (temporary) input file
      # created in the same directory as the first input file
      @tmp_file = Tempfile.new('pandocomatic_tmp_', File.dirname(absolute_path))

      contents = @input_files.map do |file|
        @errors.push IOError.new(:file_does_not_exist, nil, file) unless File.exist? file
        @errors.push IOError.new(:file_is_not_a_file, nil, file) unless File.file? file
        @errors.push IOError.new(:file_is_not_readable, nil, file) unless File.readable? file
        File.read File.absolute_path(file)
      end.join("\n\n")

      metadata = PandocMetadata.load contents

      unless metadata.unique?
        warn "\nWarning: Encountered the pandocomatic metadata property in " \
             'more than one YAML metadata block. Only the pandocomatic property ' \
             'from the first YAML metadata block is being used; the other ' \
             "pandocomatic properties have been discarded.\n\n"
      end

      @tmp_file.write contents
      @tmp_file.rewind
    end

    # rubocop:enable Metrics/AbcSize
  end
end
