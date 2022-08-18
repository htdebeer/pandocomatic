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
  require_relative 'command'

  require_relative '../warning'
  require_relative '../error/io_error'
  require_relative '../printer/warning_printer'

  # A command to create a link to a file
  #
  # @!attribute src
  #   @return [String] the path to the file to link to
  #
  # @!attribute dst
  #   @return [String] the link name to create
  #
  # @!attribute dst_target
  #   @return [String] the link in the destination tree to link to
  class CreateLinkCommand < Command
    attr_reader :src, :dst, :dst_target

    # Create a new CreateLinkCommand
    #
    # @param src [String] the path to the file to link
    # @param dst [String] the path to the name of the link to create
    def initialize(src, dst)
      super()
      @src = src
      begin
        src_target = File.readlink @src

        if src_target.start_with? '.'
          full_src_target = File.expand_path src_target, File.dirname(src)

          if full_src_target.start_with? src_root
            @dst = dst
            @dst_target = src_target
          else
            WarningPrinter.new(Warning.new(:skipping_link_because_it_points_outside_the_source_tree, @src)).print
          end

          uncount if skip?
        end
      rescue StandardError => e
        @errors.push IOError.new(:unable_to_read_symbolic_link, e, @src)
      end
    end

    # Run this CreateLinkCommand
    def run
      File.symlink @dst_target, @dst unless File.exist? @dst
    rescue StandardError => e
      raise IOError.new(:unable_to_create_symbolic_link, e, [@src, @dst])
    end

    # Can this CreateLinkCommand be run?
    #
    # @return [Boolean] True if there are no errors and both source and
    #   destination do exist
    def runnable?
      !(errors? or @dst.nil? or @dst_target.nil? or @src.nil?)
    end

    # Create a string representation of this CreateLinkCommand
    def to_s
      "link #{File.basename @dst} -> #{@dst_target}"
    end

    # Should this CreateLinkCommand be skipped?
    #
    # @return [Boolean]
    def skip?
      !modified_only? or !modified?
    end

    # Has the source file been modified?
    #
    # @return [Boolean]
    def modified?
      if File.exist? @dst
        absolute_dst = File.realpath @dst
        target = File.expand_path(@dst_target, absolute_dst)
        absolute_dst != target
      else
        true
      end
    end
  end
end
