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

    require 'paru'
    require 'shellwords'

    require_relative '../pandoc_metadata.rb'

    require_relative '../processor.rb'
    require_relative '../processors/fileinfo_preprocessor'
    require_relative '../processors/metadata_preprocessor'

    require_relative '../configuration.rb'

    require_relative '../error/io_error.rb'
    require_relative '../error/configuration_error.rb'
    require_relative '../error/processor_error.rb'

    require_relative 'command.rb'

    OUTPUT_FORMATS = ["docx", "odt", "pdf", "beamer"]

    class ConvertFileCommand < Command

        attr_reader :config, :src, :dst

        # Create a new ConvertFileCommand
        #
        # @param config [Configuration] pandocomatic's configuration
        # @param src [String] the path to the file to convert
        # @param dst [String] the path to save the output of the conversion
        # @param template_name [String = nil] the template to use while converting
        #   this file
        def initialize(config, src, dst, template_name = nil)
            super()
            @config = config
            @src = src
            @dst = dst

            if template_name.nil? or template_name.empty?
                @template_name = @config.determine_template @src
            else
                @template_name = template_name
            end

            @errors.push IOError.new(:file_does_not_exist, nil, @src) unless File.exist? @src
            @errors.push IOError.new(:file_is_not_a_file, nil, @src) unless File.file? @src
            @errors.push IOError.new(:file_is_not_readable, nil, @src) unless File.readable? @src
        end

        # Execute this ConvertFileCommand
        def run
            convert_file
        end

        # Create a string representation of this ConvertFileCommand
        #
        # @return [String]
        def to_s
            "convert #{File.basename @src} #{"-> #{File.basename @dst}" unless @dst.nil?}"
        end

        private

        def convert_file
            metadata = PandocMetadata.load_file @src
            pandoc_options = metadata.pandoc_options || {}
            template = {}

            # Determine the actual options and settings to use when converting this
            # file.
            if not @template_name.nil? and not @template_name.empty?
                raise ConfigurationError.new(:no_such_template, nil, @template_name) unless @config.has_template? @template_name
                template = @config.get_template @template_name

                pandoc_options = (template['pandoc'] || {}).merge(pandoc_options) do |key, oldval, newval| 
                    # Options that can occur more than once, such as 'filter' or
                    # 'metadata' are merged, not replaced like options that can occur
                    # only once, such as 'toc' or 'from'
                    if oldval.is_a? Array
                        oldval + newval
                    else
                        newval
                    end
                end
            end

            # Run setup scripts
            setup template

            # Read in the file to convert
            input = File.read @src

            # Run the default preprocessors to mix-in information about the file
            # that is being converted and mix-in the template's metadata section as
            # well
            input = FileInfoPreprocessor.run input, @src, pandoc_options
            input = MetadataPreprocessor.run input, template['metadata'] if template.has_key? 'metadata' and not template['metadata'].empty?

            # Convert the file by preprocessing it, run pandoc on it, and
            # postprocessing the output
            input = preprocess input, template
            input = pandoc input, pandoc_options, File.dirname(@src)
            output = postprocess input, template

            # Write out the results of the conversion process to file.
            if @dst.to_s.empty? and metadata.pandoc_options.has_key? 'output'
                @dst = metadata.pandoc_options['output']
            end

            begin
                unless OUTPUT_FORMATS.include? pandoc_options["to"] then
                    File.open(@dst, 'w') do |file| 
                        raise IOError.new(:file_is_not_a_file, nil, @dst) unless File.file? @dst
                        raise IOError.new(:file_is_not_writable, nil, @dst) unless File.writable? @dst
                        file << output
                    end
                end
            rescue StandardError => e
                raise IOError.new(:error_writing_file, e, @dst)
            end

            # run cleanup scripts
            cleanup template
        end

        # TODO: update this list
        PANDOC_OPTIONS_WITH_PATH = [
            'filter', 
            'template', 
            'css', 
            'include-in-header', 
            'include-before-body',
            'include-after-body',
            'reference-odt',
            'reference-docx',
            'epub-stylesheet',
            'epub-cover-image',
            'epub-metadata',
            'epub-embed-font',
            'epub-subdirectory',
            'bibliography',
            'csl',
            'syntax-definition',
            'reference-doc',
            'lua-filter',
            'extract-media',
            'resource-path',
            'citation-abbreviations',
            'abbreviations',
            'log'
        ]

        def pandoc(input, options, src_dir)
            converter = Paru::Pandoc.new
            options.each do |option, value|
                # Pandoc multi-word options can have the multiple words separated by
                # both underscore (_) and dash (-).
                option= option.gsub "-", "_"

                if PANDOC_OPTIONS_WITH_PATH.include? option
                    if value.is_a? Array
                        value = value.map {|v| @config.update_path(v, src_dir, option == "filter")}
                    else
                        value = @config.update_path(value, src_dir, option == "filter")
                    end
                end

                # There is no "pdf" output format; change it to latex but keep the
                # extension.
                value = "latex" if option == "to" and value == "pdf"

                converter.send option, value unless option == 'output'
                # don't let pandoc write the output to enable postprocessing
            end

            converter.send "output", @dst if OUTPUT_FORMATS.include? options["to"]

            begin
                puts converter.to_command if debug?
                converter << input
            rescue Paru::Error => e
                raise PandocError.new(:error_running_pandoc, e, input_document)
            end
        end

        def preprocess(input, config = {})
            process input, 'preprocessors', config
        end

        def postprocess(input, config = {})
            process input, 'postprocessors', config
        end

        def setup(config = {})
            process "", 'setup', config
        end

        def cleanup(config = {})
            process "", 'cleanup', config
        end

        # Run the input string through a list of filters called processors. There
        # are to types: preprocessors and postprocessors
        def process(input, type, config = {})
            if config.has_key? type then
                processors = config[type]
                output = input
                processors.each do |processor|
                    script = @config.update_path(processor, File.dirname(@src))

                    command, *parameters = script.shellsplit # split on spaces unless it is preceded by a backslash

                    if not File.exists? command
                        command = Configuration.which(command)
                        script = "#{command} #{parameters.join(' ')}"

                        raise ProcessorError.new(:script_does_not_exist, nil, command) if command.nil?
                    end

                    raise ProcessorError.new(:script_is_not_executable, nil, command) unless File.executable? command

                    begin
                        output = Processor.run(script, output)
                    rescue StandardError => e
                        ProcessorError.new(:error_processing_script, e, [script, @src])
                    end
                end
                output
            else
                input
            end
        end
    end
end
