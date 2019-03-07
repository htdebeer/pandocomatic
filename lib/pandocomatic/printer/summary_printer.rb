#--
# Copyright 2017, Huub de Beer <Huub@heerdebeer.org>
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
    require_relative './printer.rb'

    # Printer for printing a summary of the conversion process in non-quiet mode
    class SummaryPrinter < Printer

        # Create a new SummaryPrinter
        # 
        # @param command [Command] the command to summarize
        # @param configuration [Configuration] the configuration of the
        # pandocomatic invokation
        def initialize(command, configuration)
            super 'summary.txt'
            @command = command
            @input = configuration.input.to_s
            @output = configuration.output
        end

        # A string representation of the commands being executed
        #
        # @return [String]
        def commands()
            "#{@command.count} command#{'s' if @command.count != 1}"
        end

        # Is there an output file?
        #
        # @return [Boolean] True if there is an output defined in this
        #   SummaryPrinter, false otherwise
        def has_output?()
            not @output.nil? and not @output.empty?
        end

    end
end
