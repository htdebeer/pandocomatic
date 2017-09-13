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
    Encoding.default_external = Encoding::UTF_8 #ensure unicode encoding
    Encoding.default_internal = Encoding::UTF_8

    require 'paru'

    require_relative './error/pandocomatic_error.rb'
    require_relative './error/pandoc_error.rb'
    require_relative './error/configuration_error.rb'

    require_relative './cli.rb'

    require_relative './configuration.rb'

    require_relative './printer/help_printer.rb'
    require_relative './printer/version_printer.rb'
    require_relative './printer/error_printer.rb'
    require_relative './printer/configuration_errors_printer.rb'
    require_relative './printer/finish_printer.rb'
    require_relative './printer/summary_printer.rb'

    require_relative './command/command.rb'
    require_relative './command/convert_dir_command.rb'
    require_relative './command/convert_list_command.rb'
    require_relative './command/convert_file_command.rb'
    require_relative './command/convert_file_multiple_command.rb'

    # The Pandocomatic class controlls the pandocomatic conversion process
    class Pandocomatic
        
        # Pandocomatic error status codes start from ERROR_STATUS
        ERROR_STATUS = 1266 # This is the sum of the ascii values of the characters in 'pandocomatic'

        # Pandocomatic's current version
        VERSION = [0, 1, 4, 17]

        # Pandocomatic's default configuration file
        CONFIG_FILE = 'pandocomatic.yaml'

        # Run pandocomatic given options
        #
        # @param args [String[]] list of options to configure pandocomatic
        def self.run(args)
            begin
                start_time = Time.now
                options = CLI.parse args

                if options[:version_given]
                    # The version option has precedence over all other options; if
                    # given, the version is printed
                    VersionPrinter.new(VERSION).print
                elsif options[:help_given]
                    # The help option has precedence over all other options except the
                    # version option. If given, the help is printed.
                    HelpPrinter.new().print
                else
                    # Run the pandocomatic converter configured according to the options
                    # given.
                    input = options[:input]
                    output = options[:output]
                    configuration = configure options

                    # Extend the command classes by setting the source tree root
                    # directory, and the options quiet and dry-run, which are used when
                    # executing a command: if dry-run the command is not actually
                    # executed and if quiet the command is not printed to STDOUT
                    src_root = File.absolute_path input
                    dry_run = if options[:dry_run_given] then options[:dry_run] else false end
                    quiet = if options[:quiet_given] then options[:quiet] else false end
                    debug = if options[:debug_given] and not quiet then options[:debug] else false end
                    modified_only = if options[:modified_only_given] then options[:modified_only_given] else false end

                    Command.reset(src_root, dry_run, quiet, debug, modified_only)

                    # Pandocomatic has two modes: converting a directory tree or
                    # converting a single file. The mode is selected by the input.
                    if File.directory? input
                        command = ConvertDirCommand.new(configuration, input, output)
                    else
                        destination = if output.nil? or output.empty? then File.basename input else output end

                        command = ConvertFileMultipleCommand.new(configuration, input, destination)
                        command.make_quiet unless command.subcommands.size > 1
                    end

                    # Notify the user about all configuration errors collected when
                    # determining the commands to run to perform this pandocomatic
                    # conversion.
                    if command.all_errors.size > 0
                        ConfigurationErrorsPrinter.new(command.all_errors).print
                        exit ERROR_STATUS
                    end

                    # Pandocomatic is successfully configured: running the
                    # actual conversion now. But first a short summary of the
                    # process to execute is printed.
                    SummaryPrinter.new(command, input, output).print unless quiet or not command.directory?

                    # Depending on the options dry-run and quiet, the command.execute
                    # method will actually performing the commands (dry-run = false) and
                    # print the command to STDOUT (quiet = false)
                    command.execute()

                    FinishPrinter.new(command, input, output, start_time).print unless quiet
                end
            rescue PandocomaticError => e
                # Report the error and break off the conversion process.
                ErrorPrinter.new(e).print
                exit ERROR_STATUS + 1
            rescue StandardError => e
                # An unexpected error has occurred; break off the program drastically
                # for now. This is likely a bug: ask the user to report it.
                warn "An unexpected error has occurred. You can report this bug via https://github.com/htdebeer/pandocomatic/issues/new."
                raise e
            end
        end

        private

        def self.determine_config_file(options, data_dir = Dir.pwd)
            config_file = ''

            if options[:config_given]
                config_file = options[:config]
            elsif Dir.entries(data_dir).include? CONFIG_FILE
                config_file = File.join(data_dir, CONFIG_FILE)
            elsif Dir.entries(Dir.pwd()).include? CONFIG_FILE
                config_file = File.join(Dir.pwd(), CONFIG_FILE)
            else
                # Fall back to default configuration file distributed with
                # pandocomatic
                config_file = File.join(__dir__, 'default_configuration.yaml')
            end

            path = File.absolute_path config_file

            raise ConfigurationError.new(:config_file_does_not_exist, nil, path) unless File.exist? path
            raise ConfigurationError.new(:config_file_is_not_a_file, nil, path) unless File.file? path
            raise ConfigurationError.new(:config_file_is_not_readable, nil, path) unless File.readable? path

            path
        end

        def self.determine_data_dir(options)
            data_dir = ''

            if options[:data_dir_given]
                data_dir = options[:data_dir]
            else
                # No data-dir option given: try to find the default one from pandoc
                begin
                    data_dir = Paru::Pandoc.info()[:data_dir]
                rescue Paru::Error => e
                    # If pandoc cannot be run, continuing probably does not work out
                    # anyway, so raise pandoc error
                    raise PandocError.new(:error_running_pandoc, e, data_dir)
                rescue StandardError => e
                    # Ignore error and use the current working directory as default working directory
                    data_dir = Dir.pwd
                end
            end

            # check if data directory does exist and is readable
            path = File.absolute_path data_dir

            raise ConfigurationError.new(:data_dir_does_not_exist, nil, path) unless File.exist? path
            raise ConfigurationError.new(:data_dir_is_not_a_directory, nil, path) unless File.directory? path
            raise ConfigurationError.new(:data_dir_is_not_readable, nil, path) unless File.readable? path

            path
        end

        def self.configure(options)
            data_dir = determine_data_dir options
            config_file = determine_config_file options, data_dir
            Configuration.new options, data_dir, config_file
        end

    end
end
