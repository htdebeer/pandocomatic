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

  require_relative '../pandoc_metadata.rb'
  require_relative '../processor.rb'
  require_relative '../fileinfo_preprocessor'

  require_relative '../configuration.rb'

  require_relative '../error/io_error.rb'
  require_relative '../error/configuration_error.rb'
  require_relative '../error/processor_error.rb'

  require_relative 'command.rb'

  class ConvertFileCommand < Command

    attr_reader :config, :src, :dst

    def initialize(config, src, dst)
      super()
      @config = config
      @src = src
      @dst = dst

      @errors.push IOError.new(:file_does_not_exist, nil, @src) unless File.exist? @src
      @errors.push IOError.new(:file_is_not_a_file, nil, @src) unless File.file? @src
      @errors.push IOError.new(:file_is_not_readable, nil, @src) unless File.readable? @src
    end

    def run
      convert_file
    end

    def to_s
      "convert #{File.basename @src} #{"-> #{File.basename @dst}" unless @dst.nil?}"
    end

    private

    def convert_file
      metadata = PandocMetadata.load_file @src
      pandoc_options = metadata.pandoc_options || {}
      template = {}

      if metadata.has_template? then
        template_name = metadata.template_name
      else
        template_name = @config.determine_template @src
      end

      if not template_name.nil? and not template_name.empty?
        raise ConfigurationError.new(:no_such_template, nil, template_name) unless @config.has_template? template_name

        template = @config.get_template template_name

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

      input = File.read @src
      input = FileInfoPreprocessor.run input, @src
      input = preprocess input, template
      input = pandoc input, pandoc_options, File.dirname(@src)
      output = postprocess input, template

      if @dst.to_s.empty? and metadata.pandoc_options.has_key? 'output'
        @dst = metadata.pandoc_options['output']
      end

      begin
        File.open(@dst, 'w') do |file| 
          raise IOError.new(:file_is_not_a_file, nil, @dst) unless File.file? @dst
          raise IOError.new(:file_is_not_writable, nil, @dst) unless File.writable? @dst
          file << output
        end
      rescue StandardError => e
        raise IOError.new(:error_writing_file, e, @dst)
      end
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
      'bibliography',
      'csl'
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

        converter.send option, value unless option == 'output'
        # don't let pandoc write the output to enable postprocessing
      end

      begin
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

    # Run the input string through a list of filters called processors. There
    # are to types: preprocessors and postprocessors
    def process(input, type, config = {})
      if config.has_key? type then
        processors = config[type]
        output = input
        processors.each do |processor|
          script = @config.update_path(processor, File.dirname(@src))

          if not File.exists? script
            script = Configuration.which(script)

            raise ProcessorError.new(:script_does_not_exist, nil, script) if script.nil?
          end

          raise ProcessorError.new(:script_is_not_executable, nil, script) unless File.executable? script

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
