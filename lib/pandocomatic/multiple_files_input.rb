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
    require_relative './input.rb'

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
        def name()
            @tmp_file
        end

        # Is this input a directory? A MultipleFilesInput cannot be a
        # directory
        #
        # @return Boolean
        def directory?()
            false
        end

        # Destroy the temporary file created for this MultipleFilesInput
        def destroy!()
            if not @tmp_file.nil?
                @tmp_file.close
                @tmp_file.unlink
            end
        end

        # A string representation of this Input
        #
        # @return String
        def to_s()
            @input_files.join(" + ")
        end

        private 

        def create_temp_file()
            # Concatenate all input files into one (temporary) input file
            # created in the same directory as the first input file
            @tmp_file = Tempfile.new(@input_files.first, File.dirname(self.absolute_path))

            # Read first file and its metadata
            metadata = PandocMetadata.load_file @input_files.first

            strip_metadata = 
                "markdown" == if metadata.pandoc_options.has_key? "from" then
                                  metadata.pandoc_options["from"]
                              else
                                  template = @config.determine_template @input_files.first
                                  if not template.nil? and not template.dig("pandoc", "from").nil? then
                                      template["pandoc"]["from"]
                                  else
                                      "unknown"
                                  end
                              end

            @input_files.each_with_index do |filename, index|
                input = File.read File.absolute_path(filename)
                input = if 0 == index or not strip_metadata then input else PandocMetadata.remove_metadata(input) end
                @tmp_file.write input
            end

            @tmp_file.rewind
        end
    end
end
