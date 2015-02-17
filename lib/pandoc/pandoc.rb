require 'yaml'
module Pandoc

  class Pandoc
    # wrapper around pandoc program
    
    def initialize
      @config = Hash.new
      @spec = YAML::load_file(File.join(__dir__, 'cli_options.yaml'))
      require 'pp'
      pp @spec
    end

    def execute
    end

    def to(format)
    end

    def from(format)
    end

    def >>(out)
    end



    # Makes more sense to write a couple of specialize "ruby-like" methods, and
    # take care of the rest of Pandoc's options through a flexible scheme to
    # collect options through method_missing.

    def method_missing(name, *args)
      @config[name.to_s] = args.join ' '
    end

  end

end
