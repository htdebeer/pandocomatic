module Pandocomatic

  require_relative "./cli.rb"

  VERSION = [0, 1, 0]

  class Pandocomatic
    def initialize config = {}, args = ARGV
      invoke args
    end

    def invoke args = ARGV
      @global_options, @subcommand, @options = CLI.parse args
    end

    def configure config
    end

    # Run pandocomatic with options

    def run options = {}
    end

    # Manage assets used by pandocomatic

    def install options = {}
    end

    def uninstall options = {}
    end

    def list options = {}
    end

    def search options = {}
    end

    # Help on pandocomatic
    def help options = {}
      if :default == options[:topic]
        "general help"
      else
        "help for #{options[:topic]}"
      end
    end

    ##
    # Return the current version of pandocomatic. Pandocomatic's version uses
    # {semantic versioning}[http://semver.org/].
    #
    def version
      VERSION
    end
  end
end
