module Pandocomatic


  require 'paru/pandoc'
  require_relative 'pandoc_metadata.rb'
  require_relative 'processor.rb'

  class FileConverter

    def initialize
        @config = nil
    end

    def convert src, dst, current_config
      @config = current_config
      metadata = PandocMetadata.load_file src

      if metadata.has_template? then
        template = metadata.template
      else
        template = @config.determine_template src
      end

      config = @config.get_template_config template
      pandoc_options = (config['pandoc'] || {}).merge(metadata.pandoc_options || {})

      input = File.read src
      input = preprocess input, config
      input = pandoc input, pandoc_options
      output = postprocess input, config

      if dst.to_s.empty? and metadata.pandoc_options.has_key? 'output'
        dst = metadata.pandoc_options['output']
      end
     
      File.open( dst, 'w') do |file| 
        file << output
      end
    end

    private

    def pandoc input, options
      converter = Paru::Pandoc.new
      options.each do |option, value|
        
        case option
        when 'filter', 'template' 
            value = @config.update_path option, value
        else ;
        end
        converter.send option, value unless option == 'output'
        # don't let pandoc write the output to enable postprocessing
      end
      converter << input
    end

    def preprocess input, config
      process input, 'preprocessors', config
    end

    def postprocess input, config
        return input
      process input, 'postprocessors', config
    end

    # Run the input string through a list of filters called processors. There
    # are to types: preprocessors and postprocessors
    def process input, type, config
      if config.has_key? type then
        processors = config[type]
        output = input
        processors.each do |processor|
          output = Processor.run(@config.update_path(type, processor), output)
        end
        output
      else
        input
      end
    end

  end

end
