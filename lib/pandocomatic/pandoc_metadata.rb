module Pandocomatic

  require 'json'
  require 'yaml'
  require 'paru/pandoc'

  class PandocMetadata < Hash

    def initialize hash = {}
      super
      merge! hash
    end

    # Collect the metadata embedded in the src file
    def self.load_file src
      begin
        yaml_metadata = pandoc2yaml File.read(src)
        if yaml_metadata.empty? then
            return PandocMetadata.new
        else
            return PandocMetadata.new YAML.load(yaml_metadata)
        end
      rescue Exception => e
        raise "Error while reading metadata from #{src}; Are you sure it is a pandoc markdown file?\n#{e.message}"
      end
    end

    def self.pandoc2yaml document
        json_reader = Paru::Pandoc.new {from 'markdown'; to 'json'}
        json_document = JSON.parse json_reader << document
        yaml_metadata = ''
        metadata = json_document.first
        if metadata.has_key? "unMeta" and not metadata["unMeta"].empty? then
            json_metadata = [metadata, []]
            json_writer = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}
            yaml_metadata = json_writer << JSON.generate(json_metadata)
        end
        yaml_metadata
    end

    def has_template?
      self['pandocomatic'] and self['pandocomatic']['use-template'] and 
          not self['pandocomatic']['use-template'].empty?
    end

    def template_name
      if has_template? then
        self['pandocomatic']['use-template']
      else
        ''
      end
    end

    def has_pandoc_options?
      self['pandocomatic'] and self['pandocomatic']['pandoc']
    end

    def pandoc_options
      if has_pandoc_options? then
        self['pandocomatic']['pandoc']
      else
        {}
      end
    end

  end

end
