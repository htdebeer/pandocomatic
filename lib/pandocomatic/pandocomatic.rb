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

  require_relative './cli.rb'

  VERSION = [0, 1, 0]

  class Pandocomatic
    def initialize(config = {}, args = ARGV)
      invoke args
    end

    def invoke(args = ARGV)
      @global_options, @subcommand, @options = CLI.parse args
    end

    def configure(config)
    end

    # Run pandocomatic with options

    def generate(options = {})
    end

    def convert(options = {})
    end

    # Help on pandocomatic
    def help(options = {})
      if :default == options[:topic]
        "general help"
      else
        "help for #{options[:topic]}"
      end
    end

    ##
    # Return the current version of pandocomatic. Pandocomatic's version uses
    # {semantic versioning}[http://semver.org/].
    #
    def version
      VERSION
    end
  end
end
