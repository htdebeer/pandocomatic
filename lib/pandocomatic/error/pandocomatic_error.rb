# frozen_string_literal: true

#--
# Copyright 2017 Huub de Beer <Huub@heerdebeer.org>
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
  require_relative '../printer/error_printer'

  # General pandocomatic error
  #
  # @!attribute type
  #   @return [Symbol] type of error
  #
  # @!attribute error
  #   @return [Error] the underlying error, if any
  #
  # @!attribute data
  #   @return [Object] attached data, if any
  class PandocomaticError < StandardError
    attr_reader :type, :error, :data

    # Create a new PandocomaticError
    #
    # @param type [Symbol = :unknown] the type of error, defaults to :unknown
    # @param error [Error = nil] the underlying error, optional
    # @param data [Object = nil] extra information attached to this
    #   PandocomaticError, if any; optional
    def initialize(type = :unknown, error = nil, data = nil)
      super type.to_s.gsub('_', ' ').capitalize
      @type = type
      @error = error
      @data = data
    end

    # Has this PandocomaticError an underlying error?
    #
    # @return [Boolean]
    def error?
      !@error.nil?
    end

    # Has this PandocomaticError extra information associated to it?
    #
    # @return [Boolean]
    def data?
      !@data.nil?
    end

    # Print this error.
    def print
      ErrorPrinter.new(self).print
    end

    # Show this error
    #
    # @return [String] a string representation of this PandocomaticError
    def show
      ErrorPrinter.new(self).to_s
    end
  end
end
