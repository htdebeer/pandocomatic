require 'yaml'
require 'pathname'
module Pandoc

  class Pandoc
    # wrapper around pandoc program
    attr_reader :config
    
    def initialize &config_block
      @config = Hash.new
      configure(&config_block) if block_given?
      @spec = YAML::load_file(File.join(__dir__, 'pandoc_options.yaml'))
#      require 'pp'
#      pp @spec
    end

    def configure &config_block
      yield self if block_given?
    end

    def execute
    end

    def to(format)
    end

    def from(format)
    end

    def >>(out)
    end


    def flag(name)
      @config[name] = true
    end

    def string(name, val) 
      @config[name] = val
    end

    def path(name, path, check_path = false)
      raise "#{path} does not exist"  if check_path and not Pathname.new(path).exists?
      string name, path      
    end

    def list(name, val)
      @config[name] = Array.new if not @config[name]
      @config[name].push val
    end

    def method_missing(name, *args)
      puts name
      puts @spec[name.to_s]

      self.send(@spec[name.to_s]['type'], name.to_s, args)
    end

  end

end
