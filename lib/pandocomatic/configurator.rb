module Pandocomatic

  require 'yaml'

  class Config

    def initialize config_hash = {}
      @config = config_hash
    end

    def self.load path
      Config.new YAML.load_file(path)
    end

    def configure config_hash
      config.hash.keys.each do |key|
        @config[key] = config_hash[key]
      end
    end

  end

end
