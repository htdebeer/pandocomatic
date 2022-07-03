#--
# Copyright 2017, 2022, Huub de Beer <Huub@heerdebeer.org>
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

  # A Command with sub commands
  #
  # @!attribute subcommands
  #   @return [Command[]] the subcommands of this ConvertListCommand
  class ConvertListCommand < Command

    attr_reader :subcommands

    # Create a new ConvertListCommand
    def initialize()
      super()
      @subcommands = []
    end

    # Push a command to this ConvertListCommand
    #
    # @param command [Command] command to add
    def push(command)
        @subcommands.push command
    end

    # Skip this ConvertListCommand when there are no sub commands
    #
    # @return [Boolean]
    def skip?()
      @subcommands.empty?
    end

    # The number of commands to execute when this ConvertListCommand
    # is executed.
    def count()
      @subcommands.reduce(0) do |total, subcommand|
        total + subcommand.count
      end
    end

    # Get a list of all errors generated while running this command
    #
    # @return [Error[]]  
    def all_errors()
      @subcommands.reduce(@errors) do |total, subcommand|
        total + subcommand.all_errors
      end
    end

    # A string representation of this ConvertListCommand
    #
    # @return [String]
    def to_s()
        "converting #{@subcommands.size} items:"
    end

    # Can this command have multiple commands?
    #
    # @return [Boolean] true
    def multiple?
        true
    end

    # Execute this ConvertListCommand
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
