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
  require 'trollop'

  require_relative './error/cli_error.rb'

  ##
  # Command line options parser for pandocomatic using trollop.
  #
  class CLI

    ##
    # Parse the arguments, returns a triplet with the global options, an
    # optional subcommand, and the (optional) options for that subcommand.
    #
    # @param args [String, Array] A command line invocation string or a list of strings like ARGV
    #
    # @return [Hash] The options to pandocomatic
    # the subcommand's options
    #
    def self.parse(args)
      args = args.split if args.is_a? String

      begin
        options = parse_options args || {:help => true, :help_given => true}
        options
      rescue Trollop::CommandlineError => e
        raise CLIError.new(:problematic_invocation, e, args)
      end
    end

    private 

    # Parse pandocomatic's global options.
    def self.parse_options(args)
      parser = Trollop::Parser.new do
        # General options 
        opt :dry_run, 'Do a dry run', :short => '-y'
        opt :quiet, 'Run quietly', :short => '-q'
        opt :modified_only, 'Modified files only', :short => '-m'

        # Configuration of the converter
        opt :data_dir, 'Data dir', :short => '-d', :type => String
        opt :config, 'Configuration file', :short => '-c', :type => String

        # What to convert and where to put it
        opt :output, 'Output', :short => '-o', :type => String
        opt :input, 'Input', :short => '-i', :type => String

        # Version and help
        opt :show_version, 'Version', :short => '-v', :long => 'version'
        opt :show_help, 'Help', :short => '-h', :long => 'help'
      end

      # All options should be parsed according to the specification given in the parser
      begin
        options = parser.parse args
      rescue Trollop::CommandlineError => e
        raise CLIError.new(:problematic_invocation, e, args)
      end
      
      options = use_custom_version options
      options = use_custom_help options
     
      if options_need_to_be_validated? options
        # if no input option is specified, it should follow as the last item
        if not options[:input_given]
          options[:input] = args.shift
          options[:input_given] = true
        end

        # There should be no other options left.
        raise CLIError.new(:too_many_options, nil, args) if not args.empty?

        # There should be an input specified
        raise CLIError.new(:no_input_given) if options[:input].nil? or options[:input].empty?

        # The input file or directory should exist
        input = File.absolute_path options[:input]
        raise CLIError.new(:input_does_not_exist, nil, options[:input]) unless File.exist? input
        raise CLIError.new(:input_is_not_readable, nil, input) unless File.readable? input

        if options[:output_given]
          output = File.absolute_path options[:output]
          # Input and output should be both files or directories
          match_file_types input, output

          # The output, if it already exist, should be writable
          raise CLIError.new(:output_is_not_writable, nil, output) unless not File.exist? output or File.writable? output
        else
          # If the input is a directory, an output directory should be
          # specified as well. If the input is a file, the output could be
          # specified in the input file, or STDOUT could be used.
          raise CLIError.new(:no_output_given) if File.directory? input
        end

        # Data dir, if specified, should be an existing and readable directory
        if options[:data_dir_given]
          data_dir = File.absolute_path options[:data_dir]

          raise CLIError.new(:data_dir_does_not_exist, nil, options[:data_dir]) unless File.exist? data_dir
          raise CLIError.new(:data_dir_is_not_readable, nil, data_dir) unless File.readable? data_dir
          raise CLIError.new(:data_dir_is_not_a_directory, nil, data_dir) unless File.directory? data_dir
        end

        # Config file, if specified, should be an existing and readable file
        if options[:config_given]
          config = File.absolute_path options[:config]

          raise CLIError.new(:config_file_does_not_exist, nil, options[:config]) unless File.exist? config
          raise CLIError.new(:config_file_is_not_readable, nil, config) unless File.readable? config
          raise CLIError.new(:config_file_is_not_a_file, nil, config) unless File.file? config
        end

      end
      
      options
    end

    def self.options_need_to_be_validated? options
      not options[:version_given] and not options[:help_given]
    end

    #--
    #Trollop has special behavior for the version and help options. To
    # overcome, "show_version" and "show_help" options are introduced. When
    # set, these are put in the options as "version" and "help"
    # respectively.
    #++
    
    def self.use_custom_version options
      if options[:show_version]
        options.delete :show_version
        options.delete :show_version_given
        options[:version] = true
        options[:version_given] = true
      end
      options
    end

    def self.use_custom_help options
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
    def self.matching_file_types?(input, output)
      not File.exist?(output) or File.ftype(input) == File.ftype(output)
    end
    
    def self.match_file_types(input, output)
        if not matching_file_types? input, output 
          raise CLIError.new(:output_is_not_a_file, nil, input) if File.file? input
          raise CLIError.new(:output_is_not_a_directory, nil, input) if File.directory? input
        end
    end

  end
end
