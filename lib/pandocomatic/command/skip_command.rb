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

  require_relative 'command.rb'

  # A command to skip a file or directory
  #
  # @!attribute src
  #   @return [String] the file or directory to skip
  #
  # @!attribute message
  #   @return [String] message explaining why the file or directory is being skipped.
  class SkipCommand < Command
    attr_reader :src, :message

    # Create a new SkipCommand
    #
    # @param src [String] path to the file to skip
    # @param message [String] the message explaining why this file is being
    #   skipped
    def initialize(src, message)
      super()
      @src = src
      @message = message
    end

    # Has this SkipCommand a message?
    #
    # @return [Boolean]
    def has_message?()
      not(@message.nil? or @message.empty?)
    end

    # 'Run' this SkipCommand by doing nothing
    def run()
    end

    # Skip this command
    #
    # @return [Boolean] true
    def skip?()
      true
    end

    # A string representation of this SkipCommand
    #
    # @return [String]
    def to_s
      "skipping #{File.basename @src}" + if has_message?
        ": #{@message}"
      end
    end

  end
end
