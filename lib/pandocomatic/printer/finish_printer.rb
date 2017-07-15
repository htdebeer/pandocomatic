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
  require_relative './summary_printer.rb'

  # Printer for the end of the conversion process in non-quiet mode
  class FinishPrinter < SummaryPrinter
    # A minute has 60 seconds
    MINUTE = 60

    # Create a new FinishPrinter
    def initialize(command, input, output, start_time)
      super command, input, output
      set_template 'finish.txt'

      @start_time = start_time
      @end_time = Time.now
    end

    # Calculate the duration of the whole conversion process
    def duration()
      seconds = @end_time - @start_time
      if seconds > MINUTE
        minutes = (seconds / MINUTE).floor
        seconds = seconds - (minutes * MINUTE)
        "#{minutes} minute#{'s' if minutes != 1} and #{seconds.round(1)} second#{'s' if seconds != 1}"
      else
        "#{seconds.round(1)} second#{'s' if seconds != 1}"
      end
    end

  end
end
