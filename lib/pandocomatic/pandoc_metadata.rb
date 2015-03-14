module Pandocomatic

  require 'json'
  require 'yaml'
  require 'paru/pandoc'

  require_relative 'configuration.rb'

  class PandocMetadata < Hash

    def initialize hash = {}
      super
      merge! hash
    end

    # Collect the metadata embedded in the src file
    def self.load_file src
      begin
        json_reader = Paru::Pandoc.new {from 'markdown'; to 'json'}
        json_document = JSON.parse json_reader << File.read(src)
        json_metadata = [json_document.first, []]
        json_writer = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}
        yaml_metadata = json_writer << JSON.generate(json_metadata)
        return PandocMetadata.new YAML.load yaml_metadata.strip.lines[1..-1].join("\n")
      rescue Exception => e
        raise "Error while reading metadata from #{src}; Are you sure it is a pandoc markdown file?\n#{e.message}"
      end
    end

    def has_target?
      has_key? 'pandocomatic' and self['pandocomatic'].has_key? 'target'
    end

    def target
      self['pandocomatic']['target'] if has_target?
    end

    def has_pandoc_options?
      has_key? 'pandocomatic' and self['pandocomatic'].has_key? 'pandoc'
    end

    def pandoc_options
      self['pandocomatic']['pandoc'] if has_pandoc_options?
    end

    def to_configuration parent_config = Configuration.new
    end

  end

end
