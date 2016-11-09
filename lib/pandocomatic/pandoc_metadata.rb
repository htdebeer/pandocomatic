module Pandocomatic

  require 'json'
  require 'yaml'
  require 'paru/pandoc'

  class PandocMetadata < Hash
  
    # Paru converters:
    # Note. When converting metadata back to the pandoc markdown format, you have
    # to use the option "standalone", otherwise the metadata is skipped
    PANDOC_2_JSON = Paru::Pandoc.new {from "markdown"; to "json"}
    JSON_2_PANDOC = Paru::Pandoc.new {from "json"; to "markdown"; standalone}

    # When converting a pandoc document to JSON, or vice versa, the JSON object
    # has the following three properties:
    VERSION = "pandoc-api-version"
    META = "meta"
    BLOCKS = "blocks"

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
        json = JSON.parse(PANDOC_2_JSON << File.read(document))
        yaml = ""

        version, metadata = json.values_at(VERSION, META)

        if not metadata.empty? then
          metadata_document = {
            VERSION => version, 
            META => metadata, 
            BLOCKS => []
          }

          yaml = JSON_2_PANDOC << JSON.generate(metadata_document)
        end

        yaml
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
