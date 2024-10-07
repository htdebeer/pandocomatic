# frozen_string_literal: true

#--
# Copyright 2017—2024, Huub de Beer <Huub@heerdebeer.org>
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
  require_relative 'printer'

  # Printer for ConfigurationErrors in non-quiet mode
  class ConfigurationErrorsPrinter < Printer
    # Create a new ConfigurationErrorsPrinter
    def initialize(errors)
      super('configuration_errors.txt')
      @errors = errors
    end

    # Print configuration errors to STDOUT
    def print
      Pandocomatic::LOG.warn self
      warn self
    end
  end
end
