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

  require_relative '../error/io_error.rb'

  require_relative 'command.rb'
  require_relative 'create_link_command.rb'
  require_relative 'convert_file_command.rb'
  require_relative 'convert_list_command.rb'
  require_relative 'convert_file_multiple_command.rb'
  require_relative 'copy_file_command.rb'
  require_relative 'skip_command.rb'

  class ConvertDirCommand < ConvertListCommand

    attr_reader :config, :src_dir, :dst_dir

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

        next if config.skip? src

        @errors.push IOError.new(:file_or_directory_does_not_exist, nil, src) unless File.exist? src

        dst = File.join @dst_dir, filename

        if File.symlink? src and not config.follow_links?
          subcommand = CreateLinkCommand.new(src, dst)
        elsif File.directory? src then
          if config.recursive? then
            subcommand = ConvertDirCommand.new(config, src, dst)
          else
            subcommand = SkipCommand.new(src, :skipping_directory)
          end
        elsif File.file? src 
          if config.convert? src then
              subcommand = ConvertFileMultipleCommand.new(config, src, dst)
          else
            if not modified_only? or file_modified? src, dst then
              subcommand = CopyFileCommand.new(src, dst)
            end
          end
        else
          subcommand = SkipCommand.new(src, :unclear_what_to_do)
        end

        push subcommand unless subcommand.nil? or subcommand.skip?
      end

      # Empty commands do not count to the total amount of commands to execute
      uncount if skip?
    end

    def skip?()
      @subcommands.empty?
    end

    def directory?()
      true
    end

    def to_s()
      "convert #{@src_dir}" + '; ' + if create_directory? then 'create and ' else '' end + "enter #{@dst_dir}"
    end

    def run()
      begin
        Dir.mkdir @dst_dir if create_directory?
      rescue SystemError => e
        raise IOError.new(:error_creating_directory, e, @dst_dir)
      end
    end

    private

    def create_directory?()
      not File.exist? @dst_dir or not File.directory? @dst_dir
    end

    # If the source directory contains a configuration file, use it to
    # reconfigure the converter. Otherwise, use the current configuration
    def reconfigure(current_config, src_dir)
      config_file = File.join src_dir, Pandocomatic::CONFIG_FILE
      if File.exist? config_file then
        config = current_config.reconfigure config_file
      else
        config = current_config
      end
      config
    end

  end
end
