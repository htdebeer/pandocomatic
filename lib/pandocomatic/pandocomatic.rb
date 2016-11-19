module Pandocomatic
  VERSION = [0, 1, 0]

  class Pandocomatic
    def initialize config = {}
    end

    def configure config
    end

    # Run pandocomatic with parameters

    def run path = ".", parameters = {}
    end

    # Generate pandocomatic configuartion
    def generate path = ".", parameters = {}
    end

    # Manage assets used by pandocomatic

    def install path, parameters = {}
    end

    def uninstall path, parameters = {}
    end

    def list type = nil, parameters = {}
    end

    def search search_string, parameters = {}
    end

    # Help on pandocomatic
    def help subcommand = nil, parameters = {}
      if subcommand.nil?
        "general help"
      else
        "help for #{subcommand}"
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
