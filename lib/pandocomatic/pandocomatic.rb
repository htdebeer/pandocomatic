module Pandocomatic

  require 'yaml'
  require 'json'
  require 'fileutils'
  require 'paru/pandoc'

  # Generate the website defined in src_dir and copy the output to dst_dir.
  def self.generate src_dir, dst_dir, parent_config

    # Ensure dst_dir exist and is a directory
    if File.exist? dst_dir then
      raise "Destination problem" if not File.directory? dst_dir
    else
      Dir.mkdir(dst_dir) if not File.exist? dst_dir
    end

    # Reconfigure when there is a config file in src_dir
    config_file = File.join src_dir, 'pandocomatic.yaml'
    if File.exist? config_file then
      config = parent_config.reconfigure YAML.load_file(config_file)
    else
      config = parent_config
    end

    # Process the files in src_dir using config
    Dir.foreach(src_dir) do |basename|
      src = File.join src_dir, basename
      next if config.skip? src

      dst = File.join dst_dir, basename

      # TODO: symlinks

      if File.directory? src
        generate src, dst, config if config.recursive?
      else
        # dst is a file
        if config.convert? src
          config.convert src, dst_dir
        else
          FileUtils.cp src, dst
        end
      end
    end

  end # self.generate

  def self.convert_file src, dst, parent_config
    
  end

  def self.pandoc2yaml src
    # read src as json AST
    pandoc = Paru::Pandoc.new do
      from 'markdown'
      to 'json'
    end
    document = JSON.parse pandoc.convert(File.read(src))
    
    # strip everything but metadata
    metadata = [document.first, []]

    # write src as json AST
    pandoc.configure do
      from 'json'
      to 'markdown'
      standalone # needed to get metadata back in the file
    end

    # return yaml metadata
    pandoc.convert(JSON.generate metadata)
  end

end
