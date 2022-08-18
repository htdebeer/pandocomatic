# frozen_string_literal: true

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
  require_relative '../printer/command_printer'

  # Command is a base class of all actions pandocomatic executes while
  # converting a file or a directory of files.
  #
  # @!attribute errors
  #   @return [Error[]] list of errors created while preparing and running a
  #     command
  #
  # @!attribute index
  #   @return [Number] the index of this Command in the list with all commands
  #     to run when running pandocomatic.
  class Command
    attr_reader :errors, :index

    # rubocop:disable Style/ClassVars

    @@total = 0
    @@dry_run = false
    @@quiet = false
    @@debug = false
    @@src_root = '.'
    @@modified_only = false

    # Create a new Command
    def initialize
      @errors = []
      @@total += 1
      @index = @@total
    end

    # Reset all Commands
    #
    # @param configuration [Configuration] the configuration used to convert
    def self.reset(configuration)
      @@src_root = configuration.src_root
      @@dry_run = configuration.dry_run?
      @@quiet = configuration.quiet?
      @@debug = configuration.debug?
      @@modified_only = configuration.modified_only?
      @@total = 0
    end

    # Get the root directory of this Command's conversion process
    #
    # @return [String]
    def src_root
      @@src_root
    end

    # Does this Command not actually execute?
    #
    # @return [Boolean]
    def dry_run?
      @@dry_run
    end

    # Is this Command executed silently?
    #
    # @return [Boolean]
    def quiet?
      @@quiet
    end

    # Is this Command executed in debug mode?
    #
    # @return [Boolean]
    def debug?
      @@debug
    end

    # Is this Command only executed on modified files?
    #
    # @return [Boolean]
    def modified_only?
      @@modified_only
    end

    # The number of commands executed by this Command; a Command can have sub
    # commands as well.
    #
    # @return [Number]
    def count
      1
    end

    # Get all the errors generated while executing this Command
    #
    # @return [Error[]]
    def all_errors
      @errors
    end

    # Make this Command run quietly
    def make_quiet
      @@quiet = true
    end

    # Convert this Command's index to a string representation
    #
    # @return [String]
    def index_to_s
      (@@total - @index + 1).to_s.rjust(@@total.to_s.size)
    end

    # Execute this Command. A Command can be dry-run as well, in which it is
    # not actually run.
    def execute
      CommandPrinter.new(self).print unless quiet?
      run if !dry_run? && runnable?
    end

    # Actually run this Command
    def run; end

    # Are there any errors while configuring this Command? If not, this
    # Command is runnable.
    #
    # @return [Boolean]
    def runnable?
      !errors?
    end

    # Create a String representation of this Command
    #
    # @return [String]
    def to_s
      'command'
    end

    # Is this Command converting a directory?
    #
    # @return [Boolean] false
    def directory?
      false
    end

    # Does this Command convert a file multiple times?
    #
    # @return [Boolean] false
    def multiple?
      false
    end

    # Will this Command be skipped, thus not executed?
    #
    # @return [Boolean] false
    def skip?
      false
    end

    # Decrement the total number of conversion commands by 1
    def uncount
      @@total -= 1
    end

    # rubocop:enable Style/ClassVars

    # Has this Command run in any errors?
    #
    # @return [Error[]]
    def errors?
      !@errors.empty?
    end

    # Is the source file newer than the destination file?
    #
    # @param src [String] the source file
    # @param dst [String] the destination file
    #
    # @return [Boolean] True if src has been modified after dst has been last
    def file_modified?(src, dst)
      !File.exist? dst or File.mtime(src) > File.mtime(dst)
    end
  end
end
