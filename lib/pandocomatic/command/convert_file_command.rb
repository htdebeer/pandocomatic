# frozen_string_literal: true

#--
# Copyright 2017-2022, Huub de Beer <Huub@heerdebeer.org>
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

  require_relative '../pandoc_metadata'

  require_relative '../processor'
  require_relative '../processors/fileinfo_preprocessor'
  require_relative '../processors/metadata_preprocessor'

  require_relative '../configuration'

  require_relative '../template'

  require_relative '../error/io_error'
  require_relative '../error/configuration_error'
  require_relative '../error/processor_error'

  require_relative 'command'

  # Output formats used in pandocomatic
  OUTPUT_FORMATS = %w[docx pptx odt pdf epub epub3 epub2].freeze

  # Command to convert a file
  #
  # @!attribute config
  #   @return [Configuration] the configuration of pandocomatic used to
  #     convert the file
  #
  # @!attribute src
  #   @return [String] the path to the file to convert
  #
  # @!attribute dst
  #   @return [String] the path to the output file
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

      @template_name = if template_name.nil? || template_name.empty?
                         @config.determine_template @src
                       else
                         template_name
                       end

      @metadata = PandocMetadata.load_file @src
      @dst = @config.set_destination @dst, @template_name, @metadata

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
      str = "convert #{File.basename @src} #{"-> #{File.basename @dst}" unless @dst.nil?}"
      unless @metadata.unique?
        str += "\n\t encountered multiple YAML metadata blocks with a pandocomatic property."\
               ' Only the pandocomatic property in the first YAML metadata block is being used;'\
               ' the others are discarded.'
      end
      str
    end

    private

    INTERNAL_TEMPLATE = 'internal template'

    # rubocop:disable Metrics

    def convert_file
      pandoc_options = @metadata.pandoc_options || {}
      template = nil

      # Determine the actual options and settings to use when converting this
      # file.
      if !@template_name.nil? && !@template_name.empty?
        unless @config.template? @template_name
          raise ConfigurationError.new(:no_such_template, nil,
                                       @template_name)
        end

        template = @config.get_template @template_name
        pandoc_options = Configuration.extend_value(pandoc_options, template.pandoc)
      else
        template = Template.new INTERNAL_TEMPLATE
      end

      template.merge! Template.new(INTERNAL_TEMPLATE, @metadata.pandocomatic) if @metadata.pandocomatic?

      # Write out the results of the conversion process to file.
      @dst = @metadata.pandoc_options['output'] if @dst.to_s.empty? && @metadata.pandoc_options.key?('output')

      # Run setup scripts
      setup template

      # Read in the file to convert
      input = File.read @src

      # Run the default preprocessors to mix-in information about the file
      # that is being converted and mix-in the template's metadata section as
      # well
      input = FileInfoPreprocessor.run input, @src, src_root, pandoc_options
      input = MetadataPreprocessor.run input, template.metadata if template.metadata?

      # Convert the file by preprocessing it, run pandoc on it, and
      # postprocessing the output
      input = preprocess input, template
      input = pandoc input, pandoc_options, File.dirname(@src)
      output = postprocess input, template

      begin
        # Either output to file or to STDOUT.

        if @config.stdout?
          puts output
          @dst.close!
        else
          unless use_output_option @dst
            File.open(@dst, 'w') do |file|
              raise IOError.new(:file_is_not_a_file, nil, @dst) unless File.file? @dst
              raise IOError.new(:file_is_not_writable, nil, @dst) unless File.writable? @dst

              file << output
            end
          end
        end
      rescue StandardError => e
        raise IOError.new(:error_writing_file, e, @dst)
      end

      # run cleanup scripts
      cleanup template
    end

    # rubocop:enable Metrics

    PANDOC_OPTIONS_WITH_PATH = %w[
      data-dir
      filter
      template
      css
      include-in-header
      include-before-body
      include-after-body
      reference-odt
      reference-docx
      epub-stylesheet
      epub-cover-image
      epub-metadata
      epub-embed-font
      epub-subdirectory
      bibliography
      csl
      syntax-definition
      reference-doc
      lua-filter
      extract-media
      resource-path
      citation-abbreviations
      abbreviations
      log
      resource-path
    ].freeze

    # rubocop:disable Metrics

    def pandoc(input, options, src_dir)
      absolute_dst = File.expand_path @dst
      Dir.chdir(src_dir) do
        converter = Paru::Pandoc.new
        options.each do |option, value|
          # Options come from a YAML string. In YAML, properties without a value get value nil.
          # Interpret these empty properties as "skip this property"
          next if value.nil?

          if PANDOC_OPTIONS_WITH_PATH.include? option
            executable = option == 'filter'
            value = if value.is_a? Array
                      value.map { |v| @config.update_path(v, absolute_dst, check_executable: executable) }
                    else
                      @config.update_path(value, @dst, check_executable: executable)
                    end
          end

          # There is no "pdf" output format; change it to latex but keep the
          # extension.
          value = determine_output_for_pdf(options) if (option == 'to') && (value == 'pdf')

          begin
            # Pandoc multi-word options can have the multiple words separated by
            # both underscore (_) and dash (-).
            option = option.gsub '-', '_'
            converter.send option, value unless
                    (option == 'output') ||
                    (option == 'use_extension') ||
                    (option == 'rename')
            # don't let pandoc write the output to enable postprocessing
          rescue StandardError
            if debug?
              warn "WARNING: The pandoc option '#{option}' (with value '#{value}')"\
                   ' is not recognized by paru. This option is skipped.'
            end
          end
        end

        converter.send 'output', absolute_dst if use_output_option absolute_dst

        begin
          puts converter.to_command if debug?
          converter << input
        rescue Paru::Error => e
          raise PandocError.new(:error_running_pandoc, e, input)
        end
      end
    end

    # rubocop:enable Metrics

    # Preprocess the input
    #
    # @param input [String] the input to preprocess
    # @param template [Template] template
    #
    # @return [String] the generated output
    def preprocess(input, template)
      process input, Template::PREPROCESSORS, template
    end

    # Postprocess the input
    #
    # @param input [String] the input to postprocess
    # @param template [Template] template
    #
    # @return [String] the generated output
    def postprocess(input, template)
      process input, Template::POSTPROCESSORS, template
    end

    # Run setup scripts
    #
    # @param template [Template] template
    def setup(template)
      process '', Template::SETUP, template
    end

    # Run cleanup scripts
    #
    # @param template [Template] template
    def cleanup(template)
      process '', Template::CLEANUP, template
    end

    # rubocop:disable Metrics

    # Run the input string through a list of filters called processors. There
    # are various types: preprocessors and postprocessors, setup and
    # cleanup, and rename
    def process(input, type, template)
      if template.send "#{type}?"
        processors = template.send type
        output = input
        processors.each do |processor|
          script = if @config.local_path? processor
                     processor
                   else
                     @config.update_path(processor, @dst, check_executable: true)
                   end

          command, *parameters = script.shellsplit # split on spaces unless it is preceded by a backslash

          unless File.exist? command
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

    # rubocop:enable Metrics

    def use_output_option(dst)
      OUTPUT_FORMATS.include?(File.extname(dst).slice(1..-1))
    end

    # Pandoc version 2 supports multiple pdf engines. Determine which
    # to use given the options.
    #
    # @param options [Hash] the options to a paru pandoc converter
    # @return [String] the output format for the pdf engine to use.
    def determine_output_for_pdf(options)
      if options.key? 'pdf-engine'
        engine = options['pdf-engine']
        case engine
        when 'context'
          'context'
        when 'pdfroff'
          'ms'
        when 'wkhtmltopdf', 'weasyprint', 'prince'
          'html'
        else
          'latex'
        end
      else
        # According to pandoc's manual, the default is LaTeX
        'latex'
      end
    end
  end
end
