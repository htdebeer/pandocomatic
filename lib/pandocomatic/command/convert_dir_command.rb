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
  require_relative '../error/io_error'

  require_relative 'command'
  require_relative 'create_link_command'
  require_relative 'convert_file_command'
  require_relative 'convert_list_command'
  require_relative 'convert_file_multiple_command'
  require_relative 'copy_file_command'
  require_relative 'skip_command'

  # Commmand to convert a directory
  #
  # @!attribute config
  #   @return [Configuration] configuration to use when converting directory
  #
  # @!attribute src_dir
  #   @return [String] the source directory to convert from
  #
  # @!attribute dst_dir
  #   @return [String] the destination directory to convert to
  class ConvertDirCommand < ConvertListCommand
    attr_reader :config, :src_dir, :dst_dir

    # rubocop:disable Metrics

    # Create a new ConvertDirCommand
    #
    # @param current_config [Configuration] The configuration of pandocomatic
    #   as it was before entering the source directory
    # @param src_dir [String] the directory to convert
    # @param dst_dir [String] the directory to convert to
    def initialize(current_config, src_dir, dst_dir)
      super()
      @src_dir = src_dir
      @config = current_config

      begin
        @config = reconfigure current_config, @src_dir
      rescue ConfigurationError => e
        @errors.push e
      end

      @dst_dir = dst_dir

      if Dir.exist? @dst_dir
        @errors.push IOError.new(:directory_is_not_readable, nil, @dst_dir) unless File.readable? @dst_dir
        @errors.push IOError.new(:directory_is_not_writable, nil, @dst_dir) unless File.writable? @dst_dir
        @errors.push IOError.new(:directory_is_not_a_directory, nil, @dst_dir) unless File.directory? @dst_dir
      end

      Dir.foreach @src_dir do |filename|
        src = File.join @src_dir, filename

        next if @config.skip? src

        @errors.push IOError.new(:file_or_directory_does_not_exist, nil, src) unless File.exist? src

        dst = File.join @dst_dir, filename

        if File.symlink?(src) && !@config.follow_links?
          subcommand = CreateLinkCommand.new(src, dst)
        elsif File.directory? src
          subcommand = if @config.recursive?
                         ConvertDirCommand.new(@config, src, dst)
                       else
                         SkipCommand.new(src, :skipping_directory)
                       end
        elsif File.file? src
          if @config.convert? src
            subcommand = ConvertFileMultipleCommand.new(@config, src, dst)
          elsif !modified_only? || file_modified?(src, dst)
            subcommand = CopyFileCommand.new(src, dst)
          end
        else
          subcommand = SkipCommand.new(src, :unclear_what_to_do)
        end

        push subcommand unless subcommand.nil? || subcommand.skip?
      end

      # Empty commands do not count to the total amount of commands to execute
      uncount if skip?
    end

    # rubocop:enable Metrics

    # Should this command be skipped?
    #
    # @return [Boolean] True if this command has no sub commands
    def skip?
      @subcommands.empty?
    end

    # Converts this command a directory?
    #
    # @return [Boolean] true
    def directory?
      true
    end

    # Convert this command to a String representation for a Printer
    #
    # @return [String]
    def to_s
      "convert #{@src_dir}; #{create_directory? ? 'create and ' : ''}enter #{@dst_dir}"
    end

    # Run this command
    def run
      if create_directory?
        Pandocomatic::LOG.info "  Creating directory '#{@dst_dir}'"
        Dir.mkdir @dst_dir
      end
    rescue SystemError => e
      raise IOError.new(:error_creating_directory, e, @dst_dir)
    end

    private

    def create_directory?
      !File.exist? @dst_dir or !File.directory? @dst_dir
    end

    # If the source directory contains a configuration file, use it to
    # reconfigure the converter. Otherwise, use the current configuration
    def reconfigure(current_config, src_dir)
      config_file = File.join src_dir, Configuration::CONFIG_FILE
      if File.exist? config_file
        current_config.reconfigure config_file
      else
        current_config.clone
      end
    end
  end
end
