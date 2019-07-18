#--
# Copyright 2014—2019, Huub de Beer <Huub@heerdebeer.org>
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
    require 'tempfile'

    require_relative './error/pandocomatic_error.rb'
    require_relative './error/pandoc_error.rb'

    require_relative './cli.rb'

    require_relative './printer/help_printer.rb'
    require_relative './printer/version_printer.rb'
    require_relative './printer/error_printer.rb'
    require_relative './printer/configuration_errors_printer.rb'
    require_relative './printer/finish_printer.rb'
    require_relative './printer/summary_printer.rb'

    require_relative './command/convert_dir_command.rb'
    require_relative './command/convert_list_command.rb'
    require_relative './command/convert_file_command.rb'
    require_relative './command/convert_file_multiple_command.rb'

    # The Pandocomatic class controlls the pandocomatic conversion process
    class Pandocomatic
        
        # Pandocomatic error status codes start from ERROR_STATUS
        ERROR_STATUS = 1266 # This is the sum of the ascii values of the characters in 'pandocomatic'

        # Pandocomatic's current version
        VERSION = [0, 2, 5, 4]

        # Run pandocomatic given options
        #
        # @param args [String[]] list of options to configure pandocomatic
        def self.run(args)
            begin
                start_time = Time.now
                configuration = CLI.parse args

                if configuration.show_version?
                    # The version option has precedence over all other options; if
                    # given, the version is printed
                    VersionPrinter.new(VERSION).print
                elsif configuration.show_help?
                    # The help option has precedence over all other options except the
                    # version option. If given, the help is printed.
                    HelpPrinter.new().print
                else
                    # When using multiple input files, errors reading these
                    # files are already encountered at this point. If there
                    # are any errors, there is no reason to continue.
                    if configuration.input.has_errors?
                        ConfigurationErrorsPrinter.new(configuration.input.all_errors).print
                        exit ERROR_STATUS
                    end

                    # Run the pandocomatic converter configured according to the options
                    # given.
                    #
                    # Pandocomatic has two modes: converting a directory tree or
                    # converting a single file. The mode is selected by the input.
                    if configuration.directory?
                        command = ConvertDirCommand.new(configuration, configuration.input_file, configuration.output)
                    else
                        command = ConvertFileMultipleCommand.new(configuration, configuration.input_file, configuration.output)
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
                    SummaryPrinter.new(command, configuration).print unless configuration.quiet? or not command.directory?

                    # Depending on the options dry-run and quiet, the command.execute
                    # method will actually performing the commands (dry-run = false) and
                    # print the command to STDOUT (quiet = false)
                    command.execute()

                    FinishPrinter.new(command, configuration, start_time).print unless configuration.quiet?
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
            ensure
                configuration.clean_up! unless configuration.nil?
            end
        end
    end
end
