module Pandocomatic
  DEFAULT_CONFIG = {
    skip: ['.*'],
    convert: ['*.markdown', '*.md']
  }

  require 'pathname'
  require 'fileutils'
  require 'paru/pandoc'

  class Pandocomatic

    def initialize(source, destination, config = DEFAULT_CONFIG)
      @source = source
      @destination = destination
      @config = reconfigure config
    end

    def generate
      destination_tree = ensure_destination
      source_tree = Pathname.new @source
      source_tree.each_child do |source_child|
        next if skip? source_child

        destination_child = destination_tree.join source_child.basename

        if source_child.directory?
          Pandocomatic.new(source_child.to_path, destination_child.to_path, @config).generate
        else
          if convert? source_child
            convert_file source_child, destination_tree
          else
            FileUtils.cp source_child, destination_child
          end
        end
      end
    end
    
    private 

    def skip? file
      do_action? :skip, file
    end

    def convert? file
      do_action? :convert, file
    end
    
    def reconfigure config
      return config
    end

    def ensure_destination
      destination = Pathname.new @destination
      destination.mkdir if not destination.exist?
      raise "Destination problem" if not destination.directory?
      destination
    end

    def convert_file src_file, dst_tree
      destination =  dst_tree.join "#{src_file.basename(src_file.extname)}.html"
      Paru::Pandoc.new do 
        from :markdown
        to :html5
        standalone
        output destination
      end << File.read(src_file)
    end

    def do_action? action, file
      @config[action].any? do |pattern|
        Pathname.glob("#{@source}/" "#{pattern}").include? file
      end
    end

  end
end
