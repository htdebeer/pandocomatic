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

  require_relative './pandocomatic_error.rb'
  require_relative './cli.rb'
  require_relative './configuration.rb'

  VERSION = [0, 1, 0]
  CONFIG_FILE = 'pandocomatic.yaml'

  class Pandocomatic

    def initialize(args)
      begin
        global_options, subcommand, options = CLI.parse args
        configure global_options
        method(subcommand).call(options)
      rescue PandocomaticError => e
        raise e
      end
    end

    def run
    end

    # Run pandocomatic with options

    def convert_dir(options = {})
    end

    def convert_file(options = {})
    end

    # Help on pandocomatic
    def help(options = {})
      if 'default' == options[:topic]
        "general help"
      else
        "help for #{options[:topic]}"
      end
    end

    ##
    # Return the current version of pandocomatic. Pandocomatic's version uses
    # {semantic versioning}[http://semver.org/].
    #
    def version(options = {})
      VERSION
    end


    private

    def determine_data_dir(data_dir_option)
      data_dir = "?"
      if data_dir_option.nil?
        # No data-dir option given: try to find the default one from pandoc
        begin
          data_dir = Paru::Pandoc.info()[:data_dir]
        rescue StandardError => e
          raise PandocomaticError.new("Error running 'pandoc' while trying to determine the default data directory: #{e.message}")
        end
      else
        # Check data dir given as an option
      end

      # check if data directory does exist and is readable
      path = File.absolute_path data_dir

      raise PandocomaticError.new("Unable to find data directory '#{data_dir}'") unless File.exist? path
      raise PandocomaticError.new("Data directory '#{data_dir}' is not a directory") unless File.directory? path
      raise PandocomaticError.new("Unable to read data directory '#{data_dir}'") unless File.readable? path

      path
    end


    def configure(options)
      @dry_run = if options.has_key? :dry_run then options[:dry_run] else false end
      @quiet = if options.has_key? :quiet then options[:quiet] else false end
      @data_dir = determine_data_dir options[:data_dir]
    end

  end
end
