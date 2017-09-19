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
  require_relative 'convert_list_command.rb'
  require_relative 'copy_file_command.rb'
  require_relative 'skip_command.rb'

  # Create a command to convert one file multiple times
  #
  # @!attribute subcommands
  #   @return [Command[]] the subcommands to execute when running this
  #   ConvertFileMultipleCommand
  class ConvertFileMultipleCommand < ConvertListCommand

    attr_reader :subcommands

    # Create a new ConvertFileMultipleCommand
    #
    # @param config [Configuration] Pandocomatic's configuration used to
    #   convert the source file
    # @param src [String] the file to convert
    # @param dst [String] the output file
    def initialize(config, src, dst)
        super()
        @config = config
        @src = src
        
        metadata = PandocMetadata.load_file @src

        metadata.templates.each do |template_name|
            raise ConfigurationError.new(:no_such_template, nil, template_name) unless template_name.empty? or config.has_template? template_name

            dst = config.set_extension dst, template_name, metadata
            if not modified_only? or file_modified? @src, dst then
                subcommand = ConvertFileCommand.new(@config, @src, dst, template_name)
                push subcommand unless subcommand.nil? or subcommand.skip?
            end
        end
    end


    # A string representation of this command
    #
    # @return [String]
    def to_s()
        "converting #{@src} #{@subcommands.size} time#{'s' if @subcommands.size != 1}:"
    end

    # Execute this ConvertFileMultipleCommand
    def execute()
      if not @subcommands.empty?
        CommandPrinter.new(self).print unless quiet? or @subcommands.size == 1
        run if not dry_run? and runnable?

        @subcommands.each do |subcommand|
          subcommand.execute
        end
      end
    end

  end
end
