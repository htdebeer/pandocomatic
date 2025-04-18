# frozen_string_literal: true

#--
# Copyright 2014—2024, Huub de Beer <huub@heerdebeer.org>
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
  Encoding.default_external = Encoding::UTF_8 # ensure unicode encoding
  Encoding.default_internal = Encoding::UTF_8

  require 'logger'
  require 'paru'
  require 'tempfile'

  require_relative 'error/pandocomatic_error'
  require_relative 'error/pandoc_error'

  require_relative 'cli'

  require_relative 'printer/help_printer'
  require_relative 'printer/version_printer'
  require_relative 'printer/error_printer'
  require_relative 'printer/configuration_errors_printer'
  require_relative 'printer/finish_printer'
  require_relative 'printer/summary_printer'
  require_relative 'printer/unknown_error_printer'

  require_relative 'command/convert_dir_command'
  require_relative 'command/convert_list_command'
  require_relative 'command/convert_file_command'
  require_relative 'command/convert_file_multiple_command'

  require_relative 'version'

  # The Pandocomatic class controlls the pandocomatic conversion process
  module Pandocomatic
    # Pandocomatic's log. Depending on given command-line arguments,
    # pandocomatic will log its actions to file or not log anything at all.
    class Log
      # Add pandocomatic's command-line arguments to the log
      #
      # @param [String[]] args
      def pandocomatic_called_with(args)
        @args = if args.respond_to? :join
                  args.join(' ')
                else
                  args
                end
      end

      # Install a logger that writes to a given log file for given log level
      #
      # @param log_file [String] name or path to log file
      # @param log_level [String] log level, one of "fatal", "error",
      # "warning", or "debug". Defaults to "info"
      def install_file_logger(log_file, log_level = 'info')
        unless log_file.nil?
          begin
            @logger = Logger.new(log_file, level: log_level)
            @logger.formatter = proc do |severity, datetime, _progname, msg|
              date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
              "#{date_format} #{severity.ljust(5)}: #{msg}\n"
            end
          rescue StandardError => e
            warn "Unable to create log file '#{log_file}' with log level '#{log_level}' because:\n#{e}."
            warn 'Continuing with logging disabled.'
          end
        end

        info '------------ START ---------------'
        info "Running #{$PROGRAM_NAME} #{@args}"
      end

      # Log a debug message
      #
      # @param [String] msg
      def debug(msg)
        @logger&.debug(msg)
      end

      # Log an error message
      #
      # @param [String] msg
      def error(msg)
        @logger&.error(msg)
      end

      # Log a fatal message
      #
      # @param [String] msg
      def fatal(msg)
        @logger&.fatal(msg)
      end

      # Log an informational message
      #
      # @param [String] msg
      def info(msg)
        @logger&.info(msg)
      end

      # Log a warning message
      #
      # @param [String] msg
      def warn(msg)
        @logger&.warn(msg)
      end

      # Indent given string with given number of spaces. Intended for logging
      # purposes.
      #
      # @param str [String] string to indent
      # @param number_of_spaces [Number] number of spaces to indent string
      # @return [String] indented string
      def indent(str, number_of_spaces)
        str.split("\n").join("\n#{' ' * number_of_spaces}")
      end
    end

    private_constant :Log

    # Global logger for pandocomatic
    LOG = Log.new

    # Feature toggles supported by pandocomatic
    FEATURES = [:pandoc_verbose].freeze

    # Pandocomatic error status codes start from ERROR_STATUS
    ERROR_STATUS = 1266 # This is the sum of the ASCII values of the characters in 'pandocomatic'

    # rubocop:disable Metrics

    # Run pandocomatic given options
    #
    # @param args [String[]] list of options to configure pandocomatic
    def self.run(args)
      LOG.pandocomatic_called_with args
      start_time = Time.now

      # Depending on given command-line arguments, CLI#parse! also
      # installs a file logger in LOG.
      configuration = CLI.parse! args

      if configuration.show_version?
        # The version option has precedence over all other options; if
        # given, the version is printed
        VersionPrinter.new(VERSION).print
      elsif configuration.show_help?
        # The help option has precedence over all other options except the
        # version option. If given, the help is printed.
        HelpPrinter.new.print
      else
        # When using multiple input files, errors reading these
        # files are already encountered at this point. If there
        # are any errors, there is no reason to continue.
        if configuration.input.errors?
          ConfigurationErrorsPrinter.new(configuration.input.all_errors).print
          exit ERROR_STATUS
        end

        if configuration.dry_run?
          LOG.debug 'Start dry-run conversion:'
        else
          LOG.debug 'Start conversion:'
        end

        # Run the pandocomatic converter configured according to the options
        # given.
        #
        # Pandocomatic has two modes: converting a directory tree or
        # converting a single file. The mode is selected by the input.
        if configuration.directory?
          command = ConvertDirCommand.new(configuration, configuration.input_file, configuration.output)
        else
          command = ConvertFileMultipleCommand.new(configuration, configuration.input_file,
                                                   configuration.output)
          command.make_quiet unless command.subcommands.size > 1
        end

        # Notify the user about all configuration errors collected when
        # determining the commands to run to perform this pandocomatic
        # conversion.
        if command.all_errors.size.positive?
          ConfigurationErrorsPrinter.new(command.all_errors).print
          exit ERROR_STATUS
        end

        # Pandocomatic is successfully configured: running the
        # actual conversion now. But first a short summary of the
        # process to execute is printed.
        SummaryPrinter.new(command, configuration).print if !configuration.quiet? || command.directory?

        # Depending on the options dry-run and quiet, the command.execute
        # method will actually performing the commands (dry-run = false) and
        # print the command to STDOUT (quiet = false)
        command.execute

        FinishPrinter.new(command, configuration, start_time).print unless configuration.quiet?
      end
    rescue PandocomaticError => e
      # Report the error and break off the conversion process.
      ErrorPrinter.new(e).print
      exit ERROR_STATUS + 1
    rescue StandardError => e
      warn e
      warn e.backtrace
      # An unexpected error has occurred; break off the program drastically
      # for now. This is likely a bug: ask the user to report it.
      UnknownErrorPrinter.new(e).print
      exit ERROR_STATUS + 2
    ensure
      configuration&.clean_up!
      LOG.info "------------  END  ---------------\n"
    end
  end

  # rubocop:enable Metrics
end
