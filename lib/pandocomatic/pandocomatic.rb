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

  require 'paru'

  require_relative './error/pandocomatic_error.rb'
  require_relative './error/pandoc_error.rb'
  require_relative './error/configuration_error.rb'

  require_relative './cli.rb'

  require_relative './configuration.rb'

  require_relative './dir_converter.rb'
  require_relative './file_converter.rb'

  require_relative './printer/help_printer.rb'
  require_relative './printer/version_printer.rb'
  require_relative './printer/error_printer.rb'

  class Pandocomatic
    VERSION = [0, 1, 0]
    CONFIG_FILE = 'pandocomatic.yaml'

    def self.run(args)
      begin
        options = CLI.parse args

        if options[:version_given]
          # The version option has precedence over all other options; if
          # given, the version is printed
          VersionPrinter.new(VERSION).print
        elsif options[:help_given]
          # The help option has precedence over all other options except the
          # version option. If given, the help is printed.
          HelpPrinter.new().print
        else
          input = options[:input]
          output = options[:output]
          configuration = configure options

          converter_type = if File.directory? input then DirConverter else FileConverter end

          converter_type
            .new(input, output, configuration)
            .convert
        end
      rescue PandocomaticError => e
        ErrorPrinter.new(e).print
      end
    end

    private

    def self.determine_config_file(options, data_dir = Dir.pwd)
      config_file = ''

      if options[:config_given]
        config_file = options[:config]
      elsif Dir.entries(data_dir).include? CONFIG_FILE
        config_file = File.join(data_dir, CONFIG_FILE)
      elsif Dir.entries(Dir.pwd()).include? CONFIG_FILE
        config_file = File.join(Dir.pwd(), CONFIG_FILE)
      else
        # Fall back to default configuration file distributed with
        # pandocomatic
        config_file = File.join(__dir__, 'default_configuration.yaml')
      end

      path = File.absolute_path config_file

      raise ConfigurationError.new(:config_file_does_not_exist, nil, path) unless File.exist? path
      raise ConfigurationError.new(:config_file_is_not_a_file, nil, path) unless File.file? path
      raise ConfigurationError.new(:config_file_is_not_readable, nil, path) unless File.readable? path

      path
    end

    def self.determine_data_dir(options)
      data_dir = ''

      if options[:data_dir_given]
        data_dir = options[:data_dir]
      else
        # No data-dir option given: try to find the default one from pandoc
        begin
          data_dir = Paru::Pandoc.info()[:data_dir]
        rescue Paru::Error => e
          # If pandoc cannot be run, continuing probably does not work out
          # anyway, so raise pandoc error
          raise PandocError.new(:error_running_pandoc, e, data_dir)
        rescue StandardError => e
          # Ignore error and use the current working directory as default working directory
          data_dir = Dir.pwd
        end
      end

      # check if data directory does exist and is readable
      path = File.absolute_path data_dir

      raise ConfigurationError.new(:data_dir_does_not_exist, nil, path) unless File.exist? path
      raise ConfigurationError.new(:data_dir_is_not_a_directory, nil, path) unless File.directory? path
      raise ConfigurationError.new(:data_dir_is_not_readable, nil, path) unless File.readable? path

      path
    end

    def self.configure(options)
      data_dir = determine_data_dir options
      config_file = determine_config_file options, data_dir
      Configuration.new options, data_dir, config_file
    end

  end
end
