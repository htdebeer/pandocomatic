# frozen_string_literal: true

#--
# Copyright 2017—2025 Huub de Beer <Huub@heerdebeer.org>
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
  require_relative '../error/io_error'

  require_relative 'command'
  require_relative 'create_link_command'
  require_relative 'convert_file_command'
  require_relative 'convert_list_command'
  require_relative 'copy_file_command'
  require_relative 'skip_command'

  # Create a command to convert one file multiple times
  #
  # @!attribute subcommands
  #   @return [Command[]] the subcommands to execute when running this
  #   ConvertFileMultipleCommand
  class ConvertFileMultipleCommand < ConvertListCommand
    attr_reader :subcommands

    # rubocop:disable Metrics

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


      subcommands = []

      if @config.use_templates?
        # Command-line specified template overrides all internal templates
        @config.selected_templates.each do |template|
          subcommands.push ConvertFileCommand.new(@config, @src, dst, template)
        end
      else
        metadata = @config.get_metadata @src

        if metadata&.template?
          # There are templates in this document's metadata, try to use
          # those.
          metadata.templates.each do |template_name|
            unless template_name.empty? || config.template?(template_name)
              raise ConfigurationError.new(:no_such_template, nil,
                                           template_name)
            end

            subcommands.push ConvertFileCommand.new(@config, @src, dst, template_name)
          end
        else
          # Try to match any global templates using the glob patterns
          global_templates = @config.determine_templates(@src)

          if global_templates.empty?
            subcommands.push ConvertFileCommand.new(@config, @src, dst)
          else
            global_templates.each do |template_name|
              subcommands.push ConvertFileCommand.new(@config, @src, dst, template_name)
            end
          end
        end
      end

      # Only run a command if the src file is modified, or if the modified
      # setting is ignored.
      subcommands.each do |subcommand|
        if (!modified_only? || file_modified?(@src, subcommand.dst)) && !(subcommand.nil? || subcommand.skip?)
          push subcommand
        end
      end
    end

    # rubocop:enable Metrics

    # A string representation of this command
    #
    # @return [String]
    def to_s
      "converting #{@src} #{@subcommands.size} time#{'s' if @subcommands.size != 1}:"
    end

    # Execute this ConvertFileMultipleCommand
    def execute
      return if @subcommands.empty?

      description = CommandPrinter.new(self)
      Pandocomatic::LOG.info description
      description.print unless quiet? || (@subcommands.size == 1)
      run if !dry_run? && runnable?

      @subcommands.each(&:execute)
    end
  end
end
