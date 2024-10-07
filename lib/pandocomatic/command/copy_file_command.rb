# frozen_string_literal: true

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
  require 'fileutils'

  require_relative '../error/io_error'
  require_relative 'command'

  # A command to copy a file
  #
  # @!attribute src
  #   @return [String] path to the file to copy
  class CopyFileCommand < Command
    attr_reader :src

    # Create a new CopyFileCommand
    #
    # @param src [String] path to the file to copy
    # @param dst [String] path to the place to copy the source file to
    def initialize(src, dst)
      super()
      @src = src
      @dst = dst
      @errors.push IOError.new(:file_is_not_readable, nil, @src) unless File.readable? @src
      @errors.push IOError.new(:file_is_not_writable, nil, @dst) unless !File.exist?(@dst) || File.writable?(@dst)
    end

    # Run this CopyFileCommand
    def run
      if file_modified?(@src, @dst)
        Pandocomatic::LOG.info "Copying '#{@src}' → '#{@dst}'"
        FileUtils.cp(@src, @dst)
      end
    rescue StandardError => e
      raise IOError.new(:unable_to_copy_file, e, [@src, @dst])
    end

    # A string representation of this CopyFileCommand
    #
    # @return [String]
    def to_s
      "copy #{File.basename @src}"
    end
  end
end
