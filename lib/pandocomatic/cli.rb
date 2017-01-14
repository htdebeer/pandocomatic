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

  require_relative './cli_error.rb'

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
        raise CLIError.new(CLIError::PROBLEMATIC_INVOCATION, e)
      end
    end

    private 

    # Parse pandocomatic's global options.
    def self.parse_options(args)
      parser = Trollop::Parser.new do
        # General options 
        opt :dry_run, 'Do a dry run', :short => '-y'
        opt :quiet, 'Run quietly', :short => '-q'

        # Configuration of the converter
        opt :data_dir, 'Data dir', :short => '-d', :type => String
        opt :config, 'Configuration file', :short => '-c', :type => String

        opt :follow_links, 'Follow symbolic links', :short => '-l', 
          :default => true
        opt :recursive, 'Run on sub directories as well', :short => '-r', 
          :default => true
        opt :skip, 'Skip files/directory that match pattern', :short => '-s', :multi => true, :type => String

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
        raise CLIError.new(CLIError::PROBLEMATIC_INVOCATION, e)
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
        raise CLIError.new(CLIError::TOO_MANY_OPTIONS) if not args.empty?

        # There should be an input specified
        raise CLIError.new(CLIError::NO_INPUT_GIVEN) if options[:input].nil? or options[:input].empty?

        # The input file or directory should exist
        input = File.absolute_path options[:input]
        raise CLIError.new(CLIError::INPUT_DOES_NOT_EXIST) unless File.exist? input
        raise CLIError.new(CLIError::INPUT_IS_NOT_READABLE) unless File.readable? input

        if options[:output_given]
          output = File.absolute_path options[:output]
          # Input and output should be both files or directories
          match_file_types input, output

          # The output, if it already exist, should be writable
          raise CLIError.new(CLIError::OUTPUT_IS_NOT_WRITABLE) unless not File.exist? output or File.writable? output
        else
          # If the input is a directory, an output directory should be
          # specified as well. If the input is a file, the output could be
          # specified in the input file, or STDOUT could be used.
          raise CLIError.new(CLIError::NO_OUTPUT_GIVEN) if File.directory? input
        end

        # Data dir, if specified, should be an existing and readable directory
        if options[:data_dir_given]
          data_dir = File.absolute_path options[:data_dir]

          raise CLIError.new(CLIError::DATA_DIR_DOES_NOT_EXIST) unless File.exist? data_dir
          raise CLIError.new(CLIError::DATA_DIR_IS_NOT_READABLE) unless File.readable? data_dir
          raise CLIError.new(CLIError::DATA_DIR_IS_NOT_A_DIRECTORY) unless File.directory? data_dir
        end

        # Config file, if specified, should be an existing and readable file
        if options[:config_given]
          config = File.absolute_path options[:config]

          raise CLIError.new(CLIError::CONFIG_FILE_DOES_NOT_EXIST) unless File.exist? config
          raise CLIError.new(CLIError::CONFIG_FILE_IS_NOT_READABLE) unless File.readable? config
          raise CLIError.new(CLIError::CONFIG_FILE_IS_NOT_A_FILE) unless File.file? config
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
        options[:version] = true
        options[:version_given] = true
      end
      options
    end

    def self.use_custom_help options
      if options[:show_help]
        options.delete :show_help
        options[:help] = true
        options[:help_given] = true
      end
      options 
    end

    def self.matching_file_types?(input, output)
      File.ftype(input) == File.ftype(output)
    end
    
    def self.match_file_types(input, output)
        if not matching_file_types input, output 
          raise CLIError.new(CLIError::OUTPUT_IS_NOT_A_FILE) if File.file? input
          raise CLIError.new(CLIError::OUTPUT_IS_NOT_A_DIRECTORY) if File.directory? input
        end
    end

  end
end
