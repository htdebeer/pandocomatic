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

  require 'paru/pandoc'
  require_relative 'pandoc_metadata.rb'
  require_relative 'processor.rb'
  require_relative 'fileinfo_preprocessor'

  class FileConverter

    def convert src, dst, current_config
      @config = current_config
      @src = src
      metadata = PandocMetadata.load_file src

      if metadata.has_template? then
        template_name = metadata.template_name
      else
        template_name = @config.determine_template src
      end

      template = @config.get_template template_name

      pandoc_options = (template['pandoc'] || {}).merge(metadata.pandoc_options || {})

      input = File.read src
      input = FileInfoPreprocessor.run input, src
      input = preprocess input, template
      input = pandoc input, pandoc_options, File.dirname(src)
      output = postprocess input, template

      if dst.to_s.empty? and metadata.pandoc_options.has_key? 'output'
        dst = metadata.pandoc_options['output']
      end
     
      File.open( dst, 'w') do |file| 
        file << output
      end
    end

    private

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

    def pandoc input, options, src_dir
      converter = Paru::Pandoc.new
      options.each do |option, value|

        value = @config.update_path value, src_dir if 
            PANDOC_OPTIONS_WITH_PATH.include? option

        converter.send option, value unless option == 'output'
        # don't let pandoc write the output to enable postprocessing
      end
      converter << input
    end

    def preprocess input, config
      process input, 'preprocessors', config
    end

    def postprocess input, config
      process input, 'postprocessors', config
    end

    # Run the input string through a list of filters called processors. There
    # are to types: preprocessors and postprocessors
    def process input, type, config
      if config.has_key? type then
        processors = config[type]
        output = input
        processors.each do |processor|
          script = @config.update_path(processor, File.dirname(@src))
          output = Processor.run(script, output)
        end
        output
      else
        input
      end
    end

  end

end
