module Pandoc

  class Pandoc
    # wrapper around pandoc program
    
    def initialize
      @config = hash.new

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
