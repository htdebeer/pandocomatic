# frozen_string_literal: true

#--
# Copyright 2017-2024, Huub de Beer <huub@heerdebeer.org>
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
  require 'optimist'

  require_relative 'error/cli_error'
  require_relative 'configuration'

  ##
  # Command line options parser for pandocomatic using optimist.
  #
  class CLI
    ##
    # Parse the arguments, returns a triplet with the global options, an
    # optional subcommand, and the (optional) options for that subcommand.
    #
    # As a side effect, this method will create and install a logger for
    # Pandocomatic::LOG.
    #
    # @param args [String, Array] A command-line invocation string or a list of strings like ARGV
    #
    # @return [Configuration] The configuration for running pandocomatic given
    # the command-line options.
    def self.parse!(args)
      args = args.split if args.is_a? String

      begin
        parse_options args || Configuration.new({ help: true, help_given: true })
      rescue Optimist::CommandlineError => e
        raise CLIError.new(:problematic_invocation, e, args)
      end
    end

    # rubocop:disable Metrics

    # Parse pandocomatic's global options.
    #
    # @return [Configuration]
    private_class_method def self.parse_options(args)
      parser = Optimist::Parser.new do
        # General options
        opt :dry_run, 'Do a dry run', short: '-y'
        opt :verbose, 'Run verbosely', short: '-V'
        opt :modified_only, 'Modified files only', short: '-m'
        opt :enable, 'Enable feature', short: '-e', multi: true, type: String

        # Logging
        opt :log, 'Log to file', short: '-l', type: String, default: 'pandocomatic.log'
        opt :log_level, 'Log level', type: String, default: 'INFO'

        # Configuration of the converter
        opt :data_dir, 'Data dir', short: '-d', type: String
        opt :config, 'Configuration file', short: '-c', type: String
        opt :root_path, 'Root path', short: '-r', type: String

        # What to convert and where to put it
        opt :output, 'Output', short: '-o', type: String
        opt :input, 'Input', short: '-i', type: String, multi: true
        opt :stdout, 'Output to standard out', short: '-s'

        # Common
        opt :show_version, 'Version', short: '-v', long: 'version'
        opt :show_help, 'Help', short: '-h', long: 'help'
      end

      # All options should be parsed according to the specification given in the parser
      # parser#parse removes arguments from args during parsing. Keep a copy for error reporting.
      given_arguments = args.dup

      begin
        options = parser.parse args
      rescue Optimist::CommandlineError => e
        raise CLIError.new(:problematic_invocation, e, given_arguments)
      end

      if options[:log_given]
        log_file = options[:log]
        log_level = options[:log_level]
      end

      Pandocomatic::LOG.install_file_logger(log_file, log_level)

      options = use_custom_version options
      options = use_custom_help options

      if options_need_to_be_validated? options
        Pandocomatic::LOG.debug 'Validating command-line arguments:'

        # if no input option is specified, all items following the last option
        # are treated as input files.
        if !(options[:input_given])
          Pandocomatic::LOG.debug '✓  Option \'--input\' not used:  ' \
                                  'treat all arguments after last option as input files or directories.'
          options[:input] = args
          options[:input_given] = true
        elsif !args.empty?
          raise CLIError, :no_mixed_inputs
        end

        # There should be an input specified
        raise CLIError, :no_input_given if options[:input].nil? || options[:input].empty?

        # Support multiple input files for conversion
        multiple_inputs = options[:input].size > 1

        if multiple_inputs
          Pandocomatic::LOG.debug '✓  Convert multiple input files or directories.'
        else
          Pandocomatic::LOG.debug '✓  Convert single input file or directory.'
        end

        # The input files or directories should exist
        input = options[:input].map do |input_file|
          raise CLIError.new(:input_does_not_exist, nil, input_file) unless File.exist? input_file
          raise CLIError.new(:input_is_not_readable, nil, input_file) unless File.readable? input_file

          # If there are multiple input files, these files cannot be directories
          if multiple_inputs && File.directory?(input_file)
            raise CLIError.new(:multiple_input_files_only, nil,
                               input_file)
          end

          File.absolute_path input_file
        end
        Pandocomatic::LOG.debug '✓  Input files and directories exist.'

        # You cannot use the --stdout option while converting directories
        if options[:stdout_given] && File.directory?(input.first)
          options[:stdout] = false
          raise CLIError, :cannot_use_stdout_with_directory
        end
        Pandocomatic::LOG.debug '✓  Write output to STDOUT.' if options[:stdout_given]

        if options[:output_given]
          # You cannot use --stdout with --output
          if options[:stdout_given]
            options[:stdout] = false
            raise CLIError, :cannot_use_both_output_and_stdout
          else
            Pandocomatic::LOG.debug "✓  Write output to '#{options[:output]}'."
            output = File.absolute_path options[:output]
            # Input and output should be both files or directories
            match_file_types input.first, output
            Pandocomatic::LOG.debug '✓  Input and outputs types match.'

            # The output, if it already exist, should be writable
            unless (!File.exist? output) || File.writable?(output)
              raise CLIError.new(:output_is_not_writable, nil,
                                 output)
            end
            Pandocomatic::LOG.debug '✓  Existing output is writable.' if File.exist? output
          end
        elsif !multiple_inputs && File.directory?(input.first)
          raise CLIError, :no_output_given
        end

        # If the input is a directory, an output directory should be
        # specified as well. If the input is a file, the output could be
        # specified in the input file, or STDOUT could be used.

        # No check for root_path: a user can supply one that does not exists
        # at this location and still work on the output location.

        # Data dir, if specified, should be an existing and readable directory
        if options[:data_dir_given]
          data_dir = File.absolute_path options[:data_dir]

          raise CLIError.new(:data_dir_does_not_exist, nil, options[:data_dir]) unless File.exist? data_dir
          raise CLIError.new(:data_dir_is_not_readable, nil, data_dir) unless File.readable? data_dir
          raise CLIError.new(:data_dir_is_not_a_directory, nil, data_dir) unless File.directory? data_dir
        end
        Pandocomatic::LOG.debug "✓  Can read data directory '#{options[:data_dir]}'." if options[:data_dir_given]

        # Config file, if specified, should be an existing and readable file
        if options[:config_given]
          config = File.absolute_path options[:config]

          raise CLIError.new(:config_file_does_not_exist, nil, options[:config]) unless File.exist? config
          raise CLIError.new(:config_file_is_not_readable, nil, config) unless File.readable? config
          raise CLIError.new(:config_file_is_not_a_file, nil, config) unless File.file? config
        end
        Pandocomatic::LOG.debug "✓  Can read configuration file '#{options[:config]}'." if options[:config_given]

        if options[:enable_given]
          Pandocomatic::LOG.info '-  Checking feature toggles:'

          features = []

          options[:enable].each do |feature_string|
            feature = feature_string.downcase.sub('-', '_').to_sym
            unless Pandocomatic::FEATURES.include? feature
              raise CLIError.new(:feature_toggle_does_not_exist, nil, feature_string)
            end

            Pandocomatic::LOG.info "   ✓ Enabling feature '#{feature}'."
            features << feature
          end

          options[:enable] = features
        end
      end

      Configuration.new(options, input)
    end

    # rubocop:enable Metrics

    private_class_method def self.options_need_to_be_validated?(options)
      !(options[:version_given]) and !(options[:help_given])
    end

    #--
    # Optimist has special behavior for the version and help options. To
    # overcome, "show_version" and "show_help" options are introduced. When
    # set, these are put in the options as "version" and "help"
    # respectively.
    #++

    private_class_method def self.use_custom_version(options)
      if options[:show_version]
        options.delete :show_version
        options.delete :show_version_given
        options[:version] = true
        options[:version_given] = true
      end
      options
    end

    private_class_method def self.use_custom_help(options)
      if options[:show_help]
        options.delete :show_help
        options.delete :show_help_given
        options[:help] = true
        options[:help_given] = true
      end
      options
    end

    # If output does not exist, the output can be
    # created with the same type. If output does exist, however, it should
    # have the same type as the input.
    private_class_method def self.matching_file_types?(input, output)
      !File.exist?(output) or File.ftype(input) == File.ftype(output)
    end

    private_class_method def self.match_file_types(input, output)
      return if matching_file_types? input, output

      raise CLIError.new(:output_is_not_a_file, nil, input) if File.file? input
      raise CLIError.new(:output_is_not_a_directory, nil, input) if File.directory? input
    end
  end
end
