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
  require_relative 'copy_file_command.rb'
  require_relative 'skip_command.rb'

  class ConvertListCommand < Command

    attr_reader :subcommands

    def initialize()
      super()
      @subcommands = []
    end

    def push(command)
        @subcommands.push command
    end

    def skip?()
      @subcommands.empty?
    end

    def count()
      @subcommands.reduce(if skip? then 0 else 1 end) do |total, subcommand|
        total += subcommand.count
      end
    end

    def all_errors()
      @subcommands.reduce(@errors) do |total, subcommand|
        total += subcommand.all_errors
      end
    end

    def to_s()
        "converting #{@subcommands.size} items:"
    end

    def multiple?
        true
    end

    def execute()
      if not @subcommands.empty?
        CommandPrinter.new(self).print unless quiet?
        run if not dry_run? and runnable?

        @subcommands.each do |subcommand|
          subcommand.execute
        end
      end
    end

  end
end
