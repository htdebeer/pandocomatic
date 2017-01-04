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
    def self.parse(args)
      args = args.split if args.is_a? String
      global_options = parse_global_options args || {}
      subcommand = args.shift
      options = if subcommand.nil? then nil else parse_options subcommand, args end
      [global_options, subcommand, options]
    end

    private 

    SUBCOMMANDS = [
      'convert',
      'generate', 
      'version',
      'help'
    ]

    # Check existence and readability of the path for this option.
    def self.readable?(option, path)
      path = File.absolute_path path
      Trollop::die option, "unable to find #{path}" unless File.exist? path 
      Trollop::die option, "unable to read #{path}" unless File.readable? path
      true
    end

    # Check existence and writability of the path for this option.
    def self.writable?(option, path)
      path = File.absolute_path path
      Trollop::die option, "unable to find #{path}" unless File.exist? path 
      Trollop::die option, "unable to write #{path}" unless File.writable? path
      true
    end

    # Parse pandocomatic's global options.
    def self.parse_global_options(args)
      options = Trollop::options(args) do
        banner 'Pandocomatic—Automating the use of pandoc'
        opt :config, 'Configuration file', :short => '-c', :type => String
        opt :data_dir, 'Data dir', :short => '-d', :type => String
        opt :quiet, 'Run quietly', :short => '-q'
        opt :dry_run, 'Do a dry run', :short => '-y'
        opt :version, 'Version', :short => '-v'
        stop_on SUBCOMMANDS
      end

      if options.has_key? :version
        options = parse_version
      else
        readable? options[:config] if options.has_key? :config
        readable? options[:data_dir] if options.has_key? :data_dir
      end
      
      options
    end

    # Parse the options of a subcommand. For each subcommand, add a
    # `parse_<subcommand>(args)` method to this class. This method will be
    # used automatically to parse that subcommand's options.
    def self.parse_options(subcommand, args)
      if SUBCOMMANDS.include? subcommand
        parse_method_name = 'parse_#{subcommand}'
        parse_method = method parse_method_name if respond_to? parse_method_name
        parse_method.call args
      else
        # error
        raise PandocomaticError.new "Subcommand '#{subcommand}' unknown." unless subcommand.nil?
      end
    end

    # Parse the options for the file converter.
    def self.parse_convert(args)
      options = Trollop::options(args) do 
        opt :output, 'Output file', :short => '-o', :type => String
      end

      writable? options[:output] if options.has_key? :output

      options
    end

    # Parse the options for the static site generator subcommand.
    def self.parse_generate(args)
      Trollop::options(args) do 
        opt :follow_links, 'Follow symbolic links', :short => '-l', 
          :default => true
        opt :recursive, 'Run on sub directories as well', :short => '-r', 
          :default => true
        opt :skip, 'Skip files/directory that match pattern', :short => '-s', :multi => true, :type => String
        opt :output, 'Output directory', :short => '-o', :type => String, :required => true
      end

      writable? options[:output]

      options
    end

    # When a version subcommand or option is given, all other options and
    # subcommands are ignored.
    def self.parse_version
      {:version => true}
    end

    # Determine if help is requested for a subcommand or pandocomatic as a
    # whole.
    def self.parse_help(args)
      Trollop::options(args) do
        stop_on SUBCOMMANDS
        # no options allowed
      end

      {:topic => args.shift || :default}
    end

  end
end
