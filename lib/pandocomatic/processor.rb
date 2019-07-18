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
    require 'open3'
    require_relative 'error/processor_error.rb'

    # Generic class for processors used to preprocess, postproces, setup, and
    # cleanup with external scripts or programs during the conversion process.
    #
    # For preprocessors and postprocessors it is assumed that the input is the
    # contents of the file to convert and the output the processed input. In
    # the end, the output will be put through pandoc.
    class Processor

        # Run script on input and return captured output
        #
        # @param script [String] path to script to run
        # @param input [String] input to process in the script
        # 
        # @return [String] output of script.
        def self.run script, input
            output, error, status = Open3.capture3(script, :stdin_data => input)
            warn error unless error.empty?

            if status.exitstatus > 0
                raise ProcessorError.new(:error_processing_script, StandardError.new(error), [script, input]) 
            end

            output
        end

    end
end
