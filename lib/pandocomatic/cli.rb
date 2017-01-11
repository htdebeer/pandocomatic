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

  require_relative './pandocomatic_error.rb'

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
    # @return [Array] a list containing the global option, the subcommand, and
    # the subcommand's options
    #
    def self.parse(args)
      args = args.split if args.is_a? String

      begin
        global_options = parse_global_options args || {}

        subcommand = args.shift
        subcommand = '' if subcommand.nil?

        # "global" options for help and version are converted to subcommands;
        # other global options are ignored.
        if global_options[:version]
          subcommand = 'version'
        elsif global_options[:help]
          subcommand = 'help'
        end

        if ['version', 'help'].include? subcommand
          global_options = {}
        end

        # There cannot be any options if there is no subcommand; no need to
        # parse the rest if there is no subcommand and no need for general
        # options either
        if subcommand.empty? then 
          global_options = {}
          options = {}
        else 
          options = parse_subcommand_options subcommand, args
        end

        [global_options, subcommand, options]
      rescue Trollop::CommandlineError => e
        raise PandocomaticError.new("Error while parsing the command line options: #{e.message}")
      end
    end

    private 

    SUBCOMMANDS = [
      'convert',
      'generate', 
      'version',
      'help'
    ]

    # Parse pandocomatic's global options.
    def self.parse_global_options(args)
      parser = Trollop::Parser.new do
        banner 'Pandocomatic—Automating the use of pandoc'
        opt :data_dir, 'Data dir', :short => '-d', :type => String
        opt :quiet, 'Run quietly', :short => '-q'
        opt :dry_run, 'Do a dry run', :short => '-y'
        opt :show_version, 'Version', :short => '-v', :long => 'version'
        opt :show_help, 'Help', :short => '-h', :long => 'help'
        stop_on SUBCOMMANDS
      end

      options = parser.parse args

      # Trollop has special behavior for the version and help options. To
      # overcome, "show_version" and "show_help" options are introduced. When
      # set, these are put in the options as "version" and "help"
      # respectively.
      #
      # If version of help is in the general options, ignore all other
      # options. Version has priority over help.
      if options[:show_version]
        options = {:version => true}
      elsif options[:show_help]
        options = {:help => true}
      else
        options.delete :show_version
        options.delete :show_help
      end
      
      options
    end

    # Parse the options of a subcommand. For each subcommand, add a
    # `parse_<subcommand>(args)` method to this class. This method will be
    # used automatically to parse that subcommand's options.
    def self.parse_subcommand_options(subcommand, args)
      if SUBCOMMANDS.include? subcommand
        parse_method_name = "parse_#{subcommand}"
        parse_method = method parse_method_name if respond_to? parse_method_name
        parse_method.call args
      else
        # error
        raise PandocomaticError.new "Subcommand '#{subcommand}' unknown." unless subcommand.nil?
      end
    end

    # Parse the options for the file converter.
    def self.parse_convert(args)
      parser = Trollop::Parser.new do 
        opt :output, 'Output file', :short => '-o', :type => String
        opt :input, 'Input file', :short => '-i', :type => String
      end

      options = parser.parse args
      options.delete :help

      # if no input option specified, it should follow
      options[:input] = args.shift unless options[:input]

      raise PandocomaticError.new("No input file specified") if options[:input].nil? or options[:input].empty?

      options
    end

    # Parse the options for the static site generator subcommand.
    def self.parse_generate(args)
      parser = Trollop::Parser.new do 
        opt :config, 'Configuration file', :short => '-c', :type => String
        opt :follow_links, 'Follow symbolic links', :short => '-l', 
          :default => true
        opt :recursive, 'Run on sub directories as well', :short => '-r', 
          :default => true
        opt :skip, 'Skip files/directory that match pattern', :short => '-s', :multi => true, :type => String
        opt :output, 'Output directory', :short => '-o', :type => String
        opt :input, 'Input directory', :short => '-i', :type => String
      end

      options = parser.parse args
      options.delete :help

      # if no input option is specified, it should follow
      options[:input] = args.shift unless options[:input]

      raise PandocomaticError.new("No input directory specified") if options[:input].nil? or options[:input].empty?
      raise PandocomaticError.new("No output directory specified") if options[:output].nil? or options[:output].empty?
      
      options
    end

    # When a version subcommand or option is given, all other options and
    # subcommands are ignored.
    def self.parse_version(args)
      {}
    end

    # Determine if help is requested for a subcommand or pandocomatic as a
    # whole.
    def self.parse_help(args)
      options = {:topic => 'default'}

      parser = Trollop::Parser.new do
        stop_on SUBCOMMANDS
        # no options allowed
      end

      begin
        parser.parse args
        options[:topic] = args.shift || 'default'
      rescue Exception
        # Ignore errors when trying to parse the help subcommand: the user
        # probably can use the help :-).
      end

      options
    end

  end
end
